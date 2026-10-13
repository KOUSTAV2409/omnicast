import React from "react";
import { Composition } from "remotion";
import { OmnicastDemoVideo } from "./Composition";

// 170 + 180 + 150 + 160 + 200 + 66 = 926 frames
// Minus 5 transitions * 18 frames overlap = 90 frames
// Total duration = 836 frames (~27.86 seconds at 30fps)
export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="OmnicastDemo"
        component={OmnicastDemoVideo}
        durationInFrames={836}
        fps={30}
        width={1280}
        height={720}
      />
    </>
  );
};
