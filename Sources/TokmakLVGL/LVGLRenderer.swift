// Copyright 2026 Checle LLC
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
struct LVGLVisitor: ReconciliationWalker, AppWalker {
  var parent: UnsafeMutablePointer<lv_obj_t>
  let renderer: LVGLRenderer
  
  var currentFiber: (any AnyFiber)?
  var childIndex: Int = 0
  
  init(parent: UnsafeMutablePointer<lv_obj_t>, renderer: LVGLRenderer, rootFiber: (any AnyFiber)?) {
    self.parent = parent
    self.renderer = renderer
    self.currentFiber = rootFiber
  }

  mutating func visit<A: App>(_ app: A) {
    let originalFiber = currentFiber
    let originalIndex = childIndex
    
    currentFiber = currentFiber?.makeChild(A.self, at: childIndex)
    childIndex = 0
    
    // Apps are transparent, continue to body
    app.body.walk(&self)
    
    currentFiber = originalFiber
    childIndex = originalIndex + 1
  }

  mutating func visit<S: Scene>(_ scene: S) {
    let originalFiber = currentFiber
    let originalIndex = childIndex
    
    currentFiber = currentFiber?.makeChild(S.self, at: childIndex)
    childIndex = 0
    
    // Scenes are transparent, continue to body
    scene.body.walk(&self)
    
    currentFiber = originalFiber
    childIndex = originalIndex + 1
  }

  mutating func visit<V: View>(_ view: V) {
    let originalFiber = currentFiber
    let originalIndex = childIndex
    
    let fiber = currentFiber?.makeChild(V.self, at: childIndex)
    currentFiber = fiber
    childIndex = 0
    
    // If we have a fiber, we can reuse or update its target
    let target: UnsafeMutablePointer<lv_obj_t>
    
    if let existingTarget = fiber?.target {
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
      fiber?.target = UnsafeMutableRawPointer(target)
    }

    // Primitive views don't have bodies to walk, they manage their own children.
    // Non-primitives walk their body.
    if !(view is any _PrimitiveView) {
      let originalParent = parent
      parent = target
      view.body.walk(&self)
      parent = originalParent
    }
    
    currentFiber = originalFiber
    childIndex = originalIndex + 1
  }
}

/// A specialized renderer for Embedded Swift that uses static dispatch.
final class LVGLRenderer {
  static var shared: LVGLRenderer?
  
  let screen: UnsafeMutablePointer<lv_obj_t>
  
  private var rootFiber: (any AnyFiber)?
  private var rootApp: (any App)?
  
  init() {
    self.screen = lv_scr_act()
    Self.shared = self
  }
  
  func render<A: App>(_ app: A) {
    self.rootApp = app
    if rootFiber == nil {
      rootFiber = Fiber<A>()
    }
    
    var visitor = LVGLVisitor(parent: screen, renderer: self, rootFiber: rootFiber)
    app.walk(&visitor)
  }

  func requestRedraw() {
    guard let rootApp = rootApp else { return }
    var visitor = LVGLVisitor(parent: screen, renderer: self, rootFiber: rootFiber)
    rootApp.walk(&visitor)
    lv_refr_now(nil)
  }
}

private struct EmptyApp: App {
    var body: some Scene { WindowGroup { EmptyView() } }
}
