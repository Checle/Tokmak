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

extension _PrimitiveButtonStyleBody: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let button = lv_btn_create(parent)!
    
    // Set up the action
    let action = self.action
    let box = ActionBox(action: action)
    let pointer = Unmanaged.passRetained(box).toOpaque()
    lv_obj_set_user_data(button, pointer)
    
    // Use a non-capturing closure for the callback
    lv_obj_add_event_cb(button, { event in
      guard let event = event else { return }
      let code = lv_event_get_code(event)
      let obj = lv_event_get_target(event)
      
      if code == LV_EVENT_CLICKED {
        if let pointer = lv_obj_get_user_data(obj) {
          let box = Unmanaged<ActionBox>.fromOpaque(pointer).takeUnretainedValue()
          box.action()
        }
      } else if code == LV_EVENT_DELETE {
        if let pointer = lv_obj_get_user_data(obj) {
          Unmanaged<ActionBox>.fromOpaque(pointer).release()
          lv_obj_set_user_data(obj, nil)
        }
      }
    }, LV_EVENT_ALL, nil)
    
    // Buttons in LVGL are also containers, they will have children (the label)
    // We want the label to be centered by default
    lv_obj_set_flex_flow(button, LV_FLEX_FLOW_ROW)
    lv_obj_set_flex_align(button, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER)
    
    return button
  }

  func update(widget: LVGLWidget) {
    if case let .widget(w) = widget.storage {
      // Re-set action
      if let oldPointer = lv_obj_get_user_data(w) {
         Unmanaged<ActionBox>.fromOpaque(oldPointer).release()
      }
      
      let action = self.action
      let box = ActionBox(action: action)
      let pointer = Unmanaged.passRetained(box).toOpaque()
      lv_obj_set_user_data(w, pointer)
    }
  }
}

private final class ActionBox {
  let action: () -> ()
  init(action: @escaping () -> ()) {
    self.action = action
  }
}
