import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { ScreenRecording } from "@/components/snap-cn/screen-recording";

export const PreviewScene: React.FC = () => {
  const frame = useCurrentFrame();

  const bannerOpacity = interpolate(frame, [0, 20], [0, 1], {
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill style={{ backgroundColor: "#1a1b26", overflow: "hidden" }}>
      {/* Zoomed-in preview focus */}
      <ScreenRecording
        src="/teaser.mp4"
        crop={{ top: 0.035 }}
        camera={[
          { at: 0, duration: 30, zoom: 2.3, x: 0.52, y: 0.46 },
          { at: 100, duration: 40, zoom: 2.5, x: 0.54, y: 0.48 },
        ]}
        fit="cover"
        mode="dark"
      />

      {/* Top Banner */}
      <div
        style={{
          position: "absolute",
          top: 36,
          left: "50%",
          transform: "translateX(-50%)",
          opacity: bannerOpacity,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 6,
          padding: "14px 28px",
          background: "rgba(26, 27, 38, 0.9)",
          backdropFilter: "blur(16px)",
          border: "1px solid rgba(158, 206, 106, 0.4)",
          borderRadius: 16,
          boxShadow: "0 12px 32px rgba(0, 0, 0, 0.5)",
          fontFamily: "JetBrains Mono, monospace",
          zIndex: 10,
        }}
      >
        <span
          style={{
            color: "#9ece6a",
            fontSize: 22,
            fontWeight: 700,
            letterSpacing: "-0.01em",
          }}
        >
          Live Split-Pane Previews
        </span>
        <span
          style={{
            color: "rgba(192, 202, 245, 0.75)",
            fontSize: 14,
            fontWeight: 400,
          }}
        >
          Rendered Markdown · Syntax-Highlighted Code · PDF Extracts
        </span>
      </div>

      {/* Bottom Highlight Pill */}
      <div
        style={{
          position: "absolute",
          bottom: 36,
          left: "50%",
          transform: "translateX(-50%)",
          padding: "10px 20px",
          background: "rgba(31, 35, 53, 0.95)",
          backdropFilter: "blur(12px)",
          border: "1px solid rgba(125, 207, 255, 0.35)",
          borderRadius: 20,
          fontFamily: "JetBrains Mono, monospace",
          fontSize: 14,
          fontWeight: 500,
          color: "#7dcfff",
          boxShadow: "0 8px 24px rgba(0, 0, 0, 0.4)",
          zIndex: 10,
        }}
      >
        ⚡ Instant Inspection: Zero Application Launch Needed
      </div>
    </AbsoluteFill>
  );
};
