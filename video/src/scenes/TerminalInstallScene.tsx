import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { TerminalSimulator } from "@/components/snap-cn/terminal-simulator";
import { omnicastTheme } from "../theme";

export const TerminalInstallScene: React.FC = () => {
  const frame = useCurrentFrame();

  const ctaOpacity = interpolate(frame, [110, 135], [0, 1], {
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
        intro="*Install* in *one line.*"
        command={{
          managers: ["omarchy", "curl"],
          text: "omarchy plugin add omnicast",
        }}
        lines={[
          { text: "Verifying Omarchy environment...", type: "log", pause: 2 },
          { text: "✓ Installed omnicast plugin", type: "success", pause: 2 },
          { text: "✓ Bound Alt+Space keybind", type: "success", pause: 2 },
          { text: "Ready. Launch with Alt+Space", type: "command" },
        ]}
        fontSize={12}
        charsPerFrame={5.5}
        chunkSize={4}
        zoom={{ enabled: true, scale: 0.82 }}
        speed={1.38}
        mode="dark"
        theme={omnicastTheme}
      />

      {/* Modern bottom pill CTA that lands with the finished install */}
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
