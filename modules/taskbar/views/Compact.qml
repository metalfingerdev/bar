import QtQuick
import Quickshell
import qs.modules.taskbar

// Always-on resting view (shown while collapsed when space is reserved).
// Shows ONE thing, picked by IslandState.compactWidget.
Item {
    implicitWidth: 120
    implicitHeight: IslandState.compactHeight

    SystemClock { id: clock; precision: SystemClock.Minutes }

    Text {
        id: label
        anchors.centerIn: parent
        color: "#f7f7f7"
        font.pixelSize: 13
        text: IslandState.compactWidget === IslandState.Widget.Date
              ? Qt.formatDateTime(clock.date, "ddd d MMM")
              : Qt.formatDateTime(clock.date, "HH:mm")
    }
}