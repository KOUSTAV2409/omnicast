import React from "react";
import { Composition } from "remotion";
import { OmnicastDemoVideo } from "./Composition";

// Omnicast Launch Video v4 (Flagship)
// Scene 1 (Keycap Hook): 90
// Scene 2 (Hero Arrival): 120
// Scene 3 (Desktop Simulation & Markdown Preview): 210
// Scene 4 (Precision Engine 0.8ms): 150
// Scene 5 (Superpower Grid): 180
// Scene 6 (One-Line Install & Marketplace): 150
// Scene 7 (Grand Finale & CTA): 120
// Total scene frames = 1020 frames
// Minus 6 transitions * 18 frames overlap = 108 frames
// Net duration = 912 frames (~30.40 seconds at 30fps)
export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="OmnicastDemo"
        component={OmnicastDemoVideo}
        durationInFrames={912}
        fps={30}
        width={1280}
        height={720}
      />
    </>
  );
};
