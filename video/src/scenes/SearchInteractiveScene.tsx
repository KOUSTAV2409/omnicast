import React from "react";
import { AbsoluteFill } from "remotion";
import { SearchTyping } from "@/components/snap-cn/search-typing";

export const SearchInteractiveScene: React.FC = () => {
  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#1a1b26",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        overflow: "hidden",
      }}
    >
      <SearchTyping
        text="hyprland window bindings config"
        charsPerSecond={22}
        humanize={0.25}
        wordPause={1.1}
        punctuationPause={1.4}
        startDelay={0.3}
        dollyDuration={0.7}
        panDuration={0.5}
        holdAfter={0.8}
        recedeDuration={0.8}
        dolly={1.2}
        fieldHeight={0.24}
        frontVisible={0.65}
        edgeInset={48}
        caret={true}
        surface="shadcn"
        mode="dark"
        icon="search"
        fontWeight={500}
        seed="omnicast-search-speed"
        speed={1.05}
      />

      {/* Floating Tokyo Night pill badge */}
      <div
        style={{
          position: "absolute",
          bottom: 36,
          left: "50%",
          transform: "translateX(-50%)",
          display: "flex",
          alignItems: "center",
          gap: 12,
          padding: "8px 20px",
          background: "rgba(22, 22, 30, 0.9)",
          backdropFilter: "blur(12px)",
          border: "1px solid rgba(122, 162, 247, 0.25)",
          borderRadius: 20,
          fontFamily: "JetBrains Mono, monospace",
          zIndex: 10,
        }}
      >
        <span style={{ color: "#7dcfff", fontSize: 14, fontWeight: 600 }}>
          Alt + Space
        </span>
        <span style={{ color: "#565f89" }}>|</span>
        <span style={{ color: "#a9b1d6", fontSize: 13 }}>
          Sub-millisecond FTS5 search across all browsers
        </span>
      </div>
    </AbsoluteFill>
  );
};
