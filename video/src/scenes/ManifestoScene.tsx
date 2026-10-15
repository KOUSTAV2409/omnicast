import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export const ManifestoScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // 3 distinct 50-frame beats
  // Beat 1: frames 0-48
  // Beat 2: frames 49-98
  // Beat 3: frames 99-150

  const activeBeat = frame < 50 ? 1 : frame < 100 ? 2 : 3;

  // Local frame within each beat
  const beatFrame =
    activeBeat === 1 ? frame : activeBeat === 2 ? frame - 50 : frame - 100;

  const cardSpring = spring({
    frame: beatFrame,
    fps,
    config: { damping: 15, mass: 0.8, stiffness: 120 },
  });

  const cardExit =
    beatFrame > 40
      ? interpolate(beatFrame, [40, 50], [1, 0], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
        })
      : 1;

  const opacity = Math.min(cardSpring, cardExit);
  const scale =
    interpolate(cardSpring, [0, 1], [0.92, 1]) *
    (beatFrame > 40 ? interpolate(beatFrame, [40, 50], [1, 1.05]) : 1);

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#0d1017",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        overflow: "hidden",
        fontFamily: "Inter, -apple-system, BlinkMacSystemFont, sans-serif",
      }}
    >
      {/* Dynamic ambient colored glow per beat */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          transform: "translate(-50%, -50%)",
          width: 700,
          height: 450,
          background:
            activeBeat === 1
              ? "radial-gradient(circle, rgba(158, 206, 106, 0.15) 0%, transparent 70%)"
              : activeBeat === 2
                ? "radial-gradient(circle, rgba(125, 207, 255, 0.16) 0%, transparent 70%)"
                : "radial-gradient(circle, rgba(187, 154, 247, 0.16) 0%, transparent 70%)",
          filter: "blur(60px)",
          pointerEvents: "none",
        }}
      />

      {/* Flagship Manifesto Card */}
      <div
        style={{
          width: 820,
          backgroundColor: "rgba(17, 20, 32, 0.92)",
          backdropFilter: "blur(20px)",
          border: `1px solid ${
            activeBeat === 1
              ? "rgba(158, 206, 106, 0.3)"
              : activeBeat === 2
                ? "rgba(125, 207, 255, 0.3)"
                : "rgba(187, 154, 247, 0.3)"
          }`,
          borderRadius: 20,
          padding: "40px 48px",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          textAlign: "center",
          boxShadow: `0 25px 60px rgba(0, 0, 0, 0.6), 0 0 45px ${
            activeBeat === 1
              ? "rgba(158, 206, 106, 0.1)"
              : activeBeat === 2
                ? "rgba(125, 207, 255, 0.1)"
                : "rgba(187, 154, 247, 0.1)"
          }`,
          opacity: Math.max(0, opacity),
          transform: `scale(${scale})`,
        }}
      >
        {/* Top Tag Pill */}
        <div
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: 8,
            padding: "6px 16px",
            borderRadius: 20,
            backgroundColor:
              activeBeat === 1
                ? "rgba(158, 206, 106, 0.12)"
                : activeBeat === 2
                  ? "rgba(125, 207, 255, 0.12)"
                  : "rgba(187, 154, 247, 0.12)",
            color:
              activeBeat === 1
                ? "#9ece6a"
                : activeBeat === 2
                  ? "#7dcfff"
                  : "#bb9af7",
            fontSize: 12,
            fontWeight: 700,
            textTransform: "uppercase",
            letterSpacing: "0.14em",
            fontFamily: "'JetBrains Mono', monospace",
            marginBottom: 20,
          }}
        >
          <span>{activeBeat === 1 ? "🔒" : activeBeat === 2 ? "⚡" : "✓"}</span>
          <span>
            {activeBeat === 1
              ? "Strict Privacy"
              : activeBeat === 2
                ? "Ultra-Low Latency"
                : "Community Verified"}
          </span>
        </div>

        {/* Main Headline */}
        <div
          style={{
            fontSize: 48,
            fontWeight: 800,
            letterSpacing: "-0.03em",
            color: "#ffffff",
            marginBottom: 16,
            lineHeight: 1.15,
          }}
        >
          {activeBeat === 1 && (
            <span>
              100% Offline.{" "}
              <span style={{ color: "#9ece6a" }}>Zero Telemetry.</span>
            </span>
          )}
          {activeBeat === 2 && (
            <span>
              Sub-Millisecond.{" "}
              <span style={{ color: "#7dcfff" }}>Local FTS5 SQLite.</span>
            </span>
          )}
          {activeBeat === 3 && (
            <span>
              Approved on{" "}
              <span style={{ color: "#bb9af7" }}>Omarchy Marketplace.</span>
            </span>
          )}
        </div>

        {/* Supporting Narrative */}
        <div
          style={{
            fontSize: 18,
            color: "#9aa5ce",
            maxWidth: 620,
            lineHeight: 1.5,
          }}
        >
          {activeBeat === 1 &&
            "Your keystrokes, bookmarks, and configs never leave your machine. No background telemetry sockets."}
          {activeBeat === 2 &&
            "Embedded C-level SQLite engine with BM25 ranker parses queries and renders results in under 1ms."}
          {activeBeat === 3 &&
            "Security audited, open source, and natively integrated with Hyprland and Wayland layer shells."}
        </div>
      </div>
    </AbsoluteFill>
  );
};
