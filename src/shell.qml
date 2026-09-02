import QtQuick
import Quickshell
import Quickshell.Io
import "services"

ShellRoot {
  id: root

  // Continuous background text clipboard watcher
  Process {
    id: textClipboardDaemon
    command: ["sh", "-c", "wl-paste --type text --watch python3 /home/iamkxyz/Projects/omnicast/src/backend/clipboard_manager.py capture"]
    running: true
  }

  // Continuous background image clipboard watcher
  Process {
    id: imageClipboardDaemon
    command: ["sh", "-c", "wl-paste --type image/png --watch python3 /home/iamkxyz/Projects/omnicast/src/backend/clipboard_manager.py capture-image"]
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
    console.log("[Omnicast] Initialized with text + image clipboard daemons on IPC target 'omnicast'")
  }
}
