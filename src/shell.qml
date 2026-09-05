import QtQuick
import Quickshell
import Quickshell.Io
import "services"

ShellRoot {
  id: root

  OmnicastWindow {
    id: omnicastWindow
  }

  HudPanel {
    id: hudPanel
  }

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

    function hud(message: string): string {
      Hud.success(message || "")
      return "ok"
    }
  }

  Component.onCompleted: {
    console.log("[Omnicast] shell ready: Paths.srcRoot=", Paths.srcRoot)
  }
}
