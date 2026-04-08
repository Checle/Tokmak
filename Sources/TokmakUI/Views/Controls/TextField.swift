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

public struct TextField: _PrimitiveView, AnyLVGLWidget {
  public let title: String
  public let text: Binding<String>

  public init(_ title: String, text: Binding<String>) {
    self.title = title
    self.text = text
  }

  public var body: Never {
    neverBody("TextField")
  }

  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let obj = lv_textarea_create(parent)!

    lv_textarea_set_one_line(obj, true)
    lv_textarea_set_cursor_click_pos(obj, true)
    lv_obj_set_width(obj, tokmakLVCoord(220))
    lv_obj_set_height(obj, tokmakLVCoord(34))
    lv_obj_set_style_radius(obj, tokmakLVCoord(8), UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(obj, 1, UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_color(obj, tokmakLVPrimaryBlueMuted, UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_color(obj, lv_color_hex(0xFFFFFF), UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(obj, lv_opa_t(LV_OPA_COVER), UInt32(LV_PART_MAIN))
    lv_obj_set_style_text_color(obj, lv_color_hex(0x000000), UInt32(LV_PART_MAIN))
    lv_obj_set_style_pad_hor(obj, 6, UInt32(LV_PART_MAIN))
    lv_obj_set_style_pad_ver(obj, 4, UInt32(LV_PART_MAIN))
    lv_obj_set_style_anim_time(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_text_color(
      obj,
      lv_color_hex(0x9A9A9A),
      UInt32(LV_PART_TEXTAREA_PLACEHOLDER)
    )
    let focusedSelector = UInt32(LV_PART_MAIN | LV_STATE_FOCUSED)
    lv_obj_set_style_border_color(obj, tokmakLVPrimaryBlue, focusedSelector)
    lv_obj_set_style_border_width(obj, 2, focusedSelector)

    updateTextField(obj)
    TextFieldRegistry.register(obj: obj, text: text)

    return obj
  }

  func updateTextField(_ obj: UnsafeMutablePointer<lv_obj_t>) {
    let current = String(cString: lv_textarea_get_text(obj))
    if current != text.wrappedValue {
      text.wrappedValue.withCString { cString in
        lv_textarea_set_text(obj, cString)
      }
      lv_textarea_set_cursor_pos(obj, Int32(LV_TEXTAREA_CURSOR_LAST))
    }

    title.withCString { cString in
      lv_textarea_set_placeholder_text(obj, cString)
    }
  }
}
