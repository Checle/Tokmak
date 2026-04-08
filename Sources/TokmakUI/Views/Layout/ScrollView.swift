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

public struct ScrollView<Content: View>: View, AnyLVGLWidget {
  public let axes: Axis.Set
  public let showsIndicators: Bool
  public let content: Content

  public init(
    _ axes: Axis.Set = .vertical,
    showsIndicators: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self.axes = axes
    self.showsIndicators = showsIndicators
    self.content = content()
  }

  public var body: Content { content }

  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let obj = lv_obj_create(parent)!

    lv_obj_set_width(obj, lv_pct(100))
    lv_obj_set_height(obj, lv_pct(100))
    lv_obj_set_layout(obj, tokmakLVLayout(LV_LAYOUT_FLEX))
    lv_obj_set_flex_flow(obj, axes.contains(.horizontal) ? LV_FLEX_FLOW_ROW : LV_FLEX_FLOW_COLUMN)
    lv_obj_set_style_pad_all(obj, 8, UInt32(LV_PART_MAIN))
    lv_obj_set_style_radius(obj, tokmakLVCoord(8), UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(obj, 1, UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_color(obj, lv_color_hex(0x000000), UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_color(obj, lv_color_hex(0xFFFFFF), UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(obj, lv_opa_t(LV_OPA_COVER), UInt32(LV_PART_MAIN))

    lv_obj_set_scroll_dir(obj, scrollDirection)
    lv_obj_set_scrollbar_mode(
      obj,
      lv_scrollbar_mode_t(showsIndicators ? LV_SCROLLBAR_MODE_ON : LV_SCROLLBAR_MODE_OFF)
    )
    lv_obj_set_style_bg_color(obj, lv_color_hex(0x000000), UInt32(LV_PART_SCROLLBAR))
    lv_obj_set_style_bg_opa(obj, lv_opa_t(LV_OPA_COVER), UInt32(LV_PART_SCROLLBAR))
    lv_obj_set_style_width(obj, tokmakLVCoord(10), UInt32(LV_PART_SCROLLBAR))
    lv_obj_set_style_radius(obj, tokmakLVCoord(8), UInt32(LV_PART_SCROLLBAR))

    return obj
  }

  private var scrollDirection: lv_dir_t {
    switch (axes.contains(.horizontal), axes.contains(.vertical)) {
    case (true, true):
      return lv_dir_t(LV_DIR_ALL)
    case (true, false):
      return lv_dir_t(LV_DIR_HOR)
    case (false, true):
      return lv_dir_t(LV_DIR_VER)
    case (false, false):
      return lv_dir_t(LV_DIR_VER)
    }
  }
}
