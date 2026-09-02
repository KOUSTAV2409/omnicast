import QtQuick
import Quickshell
import Quickshell.Io
import "services"

ShellRoot {
  id: root

  // Continuous background clipboard watcher
  Process {
    id: clipboardDaemon
    command: ["sh", "-c", "wl-paste --watch python3 /home/iamkxyz/Projects/omnicast/src/backend/clipboard_manager.py capture"]
    running: true
  }

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
    console.log("[Omnicast] Initialized and listening on IPC target 'omnicast'")
  }
}
