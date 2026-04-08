# Tokmak Development Plan

Tokmak is a SwiftUI-compatible framework for Embedded Swift using LVGL. It focuses on a static, reflection-free approach to UI tree management and reconciliation.

## Current State

### Core Architecture
- **Reflection-Free:** Avoids `Mirror` and runtime reflection to remain compatible with Embedded Swift.
- **Static Reconciliation:** Uses a `Walker` / `Visitor` pattern to traverse the UI tree and link state to a persistent `Fiber` tree.
- **Fiber Tree:** A persistent tree structure that stores state and renderer-specific targets (LVGL objects).
- **LVGL Backend:** Currently supports basic `Text` rendering and allows custom `DisplayConfiguration` for hardware integration.

### Implemented Components
- **App/Scene/View Protocols:** Basic structure for SwiftUI-like apps.
- **State/Binding:** Basic state management linked to Fibers.
- **Text View:** Primitive view that maps to `lv_label`.
- **LVGLRenderer:** Manages the main render loop and tree traversal.

## Roadmap & Planning

### Versioning and Commits
- We adhere to semantic versioning.
- Make as few commits as possible (ideally 0 or 1 per session). Do not flood the history. Bundle changes together.
- Commit messages must be simple: just a verb and minimal info (e.g., "Add LVGL layout and e-paper driver"). Do not use conventional prefixes like `feat:` or `refactor:`.
- **No Amending / Force Pushing:** Do not use `git commit --amend` or `git push -f`. Once a commit is pushed, leave it alone.
- **Author & Committer Requirement:** Automated commits should use the active coding agent identity, with author and committer set to match. For Codex sessions, use `OpenAI Codex <codex@checle.com>`. For Gemini sessions, use `Google Gemini <gemini@checle.com>`.
- Codex command format:
  `GIT_COMMITTER_NAME="OpenAI Codex" GIT_COMMITTER_EMAIL="codex@checle.com" git commit --author="OpenAI Codex <codex@checle.com>" -m "..."`
- Gemini command format:
  `GIT_COMMITTER_NAME="Google Gemini" GIT_COMMITTER_EMAIL="gemini@checle.com" git commit --author="Google Gemini <gemini@checle.com>" -m "..."`

### 1. Robust State Management (Priority: High)
- [ ] Implement `visitProperties` in common views or provide a macro-like solution (if possible in Swift Embedded) to avoid manual implementation.
- [ ] Ensure all `DynamicProperty` types are correctly linked to Fibers.
- [ ] Implement `Environment` support using the same static traversal pattern.

### 2. Layout System (Priority: High)
- [x] Implement a basic layout system that maps to LVGL's flex/grid or manual positioning.
- [x] Support `VStack`, `HStack`, and `ZStack`.
- [x] Support `Padding` and `Frame` modifiers.

### 3. Basic UI Components (Priority: Medium)
- [x] `Button` with action support.
- [ ] `Image` (mapping to `lv_img`).
- [x] `Spacer`.
- [ ] `ScrollView`.

### 4. Input Handling & Emulation (Priority: Medium)
- [x] Add macOS/Linux SDL simulator (`App.mainSDL()`) to bypass E-Paper and accelerate desktop UI testing.
- [ ] Integrate hardware LVGL input device driver (touch, keypad, encoder).
- [ ] Map LVGL events to SwiftUI-like gestures or actions.

### 5. Optimization for Embedded (Priority: Ongoing)
- [ ] Minimize memory allocations.
- [ ] Optimize tree reconciliation to only visit dirty branches.
- [ ] Ensure `static` dispatch is used wherever possible.

## Design Decisions

- **Static vs Dynamic:** We choose static traversal via `walk` and `visitProperties` over `Mirror` because Embedded Swift's reflection support is limited and we want to avoid its overhead.
- **Manual Property Visitation:** Currently, developers must manually implement `visitProperties` for custom views that use `@State`. We should explore ways to automate this or make it less error-prone.
- **LVGL Integration:** We use `user_data` in LVGL objects to store references back to our Swift structures when necessary, but prefer keeping the Swift-to-C mapping unidirectional (Swift owns the C pointers).

### Hardware Abstraction & Display Drivers
- **API Surface (The "No New API" Goal):** The absolute minimum required deviation from standard SwiftUI is initialization. This is handled by a parameterless `App.main()`, which internally wires up the hardware driver and LVGL.
- **Driver Ownership & External Symbols:** The hardware display driver (e-paper driver) is owned within the `CLVGL` package. Instead of using dynamic Swift closures for hardware abstraction, we define the target system via macro constants (e.g., `#define TOKMAK_PLATFORM_PICO 1`). The driver then declares external C symbols (like `gpio_put` and `sleep_ms`) and `extern const uint32_t` pin definitions. The user's application links against the appropriate SDK (like the Pi Pico SDK) and provides these symbols, resolving them statically at link-time. This provides a zero-overhead, highly portable bare-metal integration.
- **Target Display (GDEY037T03):** The primary target is the Good Display GDEY037T03 (3.7", 416x240, UC8253 controller).
- **E-Paper Library Evaluation for Target:**
  - **bb_epaper:** While highly portable, it **does not** explicitly support the GDEY037T03 or its UC8253 controller. It is not a viable out-of-the-box solution for this specific hardware.
  - **GxEPD2:** Has **explicit, excellent support** for the GDEY037T03 (`GxEPD2_370_T03` class). However, it is heavily tied to the Arduino ecosystem (`Adafruit_GFX`, Arduino `SPI` class).
  - **Official C Drivers (Good Display / Waveshare):** Provide raw, low-level C code specifically for the UC8253 controller.
  - **Conclusion:** Because `bb_epaper` lacks support for our target, and `GxEPD2` is tied to Arduino, the most robust path for a pure Embedded Swift / C environment is to **extract the official C driver code for the GDEY037T03 (UC8253)**. We will bundle these minimal C files into the `CLVGL` target and provide a clean Swift HAL for the SPI/GPIO dependencies. Alternatively, we could manually port just the `GxEPD2_370_T03` class logic to pure C.
es. Alternatively, we could manually port just the `GxEPD2_370_T03` class logic to pure C.
