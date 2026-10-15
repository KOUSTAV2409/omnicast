import React from "react";
import { AbsoluteFill } from "remotion";
import {
  TransitionSeries,
  springTiming,
} from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";

import { KeycapHookScene } from "./scenes/v4/KeycapHookScene";
import { HeroArrivalScene } from "./scenes/v4/HeroArrivalScene";
import { DesktopSimulationScene } from "./scenes/v4/DesktopSimulationScene";
import { PrecisionEngineScene } from "./scenes/v4/PrecisionEngineScene";
import { SuperpowerGridScene } from "./scenes/v4/SuperpowerGridScene";
import { TerminalInstallSceneV4 } from "./scenes/v4/TerminalInstallSceneV4";
import { GrandFinaleScene } from "./scenes/v4/GrandFinaleScene";

/**
 * Editorial cinematic transitions:
 * Fluid spring-eased crossfades and contextual slide-up for desktop summoning.
 */
const fadeTransition = {
  presentation: fade(),
  timing: springTiming({
    durationInFrames: 18,
    config: { damping: 200, mass: 1, stiffness: 120 },
  }),
};

const slideUpTransition = {
  presentation: slide({ direction: "from-bottom" }),
  timing: springTiming({
    durationInFrames: 18,
    config: { damping: 200, mass: 1, stiffness: 120 },
  }),
};

export const OmnicastDemoVideo: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: "#0a0c12" }}>
      <TransitionSeries>
        {/* Beat 1: The Inciting Shortcut (90f / 3.0s) */}
        <TransitionSeries.Sequence durationInFrames={90}>
          <KeycapHookScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...fadeTransition} />

        {/* Beat 2: The Hero Arrival (120f / 4.0s) */}
        <TransitionSeries.Sequence durationInFrames={120}>
          <HeroArrivalScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...slideUpTransition} />

        {/* Beat 3: The True Desktop Simulation & Preview (210f / 7.0s) */}
        <TransitionSeries.Sequence durationInFrames={210}>
          <DesktopSimulationScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...fadeTransition} />

        {/* Beat 4: 0.8ms Local Engine Architecture (150f / 5.0s) */}
        <TransitionSeries.Sequence durationInFrames={150}>
          <PrecisionEngineScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...fadeTransition} />

        {/* Beat 5: The Superpower Grid (180f / 6.0s) */}
        <TransitionSeries.Sequence durationInFrames={180}>
          <SuperpowerGridScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...fadeTransition} />

        {/* Beat 6: One-Line Install & Marketplace Proof (150f / 5.0s) */}
        <TransitionSeries.Sequence durationInFrames={150}>
          <TerminalInstallSceneV4 />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition {...fadeTransition} />

        {/* Beat 7: Grand Finale & Call to Action (120f / 4.0s) */}
        <TransitionSeries.Sequence durationInFrames={120}>
          <GrandFinaleScene />
        </TransitionSeries.Sequence>
      </TransitionSeries>
    </AbsoluteFill>
  );
};
