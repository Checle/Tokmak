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

public struct ZStack<Content: View>: View, AnyLVGLWidget {
  public let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: Content { content }

  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let obj = lv_obj_create(parent)!
    lv_obj_set_width(obj, tokmakLVSizeContent)
    lv_obj_set_height(obj, tokmakLVSizeContent)
    
    // ZStack defaults to center alignment for all its children.
    // In LVGL, we can achieve this by setting the flex layout to center, 
    // or by overriding child alignment. However, a simpler way is to set 
    // the layout to grid, placing everything in a single cell, or using flex
    // with no wrap and center align. Let's just remove the default padding for now.
    lv_obj_set_style_pad_all(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(obj, 0, UInt32(LV_PART_MAIN))
    
    // Using grid to overlay children in the same cell.
    // In LVGL, grid with 1 row 1 col will place everything in that cell, stacking them.
    let col_dsc = UnsafeMutablePointer<lv_coord_t>.allocate(capacity: 2)
    col_dsc[0] = tokmakLVGridFraction(1)
    col_dsc[1] = tokmakLVGridTemplateLast
    
    let row_dsc = UnsafeMutablePointer<lv_coord_t>.allocate(capacity: 2)
    row_dsc[0] = tokmakLVGridFraction(1)
    row_dsc[1] = tokmakLVGridTemplateLast

    lv_obj_set_grid_dsc_array(obj, col_dsc, row_dsc)
    lv_obj_set_layout(obj, tokmakLVLayout(LV_LAYOUT_GRID))

    return obj
  }
}
