import React from "react";
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";

interface OmnicastItem {
  icon: string;
  title: string;
  subtitle: string;
  badge?: string;
  category: string;
  isAction?: boolean;
}

const ITEMS_ALL: OmnicastItem[] = [
  { icon: "📋", title: "Clipboard History", subtitle: "2,481 items captured · Super+Ctrl+V", category: "Omarchy Core" },
  { icon: "✨", title: "Ask AI Assistant", subtitle: "Streaming local Ollama / Claude", badge: "AI", category: "Omarchy Core" },
  { icon: "🎨", title: "Theme Switcher", subtitle: "Tokyo Night, Eventide, Nord, Catppuccin", category: "Appearance" },
  { icon: "🪟", title: "Hyprland Window Tiler", subtitle: "Tile, float, pin across 10 workspaces", category: "Window Manager" },
  { icon: "🔍", title: "docs.hyprland.org/Configuring/Binds", subtitle: "Brave Browser · Bookmarks", category: "Browser History" },
  { icon: "⚡", title: "System Info & Bench", subtitle: "CPU 18%, Mem 2.8G, Hyprland 0.56", category: "Scripts" },
];

const ITEMS_SEARCH: OmnicastItem[] = [
  { icon: "🔍", title: "docs.hyprland.org/Configuring/Binds", subtitle: "Brave Bookmarks · FTS5 bm25 matched in 0.8ms", badge: "Browser", category: "Matching Results" },
  { icon: "⌨️", title: "Keybindings Configuration", subtitle: "~/.config/hypr/bindings.conf", badge: "Config", category: "Matching Results" },
  { icon: "🪟", title: "Window Rules & Animations", subtitle: "~/.config/hypr/hyprland.conf", badge: "Config", category: "Matching Results" },
  { icon: "🌐", title: "Search Google for 'hyprland binds'", subtitle: "Execute in default browser", category: "Actions" },
];

export const CommandPaletteDemoScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Modal entrance: snappy critically damped spring
  const modalSpring = spring({
    frame,
    fps,
    config: { damping: 14, mass: 0.7, stiffness: 150 },
  });

  const modalScale = interpolate(modalSpring, [0, 1], [0.86, 1]);
  const modalOpacity = interpolate(modalSpring, [0, 1], [0, 1]);

  // Typing simulation: types 'hyprland binds' from frame 28 to 68
  const queryText = "hyprland binds";
  const typeProgress = interpolate(frame, [28, 62], [0, queryText.length], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const currentQuery = queryText.slice(0, Math.round(typeProgress));

  const isFiltered = frame >= 42;
  const items = isFiltered ? ITEMS_SEARCH : ITEMS_ALL;

  // Selected index moves down from 0 to 1 at frame 78
  const selectedIndex = frame >= 75 ? 0 : 0;

  // Camera subtle push-in when query types
  const cameraZoom = interpolate(frame, [30, 90, 130], [1, 1.04, 1.02], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // Action palette / preview card slide-in on right at frame 82
  const previewSpring = spring({
    frame: frame - 78,
    fps,
    config: { damping: 15, mass: 0.8, stiffness: 130 },
  });

  // Blinking caret
  const showCaret = frame < 85 ? Math.floor(frame / 12) % 2 === 0 : true;

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#10121a",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: "Inter, -apple-system, BlinkMacSystemFont, sans-serif",
        overflow: "hidden",
      }}
    >
      {/* Background Omarchy Desktop Landscape backdrop glow */}
      <div
        style={{
          position: "absolute",
          width: "100%",
          height: "100%",
          background: "radial-gradient(ellipse 90% 60% at 50% 40%, rgba(36, 40, 59, 0.7) 0%, rgba(16, 18, 26, 0.98) 100%)",
        }}
      />

      {/* Decorative top Waybar pill */}
      <div
        style={{
          position: "absolute",
          top: 14,
          left: "50%",
          transform: "translateX(-50%)",
          display: "flex",
          alignItems: "center",
          gap: 16,
          padding: "5px 18px",
          background: "rgba(22, 22, 30, 0.7)",
          backdropFilter: "blur(12px)",
          border: "1px solid rgba(122, 162, 247, 0.2)",
          borderRadius: 16,
          fontSize: 12,
          color: "#7aa2f7",
          fontFamily: "JetBrains Mono, monospace",
          zIndex: 5,
        }}
      >
        <span>1  2  3  4  5</span>
        <span style={{ color: "#414868" }}>|</span>
        <span style={{ color: "#c0caf5" }}>omarchy • hyprland • wayland</span>
      </div>

      {/* Floating Feature Heading Badge */}
      <div
        style={{
          position: "absolute",
          top: 48,
          left: "50%",
          transform: "translateX(-50%)",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 6,
          zIndex: 20,
        }}
      >
        <div
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: 10,
            padding: "6px 18px",
            borderRadius: 20,
            background: "rgba(125, 207, 255, 0.12)",
            border: "1px solid rgba(125, 207, 255, 0.35)",
            boxShadow: "0 0 20px rgba(125, 207, 255, 0.2)",
          }}
        >
          <span style={{ color: "#7dcfff", fontSize: 13, fontWeight: 700, letterSpacing: "0.12em", textTransform: "uppercase" }}>
            The Fluid Command Palette
          </span>
        </div>
      </div>

      {/* Main Omnicast Floating Window */}
      <div
        style={{
          width: 780,
          maxHeight: 520,
          background: "rgba(20, 27, 36, 0.94)",
          backdropFilter: "blur(30px) saturate(180%)",
          border: "1px solid rgba(122, 162, 247, 0.38)",
          borderRadius: 14,
          boxShadow: "0 28px 70px rgba(0, 0, 0, 0.8), 0 0 40px rgba(122, 162, 247, 0.15)",
          transform: `scale(${modalScale * cameraZoom})`,
          opacity: modalOpacity,
          display: "flex",
          flexDirection: "column",
          overflow: "hidden",
          zIndex: 15,
        }}
      >
        {/* Header Search Input */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            padding: "18px 24px",
            borderBottom: "1px solid rgba(122, 162, 247, 0.18)",
            background: "rgba(14, 19, 27, 0.5)",
            gap: 14,
          }}
        >
          {/* Magnifier icon */}
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#7dcfff" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
            <circle cx="11" cy="11" r="8" />
            <line x1="21" y1="21" x2="16.65" y2="16.65" />
          </svg>

          {/* Search text & caret */}
          <div style={{ flex: 1, display: "flex", alignItems: "center", fontSize: 20, fontFamily: "JetBrains Mono, monospace" }}>
            {currentQuery ? (
              <span style={{ color: "#f5f0ec", fontWeight: 500 }}>{currentQuery}</span>
            ) : (
              <span style={{ color: "rgba(216, 212, 208, 0.4)", fontWeight: 400 }}>
                Search apps, commands, bookmarks, files...
              </span>
            )}
            {showCaret && (
              <div
                style={{
                  width: 2.5,
                  height: 22,
                  backgroundColor: "#7dcfff",
                  marginLeft: 3,
                  borderRadius: 1,
                  boxShadow: "0 0 8px #7dcfff",
                }}
              />
            )}
          </div>

          {/* Quick Engine Execution Pill */}
          <div
            style={{
              padding: "4px 10px",
              borderRadius: 6,
              background: "rgba(158, 206, 106, 0.15)",
              border: "1px solid rgba(158, 206, 106, 0.35)",
              color: "#9ece6a",
              fontSize: 12,
              fontWeight: 600,
              fontFamily: "JetBrains Mono, monospace",
            }}
          >
            FTS5 0.8ms
          </div>
        </div>

        {/* Results List */}
        <div
          style={{
            padding: "10px 14px",
            display: "flex",
            flexDirection: "column",
            gap: 4,
            maxHeight: 360,
          }}
        >
          {items.slice(0, 4).map((item, idx) => {
            const isSelected = idx === selectedIndex;
            return (
              <div
                key={item.title}
                style={{
                  display: "flex",
                  alignItems: "center",
                  padding: "12px 16px",
                  borderRadius: 8,
                  background: isSelected ? "rgba(122, 162, 247, 0.18)" : "transparent",
                  borderLeft: isSelected ? "3px solid #7dcfff" : "3px solid transparent",
                  transition: "all 0.15s ease",
                  gap: 14,
                }}
              >
                {/* Icon box */}
                <div
                  style={{
                    fontSize: 20,
                    width: 34,
                    height: 34,
                    borderRadius: 6,
                    background: isSelected ? "rgba(125, 207, 255, 0.2)" : "rgba(255, 255, 255, 0.04)",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                  }}
                >
                  {item.icon}
                </div>

                {/* Title & subtitle */}
                <div style={{ flex: 1, display: "flex", flexDirection: "column", gap: 2 }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                    <span
                      style={{
                        color: isSelected ? "#ffffff" : "#d8d4d0",
                        fontSize: 15,
                        fontWeight: isSelected ? 600 : 500,
                      }}
                    >
                      {item.title}
                    </span>
                    {item.badge && (
                      <span
                        style={{
                          fontSize: 10,
                          fontWeight: 700,
                          padding: "2px 6px",
                          borderRadius: 4,
                          background: "rgba(125, 207, 255, 0.2)",
                          color: "#7dcfff",
                          textTransform: "uppercase",
                          letterSpacing: "0.05em",
                        }}
                      >
                        {item.badge}
                      </span>
                    )}
                  </div>
                  <span
                    style={{
                      color: isSelected ? "rgba(192, 202, 245, 0.85)" : "#6d7c8d",
                      fontSize: 12.5,
                      fontFamily: "JetBrains Mono, monospace",
                    }}
                  >
                    {item.subtitle}
                  </span>
                </div>

                {/* Action hint for selected item */}
                {isSelected && (
                  <div
                    style={{
                      display: "flex",
                      alignItems: "center",
                      gap: 6,
                      fontSize: 12,
                      color: "#7dcfff",
                      fontFamily: "JetBrains Mono, monospace",
                    }}
                  >
                    <span>Open</span>
                    <kbd
                      style={{
                        background: "rgba(125, 207, 255, 0.18)",
                        border: "1px solid rgba(125, 207, 255, 0.4)",
                        borderRadius: 4,
                        padding: "2px 6px",
                        fontSize: 11,
                        color: "#7dcfff",
                      }}
                    >
                      ↵
                    </kbd>
                  </div>
                )}
              </div>
            );
          })}
        </div>

        {/* Footer Bar matching Raycast / Omarchy style */}
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            padding: "10px 20px",
            background: "rgba(14, 19, 27, 0.85)",
            borderTop: "1px solid rgba(122, 162, 247, 0.15)",
            fontSize: 12,
            color: "#6d7c8d",
            fontFamily: "JetBrains Mono, monospace",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
            <span style={{ color: "#7dcfff", fontWeight: 600 }}>Omnicast</span>
            <span>•</span>
            <span>Wayland LayerShell</span>
          </div>

          <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
            <span>
              <strong style={{ color: "#c0caf5" }}>↵</strong> Open
            </span>
            <span>
              <strong style={{ color: "#c0caf5" }}>Ctrl+K</strong> Actions
            </span>
            <span>
              <strong style={{ color: "#c0caf5" }}>Esc</strong> Dismiss
            </span>
          </div>
        </div>
      </div>

      {/* Slide-out Action Palette / Quick Inspection Sheet (Linear & Raycast trademark) */}
      <div
        style={{
          position: "absolute",
          right: 48,
          width: 320,
          background: "rgba(22, 27, 38, 0.96)",
          backdropFilter: "blur(20px)",
          border: "1px solid rgba(125, 207, 255, 0.4)",
          borderRadius: 12,
          boxShadow: "0 20px 50px rgba(0, 0, 0, 0.7)",
          padding: 16,
          display: "flex",
          flexDirection: "column",
          gap: 12,
          transform: `translateX(${(1 - previewSpring) * 120}px)`,
          opacity: previewSpring,
          zIndex: 25,
        }}
      >
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", borderBottom: "1px solid rgba(255, 255, 255, 0.08)", paddingBottom: 8 }}>
          <span style={{ fontSize: 13, fontWeight: 700, color: "#7dcfff", textTransform: "uppercase", letterSpacing: "0.08em" }}>
            Actions (Ctrl+K)
          </span>
          <span style={{ fontSize: 11, color: "#9ece6a", fontFamily: "JetBrains Mono, monospace" }}>Instant</span>
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 8, fontSize: 13 }}>
          <div style={{ display: "flex", justifyContent: "space-between", color: "#f5f0ec", padding: "6px 8px", background: "rgba(125, 207, 255, 0.15)", borderRadius: 6 }}>
            <span>Open in Browser</span>
            <kbd style={{ fontSize: 10, background: "rgba(0,0,0,0.3)", padding: "2px 6px", borderRadius: 4 }}>↵</kbd>
          </div>
          <div style={{ display: "flex", justifyContent: "space-between", color: "#c0caf5", padding: "6px 8px" }}>
            <span>Copy URL</span>
            <kbd style={{ fontSize: 10, background: "rgba(255,255,255,0.06)", padding: "2px 6px", borderRadius: 4 }}>Ctrl+C</kbd>
          </div>
          <div style={{ display: "flex", justifyContent: "space-between", color: "#c0caf5", padding: "6px 8px" }}>
            <span>Quick Look Markdown</span>
            <kbd style={{ fontSize: 10, background: "rgba(255,255,255,0.06)", padding: "2px 6px", borderRadius: 4 }}>Space</kbd>
          </div>
        </div>
      </div>
    </AbsoluteFill>
  );
};
