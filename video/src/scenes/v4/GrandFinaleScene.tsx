import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export const GrandFinaleScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Entrance spring physics
  const logoSpring = spring({
    frame,
    fps,
    config: { damping: 14, mass: 0.8, stiffness: 100 },
  });

  const titleSpring = spring({
    frame: frame - 14,
    fps,
    config: { damping: 16, mass: 0.85, stiffness: 110 },
  });

  const taglineSpring = spring({
    frame: frame - 28,
    fps,
    config: { damping: 18, mass: 0.9, stiffness: 100 },
  });

  const pillSpring = spring({
    frame: frame - 42,
    fps,
    config: { damping: 16, mass: 0.8, stiffness: 120 },
  });

  // Breathing subtle pulse for the background glow
  const pulse = Math.sin(frame / 14) * 0.12 + 0.88;

  // Specular light sweep across CTA pill border
  const shimmer = interpolate(frame, [45, 95], [-100, 200], {
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
        fontFamily: "Inter, -apple-system, BlinkMacSystemFont, sans-serif",
      }}
    >
      {/* Background ambient radial glow */}
      <div
        style={{
          position: "absolute",
          top: "44%",
          left: "50%",
          transform: `translate(-50%, -50%) scale(${pulse})`,
          width: 900,
          height: 520,
          background:
            "radial-gradient(circle, rgba(125, 207, 255, 0.18) 0%, rgba(122, 162, 247, 0.05) 50%, transparent 75%)",
          filter: "blur(65px)",
          pointerEvents: "none",
        }}
      />

      {/* Hero Iris Logo Lockup */}
      <div
        style={{
          opacity: Math.max(0, Math.min(1, logoSpring)),
          transform: `scale(${interpolate(
            logoSpring,
            [0, 1],
            [0.8, 1]
          )}) translateY(${interpolate(logoSpring, [0, 1], [15, 0])}px)`,
          width: 82,
          height: 82,
          borderRadius: 24,
          background: "linear-gradient(145deg, #181d2e, #0e121d)",
          border: "1px solid rgba(125, 207, 255, 0.4)",
          boxShadow:
            "0 16px 45px rgba(0, 0, 0, 0.7), 0 0 40px rgba(125, 207, 255, 0.3)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          marginBottom: 24,
          position: "relative",
        }}
      >
        <div
          style={{
            width: 38,
            height: 38,
            borderRadius: "50%",
            border: "4px solid #7dcfff",
            boxShadow: "0 0 18px rgba(125, 207, 255, 0.7)",
            position: "relative",
          }}
        >
          <div
            style={{
              position: "absolute",
              inset: 6,
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
            [22, 0]
          )}px)`,
          textAlign: "center",
          marginBottom: 14,
        }}
      >
        <span
          style={{
            fontSize: 72,
            fontWeight: 800,
            letterSpacing: "-0.04em",
            color: "#ffffff",
          }}
        >
          Omnicast
        </span>
        <span
          style={{
            fontSize: 72,
            fontWeight: 800,
            letterSpacing: "-0.04em",
            color: "#7dcfff",
            textShadow: "0 0 32px rgba(125, 207, 255, 0.8)",
          }}
        >
          .
        </span>
      </div>

      {/* Subtitle */}
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
          marginBottom: 36,
        }}
      >
        Instant desktop search for Omarchy & Linux.
      </div>

      {/* Signature Floating Glassmorphic CTA Pill */}
      <div
        style={{
          opacity: Math.max(0, Math.min(1, pillSpring)),
          transform: `translateY(${interpolate(
            pillSpring,
            [0, 1],
            [18, 0]
          )}px) scale(${interpolate(pillSpring, [0, 1], [0.94, 1])})`,
          display: "flex",
          alignItems: "center",
          gap: 18,
          padding: "12px 28px",
          background: "rgba(16, 20, 32, 0.94)",
          backdropFilter: "blur(20px)",
          border: "1px solid rgba(125, 207, 255, 0.35)",
          borderRadius: 32,
          boxShadow:
            "0 20px 50px rgba(0, 0, 0, 0.6), 0 0 30px rgba(125, 207, 255, 0.15)",
          position: "relative",
          overflow: "hidden",
        }}
      >
        {/* Specular border shimmer */}
        <div
          style={{
            position: "absolute",
            inset: 0,
            background: `linear-gradient(90deg, transparent 0%, rgba(125, 207, 255, 0.25) ${shimmer}%, transparent 100%)`,
            pointerEvents: "none",
          }}
        />

        {/* Website domain */}
        <span
          style={{
            color: "#ffffff",
            fontSize: 16,
            fontWeight: 800,
            letterSpacing: "-0.01em",
          }}
        >
          omnicast.best
        </span>

        <span style={{ color: "rgba(255, 255, 255, 0.2)" }}>•</span>

        {/* Shortcut badge */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            padding: "3px 10px",
            backgroundColor: "rgba(125, 207, 255, 0.12)",
            border: "1px solid rgba(125, 207, 255, 0.3)",
            borderRadius: 6,
            color: "#7dcfff",
            fontSize: 13,
            fontWeight: 700,
            fontFamily: "'JetBrains Mono', monospace",
          }}
        >
          Alt + Space
        </div>

        <span style={{ color: "rgba(255, 255, 255, 0.2)" }}>•</span>

        {/* Status indicator */}
        <div style={{ display: "flex", alignItems: "center", gap: 7 }}>
          <span
            style={{
              width: 8,
              height: 8,
              borderRadius: "50%",
              backgroundColor: "#9ece6a",
              boxShadow: "0 0 10px #9ece6a",
            }}
          />
          <span style={{ color: "#9ece6a", fontSize: 13, fontWeight: 700 }}>
            Available Now
          </span>
        </div>
      </div>
    </AbsoluteFill>
  );
};
