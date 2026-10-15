import React from "react";
import { AbsoluteFill } from "remotion";
import { AgentSteps } from "@/components/snap-cn/agent-steps";

export const LocalEngineScene: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: "#1a1b26" }}>
      <AgentSteps
        query="omnicast query: bookmarks, history, tabs, open windows"
        steps={[
          {
            running: "Scanning Zen, Brave, Chrome SQLite databases…",
            done: "Indexed 14,820 bookmarks & history records",
            icon: "check",
            hold: 0.45,
          },
          {
            running: "Connecting to native Omarchy Wayland LayerShell…",
            done: "Bound to Alt+Space overlay in 1.4ms",
            icon: "check",
            hold: 0.4,
          },
          {
            running: "Verifying local offline execution boundaries…",
            done: "Zero network sockets · 100% on-device",
            icon: "check",
            hold: 0.4,
          },
          {
            running: "Executing FTS5 bm25 full-text ranker…",
            done: "Ranked results ready instantly",
            icon: "check",
            hold: 0.35,
          },
        ]}
        result="⚡ Query completed in 1.8ms"
        queryHold={0.4}
        stepHold={0.32}
        finalHold={0.35}
        paperColor="#1a1b26"
        pillColor="#24283b"
        inkColor="#c0caf5"
        stepColor="#a9b1d6"
        accentColor="#7dcfff"
        glowColor="rgba(122, 162, 247, 0.15)"
        glowRadius={0.55}
        mode="dark"
        speed={1.08}
      />
    </AbsoluteFill>
  );
};
