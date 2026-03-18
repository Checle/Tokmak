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
import TokmakCore

extension Spacer: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    // Create an empty container that expands
    let spacer = lv_obj_create(parent)!
    
    // In LVGL Flex, to make something grow, we use lv_obj_set_flex_grow
    lv_obj_set_flex_grow(spacer, 1)
    
    // Transparent and no border
    lv_obj_set_style_bg_opa(spacer, 0, 0)
    lv_obj_set_style_border_width(spacer, 0, 0)
    
    return spacer
  }
}

extension EmptyView: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    // Create a hidden container
    let empty = lv_obj_create(parent)!
    
    // Make it invisible with zero size
    lv_obj_set_size(empty, 0, 0)
    lv_obj_add_flag(empty, lv_obj_flag_t(LV_OBJ_FLAG_HIDDEN))
    
    return empty
  }
}
