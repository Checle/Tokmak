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
import Dispatch
import Foundation
@_spi(TokmakCore) import TokmakCore

extension EnvironmentValues {
  /// Returns default settings for the LVGL environment
  static var defaultEnvironment: Self {
    var environment = EnvironmentValues()
    environment.colorScheme = .light
    return environment
  }
}

final class LVGLRenderer: Renderer {
  private(set) var reconciler: StackReconciler<LVGLRenderer>?
  let screen: UnsafeMutablePointer<lv_obj_t>

  init<A: App>(
    _ app: A,
    _ rootEnvironment: EnvironmentValues? = nil
  ) {
    // Initialize LVGL display driver
    // This assumes LVGL has been initialized at the C level
    screen = lv_scr_act()

    self.reconciler = StackReconciler(
      app: app,
      target: LVGLWidget(app, screen: screen),
      environment: .defaultEnvironment.merging(rootEnvironment),
      renderer: self,
      scheduler: { next in
        DispatchQueue.main.async {
          next()
          lv_refr_now(nil)
        }
      }
    )
  }

  public func mountTarget(
    before sibling: LVGLWidget?,
    to parent: LVGLWidget,
    with host: MountedHost
  ) -> LVGLWidget? {
    guard let anyWidget = mapAnyView(
      host.view,
      transform: { (widget: AnyLVGLWidget) in widget }
    ) else {
      // handle cases like `TupleView`
      if mapAnyView(host.view, transform: { (view: ParentView) in view }) != nil {
        return parent
      }

      return nil
    }

    let widget = anyWidget.new(self, parent.storage.obj)

    // sibling is handled by LVGL default order or we could use lv_obj_move_before
    if let siblingObj = sibling?.storage.obj {
      lv_obj_move_to_index(widget, Int32(lv_obj_get_index(siblingObj)))
    }

    return LVGLWidget(host.view, widget)
  }

  func update(target: LVGLWidget, with host: MountedHost) {
    guard let widget = mapAnyView(host.view, transform: { (widget: AnyLVGLWidget) in widget })
    else { return }

    widget.update(widget: target)
  }

  func unmount(
    target: LVGLWidget,
    from parent: LVGLWidget,
    with task: UnmountHostTask<LVGLRenderer>
  ) {
    defer { task.finish() }

    guard mapAnyView(task.host.view, transform: { (widget: AnyLVGLWidget) in widget }) != nil
    else { return }

    // Delete the widget from LVGL
    if case let .widget(widget) = target.storage {
      lv_obj_del(widget)
    }
  }

  public func isPrimitiveView(_ type: Any.Type) -> Bool {
    type is AnyLVGLWidget.Type || type is (any _PrimitiveView).Type
  }

  public func primitiveBody(for view: Any) -> AnyView? {
    if let primitive = view as? LVGLPrimitive {
      return primitive.renderedBody
    }
    return nil
  }
}

protocol LVGLPrimitive {
  var renderedBody: AnyView { get }
}
