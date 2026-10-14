import QtQuick
import Quickshell

// The ONLY file that knows about both a service and the island.
// Services stay UI-ignorant, the island stays service-ignorant; wire them here.
//
// Example once you have a services/Audio.qml singleton:
//
//   Connections {
//       target: Audio
//       function onVolumeChanged() {
//           IslandState.send(IslandState.Event.Alert, IslandState.View.Volume, Audio.volume)
//       }
//   }
Scope {
}
