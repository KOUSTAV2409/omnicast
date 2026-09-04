import QtQuick
import Quickshell
import Quickshell.Wayland
import "services"
import "components"

// Independent overlay so HUD survives OmnicastWindow dismiss
PanelWindow {
  id: root

  WlrLayershell.namespace: "omnicast-hud"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  exclusionMode: ExclusionMode.Ignore

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  color: "transparent"
  visible: Hud.visible

  HudOverlay {
    anchors.fill: parent
  }
}
