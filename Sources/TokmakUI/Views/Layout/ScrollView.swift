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

public struct ScrollView<Content: View>: View, AnyLVGLWidget, LVGLContentParentProvider {
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
    let shell = lv_obj_create(parent)!

    lv_obj_set_width(shell, lv_pct(100))
    lv_obj_set_height(shell, lv_pct(100))
    lv_obj_set_layout(shell, tokmakLVLayout(LV_LAYOUT_FLEX))
    lv_obj_set_flex_flow(shell, LV_FLEX_FLOW_ROW)
    lv_obj_set_style_pad_all(shell, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_pad_column(shell, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_radius(shell, tokmakLVCoord(8), UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(shell, 1, UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_color(shell, lv_color_hex(0x000000), UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_color(shell, lv_color_hex(0xFFFFFF), UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(shell, lv_opa_t(LV_OPA_COVER), UInt32(LV_PART_MAIN))

    let viewport = lv_obj_create(shell)!
    lv_obj_set_flex_grow(viewport, 1)
    lv_obj_set_height(viewport, lv_pct(100))
    lv_obj_set_layout(viewport, tokmakLVLayout(LV_LAYOUT_FLEX))
    lv_obj_set_flex_flow(viewport, axes.contains(.horizontal) ? LV_FLEX_FLOW_ROW : LV_FLEX_FLOW_COLUMN)
    lv_obj_set_style_pad_left(viewport, 8, UInt32(LV_PART_MAIN))
    lv_obj_set_style_pad_top(viewport, 8, UInt32(LV_PART_MAIN))
    lv_obj_set_style_pad_bottom(viewport, 8, UInt32(LV_PART_MAIN))
    lv_obj_set_style_pad_right(viewport, 2, UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(viewport, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_radius(viewport, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(viewport, 0, UInt32(LV_PART_MAIN))

    lv_obj_set_scroll_dir(viewport, scrollDirection)
    lv_obj_set_scrollbar_mode(
      viewport,
      lv_scrollbar_mode_t(showsIndicators ? LV_SCROLLBAR_MODE_ON : LV_SCROLLBAR_MODE_OFF)
    )
    lv_obj_set_style_bg_color(viewport, lv_color_hex(0x000000), UInt32(LV_PART_SCROLLBAR))
    lv_obj_set_style_bg_opa(viewport, lv_opa_t(LV_OPA_COVER), UInt32(LV_PART_SCROLLBAR))
    lv_obj_set_style_width(viewport, tokmakLVCoord(10), UInt32(LV_PART_SCROLLBAR))
    lv_obj_set_style_radius(viewport, tokmakLVCoord(8), UInt32(LV_PART_SCROLLBAR))

    if axes == .vertical {
      makeVerticalControls(in: shell, viewport: viewport)
    }

    return shell
  }

  func contentParent(for target: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    lv_obj_get_child(target, 0)!
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

  private func makeVerticalControls(
    in shell: UnsafeMutablePointer<lv_obj_t>,
    viewport: UnsafeMutablePointer<lv_obj_t>
  ) {
    let controls = lv_obj_create(shell)!
    lv_obj_set_width(controls, tokmakLVCoord(34))
    lv_obj_set_height(controls, lv_pct(100))
    lv_obj_set_layout(controls, tokmakLVLayout(LV_LAYOUT_FLEX))
    lv_obj_set_flex_flow(controls, LV_FLEX_FLOW_COLUMN)
    lv_obj_set_flex_align(controls, LV_FLEX_ALIGN_START, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER)
    lv_obj_set_style_pad_all(controls, 2, UInt32(LV_PART_MAIN))
    lv_obj_set_style_pad_row(controls, 2, UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(controls, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(controls, 0, UInt32(LV_PART_MAIN))

    let step = tokmakLVCoord(36)
    makeScrollButton(in: controls, title: Image.Symbol.up) {
      lv_obj_scroll_by_bounded(viewport, 0, step, LV_ANIM_OFF)
      lv_refr_now(nil)
    }
    makeScrollButton(in: controls, title: Image.Symbol.down) {
      lv_obj_scroll_by_bounded(viewport, 0, -step, LV_ANIM_OFF)
      lv_refr_now(nil)
    }
  }

  private func makeScrollButton(
    in parent: UnsafeMutablePointer<lv_obj_t>,
    title: String,
    action: @escaping () -> Void
  ) {
    let button = lv_btn_create(parent)!
    lv_obj_set_width(button, tokmakLVCoord(28))
    lv_obj_set_height(button, tokmakLVCoord(28))
    lv_obj_set_style_pad_all(button, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_radius(button, tokmakLVCoord(6), UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(button, 1, UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_color(button, lv_color_hex(0x000000), UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_color(button, lv_color_hex(0xFFFFFF), UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(button, lv_opa_t(LV_OPA_COVER), UInt32(LV_PART_MAIN))
    lv_obj_set_style_text_color(button, lv_color_hex(0x000000), UInt32(LV_PART_MAIN))

    let pressedSelector = UInt32(LV_PART_MAIN | LV_STATE_PRESSED)
    lv_obj_set_style_bg_color(button, lv_color_hex(0x000000), pressedSelector)
    lv_obj_set_style_text_color(button, lv_color_hex(0xFFFFFF), pressedSelector)
    lv_obj_set_style_transform_width(button, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_transform_height(button, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_anim_time(button, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_transform_width(button, 0, pressedSelector)
    lv_obj_set_style_transform_height(button, 0, pressedSelector)
    lv_obj_set_style_anim_time(button, 0, pressedSelector)

    let label = lv_label_create(button)!
    title.withCString { cString in
      lv_label_set_text(label, cString)
    }
    lv_obj_center(label)

    EventRegistry.register(obj: button, action: action)
  }
}
