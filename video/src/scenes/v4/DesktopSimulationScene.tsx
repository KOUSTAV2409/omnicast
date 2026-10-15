import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export const DesktopSimulationScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Desktop blur overlay activates as Omnicast summons
  const blurProgress = interpolate(frame, [10, 30], [0, 16], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const dimProgress = interpolate(frame, [10, 30], [0, 0.65], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // Window spring entrance with subtle 3D tilt
  const windowEntrance = spring({
    frame: frame - 15,
    fps,
    config: { damping: 16, mass: 0.85, stiffness: 110 },
  });

  // Query typewriter
  const query = "hyprland binds";
  const typeStart = 32;
  const charsTyped = Math.floor(
    interpolate(frame, [typeStart, typeStart + 26], [0, query.length], {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
    })
  );
  const currentQuery = query.slice(0, charsTyped);

  // Results populate once typing starts
  const showResults = frame >= 48;
  const resultsSpring = spring({
    frame: frame - 48,
    fps,
    config: { damping: 14, mass: 0.8 },
  });

  // Side Drawer glides open at frame 105
  const drawerSpring = spring({
    frame: frame - 105,
    fps,
    config: { damping: 18, mass: 0.9, stiffness: 120 },
  });
  const drawerOpen = frame >= 105;

  const caretBlink = Math.floor(frame / 7) % 2 === 0;

  // Exit transition
  const exitOpacity = interpolate(frame, [195, 210], [1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#080a0f",
        overflow: "hidden",
        opacity: exitOpacity,
        fontFamily: "'JetBrains Mono', monospace",
        perspective: 1200,
      }}
    >
      {/* ─── Simulated Omarchy Hyprland Desktop Wallpaper ─── */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          background:
            "radial-gradient(ellipse at 70% 30%, #171d2e 0%, #0d1017 60%, #06080c 100%)",
        }}
      />

      {/* Geometric background circuit grid */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          backgroundImage:
            "radial-gradient(rgba(125, 207, 255, 0.06) 1.5px, transparent 1.5px)",
          backgroundSize: "36px 36px",
          opacity: 0.8,
        }}
      />

      {/* ─── Top Waybar Simulation ─── */}
      <div
        style={{
          position: "absolute",
          top: 14,
          left: 24,
          right: 24,
          height: 38,
          borderRadius: 10,
          backgroundColor: "rgba(13, 16, 24, 0.85)",
          backdropFilter: "blur(12px)",
          border: "1px solid rgba(255, 255, 255, 0.08)",
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          padding: "0 18px",
          fontSize: 12,
          color: "#a9b1d6",
          zIndex: 5,
        }}
      >
        {/* Workspaces */}
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <span
            style={{
              backgroundColor: "rgba(125, 207, 255, 0.2)",
              color: "#7dcfff",
              padding: "2px 8px",
              borderRadius: 6,
              fontWeight: 700,
            }}
          >
            1
          </span>
          <span style={{ color: "#565f89" }}>2</span>
          <span style={{ color: "#565f89" }}>3</span>
          <span style={{ color: "#565f89" }}>4</span>
          <span style={{ color: "#565f89" }}>5</span>
        </div>

        {/* Center Active Workspace / Window */}
        <div style={{ color: "#c0caf5", fontSize: 12, fontWeight: 500 }}>
          omarchy <span style={{ color: "#565f89" }}>•</span> hyprland
        </div>

        {/* System Stats */}
        <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
          <span>CPU 12%</span>
          <span style={{ color: "#565f89" }}>•</span>
          <span>RAM 4.1G</span>
          <span style={{ color: "#565f89" }}>•</span>
          <span style={{ color: "#7dcfff", fontWeight: 600 }}>14:32</span>
        </div>
      </div>

      {/* ─── Native Wayland LayerShell Dim & Blur Overlay ─── */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          backgroundColor: `rgba(6, 8, 14, ${dimProgress})`,
          backdropFilter: `blur(${blurProgress}px)`,
          zIndex: 10,
          pointerEvents: "none",
        }}
      />

      {/* Scene Header Chip */}
      <div
        style={{
          position: "absolute",
          top: 72,
          left: "50%",
          transform: "translateX(-50%)",
          zIndex: 20,
          display: "flex",
          alignItems: "center",
          gap: 10,
          padding: "6px 18px",
          borderRadius: 20,
          backgroundColor: "rgba(17, 21, 34, 0.9)",
          border: "1px solid rgba(125, 207, 255, 0.25)",
        }}
      >
        <span
          style={{
            width: 7,
            height: 7,
            borderRadius: "50%",
            backgroundColor: "#7dcfff",
            boxShadow: "0 0 8px #7dcfff",
          }}
        />
        <span
          style={{
            color: "#7dcfff",
            fontSize: 11,
            fontWeight: 700,
            letterSpacing: "0.14em",
            textTransform: "uppercase",
          }}
        >
          Wayland LayerShell Command Center
        </span>
      </div>

      {/* ─── Omnicast Master Window Container ─── */}
      <div
        style={{
          position: "absolute",
          top: 130,
          left: "50%",
          transform: `translateX(-50%) scale(${interpolate(
            windowEntrance,
            [0, 1],
            [0.92, 1]
          )}) translateY(${interpolate(
            windowEntrance,
            [0, 1],
            [30, 0]
          )}px) rotateX(${interpolate(windowEntrance, [0, 1], [8, 0])}deg)`,
          opacity: Math.max(0, Math.min(1, windowEntrance)),
          display: "flex",
          gap: 16,
          zIndex: 25,
        }}
      >
        {/* Main Command Palette Card */}
        <div
          style={{
            width: drawerOpen ? 680 : 820,
            transition: "width 0.3s cubic-bezier(0.16, 1, 0.3, 1)",
            backgroundColor: "rgba(14, 18, 28, 0.96)",
            backdropFilter: "blur(24px)",
            borderRadius: 16,
            border: "1px solid rgba(125, 207, 255, 0.3)",
            boxShadow:
              "0 30px 80px rgba(0, 0, 0, 0.75), 0 0 40px rgba(125, 207, 255, 0.12)",
            overflow: "hidden",
            display: "flex",
            flexDirection: "column",
          }}
        >
          {/* Search Input Bar */}
          <div
            style={{
              padding: "18px 24px",
              display: "flex",
              alignItems: "center",
              gap: 14,
              borderBottom: "1px solid rgba(255, 255, 255, 0.08)",
            }}
          >
            <span style={{ fontSize: 20, color: "#7dcfff" }}>🔍</span>
            <div style={{ flex: 1, display: "flex", alignItems: "center" }}>
              <span
                style={{
                  fontSize: 20,
                  color: "#ffffff",
                  letterSpacing: "-0.01em",
                }}
              >
                {currentQuery}
              </span>
              {caretBlink && (
                <span
                  style={{
                    display: "inline-block",
                    width: 2,
                    height: 24,
                    backgroundColor: "#7dcfff",
                    marginLeft: 2,
                  }}
                />
              )}
            </div>

            {/* Live FTS5 Microsecond Badge */}
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 6,
                padding: "4px 10px",
                borderRadius: 8,
                backgroundColor: "rgba(158, 206, 106, 0.12)",
                border: "1px solid rgba(158, 206, 106, 0.3)",
                color: "#9ece6a",
                fontSize: 11,
                fontWeight: 700,
              }}
            >
              <span>⚡</span>
              <span>FTS5 0.8ms</span>
            </div>
          </div>

          {/* Results List */}
          {showResults && (
            <div
              style={{
                padding: "12px 14px",
                display: "flex",
                flexDirection: "column",
                gap: 6,
                opacity: Math.max(0, Math.min(1, resultsSpring)),
              }}
            >
              {/* Result 1: Active Selected File */}
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  padding: "12px 16px",
                  borderRadius: 10,
                  backgroundColor: "rgba(125, 207, 255, 0.12)",
                  border: "1px solid rgba(125, 207, 255, 0.35)",
                }}
              >
                <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                  <div
                    style={{
                      width: 32,
                      height: 32,
                      borderRadius: 8,
                      backgroundColor: "rgba(125, 207, 255, 0.2)",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      fontSize: 14,
                    }}
                  >
                    ⚙️
                  </div>
                  <div>
                    <div
                      style={{
                        fontSize: 14,
                        fontWeight: 600,
                        color: "#ffffff",
                      }}
                    >
                      ~/.config/hypr/bindings.conf
                    </div>
                    <div style={{ fontSize: 11, color: "#7dcfff" }}>
                      Hyprland Configuration • FTS5 rank 0.98
                    </div>
                  </div>
                </div>

                <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                  <span
                    style={{
                      fontSize: 11,
                      color: "#7dcfff",
                      backgroundColor: "rgba(125, 207, 255, 0.15)",
                      padding: "2px 8px",
                      borderRadius: 4,
                    }}
                  >
                    CONFIG
                  </span>
                  <span style={{ fontSize: 12, color: "#a9b1d6" }}>↵ Open</span>
                </div>
              </div>

              {/* Result 2: Browser Documentation Bookmark */}
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  padding: "10px 16px",
                  borderRadius: 10,
                  backgroundColor: "transparent",
                }}
              >
                <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                  <div
                    style={{
                      width: 32,
                      height: 32,
                      borderRadius: 8,
                      backgroundColor: "rgba(255, 255, 255, 0.05)",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      fontSize: 14,
                    }}
                  >
                    🌐
                  </div>
                  <div>
                    <div
                      style={{
                        fontSize: 13,
                        fontWeight: 500,
                        color: "#c0caf5",
                      }}
                    >
                      docs.hyprland.org/Configuring/Binds
                    </div>
                    <div style={{ fontSize: 11, color: "#565f89" }}>
                      Brave Bookmarks • Matched keyword: binds
                    </div>
                  </div>
                </div>

                <span
                  style={{
                    fontSize: 11,
                    color: "#565f89",
                    border: "1px solid rgba(255, 255, 255, 0.08)",
                    padding: "2px 8px",
                    borderRadius: 4,
                  }}
                >
                  BROWSER
                </span>
              </div>

              {/* Result 3: Quick Terminal Action */}
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  padding: "10px 16px",
                  borderRadius: 10,
                  backgroundColor: "transparent",
                }}
              >
                <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                  <div
                    style={{
                      width: 32,
                      height: 32,
                      borderRadius: 8,
                      backgroundColor: "rgba(255, 255, 255, 0.05)",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      fontSize: 14,
                    }}
                  >
                    💻
                  </div>
                  <div>
                    <div
                      style={{
                        fontSize: 13,
                        fontWeight: 500,
                        color: "#c0caf5",
                      }}
                    >
                      hyprctl reload
                    </div>
                    <div style={{ fontSize: 11, color: "#565f89" }}>
                      System Action • Hot-reload compositor binds
                    </div>
                  </div>
                </div>

                <span
                  style={{
                    fontSize: 11,
                    color: "#bb9af7",
                    backgroundColor: "rgba(187, 154, 247, 0.1)",
                    padding: "2px 8px",
                    borderRadius: 4,
                  }}
                >
                  COMMAND
                </span>
              </div>
            </div>
          )}

          {/* Footer Navigation Bar */}
          <div
            style={{
              padding: "10px 20px",
              backgroundColor: "rgba(10, 13, 20, 0.9)",
              borderTop: "1px solid rgba(255, 255, 255, 0.06)",
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              fontSize: 11,
              color: "#565f89",
            }}
          >
            <div>
              <span style={{ color: "#7dcfff", fontWeight: 700 }}>
                Omnicast
              </span>{" "}
              v0.1.0 • Wayland LayerShell
            </div>

            <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
              <span>
                <kbd style={{ color: "#c0caf5" }}>Ctrl+K</kbd> Actions
              </span>
              <span>
                <kbd style={{ color: "#c0caf5" }}>Esc</kbd> Dismiss
              </span>
            </div>
          </div>
        </div>

        {/* ─── Live Actions & Syntax Preview Side Drawer ─── */}
        {drawerOpen && (
          <div
            style={{
              width: 380,
              backgroundColor: "rgba(12, 15, 24, 0.96)",
              backdropFilter: "blur(24px)",
              borderRadius: 16,
              border: "1px solid rgba(125, 207, 255, 0.35)",
              boxShadow: "0 25px 70px rgba(0, 0, 0, 0.7)",
              overflow: "hidden",
              display: "flex",
              flexDirection: "column",
              opacity: Math.max(0, Math.min(1, drawerSpring)),
              transform: `translateX(${interpolate(
                drawerSpring,
                [0, 1],
                [30, 0]
              )}px)`,
            }}
          >
            {/* Drawer Header */}
            <div
              style={{
                padding: "14px 18px",
                borderBottom: "1px solid rgba(255, 255, 255, 0.08)",
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
              }}
            >
              <div>
                <div style={{ fontSize: 13, fontWeight: 700, color: "#ffffff" }}>
                  bindings.conf
                </div>
                <div style={{ fontSize: 10, color: "#7dcfff" }}>
                  Live Config Preview
                </div>
              </div>
              <span
                style={{
                  fontSize: 10,
                  backgroundColor: "rgba(125, 207, 255, 0.15)",
                  color: "#7dcfff",
                  padding: "2px 6px",
                  borderRadius: 4,
                }}
              >
                UTF-8
              </span>
            </div>

            {/* Syntax Highlighted Code Preview */}
            <div
              style={{
                padding: "16px 18px",
                fontSize: 11,
                lineHeight: 1.6,
                backgroundColor: "rgba(8, 10, 16, 0.8)",
                flex: 1,
              }}
            >
              <div>
                <span style={{ color: "#7aa2f7" }}>$mainMod</span> = SUPER
              </div>
              <div>
                <span style={{ color: "#bb9af7" }}>bind</span> = $mainMod,
                SPACE, <span style={{ color: "#9ece6a" }}>exec, omnicast</span>
              </div>
              <div>
                <span style={{ color: "#bb9af7" }}>bind</span> = $mainMod,
                RETURN, exec, alacritty
              </div>
              <div>
                <span style={{ color: "#bb9af7" }}>bind</span> = $mainMod, Q,
                killactive
              </div>
              <div style={{ color: "#565f89", marginTop: 4 }}>
                # Hotkeys managed by Omarchy
              </div>
            </div>

            {/* Quick Actions List */}
            <div
              style={{
                padding: "12px 14px",
                display: "flex",
                flexDirection: "column",
                gap: 6,
                borderTop: "1px solid rgba(255, 255, 255, 0.08)",
                backgroundColor: "rgba(14, 18, 28, 0.9)",
              }}
            >
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  padding: "6px 10px",
                  borderRadius: 6,
                  backgroundColor: "rgba(125, 207, 255, 0.12)",
                  color: "#ffffff",
                  fontSize: 11,
                  fontWeight: 600,
                }}
              >
                <span>↵ Open in Neovim</span>
                <span style={{ color: "#7dcfff" }}>Default</span>
              </div>
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  padding: "6px 10px",
                  borderRadius: 6,
                  color: "#a9b1d6",
                  fontSize: 11,
                }}
              >
                <span>Ctrl+C Copy Absolute Path</span>
              </div>
            </div>
          </div>
        )}
      </div>
    </AbsoluteFill>
  );
};
