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

public struct Spacer: _PrimitiveView, AnyLVGLWidget {
  public let minLength: CGFloat?

  public init(minLength: CGFloat? = nil) {
    self.minLength = minLength
  }

  public var body: Never {
    neverBody("Spacer")
  }

  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let obj = lv_obj_create(parent)!
    
    lv_obj_set_style_pad_all(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(obj, 0, UInt32(LV_PART_MAIN))
    
    // In an LVGL flex layout, flex-grow allows an object to consume available space.
    // SwiftUI's Spacer pushes content apart by expanding to fill the available space.
    lv_obj_set_flex_grow(obj, 1)
    
    return obj
  }
}
