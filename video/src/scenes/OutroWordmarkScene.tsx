import React from "react";
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { WordmarkCut } from "@/components/snap-cn/wordmark-cut";
import { omnicastTheme } from "../theme";

export const OutroWordmarkScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Cards / badge entrance animation in the second half of the outro
  const ctaSpring = spring({
    frame: frame - 25,
    fps,
    config: { damping: 15, mass: 0.8, stiffness: 140 },
  });

  const ctaOpacity = interpolate(frame, [25, 42], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const sublineOpacity = interpolate(frame, [38, 55], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // Background subtle glow pulse
  const glowScale = interpolate(frame, [0, 80], [0.9, 1.25], {
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#16161e",
        fontFamily: "Inter, -apple-system, BlinkMacSystemFont, sans-serif",
        overflow: "hidden",
      }}
    >
      {/* Background ambient radial glow */}
      <div
        style={{
          position: "absolute",
          width: 900,
          height: 900,
          left: "50%",
          top: "45%",
          transform: `translate(-50%, -50%) scale(${glowScale})`,
          borderRadius: "50%",
          background: "radial-gradient(circle, rgba(125, 207, 255, 0.16) 0%, rgba(158, 206, 106, 0.08) 35%, rgba(22, 22, 30, 0) 70%)",
          pointerEvents: "none",
        }}
      />

      {/* Primary Wordmark Cut */}
      <WordmarkCut
        word="omnicast."
        dotFrom="#7dcfff"
        dotTo="#9ece6a"
        warm={1}
        mode="dark"
        theme={omnicastTheme}
      />

      {/* Floating Glassmorphic Launch Badge & Keybind Prompt */}
      <div
        style={{
          position: "absolute",
          bottom: 44,
          left: "50%",
          transform: `translateX(-50%) translateY(${(1 - ctaSpring) * 30}px) scale(${0.9 + ctaSpring * 0.1})`,
          opacity: ctaOpacity,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 12,
          zIndex: 30,
        }}
      >
        {/* Main CTA Pill */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 18,
            padding: "12px 28px",
            background: "rgba(26, 27, 38, 0.88)",
            backdropFilter: "blur(20px)",
            border: "1px solid rgba(125, 207, 255, 0.35)",
            borderRadius: 30,
            boxShadow: "0 12px 40px rgba(0, 0, 0, 0.6), 0 0 24px rgba(125, 207, 255, 0.15)",
          }}
        >
          {/* Logo mark icon */}
          <div
            style={{
              width: 26,
              height: 26,
              borderRadius: 6,
              background: "#1f2335",
              border: "1.5px solid #9ece6a",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            <div
              style={{
                width: 10,
                height: 10,
                borderRadius: "50%",
                background: "linear-gradient(135deg, #7dcfff, #9ece6a)",
              }}
            />
          </div>

          <span
            style={{
              color: "#ffffff",
              fontSize: 18,
              fontWeight: 700,
              letterSpacing: "-0.02em",
            }}
          >
            omnicast.best
          </span>

          <span style={{ color: "#565f89" }}>|</span>

          {/* Hotkey pill */}
          <div
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: 6,
              padding: "4px 12px",
              background: "rgba(122, 162, 247, 0.18)",
              border: "1px solid rgba(122, 162, 247, 0.4)",
              borderRadius: 8,
              color: "#7dcfff",
              fontSize: 14,
              fontWeight: 700,
              fontFamily: "JetBrains Mono, monospace",
            }}
          >
            Alt + Space
          </div>

          <span style={{ color: "#565f89" }}>|</span>

          <span
            style={{
              color: "#9ece6a",
              fontSize: 15,
              fontWeight: 600,
              letterSpacing: "-0.01em",
            }}
          >
            Available on Omarchy
          </span>
        </div>

        {/* Secondary Subtitle: GitHub & Marketplace */}
        <div
          style={{
            opacity: sublineOpacity,
            display: "flex",
            alignItems: "center",
            gap: 16,
            fontSize: 13,
            color: "#a9b1d6",
            fontFamily: "JetBrains Mono, monospace",
          }}
        >
          <span>omarchy plugin add omnicast</span>
          <span style={{ color: "#414868" }}>•</span>
          <span>github.com/KOUSTAV2409/omnicast</span>
        </div>
      </div>
    </AbsoluteFill>
  );
};
