import React from "react";
import { AbsoluteFill } from "remotion";
import { PunchLines } from "@/components/snap-cn/punch-lines";
import { omnicastTheme } from "../theme";

export const ManifestoScene: React.FC = () => {
  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#1a1b26",
        fontFamily: "JetBrains Mono, monospace",
      }}
    >
      <PunchLines
        script="100% Offline. / Zero telemetry. | Sub-millisecond / local FTS5 SQLite. | Approved on / Omarchy Marketplace."
        styles="slide,punch,slide"
        sizes="1.1,1.25,1.1"
        holds="50,55,55"
        lead={4}
        ground="#1a1b26"
        ink="#c0caf5"
        accentColor="#7dcfff"
        accentBeat={2}
        theme={omnicastTheme}
        mode="dark"
      />
    </AbsoluteFill>
  );
};
