import React from "react";
import { AbsoluteFill } from "remotion";
import { PunchLines } from "@/components/snap-cn/punch-lines";

export const SecurityScene: React.FC = () => {
  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#1a1b26",
        fontFamily: "JetBrains Mono, monospace",
      }}
    >
      <PunchLines
        script="Zero /proc Leakage / Stdin Streaming | Protected Credentials / Secrets & SSH Keys Shielded | Marketplace Verified / omarchyplugins.com"
        styles="slide,punch,punch"
        holds="50,50,50"
        accentBeat={3}
        fontSize={50}
        mode="dark"
      />
    </AbsoluteFill>
  );
};
