import React from "react";
import {
  AbsoluteFill,
  interpolate,
  spring,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

export const KeycapHookScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Gentle float-in spring
  const floatIn = spring({
    frame,
    fps,
    config: { damping: 16, mass: 0.9, stiffness: 90 },
  });

  // Mechanical keypress trigger at frame 38
  const pressTrigger = frame - 38;
  const keyPressSpring = spring({
    frame: pressTrigger,
    fps,
    config: { damping: 12, mass: 0.5, stiffness: 180 },
  });

  const isPressed = frame >= 38;
  const pressDepth = isPressed
    ? interpolate(keyPressSpring, [0, 0.5, 1], [0, 16, 10])
    : 0;

  // Expanding shockwave after press
  const shockwaveFrame = Math.max(0, frame - 40);
  const shockwaveScale = interpolate(shockwaveFrame, [0, 40], [0.2, 3.2], {
    extrapolateRight: "clamp",
  });
  const shockwaveOpacity = interpolate(shockwaveFrame, [0, 5, 35], [0, 0.8, 0], {
    extrapolateRight: "clamp",
  });

  // Text tag reveal
  const tagSpring = spring({
    frame: frame - 12,
    fps,
    config: { damping: 15 },
  });

  // Exit blur and fade out
  const exitOpacity = interpolate(frame, [72, 90], [1, 0], {
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
        perspective: 1100,
        opacity: exitOpacity,
        fontFamily: "Inter, -apple-system, sans-serif",
      }}
    >
      {/* Perspective floor grid lines */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          backgroundImage:
            "linear-gradient(rgba(125, 207, 255, 0.04) 1px, transparent 1px), linear-gradient(90deg, rgba(125, 207, 255, 0.04) 1px, transparent 1px)",
          backgroundSize: "60px 60px",
          transform: "rotateX(68deg) translateY(120px) scale(2.2)",
          transformOrigin: "center 80%",
          pointerEvents: "none",
          maskImage:
            "radial-gradient(ellipse at 50% 60%, black 20%, transparent 75%)",
          WebkitMaskImage:
            "radial-gradient(ellipse at 50% 60%, black 20%, transparent 75%)",
        }}
      />

      {/* Ambient background glow */}
      <div
        style={{
          position: "absolute",
          top: "45%",
          left: "50%",
          transform: "translate(-50%, -50%)",
          width: 700,
          height: 380,
          background:
            "radial-gradient(circle, rgba(125, 207, 255, 0.16) 0%, rgba(122, 162, 247, 0.04) 50%, transparent 75%)",
          filter: "blur(60px)",
          pointerEvents: "none",
        }}
      />

      {/* Expanding shockwave ring */}
      {isPressed && (
        <div
          style={{
            position: "absolute",
            top: "45%",
            left: "50%",
            transform: `translate(-50%, -50%) scale(${shockwaveScale})`,
            width: 320,
            height: 320,
            borderRadius: "50%",
            border: "2px solid rgba(125, 207, 255, 0.8)",
            boxShadow:
              "0 0 40px rgba(125, 207, 255, 0.6), inset 0 0 25px rgba(122, 162, 247, 0.4)",
            opacity: shockwaveOpacity,
            pointerEvents: "none",
          }}
        />
      )}

      {/* Top Tagline */}
      <div
        style={{
          opacity: Math.max(0, Math.min(1, tagSpring)),
          transform: `translateY(${interpolate(tagSpring, [0, 1], [-16, 0])}px)`,
          marginBottom: 36,
          display: "flex",
          alignItems: "center",
          gap: 10,
          padding: "7px 20px",
          borderRadius: 24,
          backgroundColor: "rgba(17, 21, 34, 0.85)",
          border: "1px solid rgba(125, 207, 255, 0.25)",
          boxShadow: "0 10px 25px rgba(0, 0, 0, 0.5)",
          zIndex: 10,
        }}
      >
        <span
          style={{
            width: 8,
            height: 8,
            borderRadius: "50%",
            backgroundColor: "#7dcfff",
            boxShadow: "0 0 10px #7dcfff",
          }}
        />
        <span
          style={{
            color: "#c0caf5",
            fontSize: 13,
            fontWeight: 700,
            letterSpacing: "0.14em",
            textTransform: "uppercase",
            fontFamily: "'JetBrains Mono', monospace",
          }}
        >
          Global Shortcut
        </span>
      </div>

      {/* 3D Floating Mechanical Keycaps */}
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: 22,
          transform: `scale(${interpolate(
            floatIn,
            [0, 1],
            [0.85, 1]
          )}) rotateX(15deg) translateY(${interpolate(
            floatIn,
            [0, 1],
            [30, 0]
          )}px)`,
          zIndex: 10,
        }}
      >
        {/* Alt Keycap */}
        <div
          style={{
            width: 140,
            height: 110,
            borderRadius: 18,
            backgroundColor: "#161a29",
            border: "1px solid rgba(125, 207, 255, 0.3)",
            boxShadow: isPressed
              ? "0 4px 15px rgba(0, 0, 0, 0.8), 0 0 30px rgba(125, 207, 255, 0.4)"
              : "0 18px 35px rgba(0, 0, 0, 0.7), 0 0 20px rgba(125, 207, 255, 0.15)",
            transform: `translateY(${pressDepth}px)`,
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
            position: "relative",
            background: "linear-gradient(145deg, #1f253a, #131726)",
          }}
        >
          {/* Bevel highlight */}
          <div
            style={{
              position: "absolute",
              top: 5,
              left: 8,
              right: 8,
              height: 2,
              borderRadius: 2,
              background: "linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent)",
            }}
          />
          <span
            style={{
              fontSize: 32,
              fontWeight: 800,
              fontFamily: "'JetBrains Mono', monospace",
              color: "#ffffff",
              letterSpacing: "-0.02em",
              textShadow: "0 0 15px rgba(125, 207, 255, 0.5)",
            }}
          >
            Alt
          </span>
          <span
            style={{
              fontSize: 10,
              color: "#7dcfff",
              fontWeight: 700,
              letterSpacing: "0.1em",
              textTransform: "uppercase",
              marginTop: 4,
            }}
          >
            Modifier
          </span>
        </div>

        {/* Plus Symbol */}
        <div
          style={{
            fontSize: 28,
            fontWeight: 700,
            color: "#565f89",
            fontFamily: "'JetBrains Mono', monospace",
          }}
        >
          +
        </div>

        {/* Space Keycap */}
        <div
          style={{
            width: 260,
            height: 110,
            borderRadius: 18,
            backgroundColor: "#161a29",
            border: "1px solid rgba(125, 207, 255, 0.3)",
            boxShadow: isPressed
              ? "0 4px 15px rgba(0, 0, 0, 0.8), 0 0 30px rgba(125, 207, 255, 0.4)"
              : "0 18px 35px rgba(0, 0, 0, 0.7), 0 0 20px rgba(125, 207, 255, 0.15)",
            transform: `translateY(${pressDepth}px)`,
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
            position: "relative",
            background: "linear-gradient(145deg, #1f253a, #131726)",
          }}
        >
          {/* Bevel highlight */}
          <div
            style={{
              position: "absolute",
              top: 5,
              left: 10,
              right: 10,
              height: 2,
              borderRadius: 2,
              background: "linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent)",
            }}
          />
          <span
            style={{
              fontSize: 32,
              fontWeight: 800,
              fontFamily: "'JetBrains Mono', monospace",
              color: "#ffffff",
              letterSpacing: "-0.02em",
              textShadow: "0 0 15px rgba(125, 207, 255, 0.5)",
            }}
          >
            Space
          </span>
          <span
            style={{
              fontSize: 10,
              color: "#7dcfff",
              fontWeight: 700,
              letterSpacing: "0.1em",
              textTransform: "uppercase",
              marginTop: 4,
            }}
          >
            Trigger
          </span>
        </div>
      </div>

      {/* Subtitle / Bottom Hook */}
      <div
        style={{
          marginTop: 36,
          fontSize: 20,
          fontWeight: 500,
          color: "#9aa5ce",
          letterSpacing: "-0.01em",
          opacity: Math.max(0, Math.min(1, tagSpring)),
          transform: `translateY(${interpolate(tagSpring, [0, 1], [15, 0])}px)`,
          textAlign: "center",
        }}
      >
        One keystroke to summon your entire workspace.
      </div>
    </AbsoluteFill>
  );
};
