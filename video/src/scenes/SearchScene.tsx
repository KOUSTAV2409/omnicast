import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { ScreenRecording } from "@/components/snap-cn/screen-recording";

export const SearchScene: React.FC = () => {
  const frame = useCurrentFrame();

  const badgeOpacity = interpolate(frame, [0, 20], [0, 1], {
    extrapolateRight: "clamp",
  });

  const badgeTranslateY = interpolate(frame, [0, 20], [-15, 0], {
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill style={{ backgroundColor: "#1a1b26", overflow: "hidden" }}>
      {/* Screen recording of Omnicast in action */}
      <ScreenRecording
        src="/teaser.mp4"
        crop={{ top: 0.035 }}
        camera={[
          { at: 0, duration: 25, zoom: 1.9, x: 0.5, y: 0.45 },
          { at: 120, duration: 40, zoom: 2.1, x: 0.5, y: 0.43 },
        ]}
        fit="cover"
        mode="dark"
      />

      {/* Top Floating Feature Header */}
      <div
        style={{
          position: "absolute",
          top: 36,
          left: "50%",
          transform: `translateX(-50%) translateY(${badgeTranslateY}px)`,
          opacity: badgeOpacity,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 6,
          padding: "14px 28px",
          background: "rgba(26, 27, 38, 0.85)",
          backdropFilter: "blur(16px)",
          border: "1px solid rgba(122, 162, 247, 0.4)",
          borderRadius: 16,
          boxShadow: "0 12px 32px rgba(0, 0, 0, 0.5)",
          fontFamily: "JetBrains Mono, monospace",
          zIndex: 10,
        }}
      >
        <span
          style={{
            color: "#7dcfff",
            fontSize: 22,
            fontWeight: 700,
            letterSpacing: "-0.01em",
          }}
        >
          Unified Desktop Search
        </span>
        <span
          style={{
            color: "rgba(192, 202, 245, 0.75)",
            fontSize: 14,
            fontWeight: 400,
          }}
        >
          Apps · Files · Quicklinks · 100+ Native Omarchy Tools
        </span>
      </div>

      {/* Floating Keycap Badge */}
      <div
        style={{
          position: "absolute",
          bottom: 36,
          right: 36,
          display: "flex",
          alignItems: "center",
          gap: 8,
          padding: "10px 18px",
          background: "rgba(31, 35, 53, 0.9)",
          backdropFilter: "blur(12px)",
          border: "1px solid rgba(122, 162, 247, 0.3)",
          borderRadius: 12,
          fontFamily: "JetBrains Mono, monospace",
          fontSize: 15,
          color: "#c0caf5",
          zIndex: 10,
        }}
      >
        <span style={{ color: "#7aa2f7" }}>Hotkey:</span>
        <kbd
          style={{
            background: "#24283b",
            border: "1px solid #414868",
            borderRadius: 6,
            padding: "3px 8px",
            fontSize: 13,
            color: "#7dcfff",
            boxShadow: "0 2px 0 #16161e",
          }}
        >
          Alt
        </kbd>
        <span style={{ color: "#565f89" }}>+</span>
        <kbd
          style={{
            background: "#24283b",
            border: "1px solid #414868",
            borderRadius: 6,
            padding: "3px 8px",
            fontSize: 13,
            color: "#7dcfff",
            boxShadow: "0 2px 0 #16161e",
          }}
        >
          Space
        </kbd>
      </div>
    </AbsoluteFill>
  );
};
