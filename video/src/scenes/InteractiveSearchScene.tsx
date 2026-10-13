import React from "react";
import { AbsoluteFill } from "remotion";
import { CursorTrack } from "@/components/snap-cn/cursor-track";
import { ScreenRecording } from "@/components/snap-cn/screen-recording";

// Frame coordinates are normalized (0 to 1).
// The camera pushes in on the Omnicast card (zoom: 1.88, center x:0.5, y:0.46)
// while the synthesized macOS/Wayland arrow cursor smoothly glides to and activates search.
export const InteractiveSearchScene: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: "#1a1b26", overflow: "hidden" }}>
      <CursorTrack
        variant="arrow"
        color="#c0caf5"
        outlineColor="#1a1b26"
        ringColor="#7dcfff"
        path={[
          { at: 0, x: -0.05, y: 0.8, duration: 10 },
          { at: 12, x: 0.5, y: 0.28, duration: 24, click: true },
          { at: 55, x: 0.5, y: 0.35, duration: 18, click: true },
          { at: 110, x: 0.52, y: 0.44, duration: 20, click: true },
        ]}
      >
        <ScreenRecording
          src="/teaser.mp4"
          crop={{ top: 0.035 }}
          camera={[
            { at: 0, duration: 28, zoom: 1.88, x: 0.5, y: 0.46 },
            { at: 90, duration: 32, zoom: 2.1, x: 0.5, y: 0.44 },
          ]}
          fit="cover"
          mode="dark"
        />
      </CursorTrack>

      {/* Subtle bottom contextual badge */}
      <div
        style={{
          position: "absolute",
          bottom: 40,
          left: "50%",
          transform: "translateX(-50%)",
          display: "flex",
          alignItems: "center",
          gap: 12,
          padding: "10px 22px",
          background: "rgba(22, 22, 30, 0.88)",
          backdropFilter: "blur(14px)",
          border: "1px solid rgba(122, 162, 247, 0.25)",
          borderRadius: 20,
          boxShadow: "0 8px 30px rgba(0, 0, 0, 0.6)",
          fontFamily: "JetBrains Mono, monospace",
          zIndex: 10,
        }}
      >
        <span style={{ color: "#7dcfff", fontSize: 15, fontWeight: 600 }}>
          Alt + Space
        </span>
        <span style={{ color: "#565f89" }}>|</span>
        <span style={{ color: "rgba(192, 202, 245, 0.85)", fontSize: 14 }}>
          Sub-millisecond FTS5 fuzzy indexing
        </span>
      </div>
    </AbsoluteFill>
  );
};
