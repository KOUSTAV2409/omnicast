import React from "react";
import { AbsoluteFill } from "remotion";
import {
  TransitionSeries,
  springTiming,
} from "@remotion/transitions";
import { slide } from "@remotion/transitions/slide";

import { ColdOpenHookScene } from "./scenes/ColdOpenHookScene";
import { AnnounceIntroScene } from "./scenes/AnnounceIntroScene";
import { CommandPaletteDemoScene } from "./scenes/CommandPaletteDemoScene";
import { LocalEngineScene } from "./scenes/LocalEngineScene";
import { CapabilitiesScene } from "./scenes/CapabilitiesScene";
import { ManifestoScene } from "./scenes/ManifestoScene";
import { SocialProofScene } from "./scenes/SocialProofScene";
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
        {/* Act 1 - Beat 1: Cold Open Hook (90f / 3.0s) */}
        <TransitionSeries.Sequence durationInFrames={90}>
          <ColdOpenHookScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...slideTransition} />

        {/* Act 1 - Beat 2: Hero Reveal (150f / 5.0s) */}
        <TransitionSeries.Sequence durationInFrames={150}>
          <AnnounceIntroScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...slideTransition} />

        {/* Act 2 - Beat 3: The Omnicast Command Palette in Action (135f / 4.5s) */}
        <TransitionSeries.Sequence durationInFrames={135}>
          <CommandPaletteDemoScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...slideTransition} />

        {/* Act 2 - Beat 4: Engine Under the Hood (120f / 4.0s) */}
        <TransitionSeries.Sequence durationInFrames={120}>
          <LocalEngineScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...slideTransition} />

        {/* Act 2 - Beat 5: Security Sandboxing & Manifesto Cards (150f / 5.0s) */}
        <TransitionSeries.Sequence durationInFrames={150}>
          <ManifestoScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...slideTransition} />

        {/* Act 2 - Beat 6: Capabilities & Status Cycle (135f / 4.5s) */}
        <TransitionSeries.Sequence durationInFrames={135}>
          <CapabilitiesScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...slideTransition} />

        {/* Act 3 - Beat 7: Social Proof & Marketplace Verification (90f / 3.0s) */}
        <TransitionSeries.Sequence durationInFrames={90}>
          <SocialProofScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...slideTransition} />

        {/* Act 3 - Beat 8: Terminal One-Line Install & Call to Action (180f / 6.0s) */}
        <TransitionSeries.Sequence durationInFrames={180}>
          <TerminalInstallScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...slideTransition} />

        {/* Act 3 - Beat 9: Signature Wordmark Cut Outro & Final Launch Card (80f / 2.67s) */}
        <TransitionSeries.Sequence durationInFrames={80}>
          <OutroWordmarkScene />
        </TransitionSeries.Sequence>
      </TransitionSeries>
    </AbsoluteFill>
  );
};
