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

protocol AnyLVGLWidget {
  var expand: Bool { get }
  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>
  func update(widget: LVGLWidget)
}

extension AnyLVGLWidget {
  var expand: Bool { false }
}

struct LVGLWidgetView<Content: View>: View, AnyLVGLWidget, ParentView {
  let build: (LVGLRenderer, UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>
  let update: (LVGLWidget) -> () = { _ in }
  let content: Content
  let expand: Bool

  init(
    build: @escaping (LVGLRenderer, UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>,
    expand: Bool = false,
    @ViewBuilder content: () -> Content
  ) {
    self.build = build
    self.expand = expand
    self.content = content()
  }

  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    build(renderer, parent)
  }

  func update(widget: LVGLWidget) {
    if case .widget = widget.storage {
      update(widget)
    }
  }

  var body: Never {
    neverBody("LVGLWidgetView")
  }

  var children: [AnyView] {
    [AnyView(content)]
  }
}

extension LVGLWidgetView where Content == EmptyView {
  init(
    build: @escaping (LVGLRenderer, UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>,
    expand: Bool = false
  ) {
    self.init(build: build, expand: expand) { EmptyView() }
  }
}

final class LVGLWidget: Target {
  enum Storage {
    case screen(UnsafeMutablePointer<lv_obj_t>)
    case widget(UnsafeMutablePointer<lv_obj_t>)

    var obj: UnsafeMutablePointer<lv_obj_t> {
      switch self {
      case let .screen(obj), let .widget(obj):
        return obj
      }
    }
  }

  let storage: Storage
  var view: AnyView

  init<V: View>(_ view: V, _ ref: UnsafeMutablePointer<lv_obj_t>) {
    storage = .widget(ref)
    self.view = AnyView(view)
  }

  init<V: View>(_ view: V, screen: UnsafeMutablePointer<lv_obj_t>) {
    storage = .screen(screen)
    self.view = AnyView(view)
  }

  init<A: App>(_ app: A, screen: UnsafeMutablePointer<lv_obj_t>) {
    storage = .screen(screen)
    self.view = AnyView(EmptyView())
  }
}
