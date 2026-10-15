import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export const PrecisionEngineScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Entrance spring
  const entrance = spring({
    frame,
    fps,
    config: { damping: 16, mass: 0.9, stiffness: 100 },
  });

  // Precision microsecond timer simulation
  // counts from 0.00ms to 0.80ms between frames 15 and 65
  const rawMs = interpolate(frame, [15, 65], [0.0, 0.8], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const formattedMs = rawMs.toFixed(2);
  const isLocked = frame >= 65;

  // Staggered pipeline steps
  const step1 = spring({ frame: frame - 22, fps, config: { damping: 15 } });
  const step2 = spring({ frame: frame - 38, fps, config: { damping: 15 } });
  const step3 = spring({ frame: frame - 54, fps, config: { damping: 15 } });
  const step4 = spring({ frame: frame - 70, fps, config: { damping: 15 } });

  // Bottom badge spring
  const badgeSpring = spring({
    frame: frame - 85,
    fps,
    config: { damping: 14, mass: 0.8, stiffness: 120 },
  });

  // Exit transition
  const exitOpacity = interpolate(frame, [135, 150], [1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#0a0c12",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        overflow: "hidden",
        opacity: exitOpacity,
        fontFamily: "Inter, -apple-system, BlinkMacSystemFont, sans-serif",
      }}
    >
      {/* Background radial glow */}
      <div
        style={{
          position: "absolute",
          top: "45%",
          left: "50%",
          transform: "translate(-50%, -50%)",
          width: 900,
          height: 480,
          background:
            "radial-gradient(circle, rgba(125, 207, 255, 0.15) 0%, rgba(122, 162, 247, 0.04) 50%, transparent 75%)",
          filter: "blur(60px)",
          pointerEvents: "none",
        }}
      />

      {/* Eyebrow & Headline */}
      <div
        style={{
          textAlign: "center",
          marginBottom: 24,
          opacity: Math.max(0, Math.min(1, entrance)),
          transform: `translateY(${interpolate(entrance, [0, 1], [-14, 0])}px)`,
        }}
      >
        <div
          style={{
            fontSize: 12,
            fontWeight: 700,
            color: "#7dcfff",
            textTransform: "uppercase",
            letterSpacing: "0.16em",
            fontFamily: "'JetBrains Mono', monospace",
            marginBottom: 8,
          }}
        >
          Engine Architecture
        </div>
        <div
          style={{
            fontSize: 36,
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

      {/* Master 3-Card Metrics Row */}
      <div
        style={{
          width: 920,
          display: "flex",
          gap: 16,
          marginBottom: 16,
          opacity: Math.max(0, Math.min(1, entrance)),
          transform: `scale(${interpolate(
            entrance,
            [0, 1],
            [0.94, 1]
          )}) translateY(${interpolate(entrance, [0, 1], [15, 0])}px)`,
        }}
      >
        {/* Metric 1: Live microsecond ticker */}
        <div
          style={{
            flex: 1,
            backgroundColor: "rgba(16, 20, 32, 0.92)",
            backdropFilter: "blur(18px)",
            border: isLocked
              ? "1px solid rgba(125, 207, 255, 0.45)"
              : "1px solid rgba(125, 207, 255, 0.2)",
            borderRadius: 14,
            padding: "20px 22px",
            boxShadow: isLocked
              ? "0 15px 35px rgba(0, 0, 0, 0.5), 0 0 30px rgba(125, 207, 255, 0.2)"
              : "0 15px 35px rgba(0, 0, 0, 0.5)",
            position: "relative",
          }}
        >
          <div
            style={{
              fontSize: 36,
              fontWeight: 800,
              color: isLocked ? "#7dcfff" : "#ffffff",
              fontFamily: "'JetBrains Mono', monospace",
              marginBottom: 4,
              letterSpacing: "-0.02em",
            }}
          >
            {formattedMs}{" "}
            <span style={{ fontSize: 20, color: "#7dcfff" }}>ms</span>
          </div>
          <div style={{ fontSize: 13, fontWeight: 600, color: "#ffffff" }}>
            Query Execution
          </div>
          <div style={{ fontSize: 12, color: "#565f89", marginTop: 2 }}>
            FTS5 BM25 ranked
          </div>
        </div>

        {/* Metric 2: 100% Offline */}
        <div
          style={{
            flex: 1,
            backgroundColor: "rgba(16, 20, 32, 0.92)",
            backdropFilter: "blur(18px)",
            border: "1px solid rgba(158, 206, 106, 0.3)",
            borderRadius: 14,
            padding: "20px 22px",
            boxShadow: "0 15px 35px rgba(0, 0, 0, 0.5)",
          }}
        >
          <div
            style={{
              fontSize: 36,
              fontWeight: 800,
              color: "#9ece6a",
              fontFamily: "'JetBrains Mono', monospace",
              marginBottom: 4,
              letterSpacing: "-0.02em",
            }}
          >
            100%
          </div>
          <div style={{ fontSize: 13, fontWeight: 600, color: "#ffffff" }}>
            Offline & Private
          </div>
          <div style={{ fontSize: 12, color: "#565f89", marginTop: 2 }}>
            Zero network sockets
          </div>
        </div>

        {/* Metric 3: Wayland Hardware Acceleration */}
        <div
          style={{
            flex: 1,
            backgroundColor: "rgba(16, 20, 32, 0.92)",
            backdropFilter: "blur(18px)",
            border: "1px solid rgba(187, 154, 247, 0.3)",
            borderRadius: 14,
            padding: "20px 22px",
            boxShadow: "0 15px 35px rgba(0, 0, 0, 0.5)",
          }}
        >
          <div
            style={{
              fontSize: 36,
              fontWeight: 800,
              color: "#bb9af7",
              fontFamily: "'JetBrains Mono', monospace",
              marginBottom: 4,
              letterSpacing: "-0.02em",
            }}
          >
            60 FPS
          </div>
          <div style={{ fontSize: 13, fontWeight: 600, color: "#ffffff" }}>
            Wayland Native
          </div>
          <div style={{ fontSize: 12, color: "#565f89", marginTop: 2 }}>
            Direct LayerShell buffer
          </div>
        </div>
      </div>

      {/* Execution Pipeline Trace Terminal */}
      <div
        style={{
          width: 920,
          backgroundColor: "rgba(12, 15, 24, 0.94)",
          backdropFilter: "blur(18px)",
          border: "1px solid rgba(255, 255, 255, 0.08)",
          borderRadius: 14,
          padding: "16px 24px",
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
            transform: `translateX(${interpolate(step1, [0, 1], [-10, 0])}px)`,
            display: "flex",
            alignItems: "center",
            gap: 12,
            color: "#c0caf5",
          }}
        >
          <span style={{ color: "#7dcfff", fontWeight: 700 }}>0.10ms</span>
          <span style={{ color: "#565f89" }}>│</span>
          <span>Tokenized query with Unicode61 Porter stemming</span>
        </div>

        <div
          style={{
            opacity: Math.max(0, Math.min(1, step2)),
            transform: `translateX(${interpolate(step2, [0, 1], [-10, 0])}px)`,
            display: "flex",
            alignItems: "center",
            gap: 12,
            color: "#c0caf5",
          }}
        >
          <span style={{ color: "#7dcfff", fontWeight: 700 }}>0.30ms</span>
          <span style={{ color: "#565f89" }}>│</span>
          <span>Scanned local SQLite FTS5 table across 15,000+ records</span>
        </div>

        <div
          style={{
            opacity: Math.max(0, Math.min(1, step3)),
            transform: `translateX(${interpolate(step3, [0, 1], [-10, 0])}px)`,
            display: "flex",
            alignItems: "center",
            gap: 12,
            color: "#c0caf5",
          }}
        >
          <span style={{ color: "#7dcfff", fontWeight: 700 }}>0.55ms</span>
          <span style={{ color: "#565f89" }}>│</span>
          <span>Calculated BM25 relevance scores and fuzzy matches</span>
        </div>

        <div
          style={{
            opacity: Math.max(0, Math.min(1, step4)),
            transform: `translateX(${interpolate(step4, [0, 1], [-10, 0])}px)`,
            display: "flex",
            alignItems: "center",
            gap: 12,
            color: "#9ece6a",
            fontWeight: 600,
          }}
        >
          <span>0.80ms</span>
          <span style={{ color: "#565f89" }}>│</span>
          <span>Rendered hardware surface via Wayland LayerShell protocol</span>
        </div>
      </div>

      {/* Floating Status Beacon */}
      <div
        style={{
          marginTop: 18,
          opacity: Math.max(0, Math.min(1, badgeSpring)),
          transform: `scale(${interpolate(badgeSpring, [0, 1], [0.94, 1])})`,
          padding: "7px 20px",
          borderRadius: 24,
          backgroundColor: "rgba(125, 207, 255, 0.1)",
          border: "1px solid rgba(125, 207, 255, 0.35)",
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
        <span>Benchmarked on Arch Linux & Omarchy: 0.8ms average response</span>
      </div>
    </AbsoluteFill>
  );
};
