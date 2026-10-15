import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export const TerminalInstallSceneV4: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // 3D Terminal Entrance
  const entrance = spring({
    frame,
    fps,
    config: { damping: 16, mass: 0.9, stiffness: 100 },
  });

  // Typewriter effect
  const commandText = "omarchy plugin add omnicast";
  const typeStart = 16;
  const charsTyped = Math.floor(
    interpolate(frame, [typeStart, typeStart + 28], [0, commandText.length], {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
    })
  );
  const currentCommand = commandText.slice(0, charsTyped);
  const commandFinished = charsTyped >= commandText.length;

  // Log line reveals
  const showLog1 = frame >= 50;
  const showLog2 = frame >= 66;
  const showLog3 = frame >= 82;
  const showSuccess = frame >= 98;

  // Golden badge spring at frame 108
  const badgeSpring = spring({
    frame: frame - 108,
    fps,
    config: { damping: 14, mass: 0.8, stiffness: 120 },
  });

  const cursorBlink = Math.floor(frame / 7) % 2 === 0;

  // Exit transition
  const exitOpacity = interpolate(frame, [135, 150], [1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#0a0c12",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        overflow: "hidden",
        opacity: exitOpacity,
        fontFamily: "'JetBrains Mono', monospace",
        perspective: 1100,
      }}
    >
      {/* Background radial glow */}
      <div
        style={{
          position: "absolute",
          top: "45%",
          left: "50%",
          transform: "translate(-50%, -50%)",
          width: 850,
          height: 420,
          background:
            "radial-gradient(circle, rgba(125, 207, 255, 0.12) 0%, rgba(158, 206, 106, 0.04) 50%, transparent 75%)",
          filter: "blur(60px)",
          pointerEvents: "none",
        }}
      />

      {/* Top Headline */}
      <div
        style={{
          textAlign: "center",
          marginBottom: 26,
          opacity: Math.max(0, Math.min(1, entrance)),
          transform: `translateY(${interpolate(entrance, [0, 1], [-14, 0])}px)`,
        }}
      >
        <span
          style={{
            fontSize: 34,
            fontWeight: 800,
            fontFamily: "Inter, sans-serif",
            color: "#ffffff",
            letterSpacing: "-0.02em",
          }}
        >
          Install in{" "}
        </span>
        <span
          style={{
            fontSize: 34,
            fontWeight: 800,
            fontFamily: "Inter, sans-serif",
            background: "linear-gradient(135deg, #7dcfff 0%, #9ece6a 100%)",
            WebkitBackgroundClip: "text",
            WebkitTextFillColor: "transparent",
            letterSpacing: "-0.02em",
          }}
        >
          one line.
        </span>
      </div>

      {/* Flagship Terminal Window Card */}
      <div
        style={{
          width: 860,
          borderRadius: 16,
          background: "rgba(14, 18, 28, 0.94)",
          backdropFilter: "blur(22px)",
          border: "1px solid rgba(125, 207, 255, 0.25)",
          boxShadow:
            "0 25px 60px rgba(0, 0, 0, 0.7), 0 0 40px rgba(125, 207, 255, 0.08)",
          display: "flex",
          flexDirection: "column",
          overflow: "hidden",
          transform: `scale(${interpolate(
            entrance,
            [0, 1],
            [0.93, 1]
          )}) translateY(${interpolate(entrance, [0, 1], [25, 0])}px) rotateX(4deg)`,
          opacity: Math.max(0, Math.min(1, entrance)),
        }}
      >
        {/* Titlebar */}
        <div
          style={{
            height: 42,
            backgroundColor: "rgba(10, 13, 20, 0.9)",
            borderBottom: "1px solid rgba(255, 255, 255, 0.06)",
            display: "flex",
            alignItems: "center",
            padding: "0 18px",
            justifyContent: "space-between",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <div
              style={{
                width: 11,
                height: 11,
                borderRadius: "50%",
                backgroundColor: "#f7768e",
              }}
            />
            <div
              style={{
                width: 11,
                height: 11,
                borderRadius: "50%",
                backgroundColor: "#e0af68",
              }}
            />
            <div
              style={{
                width: 11,
                height: 11,
                borderRadius: "50%",
                backgroundColor: "#9ece6a",
              }}
            />
          </div>

          <div
            style={{
              fontSize: 12,
              color: "#565f89",
              letterSpacing: "0.02em",
            }}
          >
            iamkxyz@omarchy: ~
          </div>

          <div
            style={{
              fontSize: 11,
              color: "#7aa2f7",
              backgroundColor: "rgba(122, 162, 247, 0.12)",
              padding: "2px 8px",
              borderRadius: 4,
              border: "1px solid rgba(122, 162, 247, 0.25)",
            }}
          >
            omarchy-shell
          </div>
        </div>

        {/* Terminal Content Body */}
        <div
          style={{
            padding: "22px 26px",
            display: "flex",
            flexDirection: "column",
            gap: 12,
            fontSize: 14,
            lineHeight: 1.6,
          }}
        >
          {/* Active Command Line */}
          <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
            <span style={{ color: "#7dcfff", fontWeight: 700 }}>❯</span>
            <div>
              <span style={{ color: "#e0af68" }}>
                {currentCommand.slice(0, 7)}
              </span>
              <span style={{ color: "#7aa2f7" }}>
                {currentCommand.slice(7, 14)}
              </span>
              <span style={{ color: "#c0caf5" }}>
                {currentCommand.slice(14)}
              </span>
              {!commandFinished && cursorBlink && (
                <span
                  style={{
                    display: "inline-block",
                    width: 8,
                    height: 16,
                    backgroundColor: "#7dcfff",
                    marginLeft: 2,
                    verticalAlign: "middle",
                  }}
                />
              )}
            </div>
          </div>

          {/* Log Lines */}
          {showLog1 && (
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 8,
                color: "#565f89",
              }}
            >
              <span style={{ color: "#7aa2f7" }}>[1/3]</span>
              <span>Fetching verified manifest from omarchyplugins.com...</span>
            </div>
          )}

          {showLog2 && (
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 8,
                color: "#565f89",
              }}
            >
              <span style={{ color: "#7aa2f7" }}>[2/3]</span>
              <span>Linking native Wayland LayerShell binary to /usr/bin/omnicast...</span>
            </div>
          )}

          {showLog3 && (
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 8,
                color: "#565f89",
              }}
            >
              <span style={{ color: "#7aa2f7" }}>[3/3]</span>
              <span>Bound global Hyprland keybind: </span>
              <span
                style={{
                  backgroundColor: "rgba(125, 207, 255, 0.15)",
                  color: "#7dcfff",
                  padding: "1px 6px",
                  borderRadius: 4,
                  fontWeight: 600,
                }}
              >
                Alt + Space
              </span>
            </div>
          )}

          {showSuccess && (
            <div
              style={{
                marginTop: 4,
                display: "flex",
                alignItems: "center",
                gap: 8,
                color: "#9ece6a",
                fontWeight: 600,
              }}
            >
              <span>✔</span>
              <span>Omnicast v0.1.0 installed in 0.4s. Press Alt+Space to summon.</span>
            </div>
          )}
        </div>
      </div>

      {/* Official Marketplace Verification Badge */}
      <div
        style={{
          marginTop: 24,
          opacity: Math.max(0, Math.min(1, badgeSpring)),
          transform: `translateY(${interpolate(
            badgeSpring,
            [0, 1],
            [15, 0]
          )}px) scale(${interpolate(badgeSpring, [0, 1], [0.94, 1])})`,
          display: "flex",
          alignItems: "center",
          gap: 12,
          padding: "8px 22px",
          background: "rgba(14, 18, 28, 0.95)",
          backdropFilter: "blur(14px)",
          border: "1px solid rgba(158, 206, 106, 0.4)",
          borderRadius: 24,
          boxShadow: "0 8px 30px rgba(0, 0, 0, 0.5), 0 0 20px rgba(158, 206, 106, 0.15)",
          fontFamily: "Inter, sans-serif",
        }}
      >
        <span style={{ color: "#9ece6a", fontSize: 13, fontWeight: 700 }}>
          ✓ Verified
        </span>
        <span style={{ color: "rgba(255, 255, 255, 0.2)" }}>•</span>
        <span style={{ color: "#ffffff", fontSize: 13, fontWeight: 600 }}>
          Listed on Omarchy Plugin Marketplace
        </span>
        <span style={{ color: "rgba(255, 255, 255, 0.2)" }}>•</span>
        <span style={{ color: "#7dcfff", fontSize: 13, fontWeight: 600 }}>
          omarchyplugins.com
        </span>
      </div>
    </AbsoluteFill>
  );
};
