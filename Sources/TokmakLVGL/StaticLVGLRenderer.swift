// Copyright 2026 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import CLVGL
import TokmakCore

/// A lean, reflection-free visitor for LVGL.
/// This acts as a prototype for a static reconciler.
struct LVGLStaticVisitor: StaticReconciliationVisitor {
  let parent: UnsafeMutablePointer<lv_obj_t>
  let renderer: LVGLRenderer
  
  var currentFiber: (any AnyStaticFiber)?
  
  init(parent: UnsafeMutablePointer<lv_obj_t>, renderer: LVGLRenderer, rootFiber: (any AnyStaticFiber)?) {
    self.parent = parent
    self.renderer = renderer
    self.currentFiber = rootFiber
  }

  mutating func visit<V: View>(_ view: V) {
    // If we have a fiber, we can reuse or update its target
    let target: UnsafeMutablePointer<lv_obj_t>
    
    if let fiber = currentFiber, let existingTarget = fiber.target {
      target = existingTarget.assumingMemoryBound(to: lv_obj_t.self)
      
      // Update logic based on type
      if let text = view as? Text {
        let proxy = _TextProxy(text)
        proxy.rawText.withCString { lv_label_set_text(target, $0) }
      }
      // ... more update logic
    } else {
      // Create new target
      if let text = view as? Text {
        let label = lv_label_create(parent)!
        let proxy = _TextProxy(text)
        proxy.rawText.withCString { lv_label_set_text(label, $0) }
        target = label
      } else if let widget = view as? any AnyLVGLWidget {
        target = widget.new(renderer, parent)
      } else {
        // Fallback for non-primitives that are visited
        target = parent
      }
      
      // Store in fiber if we have one
      currentFiber?.target = UnsafeMutableRawPointer(target)
    }
    
    // Advance to next sibling/child for reconciliation
    // This is handled by the StaticView.walk calls which will update currentFiber
  }
}

/// A specialized renderer for Embedded Swift that uses static dispatch.
final class StaticLVGLRenderer {
  let screen: UnsafeMutablePointer<lv_obj_t>
  let renderer: LVGLRenderer
  
  private var rootFiber: (any AnyStaticFiber)?
  
  init() {
    self.screen = lv_scr_act()
    self.renderer = LVGLRenderer(EmptyApp())
  }
  
  func render<V: StaticView>(_ view: V) {
    if rootFiber == nil {
      rootFiber = StaticFiber<V>()
    }
    
    var visitor = LVGLStaticVisitor(parent: screen, renderer: renderer, rootFiber: rootFiber)
    view.walk(&visitor)
  }
}

private struct EmptyApp: App {
    var body: some Scene { WindowGroup { EmptyView() } }
}
