pragma Singleton

import QtQuick

// View enum -> how that view behaves. Adding a view = one enum value + one line here.
//   hold:     >0 means it can be an Alert (auto-dismiss after that many ms)
//   priority: higher wins when an Alert arrives during another Alert
//   timeout:  >0 means that view closes itself after that many ms when pinned (0 = stays)
QtObject {
    readonly property var entries: [
        { view: IslandState.View.Idle,      name: "idle",      url: Qt.resolvedUrl("views/Idle.qml"),      hold: 0,    priority: 0, timeout: 0 },
        { view: IslandState.View.Media,     name: "media",     url: Qt.resolvedUrl("views/Media.qml"),     hold: 0,    priority: 1, timeout: 15000 },
        { view: IslandState.View.Notify,    name: "notify",    url: Qt.resolvedUrl("views/Notify.qml"),    hold: 3500, priority: 2, timeout: 15000 },
        { view: IslandState.View.Compact,   name: "compact",   url: Qt.resolvedUrl("views/Compact.qml"),   hold: 0,    priority: 0, timeout: 0 },
        { view: IslandState.View.Dashboard, name: "dashboard", url: Qt.resolvedUrl("views/Dashboard.qml"), hold: 0,    priority: 1, timeout: 15000 }
    ]

    function get(view)      { return entries.find(e => e.view === view) || null }
    function byName(name)   { return entries.find(e => e.name === name) || null }
    function priority(view) { const e = get(view); return e ? e.priority : -1 }
    function timeout(view)  { const e = get(view); return e ? e.timeout : 0 }
}