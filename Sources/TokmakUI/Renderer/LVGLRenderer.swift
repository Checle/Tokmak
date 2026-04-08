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

/// A lean, reflection-free visitor for LVGL.
struct LVGLVisitor: ReconciliationWalker, AppWalker, PropertyVisitor {
  var parent: UnsafeMutablePointer<lv_obj_t>
  let renderer: LVGLRenderer
  
  var currentFiber: (any AnyFiber)?
  var childIndex: Int = 0
  var dynamicPropertyIndex: Int = 0
  
  init(parent: UnsafeMutablePointer<lv_obj_t>, renderer: LVGLRenderer, rootFiber: (any AnyFiber)?) {
    self.parent = parent
    self.renderer = renderer
    self.currentFiber = rootFiber
  }

  mutating func visit<P: DynamicProperty>(_ property: inout P) {
    if let fiber = currentFiber {
      if var state = property as? StateProtocol {
        state._link(to: fiber, at: dynamicPropertyIndex, redraw: { [renderer] in
          renderer.requestRedraw()
        })
        property = state as! P
      }
    }
    dynamicPropertyIndex += 1
  }

  mutating func visit<A: App>(_ app: A) {
    let originalFiber = currentFiber
    let originalIndex = childIndex
    let originalPropertyIndex = dynamicPropertyIndex
    
    let entry = currentFiber?.reconcileChild(A.self, at: childIndex)
    currentFiber = entry?.fiber
    childIndex = 0
    dynamicPropertyIndex = 0
    
    var app = app
    app.visitProperties(&self)
    app.body.walk(&self)

    renderer.cleanup(entry?.replaced)
    if let currentFiber {
      renderer.cleanup(currentFiber.pruneChildren(after: childIndex - 1))
    }

    currentFiber = originalFiber
    childIndex = originalIndex + 1
    dynamicPropertyIndex = originalPropertyIndex
  }

  mutating func visit<S: Scene>(_ scene: S) {
    let originalFiber = currentFiber
    let originalIndex = childIndex
    let originalPropertyIndex = dynamicPropertyIndex
    
    let entry = currentFiber?.reconcileChild(S.self, at: childIndex)
    currentFiber = entry?.fiber
    childIndex = 0
    dynamicPropertyIndex = 0
    
    var scene = scene
    scene.visitProperties(&self)

    if S.Body.self != Never.self {
      scene.body.walk(&self)
    }

    renderer.cleanup(entry?.replaced)
    if let currentFiber {
      renderer.cleanup(currentFiber.pruneChildren(after: childIndex - 1))
    }

    currentFiber = originalFiber
    childIndex = originalIndex + 1
    dynamicPropertyIndex = originalPropertyIndex
  }

  mutating func visit<V: View>(_ view: V) {
    let originalFiber = currentFiber
    let originalIndex = childIndex
    let originalPropertyIndex = dynamicPropertyIndex
    
    let entry = currentFiber?.reconcileChild(V.self, at: childIndex)
    let fiber = entry?.fiber
    currentFiber = fiber
    childIndex = 0
    dynamicPropertyIndex = 0
    
    var view = view
    view.visitProperties(&self)
    
    // If we have a fiber, we can reuse or update its target
    let target: UnsafeMutablePointer<lv_obj_t>
    
    if let existingTarget = fiber?.target {
      target = existingTarget.assumingMemoryBound(to: lv_obj_t.self)
      
      // Update logic based on type
      if let text = view as? Text {
        let proxy = _TextProxy(text)
        proxy.rawText.withCString { lv_label_set_text(target, $0) }
      } else if let image = view as? Image {
        image.updateImage(target)
      }
      // ... more update logic
    } else {
      // Create new target
      if let text = view as? Text {
        let label = lv_label_create(parent)!
        let proxy = _TextProxy(text)
        proxy.rawText.withCString { lv_label_set_text(label, $0) }
        target = label
        fiber?.ownsTarget = true
      } else if let widget = view as? any AnyLVGLWidget {
        target = widget.new(renderer, parent)
        fiber?.ownsTarget = true
      } else {
        // Fallback for non-primitives that are visited
        target = parent
        fiber?.ownsTarget = false
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

    renderer.cleanup(entry?.replaced)
    if let fiber {
      renderer.cleanup(fiber.pruneChildren(after: childIndex - 1))
    }
    
    currentFiber = originalFiber
    childIndex = originalIndex + 1
    dynamicPropertyIndex = originalPropertyIndex
  }
}

/// A specialized renderer for Embedded Swift that uses static dispatch.
public final class LVGLRenderer {
  public static var shared: LVGLRenderer?
  
  let screen: UnsafeMutablePointer<lv_obj_t>
  
  private var rootFiber: (any AnyFiber)?
  private var rootApp: _AnyApp?
  
  public init() {
    self.screen = lv_scr_act()
    Self.shared = self
  }
  
  public func render<A: App>(_ app: A) {
    self.rootApp = _AnyApp(app)
    if rootFiber == nil {
      rootFiber = Fiber<A>()
    }
    
    var visitor = LVGLVisitor(parent: screen, renderer: self, rootFiber: rootFiber)
    app.walk(&visitor)
    if let rootFiber {
      cleanup(rootFiber.pruneChildren(after: 0))
    }
  }

  public func requestRedraw() {
    guard let rootApp = rootApp else { return }
    var visitor = LVGLVisitor(parent: screen, renderer: self, rootFiber: rootFiber)
    rootApp.walk(&visitor)
    if let rootFiber {
      cleanup(rootFiber.pruneChildren(after: 0))
    }
    lv_refr_now(nil)
  }

  func cleanup(_ fiber: (any AnyFiber)?) {
    guard let fiber else { return }
    cleanup([fiber])
  }

  func cleanup(_ fibers: [(any AnyFiber)]) {
    for fiber in fibers {
      cleanupSubtree(fiber)
    }
  }

  private func cleanupSubtree(_ fiber: any AnyFiber) {
    var child = fiber.child
    while let currentChild = child {
      let nextSibling = currentChild.sibling
      cleanupSubtree(currentChild)
      child = nextSibling
    }

    if fiber.ownsTarget, let target = fiber.target {
      lv_obj_del(target.assumingMemoryBound(to: lv_obj_t.self))
    }

    fiber.child = nil
    fiber.sibling = nil
    fiber.target = nil
    fiber.ownsTarget = false
    fiber.stateValues.removeAll()
  }
}
