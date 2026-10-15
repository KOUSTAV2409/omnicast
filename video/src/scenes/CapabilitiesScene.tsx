import React from "react";
import { AbsoluteFill } from "remotion";
import { StatusCycle } from "@/components/snap-cn/status-cycle";

export const CapabilitiesScene: React.FC = () => {
  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#0d1017",
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
        fieldColor="#141824"
        pageColor="#0d1017"
        pillColor="#1f2335"
        pillLabelColor="#7dcfff"
        prefixColor="#c0caf5"
        chipFills={["#161b26", "#1c2230", "#141824"]}
        chipTextColor="#c0caf5"
        chipBorderColor="rgba(122, 162, 247, 0.25)"
        fontWeight={600}
        chipFontWeight={400}
        speed={1.15}
        mode="dark"
      />
    </AbsoluteFill>
  );
};
