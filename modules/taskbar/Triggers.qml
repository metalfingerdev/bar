import QtQuick
import Quickshell
import qs.modules.taskbar.services

Scope {
    id: root

    property bool armed: false
    Timer { interval: 2000; running: true; onTriggered: root.armed = true }

    function alert(view) {
        if (armed) IslandState.send(IslandState.Event.Alert, view)
    }

    Connections {
        target: Audio
        function onVolumeChanged() { root.alert(IslandState.View.Volume) }
        function onMutedChanged()  { root.alert(IslandState.View.Volume) }
    }

    Connections {
        target: Brightness
        function onPercentChanged() { root.alert(IslandState.View.Brightness) }
    }

    Connections {
        target: Notifier
        function onReceived() {
            IslandState.send(IslandState.Event.Alert, IslandState.View.Notify)
        }
    }
}