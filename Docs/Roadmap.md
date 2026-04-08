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
- `HStack`
- `VStack`
- `ForEach`
- `Divider`
- `Spacer`
- `Color` token type

### Still Needed

- `TextField`
- `ScrollView`
- `ScrollViewReader`
- `Group`
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

### 2. Add `Group`

This is the least risky remaining piece.

- expose a public `Group` wrapper as a flattening container
- keep it behaviorally identical to a structural grouping node
- no renderer-specific target

### 3. Add renderable `Color`

`Color` already exists as a token, but not yet as a standalone visible view.

- map it to a filled LVGL object
- ensure black, white, and gray values render predictably on monochrome targets
- use it later as a building block for separators, panels, and empty states

### 4. Add `TextField`

This is the first meaningful interaction component after `Button`.

- start with single-line editing only
- use strong border affordances and a static caret if needed
- avoid placeholder styling that depends on subtle color differences
- verify redraw behavior under repeated editing

This may need explicit work in event bridging and focus handling.

### 5. Add `ScrollView`

For e-paper, scrolling should not assume touch-panning is the only interaction model.

- begin with vertical scrolling only
- expose an always-visible scrollbar/control column
- use grouped up/down arrow buttons inspired by Newton-style explicit scroll controls
- optimize for page-step and line-step movement instead of inertial scrolling

If LVGL native scrolling is used, the public Tokmak behavior should still remain explicit and monochrome-friendly.

### 6. Add `ScrollViewReader`

Only after basic scrolling works.

- support programmatic scrolling to known children
- keep the initial API small
- avoid promising full SwiftUI parity until child identity is stronger

This likely depends on better identifier handling than the current position-based reconciliation provides.

### 7. Add `ContentUnavailableView`

This should be intentionally simple on monochrome displays:

- icon or glyph
- headline
- supporting text
- optional action button

It should read like a compact empty-state card, not a full-bleed marketing panel.

## Cross-Cutting Technical Work

These items affect several views and should be tracked alongside the view work:

- reduce the manual `visitProperties` burden
- improve environment propagation coverage
- add stronger child identity support for dynamic collections
- formalize monochrome control styling in one place instead of per-view ad hoc code
- add simulator examples that specifically test e-paper legibility and scrolling affordances

## Short-Term Milestone

A practical near-term milestone is:

1. review and normalize existing controls for monochrome output
2. add `Group`
3. add renderable `Color`
4. add a minimal `TextField`

That yields a visibly more coherent e-paper UI system without immediately forcing the harder scrolling and programmatic-navigation problems.
