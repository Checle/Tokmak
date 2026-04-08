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
- `HStack`
- `VStack`
- `ZStack`
- `Spacer`
- `Divider`
- `ForEach`
- `Padding`
- `Frame`
- `foregroundColor` environment support for `Text`

## Important Limitations

### Reconciliation

- child identity is still position-based
- `ForEach` accepts `id:` for API compatibility, but keyed move reconciliation is not implemented yet
- custom views with dynamic properties still rely on manual `visitProperties`

### Styling and Design

- the framework is still function-first rather than style-system-first
- most controls use LVGL defaults with only light normalization
- monochrome and e-paper visual language is not yet enforced across all controls

### Missing or Partial Surface Area

- `TextField`
- `ScrollView`
- `ScrollViewReader`
- `ContentUnavailableView`
- `Group` as an explicit public surface type
- `Color` as a renderable fill/background primitive

## E-Paper Direction

The primary target is not a high-DPI phone-like UI. Tokmak should prefer:

- crisp 1-bit-friendly shapes
- strong outlines over soft fills
- clear spacing and large touch targets
- explicit affordances for scrolling and input
- layouts that remain legible on low-refresh, pixelated displays
