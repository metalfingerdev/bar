pragma Singleton

import QtQuick

// One row per view.
//   hold     ms an Alert (toast) stays; 0 = this view cannot be an alert
//   sticky   toast stays until dismissed (ignores hold's duration)
//   timeout  ms a pinned view stays open; 0 = until closed
//   priority higher wins when two alerts collide
//   defer    an alert arriving while Pinned is queued instead of dropped
//   keys     the view wants the keyboard
//   follow   when opened by a click, the island centres on the click's x
QtObject {
    readonly property var entries: [
        { view: Engine.View.Idle,       name: "idle",       url: Qt.resolvedUrl("views/Idle.qml"),       hold: 0,    priority: 0, timeout: 3000, keys: true },
        { view: Engine.View.Media,      name: "media",      url: Qt.resolvedUrl("views/Media.qml"),      hold: 0,    priority: 1, timeout: 2000 },
        { view: Engine.View.Notify,     name: "notify",     url: Qt.resolvedUrl("views/Notify.qml"),     hold: 3500, priority: 2, timeout: 2000, defer: true, sticky: true },
        { view: Engine.View.Volume,     name: "volume",     url: Qt.resolvedUrl("views/Volume.qml"),     hold: 1500, priority: 1, timeout: 0,    follow: true },
        { view: Engine.View.Compact,    name: "compact",    url: Qt.resolvedUrl("views/Compact.qml"),    hold: 0,    priority: 0, timeout: 0 },
        { view: Engine.View.Dashboard,  name: "dashboard",  url: Qt.resolvedUrl("views/Dashboard.qml"),  hold: 0,    priority: 1, timeout: 2000 },
        { view: Engine.View.Brightness, name: "brightness", url: Qt.resolvedUrl("views/Backlight.qml"),  hold: 1500, priority: 1, timeout: 0,    follow: true },
        { view: Engine.View.Theme,      name: "theme",      url: Qt.resolvedUrl("views/Theme.qml"),      hold: 0,    priority: 1, timeout: 0,    follow: true },
        { view: Engine.View.Bluetooth,  name: "bluetooth",  url: Qt.resolvedUrl("views/Bluetooth.qml"),  hold: 0,    priority: 1, timeout: 0,    follow: true },
        { view: Engine.View.Launcher,   name: "launcher",   url: Qt.resolvedUrl("views/Launcher.qml"),   hold: 0,    priority: 1, timeout: 2000, keys: true },
        { view: Engine.View.Workspaces, name: "workspaces", url: Qt.resolvedUrl("views/Workspaces.qml"), hold: 0,    priority: 1, timeout: 0 }
    ]

    function get(view)       { return entries.find(e => e.view === view) || null }
    function byName(name)    { return entries.find(e => e.name === name) || null }
    function priority(view)  { const e = get(view); return e ? e.priority : -1 }
    function timeout(view)   { const e = get(view); return e ? e.timeout : 0 }
    function wantsKeys(view) { const e = get(view); return !!e && e.keys === true }
    function follows(view)   { const e = get(view); return !!e && e.follow === true }
    function defers(view)    { const e = get(view); return !!e && e.defer === true && e.hold > 0 }
}
