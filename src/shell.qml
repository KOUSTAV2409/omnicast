import QtQuick
import Quickshell
import Quickshell.Io
import "services"

ShellRoot {
  id: root

  // Main Omnicast Window Modal
  OmnicastWindow {
    id: omnicastWindow
  }

  // Global IPC Endpoint for Hyprland hotkeys or CLI triggering
  IpcHandler {
    target: "omnicast"

    function toggle(): string {
      omnicastWindow.toggle()
      return omnicastWindow.isVisible ? "visible" : "hidden"
    }

    function show(): string {
      omnicastWindow.show()
      return "visible"
    }

    function dismiss(): string {
      omnicastWindow.dismiss()
      return "hidden"
    }

    function ping(): string {
      return "pong"
    }
  }

  Component.onCompleted: {
    console.log("[Omnicast] Deeply integrated with native Omarchy services on IPC target 'omnicast'")
  }
}
