import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export const TerminalInstallScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Entrance spring for the main terminal window
  const terminalEntrance = spring({
    frame,
    fps,
    config: { damping: 18, mass: 0.9, stiffness: 100 },
  });

  // Typewriter effect for: "omarchy plugin add omnicast"
  const commandText = "omarchy plugin add omnicast";
  const typeStart = 16;
  const charsTyped = Math.floor(
    interpolate(frame, [typeStart, typeStart + 32], [0, commandText.length], {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
    })
  );
  const typedCommand = commandText.slice(0, charsTyped);
  const commandFinished = charsTyped >= commandText.length;

  // Log line reveals
  const showLog1 = frame >= 56;
  const showLog2 = frame >= 72;
  const showLog3 = frame >= 88;
  const showLog4 = frame >= 104;
  const showSuccess = frame >= 120;

  // Bottom CTA reveal
  const ctaSpring = spring({
    frame: frame - 130,
    fps,
    config: { damping: 16, mass: 0.8, stiffness: 120 },
  });

  const cursorBlink = Math.floor(frame / 8) % 2 === 0;

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#0d1017",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: "'JetBrains Mono', 'Fira Code', monospace",
        overflow: "hidden",
      }}
    >
      {/* Background ambient radial glow */}
      <div
        style={{
          position: "absolute",
          top: "45%",
          left: "50%",
          transform: "translate(-50%, -50%)",
          width: 800,
          height: 400,
          background:
            "radial-gradient(circle, rgba(125, 207, 255, 0.08) 0%, rgba(122, 162, 247, 0.03) 45%, transparent 70%)",
          filter: "blur(50px)",
          pointerEvents: "none",
        }}
      />

      {/* Top Scene Tagline */}
      <div
        style={{
          marginBottom: 28,
          textAlign: "center",
          opacity: Math.min(1, frame / 15),
          transform: `translateY(${interpolate(frame, [0, 15], [-12, 0], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          })}px)`,
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
            background: "linear-gradient(135deg, #7dcfff 0%, #7aa2f7 100%)",
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
          width: 840,
          minHeight: 320,
          borderRadius: 14,
          background: "rgba(17, 20, 32, 0.94)",
          backdropFilter: "blur(20px)",
          border: "1px solid rgba(125, 207, 255, 0.2)",
          boxShadow:
            "0 25px 60px rgba(0, 0, 0, 0.7), 0 0 40px rgba(125, 207, 255, 0.06)",
          display: "flex",
          flexDirection: "column",
          overflow: "hidden",
          transform: `scale(${interpolate(
            terminalEntrance,
            [0, 1],
            [0.93, 1]
          )}) translateY(${interpolate(terminalEntrance, [0, 1], [25, 0])}px)`,
          opacity: Math.min(1, terminalEntrance),
        }}
      >
        {/* Terminal Titlebar */}
        <div
          style={{
            height: 40,
            backgroundColor: "rgba(13, 16, 23, 0.85)",
            borderBottom: "1px solid rgba(255, 255, 255, 0.06)",
            display: "flex",
            alignItems: "center",
            padding: "0 16px",
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
            zsh
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
                {typedCommand.slice(0, 7)}
              </span>
              <span style={{ color: "#7aa2f7" }}>
                {typedCommand.slice(7, 14)}
              </span>
              <span style={{ color: "#c0caf5" }}>
                {typedCommand.slice(14)}
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
              <span style={{ color: "#7aa2f7" }}>[1/4]</span>
              <span>Fetching omnicast manifest from Omarchy Marketplace...</span>
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
              <span style={{ color: "#7aa2f7" }}>[2/4]</span>
              <span>Downloading native Wayland layer shell binary (x86_64)...</span>
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
              <span style={{ color: "#7aa2f7" }}>[3/4]</span>
              <span>Indexed local configs and bindings into SQLite FTS5 database...</span>
            </div>
          )}

          {showLog4 && (
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 8,
                color: "#565f89",
              }}
            >
              <span style={{ color: "#7aa2f7" }}>[4/4]</span>
              <span>Bound global shortcut: </span>
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
              <span>Installed successfully. Omnicast is ready to launch.</span>
            </div>
          )}
        </div>
      </div>

      {/* Modern floating CTA pill */}
      <div
        style={{
          marginTop: 24,
          opacity: Math.max(0, Math.min(1, ctaSpring)),
          transform: `translateY(${interpolate(
            ctaSpring,
            [0, 1],
            [15, 0]
          )}px) scale(${interpolate(ctaSpring, [0, 1], [0.94, 1])})`,
          display: "flex",
          alignItems: "center",
          gap: 16,
          padding: "8px 22px",
          background: "rgba(17, 20, 32, 0.9)",
          backdropFilter: "blur(14px)",
          border: "1px solid rgba(125, 207, 255, 0.25)",
          borderRadius: 24,
          boxShadow: "0 8px 30px rgba(0, 0, 0, 0.5)",
          fontFamily: "Inter, sans-serif",
        }}
      >
        <span style={{ color: "#7dcfff", fontSize: 14, fontWeight: 700 }}>
          omnicast.best
        </span>
        <span style={{ color: "rgba(255, 255, 255, 0.2)" }}>•</span>
        <span style={{ color: "#9ece6a", fontSize: 13, fontWeight: 600 }}>
          omarchyplugins.com
        </span>
        <span style={{ color: "rgba(255, 255, 255, 0.2)" }}>•</span>
        <span style={{ color: "#a9b1d6", fontSize: 13, fontFamily: "monospace" }}>
          Alt + Space
        </span>
      </div>
    </AbsoluteFill>
  );
};
