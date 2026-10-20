import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

import qs.modules.taskbar

Scope {
    // Reserves screen space at the top. Fully click-through.
    PanelWindow {
        visible: Engine.reserve > 0
        anchors { top: true; left: true; right: true }
        implicitHeight: Engine.reserve
        color: "transparent"
        mask: Region {}
    }

    // Full-screen overlay; only the island itself is clickable.
    PanelWindow {
        id: overlay

        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        mask: Region { item: island }

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: Engine.keyboard ? WlrKeyboardFocus.OnDemand
                                                     : WlrKeyboardFocus.None

        // Outside clicks: while a view is pinned, a click anywhere else clears the grab -> Outside.
        // (Not Hyprland? Swap this for a full-window backdrop MouseArea + mask while Engine.grabbing.)
        HyprlandFocusGrab {
            windows: [overlay]
            active: Engine.grabbing
            onCleared: Engine.send(Engine.Event.Outside)
        }

        Island { id: island }
    }
}
