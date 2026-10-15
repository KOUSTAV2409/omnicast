import React from "react";
import { AbsoluteFill } from "remotion";
import { StatusCycle } from "@/components/snap-cn/status-cycle";

export const CapabilitiesScene: React.FC = () => {
  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#1a1b26",
        fontFamily: "JetBrains Mono, monospace",
      }}
    >
      <StatusCycle
        prefix="Omnicast is"
        statuses={[
          "local search",
          "instant preview",
          "clipboard history",
          "zero telemetry",
          "native Wayland",
        ]}
        chips={[
          "FTS5 SQLite Index",
          "Markdown Quick View",
          "Omarchy Theme Match",
          "Hyprland LayerShell",
          "100% Offline Engine",
          "Script Runner Sandbox",
        ]}
        fieldColor="#16161e"
        pageColor="#1a1b26"
        pillColor="#24283b"
        pillLabelColor="#7dcfff"
        prefixColor="#c0caf5"
        chipFills={["#1f2335", "#24283b", "#16161e"]}
        chipTextColor="#c0caf5"
        chipBorderColor="rgba(122, 162, 247, 0.3)"
        fontWeight={600}
        chipFontWeight={400}
        speed={1.1}
      />
    </AbsoluteFill>
  );
};
