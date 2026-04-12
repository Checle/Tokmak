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

public struct _BackgroundLayout: ViewModifier {
  public let color: Color

  public init(_ color: Color) {
    self.color = color
  }

  public func body(content: Content) -> some View {
    _BackgroundView(content: content, color: color)
  }
}

public struct _BackgroundView<Content: View>: View, AnyLVGLWidget {
  public let content: Content
  public let color: Color

  public var body: Content { content }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitBackgroundView(self)
  }

  public func _createTarget(renderer: LVGLRenderer, parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>? {
    new(renderer, parent)
  }

  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let obj = lv_obj_create(parent)!

    lv_obj_set_width(obj, tokmakLVSizeContent)
    lv_obj_set_height(obj, tokmakLVSizeContent)
    lv_obj_set_style_pad_all(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_layout(obj, tokmakLVLayout(LV_LAYOUT_FLEX))
    lv_obj_set_flex_flow(obj, LV_FLEX_FLOW_COLUMN)
    lv_obj_set_flex_align(obj, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER)
    tokmakLVApplyBackground(color, to: obj)

    return obj
  }
}

public extension View {
  func background(_ color: Color) -> some View {
    modifier(_BackgroundLayout(color))
  }
}

func tokmakLVApplyBackground(_ color: Color, to obj: UnsafeMutablePointer<lv_obj_t>) {
  lv_obj_set_style_bg_color(obj, tokmakLVMonochromeColor(color), UInt32(LV_PART_MAIN))
  lv_obj_set_style_bg_opa(obj, lv_opa_t(LV_OPA_COVER), UInt32(LV_PART_MAIN))
}
