// Copyright 2020 Tokamak contributors
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
import Foundation
import TokamakCore

extension VStack: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let container = lv_obj_create(parent)
    
    // Configure for vertical flex layout
    lv_obj_set_flex_flow(container, LV_FLEX_FLOW_COLUMN)
    
    // Default size to occupy parent
    lv_obj_set_size(container, lv_pct(100), lv_pct(100))
    
    // Transparent background for stacks
    lv_obj_set_style_bg_opa(container, 0, 0)
    lv_obj_set_style_border_width(container, 0, 0)
    
    return container
  }

  func update(widget: LVGLWidget) {
    if case let .widget(w) = widget.storage {
      // Update layout if needed
      lv_obj_set_flex_flow(w, LV_FLEX_FLOW_COLUMN)
    }
  }

  var expand: Bool { true }
}

extension HStack: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let container = lv_obj_create(parent)
    
    // Configure for horizontal flex layout
    lv_obj_set_flex_flow(container, LV_FLEX_FLOW_ROW)
    
    // Default size to occupy parent width
    lv_obj_set_size(container, lv_pct(100), Int16(LV_SIZE_CONTENT))
    
    // Transparent background for stacks
    lv_obj_set_style_bg_opa(container, 0, 0)
    lv_obj_set_style_border_width(container, 0, 0)
    
    return container
  }

  func update(widget: LVGLWidget) {
    if case let .widget(w) = widget.storage {
      lv_obj_set_flex_flow(w, LV_FLEX_FLOW_ROW)
    }
  }

  var expand: Bool { true }
}

extension ZStack: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    // ZStack creates a container for overlapping views
    let container = lv_obj_create(parent)
    
    // No layout for ZStack - children will be positioned absolutely or we use custom positioning
    lv_obj_set_size(container, lv_pct(100), lv_pct(100))
    
    // Transparent background for stacks
    lv_obj_set_style_bg_opa(container, 0, 0)
    lv_obj_set_style_border_width(container, 0, 0)
    
    return container
  }

  func update(widget: LVGLWidget) {
  }

  var expand: Bool { true }
}
