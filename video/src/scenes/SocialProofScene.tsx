import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { TextHighlight } from "@/components/snap-cn/text-highlight";
import { omnicastTheme } from "../theme";

export const SocialProofScene: React.FC = () => {
  const frame = useCurrentFrame();

  const sublineOpacity = interpolate(frame, [25, 45], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#0d1017",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        overflow: "hidden",
      }}
    >
      {/* Background soft ambient radial gradient */}
      <div
        style={{
          position: "absolute",
          width: 800,
          height: 800,
          borderRadius: "50%",
          background: "radial-gradient(circle, rgba(158, 206, 106, 0.12) 0%, rgba(22, 22, 30, 0) 70%)",
          pointerEvents: "none",
        }}
      />

      {/* Eyebrow badge */}
      <div
        style={{
          display: "inline-flex",
          alignItems: "center",
          gap: 8,
          padding: "6px 18px",
          borderRadius: 20,
          background: "rgba(158, 206, 106, 0.15)",
          border: "1px solid rgba(158, 206, 106, 0.4)",
          color: "#9ece6a",
          fontSize: 14,
          fontWeight: 600,
          letterSpacing: "0.12em",
          textTransform: "uppercase",
          marginBottom: 36,
          zIndex: 2,
        }}
      >
        <span>✓</span>
        <span>Official Verification</span>
      </div>

      {/* Main TextHighlight with shimmer effect */}
      <div
        style={{
          width: 1100,
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          zIndex: 2,
        }}
      >
        <TextHighlight
          before="Listed on "
          highlight="Omarchy Plugin Marketplace"
          preset="shimmer"
          baseColor="#c0caf5"
          accentColor="#7dcfff"
          shineColor="#ffffff"
          fontSize={52}
          fontWeight={700}
          startAt={10}
          drawDuration={36}
          mode="dark"
          theme={omnicastTheme}
        />
      </div>

      {/* Bottom context pill */}
      <div
        style={{
          opacity: sublineOpacity,
          marginTop: 42,
          display: "flex",
          alignItems: "center",
          gap: 16,
          padding: "10px 24px",
          background: "rgba(31, 35, 53, 0.95)",
          backdropFilter: "blur(14px)",
          border: "1px solid rgba(122, 162, 247, 0.35)",
          borderRadius: 24,
          boxShadow: "0 8px 30px rgba(0, 0, 0, 0.4)",
          zIndex: 2,
        }}
      >
        <span style={{ color: "#7dcfff", fontSize: 16, fontWeight: 700 }}>
          omarchyplugins.com
        </span>
        <span style={{ color: "#565f89" }}>•</span>
        <span style={{ color: "#c0caf5", fontSize: 15, fontWeight: 500 }}>
          Community reviewed & approved
        </span>
      </div>
    </AbsoluteFill>
  );
};
