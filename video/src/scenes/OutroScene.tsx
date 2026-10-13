import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { TerminalSimulator } from "@/components/snap-cn/terminal-simulator";
import { omnicastTheme } from "../theme";

export const OutroScene: React.FC = () => {
  const frame = useCurrentFrame();

  const ctaOpacity = interpolate(frame, [140, 170], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#1a1b26",
        fontFamily: "JetBrains Mono, monospace",
      }}
    >
      <TerminalSimulator
        intro="*Install* in one line"
        command={{
          managers: ["bash", "plugin"],
          text: "curl -fsSL https://omnicast.best/install | bash",
        }}
        lines={[
          { text: "Checking Omarchy environment...", type: "log", pause: 8 },
          { text: "✓ Installed to ~/.local/share/omnicast", type: "success", pause: 8 },
          { text: "✓ Bound Alt+Space in Hyprland bindings", type: "success", pause: 12 },
          { text: "Ready. Press Alt+Space to launch Omnicast.", type: "command" },
        ]}
        mode="dark"
        theme={omnicastTheme}
      />

      {/* Outro Callout */}
      <div
        style={{
          position: "absolute",
          bottom: 30,
          left: "50%",
          transform: "translateX(-50%)",
          opacity: ctaOpacity,
          display: "flex",
          alignItems: "center",
          gap: 24,
          padding: "12px 28px",
          background: "rgba(31, 35, 53, 0.95)",
          backdropFilter: "blur(14px)",
          border: "1px solid rgba(122, 162, 247, 0.4)",
          borderRadius: 24,
          boxShadow: "0 8px 32px rgba(0, 0, 0, 0.5)",
          zIndex: 20,
        }}
      >
        <span style={{ color: "#7dcfff", fontSize: 16, fontWeight: 700 }}>
          omnicast.best
        </span>
        <span style={{ color: "#565f89" }}>•</span>
        <span style={{ color: "#9ece6a", fontSize: 16, fontWeight: 600 }}>
          omarchyplugins.com
        </span>
        <span style={{ color: "#565f89" }}>•</span>
        <span style={{ color: "rgba(192, 202, 245, 0.8)", fontSize: 15 }}>
          First Manhattan, then Berlin.
        </span>
      </div>
    </AbsoluteFill>
  );
};
