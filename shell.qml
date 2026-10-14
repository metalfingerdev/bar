import QtQuick
import Quickshell
import qs.modules.taskbar
import qs.modules.services

ShellRoot {
    Component.onCompleted: Wallpaper.reload()

    Bar {
    }
}