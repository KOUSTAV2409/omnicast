import React from "react";
import { Composition } from "remotion";
import { OmnicastDemoVideo } from "./Composition";

// 170 + 160 + 150 + 150 + 160 + 240 + 66 = 1096 frames
// Minus 6 transitions * 18 frames overlap = 108 frames
// Total duration = 988 frames (32.93 seconds at 30fps)
export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="OmnicastDemo"
        component={OmnicastDemoVideo}
        durationInFrames={988}
        fps={30}
        width={1280}
        height={720}
      />
    </>
  );
};
