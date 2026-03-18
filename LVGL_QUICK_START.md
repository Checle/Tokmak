# TokmakLVGL Quick Start Guide

## File Structure Created

```
Tokmak/
├── Package.swift (updated)
├── LVGL_RENDERER_README.md (new)
├── LVGL_IMPLEMENTATION_GUIDE.md (new)
└── Sources/
    ├── CLVGL/ (new)
    │   ├── module.modulemap
    │   └── include/
    │       └── lvgl_shim.h
    ├── TokmakLVGL/ (new)
    │   ├── Core.swift
    │   ├── Widget.swift
    │   ├── LVGLRenderer.swift
    │   ├── Views/
    │   │   ├── Text.swift
    │   │   ├── Stack.swift
    │   │   └── Spacer.swift
    │   ├── App/
    │   │   └── App.swift
    │   └── Modifiers/ (ready for extensions)
    └── TokmakLVGLDemo/ (new)
        └── main.swift
```

## Quick Start

### 1. Install Dependencies

On macOS:
```bash
brew install gtk+3 lvgl
```

On Linux (Debian/Ubuntu):
```bash
sudo apt-get install liblvgl-dev
```

### 2. Build the Project

```bash
cd /Users/filip/Desktop/New/Tokmak
swift build
```

### 3. Run the Demo

```bash
swift run TokmakLVGLDemo
```

## Basic App Example

```swift
import TokmakLVGL

struct MyApp: App {
  var body: some Scene {
    WindowGroup("My LVGL App") {
      VStack(spacing: 16) {
        Text("Hello, LVGL!")
        Spacer()
        Text("Powered by Tokmak")
      }
      .padding()
    }
  }
}

@main
struct Main {
  static func main() {
    MyApp.main()
  }
}
```

## Adding New Views

### Template for Adding a View

Create `Sources/TokmakLVGL/Views/YourView.swift`:

```swift
import CLVGL
import TokmakCore

extension YourView: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer) -> UnsafeMutablePointer<lv_obj_t> {
    // 1. Create LVGL object
    let obj = lv_TYPE_create(lv_scr_act())
    
    // 2. Configure initial state
    // ... set properties ...
    
    // 3. Return the object
    return obj
  }

  func update(widget: LVGLWidget) {
    if case let .widget(w) = widget.storage {
      // Update LVGL object when state changes
      // ... update properties ...
    }
  }
  
  // Optional: allow flexible sizing
  var expand: Bool { true }
}
```

## Architecture Overview

```
Tokmak App Code
       ↓
StackReconciler (from TokmakCore)
       ↓
LVGLRenderer.mountTarget() → creates lv_obj_t
LVGLRenderer.update()     → updates lv_obj_t
LVGLRenderer.unmount()    → deletes lv_obj_t
       ↓
AnyLVGLWidget implementations
       ↓
LVGL C Library (lv_obj_t, lv_label_create, etc.)
       ↓
Display Driver (hardware-specific)
```

## Currently Supported Views

| View | Status | Implementation |
|------|--------|-----------------|
| Text | ✅ | LVGL label (lv_label) |
| VStack | ✅ | LVGL vertical layout |
| HStack | ✅ | LVGL horizontal layout |
| ZStack | ✅ | LVGL overlay container |
| Spacer | ✅ | LVGL flexible spacer |
| EmptyView | ✅ | Hidden container |
| Button | ⏳ | Template provided |
| TextField | ⏳ | New view needed |
| Image | ⏳ | New view needed |
| ScrollView | ⏳ | New view needed |

## Key Integration Points

### AnyLVGLWidget Protocol
Every supported view must conform to this:
```swift
protocol AnyLVGLWidget {
  var expand: Bool { get }
  func new(_ renderer: LVGLRenderer) -> UnsafeMutablePointer<lv_obj_t>
  func update(widget: LVGLWidget)
}
```

### LVGLRenderer
Main renderer class that bridges Tokmak to LVGL:
- Implements `Renderer` protocol from TokmakCore
- Manages reconciliation cycle
- Handles object lifecycle

### LVGLWidget
Target type that stores LVGL object reference:
```swift
final class LVGLWidget: Target {
  enum Storage {
    case screen(UnsafeMutablePointer<lv_obj_t>)
    case widget(UnsafeMutablePointer<lv_obj_t>)
  }
}
```

## Common LVGL Function Reference

```c
// Object creation
lv_obj_t * lv_obj_create(lv_obj_t * parent);
lv_obj_t * lv_label_create(lv_obj_t * parent);

// Properties
void lv_obj_set_size(lv_obj_t * obj, lv_coord_t w, lv_coord_t h);
void lv_obj_set_pos(lv_obj_t * obj, lv_coord_t x, lv_coord_t y);
void lv_label_set_text(lv_obj_t * obj, const char * text);

// Children
void lv_obj_set_parent(lv_obj_t * obj, lv_obj_t * parent);

// Cleanup
void lv_obj_del(lv_obj_t * obj);

// Layout
void lv_obj_set_layout(lv_obj_t * obj, lv_layout_t type);

// Refresh display
void lv_refr_now(lv_disp_t * disp);
```

## Display Driver Setup

LVGL requires a display driver to be initialized before use. This depends on your target platform:

```c
// Example (platform-specific)
void setup_display() {
  lv_init();
  
  static lv_disp_draw_buf_t draw_buf;
  static lv_color_t buf[LCD_H_RES * 10];
  lv_disp_draw_buf_init(&draw_buf, buf, NULL, LCD_H_RES * 10);
  
  static lv_disp_drv_t disp_drv;
  lv_disp_drv_init(&disp_drv);
  disp_drv.hor_res = LCD_H_RES;
  disp_drv.ver_res = LCD_V_RES;
  disp_drv.draw_buf = &draw_buf;
  disp_drv.flush_cb = flush_cb;
  lv_disp_drv_register(&disp_drv);
}
```

## Next Steps

1. **Test the build**: Run `swift build` to verify compilation
2. **Create a demo**: Extend demo with more complex layouts
3. **Add views**: Implement Button, TextField, Image support
4. **Add modifiers**: Implement padding, frame, color modifiers
5. **Add input handling**: Implement keyboard and touch support

## Resources

- [LVGL Documentation](https://docs.lvgl.io/)
- [Tokmak GitHub](https://github.com/TokmakUI/Tokmak)
- Full guides: See `LVGL_RENDERER_README.md` and `LVGL_IMPLEMENTATION_GUIDE.md`
