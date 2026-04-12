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

public struct _ClipShapeLayout<S: Shape>: ViewModifier {
  public let shape: S

  public init(_ shape: S) {
    self.shape = shape
  }

  public func body(content: Content) -> some View {
    _ClipShapeView(content: content, shape: shape)
  }
}

public struct _ClipShapeView<Content: View, S: Shape>: View, AnyLVGLWidget {
  public let content: Content
  public let shape: S

  public var body: Content { content }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitClipShapeView(self)
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
    lv_obj_set_style_bg_opa(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_layout(obj, tokmakLVLayout(LV_LAYOUT_FLEX))
    lv_obj_set_flex_flow(obj, LV_FLEX_FLOW_COLUMN)
    lv_obj_set_flex_align(obj, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER)
    tokmakLVApplyClipShape(shape, to: obj)

    return obj
  }
}

public extension View {
  func clipShape<S: Shape>(_ shape: S) -> some View {
    modifier(_ClipShapeLayout(shape))
  }
}

func tokmakLVApplyClipShape<S: Shape>(_ shape: S, to obj: UnsafeMutablePointer<lv_obj_t>) {
  if shape is Circle {
    lv_obj_set_style_radius(obj, lv_coord_t(LV_RADIUS_CIRCLE), UInt32(LV_PART_MAIN))
    lv_obj_set_style_clip_corner(obj, true, UInt32(LV_PART_MAIN))
  }
}
