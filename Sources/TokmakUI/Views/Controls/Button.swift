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

public struct Button<Label: View>: View, AnyLVGLWidget {
  public let action: () -> Void
  public let label: Label

  public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
    self.action = action
    self.label = label()
  }

  public var body: Label { label }

  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let obj = lv_btn_create(parent)!

    lv_obj_set_layout(obj, tokmakLVLayout(LV_LAYOUT_FLEX))
    lv_obj_set_flex_flow(obj, LV_FLEX_FLOW_ROW)
    lv_obj_set_flex_align(obj, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER)
    lv_obj_set_width(obj, tokmakLVSizeContent)
    lv_obj_set_height(obj, tokmakLVSizeContent)

    lv_obj_set_style_pad_hor(obj, 10, UInt32(LV_PART_MAIN))
    lv_obj_set_style_pad_ver(obj, 6, UInt32(LV_PART_MAIN))
    lv_obj_set_style_radius(obj, tokmakLVCoord(8), UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(obj, 1, UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_color(obj, tokmakLVPrimaryBlue, UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_color(obj, tokmakLVPrimaryBlue, UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(obj, lv_opa_t(LV_OPA_COVER), UInt32(LV_PART_MAIN))
    lv_obj_set_style_text_color(obj, lv_color_hex(0xFFFFFF), UInt32(LV_PART_MAIN))
    lv_obj_set_style_transform_width(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_transform_height(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_anim_time(obj, 0, UInt32(LV_PART_MAIN))

    let pressedSelector = UInt32(LV_PART_MAIN | LV_STATE_PRESSED)
    lv_obj_set_style_bg_color(obj, tokmakLVPrimaryBluePressed, pressedSelector)
    lv_obj_set_style_text_color(obj, lv_color_hex(0xFFFFFF), pressedSelector)
    lv_obj_set_style_transform_width(obj, 0, pressedSelector)
    lv_obj_set_style_transform_height(obj, 0, pressedSelector)

    EventRegistry.register(obj: obj, action: action)

    return obj
  }
}

public extension Button where Label == Text {
  init<S>(_ title: S, action: @escaping () -> Void) where S: StringProtocol {
    self.init(action: action) { Text(title) }
  }
}
