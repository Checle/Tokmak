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
  
  var currentFiber: FiberNode?
  var childIndex: Int = 0
  var dynamicPropertyIndex: Int = 0
  
  init(parent: UnsafeMutablePointer<lv_obj_t>, renderer: LVGLRenderer, rootFiber: FiberNode?) {
    self.parent = parent
    self.renderer = renderer
    self.currentFiber = rootFiber
  }

  mutating func visit<P: DynamicProperty>(_ property: inout P) {
    property.visit(&self)
  }

  mutating func visitState<V>(_ state: inout State<V>) {
    if let fiber = currentFiber {
      state._link(to: fiber, at: dynamicPropertyIndex, redraw: { [renderer] in
        renderer.requestRedraw()
      })
    }
    dynamicPropertyIndex += 1
  }

  mutating func visitBinding<V>(_ binding: inout Binding<V>) {
    // Bindings don't typically need linking in the same way State does,
    // but we increment the index for consistency if needed.
    dynamicPropertyIndex += 1
  }

  mutating func visit<A: App>(_ app: A) {
    let originalFiber = currentFiber
    let originalIndex = childIndex
    let originalPropertyIndex = dynamicPropertyIndex

    let entry = currentFiber?.reconcileChild(A.self, at: childIndex, identity: nil)
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

    let entry = currentFiber?.reconcileChild(S.self, at: childIndex, identity: nil)
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
    view._visit(&self)
  }

  // MARK: - Specialized View Visitors

  private mutating func visitPrimitive<V: View>(_ view: V, update: (UnsafeMutablePointer<lv_obj_t>) -> Void) {
    let originalFiber = currentFiber
    let originalIndex = childIndex
    let originalPropertyIndex = dynamicPropertyIndex
    
    let identity = view.reconciliationIdentity
    let entry = currentFiber?.reconcileChild(V.self, at: childIndex, identity: identity)
    let fiber = entry?.fiber
    currentFiber = fiber
    childIndex = 0
    dynamicPropertyIndex = 0
    
    var view = view
    view.visitProperties(&self)
    
    let target: UnsafeMutablePointer<lv_obj_t>
    if let existingTarget = fiber?.target {
      target = existingTarget.assumingMemoryBound(to: lv_obj_t.self)
      update(target)
    } else if let newTarget = view._createTarget(renderer: renderer, parent: parent) {
      target = newTarget
      fiber?.ownsTarget = true
      fiber?.target = UnsafeMutableRawPointer(target)
      update(target)
    } else {
      // Fallback
      target = parent
      fiber?.ownsTarget = false
      fiber?.target = UnsafeMutableRawPointer(target)
    }

    if let scrollID = view.scrollTargetID, let fiber {
      renderer.registerScrollTarget(scrollID, target: target, fiber: fiber)
    }

    renderer.cleanup(entry?.replaced)
    if let fiber {
      renderer.cleanup(fiber.pruneChildren(after: childIndex - 1))
    }

    currentFiber = originalFiber
    childIndex = originalIndex + 1
    dynamicPropertyIndex = originalPropertyIndex
  }

  private mutating func visitContainer<V: View>(
    _ view: V,
    update: (UnsafeMutablePointer<lv_obj_t>) -> Void,
    afterChildren: (UnsafeMutablePointer<lv_obj_t>) -> Void = { _ in }
  ) {
    let originalFiber = currentFiber
    let originalIndex = childIndex
    let originalPropertyIndex = dynamicPropertyIndex

    let identity = view.reconciliationIdentity
    let entry = currentFiber?.reconcileChild(V.self, at: childIndex, identity: identity)
    let fiber = entry?.fiber
    currentFiber = fiber
    childIndex = 0
    dynamicPropertyIndex = 0

    var view = view
    view.visitProperties(&self)

    let target: UnsafeMutablePointer<lv_obj_t>
    if let existingTarget = fiber?.target {
      target = existingTarget.assumingMemoryBound(to: lv_obj_t.self)
      update(target)
    } else if let newTarget = view._createTarget(renderer: renderer, parent: parent) {
      target = newTarget
      fiber?.ownsTarget = true
      fiber?.target = UnsafeMutableRawPointer(target)
      update(target)
    } else {
      // Fallback
      target = parent
      fiber?.ownsTarget = false
      fiber?.target = UnsafeMutableRawPointer(target)
    }

    let originalParent = parent
    if let customParent = view._contentParent(for: target) {
      parent = customParent
    } else {
      parent = target
    }
    view.body.walk(&self)
    afterChildren(target)
    parent = originalParent

    renderer.cleanup(entry?.replaced)
    if let fiber {
      renderer.cleanup(fiber.pruneChildren(after: childIndex - 1))
    }
    
    currentFiber = originalFiber
    childIndex = originalIndex + 1
    dynamicPropertyIndex = originalPropertyIndex
  }

  mutating func visitText(_ view: Text) {
    visitPrimitive(view, update: { view.applyTextStyle(to: $0) })
  }

  mutating func visitVStack<V: View>(_ view: VStack<V>) {
    visitContainer(view, update: { view.applyLayout(to: $0) })
  }

  mutating func visitHStack<V: View>(_ view: HStack<V>) {
    visitContainer(view, update: { view.applyLayout(to: $0) })
  }

  mutating func visitZStack<V: View>(_ view: ZStack<V>) {
    visitContainer(view, update: { _ in })
  }

  mutating func visitButton<V: View>(_ view: Button<V>) {
    visitContainer(view, update: { _ in })
  }

  mutating func visitSpacer(_ view: Spacer) {
    visitPrimitive(view, update: { _ in })
  }

  mutating func visitDivider(_ view: Divider) {
    // Implement if Divider is added
  }

  mutating func visitImage(_ view: Image) {
    visitPrimitive(view, update: { view.updateImage($0) })
  }

  mutating func visitTextField(_ view: TextField) {
    visitPrimitive(view, update: { view.updateTextField($0) })
  }

  mutating func visitForEach<Data, ID, Content>(_ view: ForEach<Data, ID, Content>) {
    // ForEach needs special handling for reconciliation
    view.body.walk(&self)
  }

  mutating func visitGroup<V: View>(_ view: Group<V>) {
    view.content.walk(&self)
  }

  mutating func visitScrollView<V: View>(_ view: ScrollView<V>) {
    visitContainer(view, update: { _ in })
  }

  mutating func visitScrollViewReader<V: View>(_ view: ScrollViewReader<V>) {
    view.body.walk(&self)
  }

  mutating func visitContentUnavailableView(_ view: ContentUnavailableView) {
    visitContainer(view, update: { _ in })
  }

  mutating func visitIdentifiedView<V: View>(_ view: _IdentifiedView<V>) {
    visitContainer(view, update: { _ in })
  }

  mutating func visitFrameView<V: View>(_ view: _FrameView<V>) {
    visitContainer(view, update: { _ in }, afterChildren: { target in
      lv_obj_update_layout(target)
      let childCount = lv_obj_get_child_cnt(target)
      for index in 0..<childCount {
        guard let child = lv_obj_get_child(target, Int32(index)) else { continue }
        if tokmakIsFrameSizedControl(view.content) {
          if let width = view.width {
            lv_obj_set_width(child, tokmakLVCoord(width))
          }
          if let height = view.height {
            lv_obj_set_height(child, tokmakLVCoord(height))
          }
        }
        lv_obj_align(child, lvAlign(view.alignment), 0, 0)
      }
    })
  }

  mutating func visitPaddingView<V: View>(_ view: _PaddingView<V>) {
    visitContainer(view, update: { _ in })
  }

  mutating func visitClipShapeView<V: View, S: Shape>(_ view: _ClipShapeView<V, S>) {
    visitContainer(
      view,
      update: { target in
        tokmakLVApplyClipShape(view.shape, to: target)
      },
      afterChildren: { target in
        applyClipShapeToTree(view.shape, target: target)
      }
    )
  }

  mutating func visitBackgroundView<V: View>(_ view: _BackgroundView<V>) {
    visitContainer(
      view,
      update: { target in
        tokmakLVApplyBackground(view.color, to: target)
      }
    )
  }

  mutating func visitForegroundStyleView<V: View>(_ view: _ForegroundStyleView<V>) {
    visitContainer(
      view,
      update: { target in
        tokmakLVApplyForegroundStyle(view.color, to: target)
      },
      afterChildren: { target in
        applyForegroundStyleToTree(view.color, target: target)
      }
    )
  }

  mutating func visitButtonStyleView<V: View, S: ButtonStyle>(_ view: _ButtonStyleView<V, S>) {
    visitContainer(
      view,
      update: { _ in },
      afterChildren: { target in
        applyButtonStyleToImmediateChildren(view.style, target: target)
      }
    )
  }

}

private func applyClipShapeToTree<S: Shape>(_ shape: S, target: UnsafeMutablePointer<lv_obj_t>) {
  lv_obj_update_layout(target)
  tokmakLVApplyClipShape(shape, to: target)

  let childCount = lv_obj_get_child_cnt(target)
  for index in 0..<childCount {
    guard let child = lv_obj_get_child(target, Int32(index)) else { continue }
    applyClipShapeToTree(shape, target: child)
  }
}

private func applyForegroundStyleToTree(_ color: Color, target: UnsafeMutablePointer<lv_obj_t>) {
  tokmakLVApplyForegroundStyle(color, to: target)

  let childCount = lv_obj_get_child_cnt(target)
  for index in 0..<childCount {
    guard let child = lv_obj_get_child(target, Int32(index)) else { continue }
    applyForegroundStyleToTree(color, target: child)
  }
}

private func applyButtonStyleToImmediateChildren<S: ButtonStyle>(_ style: S, target: UnsafeMutablePointer<lv_obj_t>) {
  let childCount = lv_obj_get_child_cnt(target)
  for index in 0..<childCount {
    guard let child = lv_obj_get_child(target, Int32(index)) else { continue }
    tokmakLVApplyButtonStyle(style, to: child)
  }
}

private func lvAlign(_ alignment: Alignment) -> lv_align_t {
  switch alignment {
  case .topLeading: return lv_align_t(LV_ALIGN_TOP_LEFT)
  case .top: return lv_align_t(LV_ALIGN_TOP_MID)
  case .topTrailing: return lv_align_t(LV_ALIGN_TOP_RIGHT)
  case .leading: return lv_align_t(LV_ALIGN_LEFT_MID)
  case .center: return lv_align_t(LV_ALIGN_CENTER)
  case .trailing: return lv_align_t(LV_ALIGN_RIGHT_MID)
  case .bottomLeading: return lv_align_t(LV_ALIGN_BOTTOM_LEFT)
  case .bottom: return lv_align_t(LV_ALIGN_BOTTOM_MID)
  case .bottomTrailing: return lv_align_t(LV_ALIGN_BOTTOM_RIGHT)
  default: return lv_align_t(LV_ALIGN_CENTER)
  }
}

/// A specialized renderer for Embedded Swift that uses static dispatch.
public final class LVGLRenderer {
  public static var shared: LVGLRenderer?
  
  let screen: UnsafeMutablePointer<lv_obj_t>
  
  private var rootFiber: FiberNode?
  private var redraw: (() -> Void)?
  private var scrollTargets: [TokmakIdentityKey: UnsafeMutablePointer<lv_obj_t>] = [:]
  
  public init() {
    self.screen = lv_scr_act()
    lv_obj_set_style_bg_color(screen, lv_color_hex(0xFFFFFF), UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(screen, lv_opa_t(LV_OPA_COVER), UInt32(LV_PART_MAIN))
    Self.shared = self
  }
  
  public func render<A: App>(_ app: A) {
    if rootFiber == nil {
      rootFiber = FiberNode()
    }

    redraw = { [self] in
      rerender(A())
    }

    rerender(app)
  }

  private func rerender<A: App>(_ app: A) {
    var visitor = LVGLVisitor(parent: screen, renderer: self, rootFiber: rootFiber)
    app.walk(&visitor)
    if let rootFiber {
      cleanup(rootFiber.pruneChildren(after: 0))
    }
  }

  public func requestRedraw() {
    redraw?()
    lv_refr_now(nil)
  }

  func registerScrollTarget(
    _ id: TokmakIdentityKey,
    target: UnsafeMutablePointer<lv_obj_t>,
    fiber: FiberNode
  ) {
    if !fiber.scrollTargetIDs.contains(id) {
      fiber.scrollTargetIDs.append(id)
    }
    scrollTargets[id] = target
  }

  public func scrollTo<ID>(_ id: ID) where ID: Hashable {
    let key = TokmakIdentityKey(id)
    guard let target = scrollTargets[key] else { return }
    lv_obj_scroll_to_view(target, LV_ANIM_OFF)
    lv_refr_now(nil)
  }

  func cleanup(_ fiber: FiberNode?) {
    guard let fiber else { return }
    cleanup([fiber])
  }

  func cleanup(_ fibers: [FiberNode]) {
    for fiber in fibers {
      cleanupSubtree(fiber)
    }
  }

  private func cleanupSubtree(_ fiber: FiberNode) {
    var child = fiber.child
    while let currentChild = child {
      let nextSibling = currentChild.sibling
      cleanupSubtree(currentChild)
      child = nextSibling
    }

    if fiber.ownsTarget, let target = fiber.target {
      lv_obj_del(target.assumingMemoryBound(to: lv_obj_t.self))
    }

    for id in fiber.scrollTargetIDs {
      scrollTargets.removeValue(forKey: id)
    }

    fiber.child = nil
    fiber.sibling = nil
    fiber.target = nil
    fiber.ownsTarget = false
    fiber.stateValues.removeAll()
    fiber.scrollTargetIDs.removeAll()
  }
}
