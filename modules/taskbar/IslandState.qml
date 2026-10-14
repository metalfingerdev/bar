pragma Singleton

import QtQuick

// A small statechart.
//   control state : phase  (Collapsed | Peek | Pinned | Transient)
//   extended state: view, data, hovered
//   config        : mode, space, compactWidget      (never changed by send())
// One transition function (send), one handler per phase, and every entry action
// (stop old timers, start the new one) lives in enter(). Timers only ever send Expire.
QtObject {
    id: root

    enum Phase  { Collapsed, Peek, Pinned, Transient }
    enum View   { Idle, Media, Notify, Compact, Dashboard }
    enum Event  { HoverIn, HoverOut, Click, Outside, Escape, Open, Back, Alert, Expire, Close }
    enum Mode   { Island, Notch }
    enum Widget { Clock, Date }

    // ---- control + extended state ----
    property int phase: IslandState.Phase.Collapsed
    property int view: IslandState.View.Idle
    property var data: "Notification (placeholder)"   // payload of the last Alert
    property bool hovered: false                      // tracked in every phase

    // ---- config ----
    property int mode: IslandState.Mode.Notch
    property bool space: false                        // reserve screen space; rest shows the default view instead of the handle
    property int compactWidget: IslandState.Widget.Clock   // the default view's content
    readonly property int compactHeight: 28
    readonly property int settleMs: 4000              // Back -> Idle stays open this long, hover or not

    readonly property bool pinned: phase === IslandState.Phase.Pinned
    readonly property var phaseNames: ["collapsed", "peek", "pinned", "transient"]

    // What hovering shows: reserved space already shows the default view, so hover opens Idle;
    // otherwise (handle at rest) hover reveals the default view.
    function peekView() { return space ? IslandState.View.Idle : IslandState.View.Compact }

    // ---- the one entry point -------------------------------------------------
    function send(event, view, data) {
        const E = IslandState.Event

        // pointer bookkeeping happens in every phase
        if (event === E.HoverIn)  { hovered = true;  graceTimer.stop() }
        if (event === E.HoverOut) { hovered = false }

        switch (phase) {
        case IslandState.Phase.Collapsed: return whenCollapsed(event, view, data)
        case IslandState.Phase.Peek:      return whenPeek(event, view, data)
        case IslandState.Phase.Transient: return whenTransient(event, view, data)
        case IslandState.Phase.Pinned:    return whenPinned(event, view, data)
        }
    }

    // ---- transition table: one function per phase ----------------------------
    function whenCollapsed(event, v, d) {
        const E = IslandState.Event
        switch (event) {
        case E.HoverIn: return enter(IslandState.Phase.Peek, peekView())
        case E.Click:   return openHome()
        case E.Open:    return open(v)
        case E.Alert:   return alert(v, d)
        }
    }

    function whenPeek(event, v, d) {
        const E = IslandState.Event
        switch (event) {
        case E.HoverOut: return graceTimer.restart()            // collapse after a short grace
        case E.Click:    return space ? close() : openHome()     // click the surface -> Idle, pinned
        case E.Open:     return open(v)
        case E.Alert:    return alert(v, d)
        case E.Close:    return close()
        }
    }

    function whenTransient(event, v, d) {
        const E = IslandState.Event
        switch (event) {
        case E.Expire:   return rest()
        case E.HoverIn:  return stateTimer.stop()               // pause while the pointer is on it
        case E.HoverOut: return resumeStateTimer()
        case E.Back:     return settle()
        case E.Click:    return close()
        case E.Open:     return open(v)
        case E.Alert:    if (Registry.priority(v) >= Registry.priority(root.view)) alert(v, d); return
        case E.Outside:
        case E.Escape:
        case E.Close:    return close()
        }
    }

    function whenPinned(event, v, d) {
        const E = IslandState.Event
        switch (event) {
        // hover and alerts are ignored on purpose; the pin timer ignores hover too
        case E.Open:     return v === root.view ? close() : open(v)
        case E.Back:     return settle()
        case E.Expire:   return rest()
        case E.Click:                                           // dead space = close
        case E.Outside:
        case E.Escape:
        case E.Close:    return close()
        }
    }

    // ---- actions ----------------------------------------------------------------
    function openHome() { return open(IslandState.View.Idle) }

    // pin a view; it may carry its own timeout (Registry), 0 = stays until closed
    function open(v) {
        if (Registry.get(v)) enter(IslandState.Phase.Pinned, v, undefined, Registry.timeout(v))
    }

    // from a view back to Idle: Idle stays up for settleMs no matter where the pointer is
    function settle() { enter(IslandState.Phase.Pinned, IslandState.View.Idle, undefined, settleMs) }

    function alert(v, d) {
        const e = Registry.get(v)
        if (e && e.hold > 0)                   // only views with a hold time can be alerts
            enter(IslandState.Phase.Transient, v, d, e.hold)
    }

    // manual close: straight to rest, even if the pointer is still over the island
    function close() { enter(IslandState.Phase.Collapsed) }

    // automatic close (timer): hover-aware
    function rest() {
        if (hovered) enter(IslandState.Phase.Peek, peekView())
        else         enter(IslandState.Phase.Collapsed)
    }

    // ---- entry action: the only place that changes phase ------------------------
    property int stateMs: 0

    function enter(newPhase, newView, newData, ms) {
        graceTimer.stop()
        stateTimer.stop()
        // view BEFORE phase, so bindings never see a half-applied state
        if (newView !== undefined) view = newView
        if (newData !== undefined) data = newData
        phase = newPhase

        stateMs = ms || 0
        stateTimer.interval = Math.max(stateMs, 1)
        // an alert waits while the pointer is on it; everything else counts down immediately
        if (stateMs > 0 && !(newPhase === IslandState.Phase.Transient && hovered))
            stateTimer.start()
    }

    function resumeStateTimer() { if (stateMs > 0) stateTimer.restart() }

    // ---- timers -----------------------------------------------------------------
    property Timer graceTimer: Timer {          // hover debounce
        interval: 140
        onTriggered: if (root.phase === IslandState.Phase.Peek && !root.hovered)
                         root.enter(IslandState.Phase.Collapsed)
    }

    property Timer stateTimer: Timer {          // "after(ms) -> Expire" for the current state
        onTriggered: root.send(IslandState.Event.Expire)
    }
}