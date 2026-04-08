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

public struct Divider: _PrimitiveView, AnyLVGLWidget {
  public init() {}

  public var body: Never {
    neverBody("Divider")
  }

  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let obj = lv_obj_create(parent)!

    lv_obj_set_width(obj, lv_pct(100))
    lv_obj_set_height(obj, tokmakLVCoord(1))
    lv_obj_set_style_pad_all(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_radius(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_color(obj, lv_palette_lighten(LV_PALETTE_GREY, 2), UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(obj, lv_opa_t(LV_OPA_COVER), UInt32(LV_PART_MAIN))

    return obj
  }
}
