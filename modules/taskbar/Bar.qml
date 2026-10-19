// Bar.qml
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

Scope {
  id: root

  // state
  property int gap: 8
  property int length: 256
  property int bredth: 56
  readonly property int screenHeight: 1080
  readonly property int screenWidth: 1920


    PanelWindow {
        id: spacer

        anchors { top: true; left: true; right: true }
        implicitHeight: gap + bredth
        color: "transparent"
        mask: Region {}
    }

    PanelWindow {
        id: screen

        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        mask: Region { item: island }

        WlrLayershell.layer: WlrLayer.Top

        Island{}
    }
}