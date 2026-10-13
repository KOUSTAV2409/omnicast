import React from "react";
import { AbsoluteFill } from "remotion";
import { AnnounceTitle } from "@/components/snap-cn/announce-title";

// Omnicast brand: Tokyo Night / Omarchy Cyan & Emerald
export const AnnounceIntroScene: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: "#1a1b26" }}>
      <AnnounceTitle
        eyebrow="Introducing"
        title="Omnicast"
        tagline="Raycast-grade speed. Native to Omarchy."
        voidColor="#16161e"
        fieldColor="#1a1b26"
        paperColor="#1f2335"
        titleColor="#7dcfff"
        nightColor="#1a1b26"
        glowColor="#7aa2f7"
        glowStrength={0.16}
        taglineColor="#c0caf5"
        inkColor="#f7768e"
        symbolPath="M 50 15 A 35 35 0 1 0 50 85 A 35 35 0 1 0 50 15 Z M 50 28 A 22 22 0 1 1 50 72 A 22 22 0 1 1 50 28 Z"
        symbolColors={["#7dcfff", "#7aa2f7", "#9ece6a"]}
        symbolScale={1.15}
      />
    </AbsoluteFill>
  );
};
