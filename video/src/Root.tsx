import React from "react";
import { Composition } from "remotion";
import { OmnicastDemoVideo } from "./Composition";

// Act 1: 90 + 150 = 240
// Act 2: 135 + 120 + 150 + 135 = 540
// Act 3: 90 + 180 + 80 = 350
// Sum of scenes = 1130 frames
// Minus 8 slide transitions * 18 frames overlap = 144 frames
// Total duration = 986 frames (~32.87 seconds at 30fps)
export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="OmnicastDemo"
        component={OmnicastDemoVideo}
        durationInFrames={986}
        fps={30}
        width={1280}
        height={720}
      />
    </>
  );
};
