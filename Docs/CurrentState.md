# Tokmak Current State

Tokmak is a SwiftUI-compatible framework for Embedded Swift on top of LVGL. The current codebase is explicitly optimized for static traversal and low runtime complexity rather than full SwiftUI API coverage.

## Architecture

- Reflection-free traversal via `walk` and `visitProperties`
- Persistent fiber tree used for state storage and renderer targets
- LVGL backend with desktop SDL simulation and embedded display-driver integration
- Position-based reconciliation with subtree pruning

## What Works Today

### App and Scene Layer

- `App`, `Scene`, `WindowGroup`
- scene conditionals
- tuple scenes
- desktop simulator startup via SDL
- embedded display configuration plumbing for e-paper targets

### State and Traversal

- `@State` linked to fibers
- static property visitation
- redraw requests from state changes
- subtree cleanup for stale branches

### Views and Modifiers

- `Text`
- `Image`
- `Button`
- `TextField`
- `HStack`
- `VStack`
- `ZStack`
- `ScrollView`
- `ScrollViewReader`
- `Spacer`
- `Divider`
- `ForEach`
- `Group`
- `ContentUnavailableView`
- renderable `Color`
- `Padding`
- `Frame`
- `foregroundColor` environment support for `Text`
- `multilineTextAlignment` environment support for `Text`

## Important Limitations

### Reconciliation

- unkeyed children are still position-based
- `.id(...)` and `ForEach(id:)` now preserve identified fibers across inserts, removals, and simple reorders
- reconciliation is still not a full general-purpose keyed diff
- custom views with dynamic properties still rely on manual `visitProperties`

### Styling and Design

- the framework is still function-first rather than style-system-first
- controls are partially normalized for monochrome simulation, but not yet fully systematized
- the current simulator styling is coherent enough for testing, but still not a finished e-paper design language

### Missing or Partial Surface Area

- `TextField` is minimal and single-line only
- `ScrollView` now includes explicit vertical step controls, but still relies on LVGL-native scrolling underneath
- `ScrollViewReader` currently supports narrow `scrollTo` behavior through `.id(...)`
- `Image` supports LVGL sources and symbol-backed images, but not a broader asset pipeline
- `Color` renders as a visible fill view, but it is still primitive rather than a full background system

## E-Paper Direction

The primary target is not a high-DPI phone-like UI. Tokmak should prefer:

- crisp 1-bit-friendly shapes
- strong outlines over soft fills
- clear spacing and large touch targets
- explicit affordances for scrolling and input
- layouts that remain legible on low-refresh, pixelated displays
