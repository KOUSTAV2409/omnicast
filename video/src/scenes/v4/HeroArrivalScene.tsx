import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export const HeroArrivalScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Entrance springs
  const logoSpring = spring({
    frame,
    fps,
    config: { damping: 14, mass: 0.8, stiffness: 100 },
  });

  const titleSpring = spring({
    frame: frame - 14,
    fps,
    config: { damping: 15, mass: 0.85, stiffness: 110 },
  });

  const taglineSpring = spring({
    frame: frame - 28,
    fps,
    config: { damping: 16, mass: 0.9, stiffness: 100 },
  });

  const pillsSpring = spring({
    frame: frame - 42,
    fps,
    config: { damping: 15, mass: 0.8, stiffness: 120 },
  });

  // Light sweep shimmer across title
  const shineProgress = interpolate(frame, [25, 75], [-100, 200], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // Ambient breathing pulse
  const pulse = Math.sin(frame / 14) * 0.12 + 0.88;

  // Exit transition
  const exitOpacity = interpolate(frame, [100, 120], [1, 0], {
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
        fontFamily: "Inter, -apple-system, BlinkMacSystemFont, sans-serif",
      }}
    >
      {/* Dynamic ambient radial illumination */}
      <div
        style={{
          position: "absolute",
          top: "42%",
          left: "50%",
          transform: `translate(-50%, -50%) scale(${pulse})`,
          width: 900,
          height: 520,
          background:
            "radial-gradient(circle, rgba(125, 207, 255, 0.16) 0%, rgba(122, 162, 247, 0.05) 50%, transparent 75%)",
          filter: "blur(65px)",
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
            [-18, 0]
          )}px)`,
          display: "flex",
          alignItems: "center",
          gap: 10,
          padding: "6px 18px",
          borderRadius: 20,
          background: "rgba(125, 207, 255, 0.08)",
          border: "1px solid rgba(125, 207, 255, 0.25)",
          marginBottom: 22,
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
            letterSpacing: "0.15em",
            textTransform: "uppercase",
            fontFamily: "'JetBrains Mono', monospace",
          }}
        >
          Introducing
        </span>
      </div>

      {/* Hero Iris Logo Lockup */}
      <div
        style={{
          opacity: Math.max(0, Math.min(1, logoSpring)),
          transform: `scale(${interpolate(
            logoSpring,
            [0, 1],
            [0.8, 1]
          )}) translateY(${interpolate(logoSpring, [0, 1], [15, 0])}px)`,
          width: 76,
          height: 76,
          borderRadius: 22,
          background: "linear-gradient(145deg, #181d2e, #0e121d)",
          border: "1px solid rgba(125, 207, 255, 0.35)",
          boxShadow:
            "0 14px 40px rgba(0, 0, 0, 0.7), 0 0 35px rgba(125, 207, 255, 0.25)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          marginBottom: 20,
        }}
      >
        <div
          style={{
            width: 36,
            height: 36,
            borderRadius: "50%",
            border: "4px solid #7dcfff",
            boxShadow: "0 0 16px rgba(125, 207, 255, 0.7)",
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

      {/* Brand Title with Specular Shine Effect */}
      <div
        style={{
          opacity: Math.max(0, Math.min(1, titleSpring)),
          transform: `translateY(${interpolate(
            titleSpring,
            [0, 1],
            [22, 0]
          )}px)`,
          textAlign: "center",
          marginBottom: 14,
          position: "relative",
        }}
      >
        <span
          style={{
            fontSize: 70,
            fontWeight: 800,
            letterSpacing: "-0.04em",
            color: "#ffffff",
            backgroundImage: `linear-gradient(115deg, #ffffff 0%, #ffffff ${
              shineProgress - 20
            }%, #7dcfff ${shineProgress}%, #ffffff ${shineProgress + 20}%, #ffffff 100%)`,
            WebkitBackgroundClip: "text",
            WebkitTextFillColor: "transparent",
          }}
        >
          Omnicast
        </span>
        <span
          style={{
            fontSize: 70,
            fontWeight: 800,
            letterSpacing: "-0.04em",
            color: "#7dcfff",
            textShadow: "0 0 30px rgba(125, 207, 255, 0.8)",
          }}
        >
          .
        </span>
      </div>

      {/* Refined Tagline */}
      <div
        style={{
          opacity: Math.max(0, Math.min(1, taglineSpring)),
          transform: `translateY(${interpolate(
            taglineSpring,
            [0, 1],
            [16, 0]
          )}px)`,
          textAlign: "center",
          fontSize: 22,
          fontWeight: 400,
          color: "#9aa5ce",
          maxWidth: 640,
          lineHeight: 1.5,
          letterSpacing: "-0.01em",
          marginBottom: 32,
        }}
      >
        Instant desktop search and command palette for{" "}
        <span style={{ color: "#ffffff", fontWeight: 600 }}>Omarchy</span> &{" "}
        <span style={{ color: "#ffffff", fontWeight: 600 }}>Hyprland</span>.
      </div>

      {/* Feature Badges */}
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
            padding: "8px 18px",
            borderRadius: 12,
            backgroundColor: "rgba(17, 21, 34, 0.85)",
            border: "1px solid rgba(125, 207, 255, 0.2)",
            fontSize: 13,
            color: "#c0caf5",
          }}
        >
          <span style={{ color: "#7dcfff" }}>⚡</span>
          <span>&lt; 1ms Local SQLite FTS5</span>
        </div>

        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 8,
            padding: "8px 18px",
            borderRadius: 12,
            backgroundColor: "rgba(17, 21, 34, 0.85)",
            border: "1px solid rgba(158, 206, 106, 0.2)",
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
            padding: "8px 18px",
            borderRadius: 12,
            backgroundColor: "rgba(17, 21, 34, 0.85)",
            border: "1px solid rgba(187, 154, 247, 0.2)",
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
