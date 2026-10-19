// Bar.qml
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

import qs.modules.taskbar

Scope {
  id: root

    PanelWindow {
        id: spacer

        anchors { top: true; left: true; right: true }
        implicitHeight: State.space
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

        Island{
            id: island
        }
    }
}