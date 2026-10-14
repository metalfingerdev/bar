pragma Singleton

import Quickshell
import Quickshell.Services.Notifications

// Knows org.freedesktop.Notifications. Knows nothing about the island.
Singleton {
    id: root

    property string appName: ""
    property string summary: ""
    property string body: ""

    signal received()

    NotificationServer {
        bodySupported: true
        onNotification: n => {
            // Copy the fields out. Without `n.tracked = true` Quickshell frees the
            // notification when this handler returns, which is fine for a bare-bones bar.
            root.appName = n.appName
            root.summary = n.summary
            root.body    = n.body
            root.received()
        }
    }
}