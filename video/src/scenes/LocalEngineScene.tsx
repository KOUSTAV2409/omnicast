import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export const LocalEngineScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const entrance = spring({
    frame,
    fps,
    config: { damping: 16, mass: 0.9, stiffness: 100 },
  });

  const step1 = spring({ frame: frame - 18, fps, config: { damping: 15 } });
  const step2 = spring({ frame: frame - 32, fps, config: { damping: 15 } });
  const step3 = spring({ frame: frame - 46, fps, config: { damping: 15 } });
  const step4 = spring({ frame: frame - 60, fps, config: { damping: 15 } });

  const badgeSpring = spring({
    frame: frame - 78,
    fps,
    config: { damping: 14, mass: 0.8, stiffness: 120 },
  });

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
      {/* Background glow */}
      <div
        style={{
          position: "absolute",
          top: "45%",
          left: "50%",
          transform: "translate(-50%, -50%)",
          width: 850,
          height: 450,
          background:
            "radial-gradient(circle, rgba(122, 162, 247, 0.12) 0%, rgba(125, 207, 255, 0.04) 50%, transparent 75%)",
          filter: "blur(55px)",
          pointerEvents: "none",
        }}
      />

      {/* Eyebrow and Section Headline */}
      <div
        style={{
          textAlign: "center",
          marginBottom: 26,
          opacity: Math.max(0, Math.min(1, entrance)),
          transform: `translateY(${interpolate(entrance, [0, 1], [-12, 0])}px)`,
        }}
      >
        <div
          style={{
            fontSize: 12,
            fontWeight: 700,
            color: "#7dcfff",
            textTransform: "uppercase",
            letterSpacing: "0.15em",
            fontFamily: "'JetBrains Mono', monospace",
            marginBottom: 8,
          }}
        >
          Performance Architecture
        </div>
        <div
          style={{
            fontSize: 34,
            fontWeight: 800,
            color: "#ffffff",
            letterSpacing: "-0.03em",
          }}
        >
          Sub-millisecond.{" "}
          <span
            style={{
              background: "linear-gradient(135deg, #7dcfff 0%, #7aa2f7 100%)",
              WebkitBackgroundClip: "text",
              WebkitTextFillColor: "transparent",
            }}
          >
            Zero network latency.
          </span>
        </div>
      </div>

      {/* Main Metric Cards Grid */}
      <div
        style={{
          width: 880,
          display: "flex",
          gap: 16,
          marginBottom: 16,
          opacity: Math.max(0, Math.min(1, entrance)),
          transform: `scale(${interpolate(
            entrance,
            [0, 1],
            [0.95, 1]
          )}) translateY(${interpolate(entrance, [0, 1], [15, 0])}px)`,
        }}
      >
        {/* Metric 1 */}
        <div
          style={{
            flex: 1,
            backgroundColor: "rgba(17, 20, 32, 0.9)",
            backdropFilter: "blur(16px)",
            border: "1px solid rgba(125, 207, 255, 0.2)",
            borderRadius: 14,
            padding: "18px 20px",
            boxShadow: "0 15px 35px rgba(0, 0, 0, 0.4)",
          }}
        >
          <div
            style={{
              fontSize: 32,
              fontWeight: 800,
              color: "#7dcfff",
              fontFamily: "'JetBrains Mono', monospace",
              marginBottom: 4,
            }}
          >
            0.8 ms
          </div>
          <div style={{ fontSize: 13, fontWeight: 600, color: "#ffffff" }}>
            Query Execution
          </div>
          <div style={{ fontSize: 12, color: "#565f89", marginTop: 2 }}>
            FTS5 BM25 ranked
          </div>
        </div>

        {/* Metric 2 */}
        <div
          style={{
            flex: 1,
            backgroundColor: "rgba(17, 20, 32, 0.9)",
            backdropFilter: "blur(16px)",
            border: "1px solid rgba(158, 206, 106, 0.25)",
            borderRadius: 14,
            padding: "18px 20px",
            boxShadow: "0 15px 35px rgba(0, 0, 0, 0.4)",
          }}
        >
          <div
            style={{
              fontSize: 32,
              fontWeight: 800,
              color: "#9ece6a",
              fontFamily: "'JetBrains Mono', monospace",
              marginBottom: 4,
            }}
          >
            100%
          </div>
          <div style={{ fontSize: 13, fontWeight: 600, color: "#ffffff" }}>
            Offline & Private
          </div>
          <div style={{ fontSize: 12, color: "#565f89", marginTop: 2 }}>
            Zero telemetry sockets
          </div>
        </div>

        {/* Metric 3 */}
        <div
          style={{
            flex: 1,
            backgroundColor: "rgba(17, 20, 32, 0.9)",
            backdropFilter: "blur(16px)",
            border: "1px solid rgba(187, 154, 247, 0.25)",
            borderRadius: 14,
            padding: "18px 20px",
            boxShadow: "0 15px 35px rgba(0, 0, 0, 0.4)",
          }}
        >
          <div
            style={{
              fontSize: 32,
              fontWeight: 800,
              color: "#bb9af7",
              fontFamily: "'JetBrains Mono', monospace",
              marginBottom: 4,
            }}
          >
            60 FPS
          </div>
          <div style={{ fontSize: 13, fontWeight: 600, color: "#ffffff" }}>
            Wayland Native
          </div>
          <div style={{ fontSize: 12, color: "#565f89", marginTop: 2 }}>
            Hardware LayerShell
          </div>
        </div>
      </div>

      {/* Execution Pipeline Trace Card */}
      <div
        style={{
          width: 880,
          backgroundColor: "rgba(13, 16, 23, 0.92)",
          backdropFilter: "blur(16px)",
          border: "1px solid rgba(255, 255, 255, 0.08)",
          borderRadius: 14,
          padding: "16px 22px",
          fontFamily: "'JetBrains Mono', monospace",
          fontSize: 13,
          display: "flex",
          flexDirection: "column",
          gap: 10,
        }}
      >
        <div
          style={{
            opacity: Math.max(0, Math.min(1, step1)),
            transform: `translateX(${interpolate(step1, [0, 1], [-8, 0])}px)`,
            display: "flex",
            alignItems: "center",
            gap: 12,
            color: "#c0caf5",
          }}
        >
          <span style={{ color: "#7dcfff", fontWeight: 700 }}>0.1ms</span>
          <span style={{ color: "#565f89" }}>│</span>
          <span>Parsed search terms: tokenized with Unicode61 tokenizer</span>
        </div>

        <div
          style={{
            opacity: Math.max(0, Math.min(1, step2)),
            transform: `translateX(${interpolate(step2, [0, 1], [-8, 0])}px)`,
            display: "flex",
            alignItems: "center",
            gap: 12,
            color: "#c0caf5",
          }}
        >
          <span style={{ color: "#7dcfff", fontWeight: 700 }}>0.3ms</span>
          <span style={{ color: "#565f89" }}>│</span>
          <span>Scanned local SQLite FTS5 table across 14,800+ records</span>
        </div>

        <div
          style={{
            opacity: Math.max(0, Math.min(1, step3)),
            transform: `translateX(${interpolate(step3, [0, 1], [-8, 0])}px)`,
            display: "flex",
            alignItems: "center",
            gap: 12,
            color: "#c0caf5",
          }}
        >
          <span style={{ color: "#7dcfff", fontWeight: 700 }}>0.5ms</span>
          <span style={{ color: "#565f89" }}>│</span>
          <span>BM25 relevance scoring and fuzzy distance calculation</span>
        </div>

        <div
          style={{
            opacity: Math.max(0, Math.min(1, step4)),
            transform: `translateX(${interpolate(step4, [0, 1], [-8, 0])}px)`,
            display: "flex",
            alignItems: "center",
            gap: 12,
            color: "#9ece6a",
            fontWeight: 600,
          }}
        >
          <span>0.8ms</span>
          <span style={{ color: "#565f89" }}>│</span>
          <span>Rendered complete result set to Wayland LayerShell</span>
        </div>
      </div>

      {/* Floating Status Badge */}
      <div
        style={{
          marginTop: 18,
          opacity: Math.max(0, Math.min(1, badgeSpring)),
          transform: `scale(${interpolate(badgeSpring, [0, 1], [0.92, 1])})`,
          padding: "6px 18px",
          borderRadius: 20,
          backgroundColor: "rgba(125, 207, 255, 0.1)",
          border: "1px solid rgba(125, 207, 255, 0.3)",
          color: "#7dcfff",
          fontSize: 12,
          fontWeight: 700,
          fontFamily: "'JetBrains Mono', monospace",
          display: "flex",
          alignItems: "center",
          gap: 8,
        }}
      >
        <span style={{ fontSize: 13 }}>⚡</span>
        <span>Average Query Response: 0.8ms on Omarchy</span>
      </div>
    </AbsoluteFill>
  );
};
