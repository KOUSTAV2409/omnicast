import React from "react";
import { Composition } from "remotion";
import { OmnicastDemoVideo } from "./Composition";

// Act 1: 90 + 150 = 240
// Act 2: 135 + 120 + 150 + 135 = 540
// Act 3: 90 + 180 + 60 = 330
// Sum of scenes = 1110 frames
// Minus 8 slide transitions * 18 frames overlap = 144 frames
// Total duration = 966 frames (~32.2 seconds at 30fps)
// Round to 972 frames for clean 32.4s buffer
export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="OmnicastDemo"
        component={OmnicastDemoVideo}
        durationInFrames={966}
        fps={30}
        width={1280}
        height={720}
      />
    </>
  );
};
