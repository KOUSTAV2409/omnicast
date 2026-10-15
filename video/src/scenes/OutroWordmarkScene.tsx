import React from "react";
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";

export const OutroWordmarkScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // 1. Logo & Brand Title Spring Entrance (0 -> 24)
  const logoSpring = spring({
    frame,
    fps,
    config: { damping: 14, mass: 0.7, stiffness: 160 },
  });

  const logoScale = interpolate(logoSpring, [0, 1], [0.75, 1]);
  const logoOpacity = interpolate(logoSpring, [0, 1], [0, 1]);

  // 2. Tagline fade & gentle slide-up
  const taglineOpacity = interpolate(frame, [14, 28], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const taglineY = interpolate(frame, [14, 28], [12, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // 3. Main Launch Pill Spring Entrance (frame 22 -> 45)
  const pillSpring = spring({
    frame: frame - 22,
    fps,
    config: { damping: 13, mass: 0.8, stiffness: 140 },
  });
  const pillY = interpolate(pillSpring, [0, 1], [24, 0]);
  const pillScale = interpolate(pillSpring, [0, 1], [0.92, 1]);
  const pillOpacity = interpolate(pillSpring, [0, 1], [0, 1]);

  // 4. Install Command Pill Entrance (frame 34 -> 54)
  const cmdOpacity = interpolate(frame, [34, 48], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const cmdY = interpolate(frame, [34, 48], [10, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // 5. Specular Shimmer across omnicast.best (frame 44 -> 74)
  const shimmerProgress = interpolate(frame, [44, 76], [-100, 200], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // Background ambient pulsing radial glow
  const glowPulse = interpolate(frame, [0, 80], [0.85, 1.15], {
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#0d1017",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: "Inter, -apple-system, BlinkMacSystemFont, sans-serif",
        overflow: "hidden",
      }}
    >
      {/* Background radial gradient glow (Tokyo Night Cyan + Emerald) */}
      <div
        style={{
          position: "absolute",
          width: 900,
          height: 900,
          borderRadius: "50%",
          background: "radial-gradient(circle, rgba(125, 207, 255, 0.18) 0%, rgba(158, 206, 106, 0.08) 38%, rgba(13, 16, 23, 0) 70%)",
          transform: `scale(${glowPulse})`,
          pointerEvents: "none",
        }}
      />

      {/* Center Lockup: Logo Mark + Full Brand Title */}
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 16,
          transform: `scale(${logoScale})`,
          opacity: logoOpacity,
          zIndex: 10,
        }}
      >
        {/* Glowing Logo Icon */}
        <div
          style={{
            width: 72,
            height: 72,
            borderRadius: 18,
            background: "linear-gradient(145deg, #1f2335, #141824)",
            border: "1.5px solid rgba(125, 207, 255, 0.4)",
            boxShadow: "0 12px 36px rgba(0, 0, 0, 0.6), 0 0 30px rgba(125, 207, 255, 0.25)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          {/* Animated concentric ring gradient nucleus */}
          <div
            style={{
              width: 32,
              height: 32,
              borderRadius: "50%",
              background: "linear-gradient(135deg, #7dcfff 0%, #7aa2f7 50%, #9ece6a 100%)",
              boxShadow: "0 0 16px rgba(125, 207, 255, 0.6)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            <div
              style={{
                width: 14,
                height: 14,
                borderRadius: "50%",
                backgroundColor: "#141824",
              }}
            />
          </div>
        </div>

        {/* Crisp Full Brand Name */}
        <div style={{ display: "flex", alignItems: "baseline", gap: 2 }}>
          <h1
            style={{
              margin: 0,
              fontSize: 68,
              fontWeight: 800,
              letterSpacing: "-0.04em",
              color: "#ffffff",
              lineHeight: 1,
            }}
          >
            Omnicast
          </h1>
          <div
            style={{
              width: 12,
              height: 12,
              borderRadius: "50%",
              background: "linear-gradient(135deg, #7dcfff, #9ece6a)",
              boxShadow: "0 0 12px #7dcfff",
            }}
          />
        </div>

        {/* Clean Sub-tagline */}
        <p
          style={{
            margin: 0,
            fontSize: 20,
            fontWeight: 500,
            color: "#a9b1d6",
            letterSpacing: "-0.01em",
            opacity: taglineOpacity,
            transform: `translateY(${taglineY}px)`,
          }}
        >
          Instant desktop search for Omarchy & Linux.
        </p>
      </div>

      {/* Floating Interactive Conversion Pill */}
      <div
        style={{
          marginTop: 36,
          transform: `translateY(${pillY}px) scale(${pillScale})`,
          opacity: pillOpacity,
          display: "flex",
          alignItems: "center",
          gap: 18,
          padding: "14px 30px",
          background: "rgba(22, 27, 38, 0.92)",
          backdropFilter: "blur(24px)",
          border: "1px solid rgba(125, 207, 255, 0.35)",
          borderRadius: 36,
          boxShadow: "0 16px 45px rgba(0, 0, 0, 0.7), 0 0 35px rgba(125, 207, 255, 0.15)",
          zIndex: 10,
          position: "relative",
          overflow: "hidden",
        }}
      >
        {/* Specular Shimmer Ray */}
        <div
          style={{
            position: "absolute",
            top: 0,
            bottom: 0,
            width: 80,
            background: "linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.22), transparent)",
            transform: `translateX(${shimmerProgress}%) skewX(-25deg)`,
            pointerEvents: "none",
          }}
        />

        {/* Domain name with bright accent */}
        <span
          style={{
            color: "#ffffff",
            fontSize: 21,
            fontWeight: 700,
            letterSpacing: "-0.02em",
          }}
        >
          omnicast.best
        </span>

        <span style={{ color: "#414868" }}>•</span>

        {/* Styled hotkey pill */}
        <div
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: 6,
            padding: "5px 14px",
            background: "rgba(122, 162, 247, 0.18)",
            border: "1px solid rgba(122, 162, 247, 0.45)",
            borderRadius: 8,
            color: "#7dcfff",
            fontSize: 15,
            fontWeight: 700,
            fontFamily: "JetBrains Mono, monospace",
            boxShadow: "0 2px 8px rgba(0,0,0,0.4)",
          }}
        >
          Alt + Space
        </div>

        <span style={{ color: "#414868" }}>•</span>

        {/* Status indicator */}
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <div
            style={{
              width: 8,
              height: 8,
              borderRadius: "50%",
              backgroundColor: "#9ece6a",
              boxShadow: "0 0 8px #9ece6a",
            }}
          />
          <span
            style={{
              color: "#9ece6a",
              fontSize: 16,
              fontWeight: 600,
              letterSpacing: "-0.01em",
            }}
          >
            Available Now
          </span>
        </div>
      </div>

      {/* Bottom One-line Terminal Command Card */}
      <div
        style={{
          marginTop: 22,
          opacity: cmdOpacity,
          transform: `translateY(${cmdY}px)`,
          display: "flex",
          alignItems: "center",
          gap: 14,
          padding: "8px 20px",
          background: "rgba(14, 18, 26, 0.8)",
          backdropFilter: "blur(12px)",
          border: "1px solid rgba(65, 72, 104, 0.5)",
          borderRadius: 20,
          fontFamily: "JetBrains Mono, monospace",
          fontSize: 13,
          color: "#a9b1d6",
          zIndex: 10,
        }}
      >
        <span style={{ color: "#7aa2f7" }}>$</span>
        <span style={{ color: "#c0caf5", fontWeight: 600 }}>omarchy plugin add omnicast</span>
        <span style={{ color: "#414868" }}>•</span>
        <span style={{ color: "#565f89" }}>github.com/KOUSTAV2409/omnicast</span>
      </div>
    </AbsoluteFill>
  );
};
