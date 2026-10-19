pragma Singleton

import QtQuick

// A small statechart.
//   control state : phase  (Collapsed | Peek | Pinned | Transient)
//   extended state: view, hovered, engaged
//   config        : mode, space, compactWidget       (never changed by send())
// One transition function (send), one handler per phase, and every entry action
// (stop old timers, start the new one) lives in enter(). Timers only ever send Expire.
QtObject {
    id: root

    enum Phase  { Collapsed, Peek, Pinned, Transient }
    enum View   { Idle, Media, Notify, Compact, Dashboard, Volume, Brightness, Theme, Bluetooth, Launcher, Workspaces }
    enum Event  { HoverIn, HoverOut, Click, Outside, Escape, Open, Back, Alert, Expire, Close, Engage, Release }
    enum Mode   { Pill, Notch }
    enum Widget { Clock, Date }

    // state
    readonly property int gap: 8
    readonly property int space: 64
    readonly property int screenHeight: 1080
    readonly property int screenWidth: 1920

    // ---- the one entry point -------------------------------------------------
    function send(event, view) {
        const E = IslandState.Event
        switch (event) {
        case E.HoverIn:  hovered = true; graceTimer.stop(); break
        case E.HoverOut: hovered = false; break
        case E.Engage:   return engage(true)
        case E.Release:  return engage(false)
        }

        switch (phase) {
        case IslandState.Phase.Collapsed: return whenCollapsed(event, view)
        case IslandState.Phase.Peek:      return whenPeek(event, view)
        case IslandState.Phase.Transient: return whenTransient(event, view)
        case IslandState.Phase.Pinned:    return whenPinned(event, view)
        }
    }
}