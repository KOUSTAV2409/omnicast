import React from "react";
import { AbsoluteFill } from "remotion";
import { WordmarkCut } from "@/components/snap-cn/wordmark-cut";
import { omnicastTheme } from "../theme";

export const OutroWordmarkScene: React.FC = () => {
  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#1a1b26",
        fontFamily: "JetBrains Mono, monospace",
      }}
    >
      <WordmarkCut
        word="omnicast."
        dotFrom="#7dcfff"
        dotTo="#9ece6a"
        warm={1}
        mode="dark"
        theme={omnicastTheme}
      />
    </AbsoluteFill>
  );
};
