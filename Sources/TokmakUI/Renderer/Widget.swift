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

protocol AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>
}

struct LVGLWidgetView<Content: View>: _PrimitiveView, AnyLVGLWidget {
  public var body: Never {
    neverBody("LVGLWidgetView")
  }

  public mutating func visitProperties<V: PropertyVisitor>(_ visitor: inout V) {}

  let build: (LVGLRenderer, UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>
  let content: Content

  init(
    build: @escaping (LVGLRenderer, UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>,
    @ViewBuilder content: () -> Content
  ) {
    self.build = build
    self.content = content()
  }

  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    build(renderer, parent)
  }

  func walk<V: ViewWalker>(_ visitor: inout V) {
    visitor.visit(self)
    content.walk(&visitor)
  }
}

extension LVGLWidgetView where Content == EmptyView {
  init(
    build: @escaping (LVGLRenderer, UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>
  ) {
    self.init(build: build) { EmptyView() }
  }
}

final class LVGLWidget: Target {
  let obj: UnsafeMutablePointer<lv_obj_t>
  var view: AnyView

  init(_ obj: UnsafeMutablePointer<lv_obj_t>) {
    self.obj = obj
    self.view = AnyView(EmptyView())
  }
}
