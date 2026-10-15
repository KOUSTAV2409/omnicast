import React from "react";
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { TextReveal } from "@/components/snap-cn/text-reveal";
import { omnicastTheme } from "../theme";

export const ColdOpenHookScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Pulse glow behind the hook text
  const glowScale = spring({
    frame,
    fps,
    config: { damping: 12, mass: 0.6 },
  });

  const glowOpacity = interpolate(frame, [0, 20, 70, 90], [0, 0.45, 0.45, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const sublineOpacity = interpolate(frame, [25, 45, 75, 88], [0, 1, 1, 0], {
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
      {/* Background radial glow */}
      <div
        style={{
          position: "absolute",
          width: 700,
          height: 700,
          borderRadius: "50%",
          background: "radial-gradient(circle, rgba(125, 207, 255, 0.22) 0%, rgba(22, 22, 30, 0) 70%)",
          opacity: glowOpacity,
          transform: `scale(${glowScale})`,
          pointerEvents: "none",
        }}
      />

      {/* Main hook text animated with TextReveal */}
      <div
        style={{
          width: 1000,
          height: 140,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          zIndex: 2,
        }}
      >
        <TextReveal
          text="Alt + Space"
          fontSize={88}
          fontWeight={800}
          color="#7dcfff"
          initialScale={2.1}
          introDuration={8}
          holdDuration={24}
          recedeDuration={16}
          assembleDuration={24}
          wordDelay={4}
          wordStagger={3}
          wordDuration={12}
          letterSpacing="-0.04em"
          mode="dark"
          theme={omnicastTheme}
        />
      </div>

      {/* Provocative sub-prompt that appears under the hotkey */}
      <div
        style={{
          opacity: sublineOpacity,
          marginTop: 18,
          display: "flex",
          alignItems: "center",
          gap: 12,
          padding: "6px 18px",
          background: "rgba(31, 35, 53, 0.75)",
          backdropFilter: "blur(12px)",
          border: "1px solid rgba(125, 207, 255, 0.25)",
          borderRadius: 20,
          zIndex: 2,
        }}
      >
        <span
          style={{
            color: "#9ece6a",
            fontSize: 16,
            fontWeight: 600,
            letterSpacing: "0.08em",
            textTransform: "uppercase",
          }}
        >
          One shortcut
        </span>
        <span style={{ color: "#565f89" }}>•</span>
        <span
          style={{
            color: "#c0caf5",
            fontSize: 15,
            fontWeight: 400,
            letterSpacing: "-0.01em",
          }}
        >
          Instant desktop command
        </span>
      </div>
    </AbsoluteFill>
  );
};
