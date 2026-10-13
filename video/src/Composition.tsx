import React from "react";
import { Composition, Series } from "remotion";
import { IntroScene } from "./scenes/IntroScene";
import { SearchScene } from "./scenes/SearchScene";
import { PreviewScene } from "./scenes/PreviewScene";
import { SecurityScene } from "./scenes/SecurityScene";
import { OutroScene } from "./scenes/OutroScene";

export const OmnicastDemoVideo: React.FC = () => {
  return (
    <Series>
      {/* Beat 1: Intro Hook & Branding */}
      <Series.Sequence durationInFrames={100}>
        <IntroScene />
      </Series.Sequence>

      {/* Beat 2: Core Search Experience */}
      <Series.Sequence durationInFrames={220}>
        <SearchScene />
      </Series.Sequence>

      {/* Beat 3: Live Split-Pane Previews */}
      <Series.Sequence durationInFrames={200}>
        <PreviewScene />
      </Series.Sequence>

      {/* Beat 4: Security Sandboxing & Marketplace Approval */}
      <Series.Sequence durationInFrames={150}>
        <SecurityScene />
      </Series.Sequence>

      {/* Beat 5: Outro & Terminal 1-Line Installer */}
      <Series.Sequence durationInFrames={230}>
        <OutroScene />
      </Series.Sequence>
    </Series>
  );
};

export const MyComposition: React.FC = () => {
  return (
    <Composition
      id="OmnicastDemo"
      component={OmnicastDemoVideo}
      durationInFrames={900}
      fps={30}
      width={1920}
      height={1080}
    />
  );
};
