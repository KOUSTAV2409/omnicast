import React from "react";
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { TextReveal } from "@/components/snap-cn/text-reveal";
import { omnicastTheme } from "../theme";

export const IntroScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const logoScale = spring({
    frame,
    fps,
    config: { damping: 14, mass: 0.8 },
  });

  const glowOpacity = interpolate(frame, [0, 40], [0, 0.4], {
    extrapolateRight: "clamp",
  });

  const subtitleOpacity = interpolate(frame, [35, 60], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#1a1b26",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: "JetBrains Mono, monospace",
      }}
    >
      {/* Background glow */}
      <div
        style={{
          position: "absolute",
          width: 800,
          height: 800,
          borderRadius: "50%",
          background: "radial-gradient(circle, rgba(122, 162, 247, 0.3) 0%, rgba(26, 27, 38, 0) 70%)",
          opacity: glowOpacity,
          pointerEvents: "none",
        }}
      />

      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 24,
          zIndex: 1,
        }}
      >
        {/* Top Tag */}
        <div
          style={{
            transform: `scale(${logoScale})`,
            padding: "8px 20px",
            borderRadius: 24,
            background: "rgba(122, 162, 247, 0.12)",
            border: "1px solid rgba(122, 162, 247, 0.35)",
            color: "#7dcfff",
            fontSize: 20,
            fontWeight: 600,
            letterSpacing: "0.15em",
            textTransform: "uppercase",
          }}
        >
          OMNICAST
        </div>

        {/* Hero Title */}
        <div style={{ width: 1100, height: 110 }}>
          <TextReveal
            text="Alt+Space for Omarchy"
            fontSize={64}
            fontWeight={700}
            color="#c0caf5"
            mode="dark"
            theme={omnicastTheme}
            initialScale={1.4}
            holdDuration={12}
            letterSpacing="-0.02em"
          />
        </div>

        {/* Subtitle */}
        <div
          style={{
            opacity: subtitleOpacity,
            color: "#9ece6a",
            fontSize: 26,
            fontWeight: 500,
            letterSpacing: "-0.01em",
            marginTop: 12,
          }}
        >
          Fast. Fluid. Raycast-grade productivity on Wayland.
        </div>
      </div>
    </AbsoluteFill>
  );
};
