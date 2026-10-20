import QtQuick
import qs.modules.taskbar

// The island is a pure projection of Engine: it shows Engine.view and reports
// pointer input back as events. It owns no state-machine logic.
Item {
    id: root

    readonly property real edgeMargin: 0

    // ---- size: follows the loaded view, remembers the last good size while the next one loads ----
    property real contentW: 0
    property real contentH: 0

    Binding {
        target: root; property: "contentW"
        value: loader.item ? loader.item.implicitWidth : 0
        when: loader.item !== null
        restoreMode: Binding.RestoreNone
    }
    Binding {
        target: root; property: "contentH"
        value: loader.item ? loader.item.implicitHeight : 0
        when: loader.item !== null
        restoreMode: Binding.RestoreNone
    }

    width: contentW
    height: contentH + Engine.gap
    Behavior on width  { NumberAnimation { duration: Engine.morphMs; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: Engine.morphMs; easing.type: Easing.OutCubic } }

    // ---- position: screen centre, or centred on the click that opened the view (clamped to the window) ----
    readonly property real wanted: Engine.anchorX >= 0 ? Engine.anchorX - width / 2
                                                       : (parent.width - width) / 2
    x: Math.max(edgeMargin, Math.min(parent.width - width - edgeMargin, wanted))
    y: 0

    function syncEngaged() {
        Engine.send(loader.item?.engaged === true ? Engine.Event.Engage : Engine.Event.Release)
    }

    // ---- input -> events ----
    Keys.onEscapePressed: Engine.send(Engine.Event.Escape)
    focus: Engine.keyboard

    Rectangle {
        id: surface
        anchors.fill: parent
        anchors.topMargin: Engine.gap
        radius: 8
        color: "black"

        HoverHandler {
            onHoveredChanged: Engine.send(hovered ? Engine.Event.HoverIn : Engine.Event.HoverOut)
        }

        // Passive: clicks that a view's own MouseArea/Button accepts never reach this.
        TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: eventPoint => Engine.send(Engine.Event.Click, { x: eventPoint.scenePosition.x })
        }
        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: Engine.send(Engine.Event.Back)
        }

        Loader {
            id: loader
            anchors.centerIn: parent
            asynchronous: true
            source: Registry.get(Engine.view)?.url ?? ""
            onLoaded: root.syncEngaged()
        }

        // optional view contract (all members optional):
        //   property bool engaged   : the user is actively working in the view
        //   signal closeRequested() : the view is done (e.g. an app was launched)
        Connections {
            target: loader.item
            ignoreUnknownSignals: true
            function onEngagedChanged() { root.syncEngaged() }
            function onCloseRequested() { Engine.send(Engine.Event.Close) }
        }
    }
}
