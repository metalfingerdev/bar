import QtQuick
import qs.modules.taskbar

// Placeholder panel: proves a pinned view can have its own clicks
// (the counter) without the island closing.
Item {
    implicitWidth: 420
    implicitHeight: 160

    property int taps: 0

    Column {
        anchors.centerIn: parent
        spacing: 14

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Media (placeholder)"
            color: "#f7f7f7"
            font.pixelSize: 18
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Pill { text: "taps: " + taps; onClicked: taps++ }
            Pill { text: "back"; onClicked: IslandState.send(IslandState.Event.Back) }
        }
    }
}