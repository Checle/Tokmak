# TokamakLVGL Implementation Guide

This guide explains how to extend the TokamakLVGL renderer with additional views and features.

## Project Structure

```
Sources/TokamakLVGL/
├── Core.swift                 # Type aliases and re-exports from TokamakCore
├── LVGLRenderer.swift        # Main renderer implementation
├── Widget.swift              # Target type and AnyLVGLWidget protocol
├── Views/
│   ├── Text.swift            # Text view implementation
│   ├── Button.swift          # (can be added)
│   ├── Stack.swift           # (can be added for HStack/VStack)
│   └── ...
├── Modifiers/
│   ├── Frame.swift           # (can be added)
│   └── ...
└── App/
    └── App.swift             # App launching and lifecycle

Sources/TokamakLVGLDemo/
└── main.swift                # Demo application

Sources/CLVGL/
├── module.modulemap          # LVGL module definition
└── include/
    └── lvgl_shim.h          # LVGL C API shim
```

## Step-by-Step: Adding a New View

### 1. Text View (Already Implemented)

The Text view is the foundation. Here's what it does:

```swift
extension Text: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer) -> UnsafeMutablePointer<lv_obj_t> {
    // Create LVGL object
    let label = lv_label_create(lv_scr_act())
    
    // Get text content from the view
    let proxy = _TextProxy(self)
    
    // Set text on the LVGL object
    let text = proxy.rawText
    text.withCString { cString in
      lv_label_set_text(label, cString)
    }
    
    return label
  }

  func update(widget: LVGLWidget) {
    if case let .widget(w) = widget.storage {
      let text = _TextProxy(self).rawText
      text.withCString { cString in
        lv_label_set_text(w, cString)
      }
    }
  }
}
```

### 2. Button View (Template)

To add Button support, create `Sources/TokamakLVGL/Views/Button.swift`:

```swift
import CLVGL
import TokamakCore

extension Button: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer) -> UnsafeMutablePointer<lv_obj_t> {
    // Create button object
    let button = lv_btn_create(lv_scr_act())
    
    // Create label for button text
    let label = lv_label_create(button)
    lv_label_set_text(label, "Button")
    
    // Set button size and properties
    lv_obj_set_size(button, 100, 40)
    
    // Store button reference somewhere (for later action handling)
    // This requires implementing action handling
    
    return button
  }

  func update(widget: LVGLWidget) {
    if case let .widget(w) = widget.storage {
      // Update button state when props change
      // e.g., update label text, enable/disable
    }
  }
}
```

### 3. VStack / HStack (Template)

Stack views are container views that arrange their children. These need special handling because they don't directly map to a single LVGL object:

```swift
import CLVGL
import TokamakCore

extension VStack: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer) -> UnsafeMutablePointer<lv_obj_t> {
    // Create a container
    let container = lv_obj_create(lv_scr_act())
    
    // Configure container for vertical layout
    // LVGL uses lv_obj_set_layout to manage child positioning
    lv_obj_set_layout(container, LV_LAYOUT_COLUMN_MID)
    
    return container
  }

  func update(widget: LVGLWidget) {
    if case let .widget(w) = widget.storage {
      // Update spacing, padding, alignment
      let spacing = self.spacing ?? 0
      // Apply spacing to LVGL layout
    }
  }
}

extension HStack: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer) -> UnsafeMutablePointer<lv_obj_t> {
    let container = lv_obj_create(lv_scr_act())
    lv_obj_set_layout(container, LV_LAYOUT_ROW_MID)
    return container
  }

  func update(widget: LVGLWidget) {
    if case let .widget(w) = widget.storage {
      // Update layout properties
    }
  }
}
```

### 4. View Modifiers

Modifiers like `.padding()`, `.frame()`, etc. need special handling. Add support in `Sources/TokamakLVGL/Modifiers/`:

```swift
// Modifiers/Frame.swift
import CLVGL
import TokamakCore

extension ModifiedContent where Modifier: _FrameModifier {
  // Handle frame modification
}
```

## Understanding the Reconciliation Process

The reconciler calls renderer methods in this sequence:

```
1. View tree built
   ↓
2. For each view:
   - `isPrimitiveView()` checks if view is LVGL-specific
   - If primitive, `primitiveBody()` gets the rendered version
   ↓
3. `mountTarget()` creates LVGL objects
   ↓
4. State change → `update()` modifies LVGL objects
   ↓
5. View removed → `unmount()` deletes LVGL objects
```

## Key Functions

### lv_obj_t Manipulation

Common LVGL functions for object manipulation:

```c
// Creation
lv_obj_t * lv_obj_create(lv_obj_t * parent);
lv_obj_t * lv_label_create(lv_obj_t * parent);
lv_obj_t * lv_btn_create(lv_obj_t * parent);

// Positioning & Sizing
void lv_obj_set_size(lv_obj_t * obj, lv_coord_t w, lv_coord_t h);
void lv_obj_set_pos(lv_obj_t * obj, lv_coord_t x, lv_coord_t y);
void lv_obj_set_align(lv_obj_t * obj, lv_align_t align);

// Properties
void lv_obj_set_style_bg_color(lv_obj_t * obj, lv_color_t color, lv_part_t part);
void lv_label_set_text(lv_obj_t * obj, const char * text);

// Hierarchy
void lv_obj_set_parent(lv_obj_t * obj, lv_obj_t * parent);
void lv_obj_del(lv_obj_t * obj);

// Refresh
void lv_refr_now(lv_disp_t * disp);
```

### Type Casting in Swift

LVGL uses void pointers extensively. Use memory rebinding for type casting:

```swift
// Reinterpret pointer types
widget.withMemoryRebound(to: GtkLabel.self, capacity: 1) {
  gtk_label_set_text($0, "text")
}

// For LVGL (less common since lv_obj_t is typically used directly)
pointer.withMemoryRebound(to: lv_obj_t.self, capacity: 1) { obj in
  lv_obj_set_size(obj, width, height)
}
```

## Integration Pattern

Each view type follows this pattern:

1. **Conform to `AnyLVGLWidget`**:
   ```swift
   extension MyView: AnyLVGLWidget {
     // Implement required methods
   }
   ```

2. **Implement `new()`**:
   - Create the LVGL object
   - Set initial properties from the view
   - Return the created object

3. **Implement `update()`**:
   - Extract the LVGL object from widget storage
   - Update its properties based on view state changes

4. **Optional: Set `expand`**:
   ```swift
   var expand: Bool { true } // for flexible sizing
   ```

## Testing Your Implementation

1. Add views to `TokamakLVGLDemo`
2. Run the demo: `swift run TokamakLVGLDemo`
3. Check visual output on LVGL display
4. Verify state updates work correctly

## Common Patterns

### Getting view properties
```swift
let proxy = _TextProxy(self)
let text = proxy.rawText
```

### Converting Swift String to C String
```swift
let text = "Hello"
text.withCString { cString in
  lv_label_set_text(label, cString)
}
```

### Accessing stored widgets
```swift
if case let .widget(w) = widget.storage {
  // w is UnsafeMutablePointer<lv_obj_t>
}
```

## Performance Considerations

1. **Memory**: LVGL is designed for low-memory environments
2. **Refresh Rate**: Call `lv_refr_now()` judiciously
3. **Object Reuse**: Update existing objects rather than recreating
4. **Batch Updates**: Group updates to minimize refresh calls

## Debugging

1. Enable LVGL logging
2. Print reconciler state changes
3. Verify C function calls succeed
4. Check memory usage on embedded systems

## References

- LVGL API: https://docs.lvgl.io/latest/en/html/
- Tokamak Core: https://github.com/TokamakUI/Tokamak/tree/main/Sources/TokamakCore
- GTK Renderer (reference): `Sources/TokamakGTK/`
