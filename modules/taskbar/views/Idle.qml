import QtQuick
import Quickshell
import qs.modules.taskbar

// Resting view: shown on hover (Peek) and when clicked (Pinned).
Item {
    implicitWidth: 300
    implicitHeight: 72

    SystemClock { id: clock; precision: SystemClock.Minutes }

    Row {
        anchors.centerIn: parent
        spacing: 16

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: "#f7f7f7"
            font.pixelSize: 22
        }

        Pill {
            anchors.verticalCenter: parent.verticalCenter
            text: "dashboard"
            onClicked: IslandState.send(IslandState.Event.Open, IslandState.View.Dashboard)
        }    

        Pill {
            anchors.verticalCenter: parent.verticalCenter
            text: "media"
            onClicked: IslandState.send(IslandState.Event.Open, IslandState.View.Media)
        }

        Pill {
            anchors.verticalCenter: parent.verticalCenter
            text: "notify"
            onClicked: IslandState.send(IslandState.Event.Open, IslandState.View.Notify)
        }
    }
}