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

public struct VStack<Content: View>: View, AnyLVGLWidget {
  public let alignment: HorizontalAlignment
  public let spacing: CGFloat?
  public let content: Content

  public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }

  public var body: Content { content }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitVStack(self)
  }

  public func _createTarget(renderer: LVGLRenderer, parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>? {
    new(renderer, parent)
  }

  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let obj = lv_obj_create(parent)!
    applyLayout(to: obj)

    lv_obj_set_style_pad_all(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(obj, 0, UInt32(LV_PART_MAIN))

    return obj
  }

  func applyLayout(to obj: UnsafeMutablePointer<lv_obj_t>) {
    lv_obj_set_layout(obj, tokmakLVLayout(LV_LAYOUT_FLEX))
    lv_obj_set_flex_flow(obj, LV_FLEX_FLOW_COLUMN)
    lv_obj_set_flex_align(obj, LV_FLEX_ALIGN_START, crossAxisAlignment, LV_FLEX_ALIGN_CENTER)
    lv_obj_set_width(obj, tokmakLVSizeContent)
    lv_obj_set_height(obj, tokmakLVSizeContent)
    lv_obj_set_style_pad_row(obj, tokmakLVCoord(spacing ?? 0), UInt32(LV_PART_MAIN))
  }

  private var crossAxisAlignment: lv_flex_align_t {
    if alignment == .leading { return LV_FLEX_ALIGN_START }
    if alignment == .trailing { return LV_FLEX_ALIGN_END }
    return LV_FLEX_ALIGN_CENTER
  }
}
