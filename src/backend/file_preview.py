#!/usr/bin/env python3
"""Build a JSON preview payload for Omnicast FilePreviewView.

Usage:
  python3 file_preview.py <path>
"""
from __future__ import annotations

import json
import mimetypes
import os
import shutil
import subprocess
import sys
import zipfile
from datetime import datetime
from pathlib import Path
from xml.etree import ElementTree as ET

TEXT_EXT = {
    ".txt", ".md", ".markdown", ".rst", ".log", ".csv", ".tsv", ".json", ".jsonc",
    ".yaml", ".yml", ".toml", ".ini", ".cfg", ".conf", ".env", ".xml", ".html",
    ".htm", ".css", ".scss", ".less", ".js", ".jsx", ".ts", ".tsx", ".mjs", ".cjs",
    ".py", ".pyi", ".rb", ".go", ".rs", ".c", ".h", ".cpp", ".hpp", ".cc", ".java",
    ".kt", ".swift", ".m", ".mm", ".sh", ".bash", ".zsh", ".fish", ".ps1", ".bat",
    ".qml", ".lua", ".sql", ".r", ".jl", ".php", ".pl", ".pm", ".vim", ".diff",
    ".patch", ".gitignore", ".dockerfile", ".makefile", ".cmake", ".nix",
}
IMAGE_EXT = {".png", ".jpg", ".jpeg", ".gif", ".webp", ".bmp", ".svg", ".ico"}
OFFICE_EXT = {
    ".doc", ".docx", ".odt", ".rtf",
    ".xls", ".xlsx", ".ods", ".csv",
    ".ppt", ".pptx", ".odp",
}
PDF_EXT = {".pdf"}
MAX_TEXT_BYTES = 200_000
MAX_TEXT_CHARS = 40_000
MAX_DIR_ENTRIES = 40


def human_size(n: int) -> str:
    units = ["B", "KB", "MB", "GB", "TB"]
    size = float(n)
    for u in units:
        if size < 1024 or u == units[-1]:
            if u == "B":
                return f"{int(size)} {u}"
            return f"{size:.1f} {u}"
        size /= 1024
    return f"{n} B"


def mime_of(path: Path) -> str:
    # Prefer file(1) when available for accuracy
    file_bin = shutil.which("file")
    if file_bin:
        try:
            out = subprocess.check_output(
                [file_bin, "-b", "--mime-type", str(path)],
                text=True,
                stderr=subprocess.DEVNULL,
                timeout=2,
            ).strip()
            if out:
                return out
        except Exception:
            pass
    guess, _ = mimetypes.guess_type(str(path))
    return guess or "application/octet-stream"


def looks_binary(sample: bytes) -> bool:
    if b"\x00" in sample:
        return True
    # High ratio of non-text bytes
    if not sample:
        return False
    textish = sum(1 for b in sample if 9 <= b <= 13 or 32 <= b <= 126)
    return (textish / len(sample)) < 0.75


def read_text_file(path: Path) -> str:
    data = path.read_bytes()[:MAX_TEXT_BYTES]
    if looks_binary(data[:4096]):
        return ""
    for enc in ("utf-8", "utf-16", "latin-1"):
        try:
            text = data.decode(enc)
            break
        except Exception:
            text = ""
    if not text:
        return ""
    if len(text) > MAX_TEXT_CHARS:
        text = text[:MAX_TEXT_CHARS] + "\n\n… truncated …"
    return text


def extract_docx_text(path: Path) -> str:
    try:
        import docx  # type: ignore

        doc = docx.Document(str(path))
        parts = [p.text for p in doc.paragraphs if p.text and p.text.strip()]
        # tables
        for table in doc.tables:
            for row in table.rows:
                cells = [c.text.strip() for c in row.cells if c.text and c.text.strip()]
                if cells:
                    parts.append(" | ".join(cells))
        text = "\n".join(parts).strip()
        if text:
            if len(text) > MAX_TEXT_CHARS:
                text = text[:MAX_TEXT_CHARS] + "\n\n… truncated …"
            return text
    except Exception:
        pass

    # Fallback: unzip document.xml and strip tags
    try:
        with zipfile.ZipFile(path) as zf:
            xml = zf.read("word/document.xml")
        root = ET.fromstring(xml)
        ns = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}
        texts = [t.text for t in root.findall(".//w:t", ns) if t.text]
        text = " ".join(texts)
        text = "\n".join(line.strip() for line in text.splitlines() if line.strip())
        if len(text) > MAX_TEXT_CHARS:
            text = text[:MAX_TEXT_CHARS] + "\n\n… truncated …"
        return text
    except Exception:
        return ""


def extract_pdf_text(path: Path) -> str:
    pdftotext = shutil.which("pdftotext")
    if not pdftotext:
        return ""
    try:
        out = subprocess.check_output(
            [pdftotext, "-l", "8", "-q", str(path), "-"],
            text=True,
            stderr=subprocess.DEVNULL,
            timeout=4,
        )
        text = out.strip()
        if len(text) > MAX_TEXT_CHARS:
            text = text[:MAX_TEXT_CHARS] + "\n\n… truncated …"
        return text
    except Exception:
        return ""


def list_dir(path: Path) -> list[dict]:
    entries = []
    try:
        children = sorted(path.iterdir(), key=lambda p: (not p.is_dir(), p.name.lower()))
    except Exception:
        return []
    for child in children[:MAX_DIR_ENTRIES]:
        try:
            st = child.stat()
            entries.append(
                {
                    "name": child.name + ("/" if child.is_dir() else ""),
                    "path": str(child.resolve()),
                    "is_dir": child.is_dir(),
                    "size_label": "dir" if child.is_dir() else human_size(st.st_size),
                }
            )
        except Exception:
            continue
    return entries


def preferred_opener(path: Path, mime: str, ext: str) -> dict:
    """Suggest the best external viewer for this file."""
    onlyoffice = shutil.which("onlyoffice-desktopeditors")
    if ext in OFFICE_EXT and onlyoffice:
        return {
            "id": "onlyoffice",
            "title": "Open in OnlyOffice",
            "argv": [onlyoffice, "--view=" + str(path)],
        }
    if ext in PDF_EXT:
        return {"id": "xdg", "title": "Open with PDF viewer", "argv": ["xdg-open", str(path)]}
    if ext in IMAGE_EXT:
        return {"id": "xdg", "title": "Open with image viewer", "argv": ["xdg-open", str(path)]}
    return {"id": "xdg", "title": "Open with system app", "argv": ["xdg-open", str(path)]}


def preview(path_str: str) -> dict:
    raw = (path_str or "").strip()
    if not raw:
        return {"ok": False, "error": "No path provided"}
    path = Path(os.path.expanduser(raw)).resolve()
    if not path.exists():
        return {"ok": False, "error": f"Not found: {path}"}

    st = path.stat()
    base = {
        "ok": True,
        "path": str(path),
        "name": path.name,
        "subtitle": str(path).replace(str(Path.home()), "~", 1),
        "is_dir": path.is_dir(),
        "size": st.st_size,
        "size_label": "directory" if path.is_dir() else human_size(st.st_size),
        "modified": datetime.fromtimestamp(st.st_mtime).strftime("%Y-%m-%d %H:%M"),
        "mime": "inode/directory" if path.is_dir() else mime_of(path),
        "ext": path.suffix.lower(),
        "text": "",
        "image": "",
        "entries": [],
        "kind": "binary",
        "opener": {"id": "xdg", "title": "Open with system app", "argv": ["xdg-open", str(path)]},
    }

    if path.is_dir():
        base["kind"] = "dir"
        base["entries"] = list_dir(path)
        base["opener"] = {
            "id": "xdg",
            "title": "Open folder",
            "argv": ["xdg-open", str(path)],
        }
        return base

    ext = path.suffix.lower()
    mime = base["mime"]
    base["opener"] = preferred_opener(path, mime, ext)

    if ext in IMAGE_EXT or mime.startswith("image/"):
        base["kind"] = "image"
        base["image"] = path.as_uri()
        return base

    if ext in PDF_EXT or mime == "application/pdf":
        base["kind"] = "pdf"
        base["text"] = extract_pdf_text(path) or "(No text layer extracted. Open externally to view.)"
        return base

    if ext in {".docx"} or "wordprocessingml" in mime:
        base["kind"] = "docx"
        text = extract_docx_text(path)
        base["text"] = text or "(Could not extract text. Open in OnlyOffice to view.)"
        return base

    if ext in OFFICE_EXT or mime.startswith("application/vnd"):
        base["kind"] = "office"
        base["text"] = "Office document. Press Enter to open in OnlyOffice / system app."
        return base

    if ext in TEXT_EXT or mime.startswith("text/") or mime in (
        "application/json",
        "application/javascript",
        "application/xml",
        "application/x-sh",
        "application/toml",
    ):
        text = read_text_file(path)
        if text:
            base["kind"] = "text"
            base["text"] = text
            return base

    # Sniff unknown small files as text
    if st.st_size <= MAX_TEXT_BYTES:
        text = read_text_file(path)
        if text:
            base["kind"] = "text"
            base["text"] = text
            return base

    base["kind"] = "binary"
    base["text"] = f"Binary file ({base['size_label']}, {mime}). Open externally to view."
    return base


def main() -> int:
    if len(sys.argv) < 2:
        print(json.dumps({"ok": False, "error": "Usage: file_preview.py <path>"}))
        return 2

    payload = preview(sys.argv[1])
    cache_dir = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "omnicast"
    cache_dir.mkdir(parents=True, exist_ok=True)
    cache_file = cache_dir / "file-preview.json"
    cache_file.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

    # Tiny stdout meta only — Quickshell StdioCollector drops larger payloads.
    print(
        json.dumps(
            {
                "ok": bool(payload.get("ok")),
                "kind": payload.get("kind", ""),
                "path": payload.get("path", sys.argv[1]),
                "cache": str(cache_file),
                "error": payload.get("error", ""),
            },
            ensure_ascii=False,
        )
    )
    return 0 if payload.get("ok") else 1


if __name__ == "__main__":
    sys.exit(main())
