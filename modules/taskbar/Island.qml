import QtQuick
import qs.modules.taskbar

Item {
    id: container

    x: ( screenWidth - length ) / 2
    y: 0

    height: loader.item.implicitHeight + gap
    width: loader.item.implicitWidth

    
    readonly property int target: State.View.Compact
    readonly property bool open: target !== -1
    readonly property bool length: open && State.item ? State.item.width : 0
    property int shown: -1

    Component.onCompleted: shown = target
    function syncEngaged() {
        State.send(loader.item?.enaged === true ? State.Event.Engage : State.Event.Release)
    }


    Rectangle {
        id: island

        anchors.top: parent.top
        anchors.topMargin: gap
        anchors.fill: parent

        radius: 8
        color: "black"
        
        Loader {
            id: loader
            anchors.centerIn: parent
            active: container.shown !== -1
            source: container.shown === -1 ? "" : Registry.get(container.shown).url
            onLoaded: {
                console.log("Island loaded:", loader.item)
                container.syncEngaged()
            }

            asynchronous: true
        }

        // ---- optional view contract (all members are optional) ----
        //   property bool engaged   : true while the user is actively working in the view
        //   signal closeRequested() : the view is done (e.g. an app was launched)
        Connections {
            target: loader.item
            ignoreUnknownSignals: true
            function onEngagedChanged()  { container.syncEngaged() }
            function onCloseRequested()  { State.send(State.Event.Close) }
        }
    }
}