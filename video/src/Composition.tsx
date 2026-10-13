import React from "react";
import { AbsoluteFill } from "remotion";
import {
  TransitionSeries,
  springTiming,
} from "@remotion/transitions";
import { slide } from "@remotion/transitions/slide";

import { AnnounceIntroScene } from "./scenes/AnnounceIntroScene";
import { SearchInteractiveScene } from "./scenes/SearchInteractiveScene";
import { LocalEngineScene } from "./scenes/LocalEngineScene";
import { CapabilitiesScene } from "./scenes/CapabilitiesScene";
import { ManifestoScene } from "./scenes/ManifestoScene";
import { TerminalInstallScene } from "./scenes/TerminalInstallScene";
import { OutroWordmarkScene } from "./scenes/OutroWordmarkScene";

/**
 * Slide transition with critically damped spring:
 * No double-inked fades, crisp cinematic separation between beats.
 */
const slideTransition = {
  presentation: slide(),
  timing: springTiming({
    durationInFrames: 18,
    config: { damping: 200, mass: 1, stiffness: 120 },
  }),
};

export const OmnicastDemoVideo: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: "#1a1b26" }}>
      <TransitionSeries>
        {/* Beat 1: Launch Announcement (Natural length: 170f) */}
        <TransitionSeries.Sequence durationInFrames={170}>
          <AnnounceIntroScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...slideTransition} />

        {/* Beat 2: Interactive Real-Time Search Typing (160f) */}
        <TransitionSeries.Sequence durationInFrames={160}>
          <SearchInteractiveScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...slideTransition} />

        {/* Beat 3: Local Offline Engine & Instant Indexing Steps (150f) */}
        <TransitionSeries.Sequence durationInFrames={150}>
          <LocalEngineScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...slideTransition} />

        {/* Beat 4: Capabilities & Status Cycle (150f) */}
        <TransitionSeries.Sequence durationInFrames={150}>
          <CapabilitiesScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...slideTransition} />

        {/* Beat 5: Security Sandboxing & Manifesto Cards (160f) */}
        <TransitionSeries.Sequence durationInFrames={160}>
          <ManifestoScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...slideTransition} />

        {/* Beat 6: Terminal One-Line Install & Call to Action (200f) */}
        <TransitionSeries.Sequence durationInFrames={200}>
          <TerminalInstallScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...slideTransition} />

        {/* Beat 7: Signature Wordmark Cut Outro (66f) */}
        <TransitionSeries.Sequence durationInFrames={66}>
          <OutroWordmarkScene />
        </TransitionSeries.Sequence>
      </TransitionSeries>
    </AbsoluteFill>
  );
};
