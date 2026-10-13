import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { TerminalSimulator } from "@/components/snap-cn/terminal-simulator";
import { omnicastTheme } from "../theme";

export const TerminalInstallScene: React.FC = () => {
  const frame = useCurrentFrame();

  const ctaOpacity = interpolate(frame, [140, 175], [0, 1], {
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
        intro={null}
        command={{
          managers: ["omarchy", "bash"],
          text: "curl -fsSL https://omnicast.best/install | bash",
        }}
        lines={[
          { text: "Verifying Omarchy Hyprland environment...", type: "log", pause: 6 },
          { text: "✓ Installed to ~/.local/share/omnicast", type: "success", pause: 6 },
          { text: "✓ Configured Alt+Space in ~/.config/hypr/bindings.lua", type: "success", pause: 8 },
          { text: "Ready. Launch Omnicast with Alt+Space.", type: "command" },
        ]}
        zoom={false}
        mode="dark"
        theme={omnicastTheme}
      />

      {/* Modern pill CTA */}
      <div
        style={{
          position: "absolute",
          bottom: 34,
          left: "50%",
          transform: "translateX(-50%)",
          opacity: ctaOpacity,
          display: "flex",
          alignItems: "center",
          gap: 20,
          padding: "10px 24px",
          background: "rgba(31, 35, 53, 0.95)",
          backdropFilter: "blur(14px)",
          border: "1px solid rgba(122, 162, 247, 0.35)",
          borderRadius: 24,
          boxShadow: "0 8px 30px rgba(0, 0, 0, 0.5)",
          zIndex: 20,
        }}
      >
        <span style={{ color: "#7dcfff", fontSize: 16, fontWeight: 700 }}>
          omnicast.best
        </span>
        <span style={{ color: "#565f89" }}>•</span>
        <span style={{ color: "#9ece6a", fontSize: 15, fontWeight: 600 }}>
          omarchyplugins.com
        </span>
        <span style={{ color: "#565f89" }}>•</span>
        <span style={{ color: "#c0caf5", fontSize: 14 }}>
          github.com/KOUSTAV2409/omnicast
        </span>
      </div>
    </AbsoluteFill>
  );
};
