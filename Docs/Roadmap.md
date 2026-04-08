# Tokmak View Roadmap

This roadmap focuses on the currently requested view set and the design direction for monochrome e-paper targets.

## Design Direction

Tokmak should not drift toward generic modern mobile styling. The better reference point is monochrome PDA software, especially Newton-era control design:

- black, white, and a small number of halftone or gray steps
- clear borders and recessed/raised control shapes
- no overlay scrollbars
- scroll controls that remain visible and operable without gestures
- typography and spacing that survive pixelation and slow refresh

Newton OS is a useful reference for this direction because its UI treated low-resolution monochrome input as a first-class target rather than as a degraded version of a richer display. GUIdebook’s Newton screenshots are a good starting point for reviewing that control language:

- https://guidebookgallery.org/guis/newton/screenshots

## Implementation Principles

- prefer simple LVGL primitives over deep abstraction if they render cleanly on e-paper
- prioritize deterministic layout and visible affordances over animation or ornament
- default to monochrome-safe visuals even in the SDL simulator
- avoid APIs that require complex keyed diffing until the fiber model supports them properly

## Requested View Set

### Already Present

- `Text`
- `Image`
- `Button`
- `TextField`
- `HStack`
- `VStack`
- `ScrollView`
- `ScrollViewReader`
- `ForEach`
- `Group`
- `Divider`
- `Spacer`
- `ContentUnavailableView`
- renderable `Color`

## Proposed Order

### 1. Review and tighten existing controls

Before adding more API, normalize the controls that already exist for monochrome output:

- `Text`: default font sizes, wrapping, alignment, and contrast
- `Button`: border weight, padding, focus/pressed states, monochrome-safe fill strategy
- `Image`: clarify whether the expected source is file path, LVGL symbol, or preprocessed bitmap
- `Divider`: confirm thickness and contrast on e-paper
- `HStack` / `VStack` / `Spacer`: verify spacing defaults on narrow portrait displays

This step should also review whether current LVGL default styling leaks through anywhere it should not.

### 2. Harden text and image behavior

The basic APIs exist, but some renderer behavior still needs tightening.

- make `Text` honor alignment and wrapping environment consistently
- keep `Image` source expectations explicit: LVGL symbol, LVGL file path, or preprocessed bitmap
- improve how framed text and placeholder/empty-state text constrain and wrap

### 3. Strengthen control styling

Current controls are usable, but not yet a coherent low-refresh control set.

- formalize button, input, divider, and scroll visuals in one place
- remove remaining LVGL-default leakage
- verify controls on narrow portrait layouts and pixelated rendering

### 4. Improve explicit scrolling affordances

The APIs exist, but the UX is still closer to LVGL defaults than to the target e-paper interaction model.

- add visible up/down controls inspired by Newton-style grouped arrows
- keep gesture scrolling available in the simulator, but not as the only affordance
- verify programmatic scrolling and manual scrolling do not fight each other

### 5. Refine `ContentUnavailableView`

This should be intentionally simple on monochrome displays:

- icon or glyph
- headline
- supporting text
- optional action button

It should read like a compact empty-state card, not a full-bleed marketing panel.

### 6. Improve child identity

- build on the current `.id(...)` and `ForEach(id:)` support
- extend identity handling beyond simple insert/remove/reorder cases
- avoid claiming full keyed diffing until moves and removals are matched reliably across the whole tree

## Cross-Cutting Technical Work

These items affect several views and should be tracked alongside the view work:

- reduce the manual `visitProperties` burden
- improve environment propagation coverage
- add stronger child identity support for dynamic collections
- formalize monochrome control styling in one place instead of per-view ad hoc code
- add simulator examples that specifically test e-paper legibility and scrolling affordances

## Short-Term Milestone

A practical near-term milestone is:

1. tighten text/image behavior and alignment
2. formalize monochrome control styling
3. add explicit e-paper-friendly scroll affordances
4. strengthen keyed reconciliation beyond the current `.id(...)` baseline

That keeps the current view surface usable while shifting from “implemented” to “reliable and shaped for the target”.
