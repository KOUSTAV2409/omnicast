import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export const SuperpowerGridScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Entrance springs for the 4 grid cards
  const card1 = spring({ frame: frame - 10, fps, config: { damping: 15 } });
  const card2 = spring({ frame: frame - 22, fps, config: { damping: 15 } });
  const card3 = spring({ frame: frame - 34, fps, config: { damping: 15 } });
  const card4 = spring({ frame: frame - 46, fps, config: { damping: 15 } });

  const titleSpring = spring({ frame, fps, config: { damping: 16 } });

  // Exit transition
  const exitOpacity = interpolate(frame, [160, 180], [1, 0], {
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
        perspective: 1100,
      }}
    >
      {/* Background ambient glow */}
      <div
        style={{
          position: "absolute",
          top: "45%",
          left: "50%",
          transform: "translate(-50%, -50%)",
          width: 850,
          height: 480,
          background:
            "radial-gradient(circle, rgba(125, 207, 255, 0.12) 0%, rgba(187, 154, 247, 0.05) 50%, transparent 75%)",
          filter: "blur(60px)",
          pointerEvents: "none",
        }}
      />

      {/* Eyebrow & Headline */}
      <div
        style={{
          textAlign: "center",
          marginBottom: 30,
          opacity: Math.max(0, Math.min(1, titleSpring)),
          transform: `translateY(${interpolate(titleSpring, [0, 1], [-15, 0])}px)`,
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
          Desktop Capabilities
        </div>
        <div
          style={{
            fontSize: 36,
            fontWeight: 800,
            color: "#ffffff",
            letterSpacing: "-0.03em",
          }}
        >
          Everything you need.{" "}
          <span
            style={{
              background: "linear-gradient(135deg, #7dcfff 0%, #bb9af7 100%)",
              WebkitBackgroundClip: "text",
              WebkitTextFillColor: "transparent",
            }}
          >
            One keystroke away.
          </span>
        </div>
      </div>

      {/* 2x2 Feature Grid */}
      <div
        style={{
          width: 900,
          display: "grid",
          gridTemplateColumns: "1fr 1fr",
          gap: 18,
          transform: "rotateX(6deg)",
        }}
      >
        {/* Card 1: Browser Unification */}
        <div
          style={{
            backgroundColor: "rgba(15, 19, 30, 0.92)",
            backdropFilter: "blur(20px)",
            border: "1px solid rgba(125, 207, 255, 0.25)",
            borderRadius: 16,
            padding: "24px 26px",
            boxShadow: "0 18px 40px rgba(0, 0, 0, 0.5)",
            opacity: Math.max(0, Math.min(1, card1)),
            transform: `translateY(${interpolate(card1, [0, 1], [25, 0])}px)`,
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 12,
              marginBottom: 10,
            }}
          >
            <div
              style={{
                width: 36,
                height: 36,
                borderRadius: 10,
                backgroundColor: "rgba(125, 207, 255, 0.15)",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontSize: 18,
              }}
            >
              🌐
            </div>
            <div style={{ fontSize: 16, fontWeight: 700, color: "#ffffff" }}>
              Browser History & Tabs
            </div>
          </div>
          <div
            style={{
              fontSize: 13,
              color: "#9aa5ce",
              lineHeight: 1.5,
            }}
          >
            Instant search across Zen, Brave, and Chrome SQLite databases. Zero cloud sync.
          </div>
        </div>

        {/* Card 2: Dotfile & Config Navigation */}
        <div
          style={{
            backgroundColor: "rgba(15, 19, 30, 0.92)",
            backdropFilter: "blur(20px)",
            border: "1px solid rgba(158, 206, 106, 0.25)",
            borderRadius: 16,
            padding: "24px 26px",
            boxShadow: "0 18px 40px rgba(0, 0, 0, 0.5)",
            opacity: Math.max(0, Math.min(1, card2)),
            transform: `translateY(${interpolate(card2, [0, 1], [25, 0])}px)`,
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 12,
              marginBottom: 10,
            }}
          >
            <div
              style={{
                width: 36,
                height: 36,
                borderRadius: 10,
                backgroundColor: "rgba(158, 206, 106, 0.15)",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontSize: 18,
              }}
            >
              ⚙️
            </div>
            <div style={{ fontSize: 16, fontWeight: 700, color: "#ffffff" }}>
              Dotfile Fast-Edit
            </div>
          </div>
          <div
            style={{
              fontSize: 13,
              color: "#9aa5ce",
              lineHeight: 1.5,
            }}
          >
            Jump straight into Hyprland, Waybar, Ghostty, or Foot configs in your favorite editor.
          </div>
        </div>

        {/* Card 3: Searchable Clipboard Ring */}
        <div
          style={{
            backgroundColor: "rgba(15, 19, 30, 0.92)",
            backdropFilter: "blur(20px)",
            border: "1px solid rgba(224, 175, 104, 0.25)",
            borderRadius: 16,
            padding: "24px 26px",
            boxShadow: "0 18px 40px rgba(0, 0, 0, 0.5)",
            opacity: Math.max(0, Math.min(1, card3)),
            transform: `translateY(${interpolate(card3, [0, 1], [25, 0])}px)`,
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 12,
              marginBottom: 10,
            }}
          >
            <div
              style={{
                width: 36,
                height: 36,
                borderRadius: 10,
                backgroundColor: "rgba(224, 175, 104, 0.15)",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontSize: 18,
              }}
            >
              📋
            </div>
            <div style={{ fontSize: 16, fontWeight: 700, color: "#ffffff" }}>
              Local Clipboard History
            </div>
          </div>
          <div
            style={{
              fontSize: 13,
              color: "#9aa5ce",
              lineHeight: 1.5,
            }}
          >
            Fuzzy search past copied code snippets, links, and text without leaving your keyboard.
          </div>
        </div>

        {/* Card 4: Strict Security & Privacy */}
        <div
          style={{
            backgroundColor: "rgba(15, 19, 30, 0.92)",
            backdropFilter: "blur(20px)",
            border: "1px solid rgba(187, 154, 247, 0.25)",
            borderRadius: 16,
            padding: "24px 26px",
            boxShadow: "0 18px 40px rgba(0, 0, 0, 0.5)",
            opacity: Math.max(0, Math.min(1, card4)),
            transform: `translateY(${interpolate(card4, [0, 1], [25, 0])}px)`,
          }}
        >
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 12,
              marginBottom: 10,
            }}
          >
            <div
              style={{
                width: 36,
                height: 36,
                borderRadius: 10,
                backgroundColor: "rgba(187, 154, 247, 0.15)",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontSize: 18,
              }}
            >
              🔒
            </div>
            <div style={{ fontSize: 16, fontWeight: 700, color: "#ffffff" }}>
              100% Offline & Private
            </div>
          </div>
          <div
            style={{
              fontSize: 13,
              color: "#9aa5ce",
              lineHeight: 1.5,
            }}
          >
            Zero network sockets. Zero telemetry. All search indices stay strictly on local disk.
          </div>
        </div>
      </div>
    </AbsoluteFill>
  );
};
