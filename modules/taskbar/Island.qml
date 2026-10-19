import QtQuick

Item {
    id: container

    x: ( screenWidth - length ) / 2
    y: 0

    height: bredth + gap
    width: length

     Rectangle {
        id: island

        anchors.top: parent.top
        anchors.topMargin: gap
        anchors.fill: parent

        radius: 8
        color: "black"
        
        Rectangle {
            id: buttons

            anchors.verticalCenter: parent.verticalCenter
            

            implicitHeight: 36
            implicitWidth: 36

            radius: 16
        }
    }
}