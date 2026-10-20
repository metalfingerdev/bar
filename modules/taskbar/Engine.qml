pragma Singleton

import QtQuick

// Island statechart, v2.
//
//   phase   Rest    resting; shows restView (Compact)
//           Peek    pointer is hovering a resting island; shows peekView (Idle)
//           Pinned  a view the user opened; optional timeout
//           Toast   an alert that interrupted; timed by Registry.hold
//
//   events  everything enters through send(event, data). `data` is an object:
//             { view }  for Open / Alert
//             { x }     for Click   (window-space x of the click -> pointer anchoring)
//
//   timers  only ever send Expire (state timer) or collapse a hover (grace timer).
//   enter() is the only function that assigns `phase`.
QtObject {
    id: root

    enum Phase  { Rest, Peek, Pinned, Toast }
    enum Event  { HoverIn, HoverOut, Click, Outside, Escape, Open, Back, Alert, Expire, Close, Engage, Release }
    enum View   { Idle, Media, Notify, Compact, Dashboard, Volume, Brightness, Theme, Bluetooth, Launcher, Workspaces }
    enum Widget { Clock, Date }

    // ---- config (never changed by send) ----
    property int reserve: 64                         // px the spacer window reserves at the top; 0 = none
    property int gap: 8                              // island distance from the top edge
    property int restView: Engine.View.Compact
    property int peekView: Engine.View.Idle
    property int homeView: Engine.View.Idle          // Click on a resting island / Back with no history
    property int compactWidget: Engine.Widget.Clock
    readonly property int graceMs: 140               // hover-out debounce
    readonly property int morphMs: 320               // island width/height animation

    // ---- state ----
    property int phase: Engine.Phase.Rest
    property int view: Engine.View.Compact
    property bool hovered: false                     // tracked in every phase
    property bool engaged: false                     // the view says "user is working in me"
    property var history: []                         // views to return to on Back (immutable updates)
    property int queued: -1                          // one deferred alert while Pinned
    property real pointerX: -1                       // window x of the click that opened this view, -1 = none
    property int stateMs: 0                          // duration of the current timed state

    // ---- derived: what the rest of the shell reads ----
    readonly property bool timed:    phase === Engine.Phase.Pinned || phase === Engine.Phase.Toast
    readonly property bool holding:  hovered || engaged                       // pauses the state timer
    readonly property bool grabbing: phase === Engine.Phase.Pinned           // Bar: grab focus -> detect outside clicks
    readonly property bool keyboard: (phase === Engine.Phase.Pinned || hovered) && Registry.wantsKeys(view)
    readonly property real anchorX:  Registry.follows(view) ? pointerX : -1  // Island: centre on this x, -1 = screen centre

    // ---- the one entry point ---------------------------------------------------
    function send(event, data) {
        const E = Engine.Event
        const d = data || {}

        // pointer + engagement are tracked regardless of phase
        switch (event) {
        case E.HoverIn:  hovered = true;  graceTimer.stop(); stateTimer.stop(); break
        case E.HoverOut: hovered = false; resume(); break
        case E.Engage:   return engage(true)
        case E.Release:  return engage(false)
        }

        switch (phase) {
        case Engine.Phase.Rest:   return whenRest(event, d)
        case Engine.Phase.Peek:   return whenPeek(event, d)
        case Engine.Phase.Toast:  return whenToast(event, d)
        case Engine.Phase.Pinned: return whenPinned(event, d)
        }
    }

    // ---- transition table: one function per phase --------------------------------
    function whenRest(event, d) {
        const E = Engine.Event
        switch (event) {
        case E.HoverIn: return enter(Engine.Phase.Peek, peekView)
        case E.Click:   return pin(homeView, d.x)
        case E.Open:    return pin(d.view, d.x)
        case E.Alert:   return toast(d.view)
        }
    }

    function whenPeek(event, d) {
        const E = Engine.Event
        switch (event) {
        case E.HoverOut: return graceTimer.restart()
        case E.Click:    return pin(homeView, d.x)
        case E.Open:     return pin(d.view, d.x)
        case E.Alert:    return toast(d.view)
        case E.Close:    return close()
        }
    }

    function whenToast(event, d) {
        const E = Engine.Event
        switch (event) {
        case E.Expire:   return rest()
        case E.Click:    return pin(view, d.x)               // click a toast -> expand it
        case E.Open:     return pin(d.view, d.x)
        case E.Back:     return back()
        case E.Alert:    if (Registry.priority(d.view) >= Registry.priority(view)) toast(d.view); return
        case E.Outside:
        case E.Escape:
        case E.Close:    return close()
        }
    }

    function whenPinned(event, d) {
        const E = Engine.Event
        switch (event) {
        case E.Alert:    return defer(d.view)
        case E.Open:     return d.view === view ? close() : pin(d.view, d.x)
        case E.Back:     return back()
        case E.Expire:   return rest()
        case E.Click:                                        // empty island surface (views handle their own clicks)
        case E.Outside:
        case E.Escape:
        case E.Close:    return close()
        }
    }

    // ---- actions ---------------------------------------------------------------
    function pin(v, x) {
        if (!Registry.get(v)) return
        if (phase === Engine.Phase.Pinned && v === view) return
        if (phase === Engine.Phase.Pinned) history = history.concat([view])   // only real pinned views are history
        pointerX = (x === undefined) ? -1 : x
        enter(Engine.Phase.Pinned, v, Registry.timeout(v))
    }

    function toast(v) {
        const e = Registry.get(v)
        if (!e || !(e.hold > 0)) return
        pointerX = -1
        enter(Engine.Phase.Toast, v, e.sticky ? 0 : e.hold)
    }

    function back() {
        if (history.length > 0) {
            const prev = history[history.length - 1]
            history = history.slice(0, -1)
            enter(Engine.Phase.Pinned, prev, Registry.timeout(prev))
        } else if (view !== homeView) {
            enter(Engine.Phase.Pinned, homeView, Registry.timeout(homeView))
        } else {
            close()
        }
    }

    function defer(v) {
        if (Registry.defers(v) && Registry.priority(v) >= Registry.priority(queued))
            queued = v
    }

    function flush() {
        if (queued === -1) return false
        const v = queued
        queued = -1
        toast(v)
        return true
    }

    // manual close: straight to rest, even if the pointer is still over the island
    function close() { if (!flush()) enter(Engine.Phase.Rest, restView) }

    // automatic close (timer): hover-aware
    function rest() {
        if (flush()) return
        if (hovered) enter(Engine.Phase.Peek, peekView)
        else         enter(Engine.Phase.Rest, restView)
    }

    // ---- entry action: the only place that changes phase --------------------------
    function enter(p, v, ms) {
        graceTimer.stop()
        stateTimer.stop()

        if (p === Engine.Phase.Rest) {
            history = []
            pointerX = -1
        }
        if (p === Engine.Phase.Rest || v !== view)
            engaged = false                                  // engagement belongs to the view that reported it

        view = v
        phase = p

        stateMs = ms || 0
        stateTimer.interval = Math.max(stateMs, 1)
        if (timed && stateMs > 0 && !holding) stateTimer.start()
    }

    // keyboard/work twin of hover: only timed phases have a timer to pause
    function engage(on) {
        const next = on && timed
        if (engaged === next) return
        engaged = next
        if (next) stateTimer.stop()
        else      resume()
    }

    function resume() { if (timed && stateMs > 0 && !holding) stateTimer.restart() }

    // ---- timers ------------------------------------------------------------------
    property Timer graceTimer: Timer {
        interval: root.graceMs
        onTriggered: if (root.phase === Engine.Phase.Peek && !root.hovered)
                         root.enter(Engine.Phase.Rest, root.restView)
    }

    property Timer stateTimer: Timer {
        onTriggered: root.send(Engine.Event.Expire)
    }
}
