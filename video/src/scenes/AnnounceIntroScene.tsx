import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export const AnnounceIntroScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Smooth entrance springs
  const logoSpring = spring({
    frame,
    fps,
    config: { damping: 14, mass: 0.8, stiffness: 100 },
  });

  const titleSpring = spring({
    frame: frame - 15,
    fps,
    config: { damping: 16, mass: 0.9, stiffness: 110 },
  });

  const taglineSpring = spring({
    frame: frame - 30,
    fps,
    config: { damping: 18, mass: 1, stiffness: 100 },
  });

  const pillsSpring = spring({
    frame: frame - 45,
    fps,
    config: { damping: 16, mass: 0.8, stiffness: 120 },
  });

  // Breathing subtle pulse for the background glow
  const pulse = Math.sin(frame / 12) * 0.15 + 0.85;

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#0d1017",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        overflow: "hidden",
        fontFamily: "Inter, -apple-system, BlinkMacSystemFont, sans-serif",
      }}
    >
      {/* Cinematic ambient radial gradient */}
      <div
        style={{
          position: "absolute",
          top: "40%",
          left: "50%",
          transform: `translate(-50%, -50%) scale(${pulse})`,
          width: 900,
          height: 500,
          background:
            "radial-gradient(circle, rgba(125, 207, 255, 0.14) 0%, rgba(122, 162, 247, 0.05) 50%, transparent 75%)",
          filter: "blur(60px)",
          pointerEvents: "none",
        }}
      />

      {/* Floating Eyebrow Badge */}
      <div
        style={{
          opacity: Math.max(0, Math.min(1, logoSpring)),
          transform: `translateY(${interpolate(
            logoSpring,
            [0, 1],
            [-15, 0]
          )}px)`,
          display: "flex",
          alignItems: "center",
          gap: 8,
          padding: "6px 16px",
          borderRadius: 20,
          background: "rgba(125, 207, 255, 0.08)",
          border: "1px solid rgba(125, 207, 255, 0.25)",
          marginBottom: 20,
        }}
      >
        <span
          style={{
            width: 7,
            height: 7,
            borderRadius: "50%",
            backgroundColor: "#7dcfff",
            boxShadow: "0 0 10px #7dcfff",
          }}
        />
        <span
          style={{
            color: "#7dcfff",
            fontSize: 12,
            fontWeight: 700,
            letterSpacing: "0.14em",
            textTransform: "uppercase",
            fontFamily: "'JetBrains Mono', monospace",
          }}
        >
          Introducing
        </span>
      </div>

      {/* App Logo Icon Lockup */}
      <div
        style={{
          opacity: Math.max(0, Math.min(1, logoSpring)),
          transform: `scale(${interpolate(
            logoSpring,
            [0, 1],
            [0.8, 1]
          )}) translateY(${interpolate(logoSpring, [0, 1], [15, 0])}px)`,
          width: 72,
          height: 72,
          borderRadius: 20,
          background: "linear-gradient(145deg, #181d2c, #0e121c)",
          border: "1px solid rgba(125, 207, 255, 0.35)",
          boxShadow:
            "0 12px 35px rgba(0, 0, 0, 0.6), 0 0 35px rgba(125, 207, 255, 0.25)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          marginBottom: 20,
          position: "relative",
        }}
      >
        <div
          style={{
            width: 32,
            height: 32,
            borderRadius: "50%",
            border: "4px solid #7dcfff",
            boxShadow: "0 0 15px rgba(125, 207, 255, 0.6)",
            position: "relative",
          }}
        >
          <div
            style={{
              position: "absolute",
              inset: 5,
              borderRadius: "50%",
              backgroundColor: "#7aa2f7",
            }}
          />
        </div>
      </div>

      {/* Hero Title */}
      <div
        style={{
          opacity: Math.max(0, Math.min(1, titleSpring)),
          transform: `translateY(${interpolate(
            titleSpring,
            [0, 1],
            [20, 0]
          )}px)`,
          textAlign: "center",
          marginBottom: 14,
        }}
      >
        <span
          style={{
            fontSize: 68,
            fontWeight: 800,
            letterSpacing: "-0.04em",
            color: "#ffffff",
          }}
        >
          Omnicast
        </span>
        <span
          style={{
            fontSize: 68,
            fontWeight: 800,
            letterSpacing: "-0.04em",
            color: "#7dcfff",
            textShadow: "0 0 30px rgba(125, 207, 255, 0.7)",
          }}
        >
          .
        </span>
      </div>

      {/* Subtitle / Tagline */}
      <div
        style={{
          opacity: Math.max(0, Math.min(1, taglineSpring)),
          transform: `translateY(${interpolate(
            taglineSpring,
            [0, 1],
            [15, 0]
          )}px)`,
          textAlign: "center",
          fontSize: 22,
          fontWeight: 400,
          color: "#9aa5ce",
          maxWidth: 620,
          lineHeight: 1.5,
          letterSpacing: "-0.01em",
          marginBottom: 32,
        }}
      >
        Instant desktop search and command palette for{" "}
        <span style={{ color: "#ffffff", fontWeight: 600 }}>Omarchy</span> &{" "}
        <span style={{ color: "#ffffff", fontWeight: 600 }}>Hyprland</span>.
      </div>

      {/* Three Flagship Feature Badges */}
      <div
        style={{
          opacity: Math.max(0, Math.min(1, pillsSpring)),
          transform: `translateY(${interpolate(
            pillsSpring,
            [0, 1],
            [15, 0]
          )}px)`,
          display: "flex",
          alignItems: "center",
          gap: 14,
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 8,
            padding: "8px 16px",
            borderRadius: 12,
            backgroundColor: "rgba(20, 24, 36, 0.8)",
            border: "1px solid rgba(255, 255, 255, 0.08)",
            fontSize: 13,
            color: "#c0caf5",
          }}
        >
          <span style={{ color: "#7dcfff" }}>⚡</span>
          <span>&lt; 1ms Local FTS5</span>
        </div>

        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 8,
            padding: "8px 16px",
            borderRadius: 12,
            backgroundColor: "rgba(20, 24, 36, 0.8)",
            border: "1px solid rgba(255, 255, 255, 0.08)",
            fontSize: 13,
            color: "#c0caf5",
          }}
        >
          <span style={{ color: "#9ece6a" }}>🔒</span>
          <span>100% Offline & Private</span>
        </div>

        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 8,
            padding: "8px 16px",
            borderRadius: 12,
            backgroundColor: "rgba(20, 24, 36, 0.8)",
            border: "1px solid rgba(255, 255, 255, 0.08)",
            fontSize: 13,
            color: "#c0caf5",
          }}
        >
          <span style={{ color: "#bb9af7" }}>🪟</span>
          <span>Native Wayland LayerShell</span>
        </div>
      </div>
    </AbsoluteFill>
  );
};
