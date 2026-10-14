import QtQuick
import qs.modules.taskbar
import qs.modules.taskbar.services

Item {
    implicitWidth: 360
    implicitHeight: 56


    Row {
        anchors.centerIn: parent
        spacing: 24

            Text {
            anchors.verticalCenter: parent.verticalCenter

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            elide: Text.ElideRight
            text: Notifier.summary
            color: "#f7f7f7"
            font.pixelSize: 15
        }

        Pill { 
            id: pill
            text: "back"
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            onClicked: IslandState.send(IslandState.Event.Back)
        }
    }
}
