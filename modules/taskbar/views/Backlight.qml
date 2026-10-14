import QtQuick
import qs.modules.taskbar
import qs.modules.taskbar.services

Meter {
    label:     "bri"
    fraction:  Brightness.percent / 100
    valueText: String(Brightness.percent)
}