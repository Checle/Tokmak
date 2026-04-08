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
    
    // Default styling for a button. In standard LVGL, buttons wrap their content.
    lv_obj_set_layout(obj, UInt16(LV_LAYOUT_FLEX))
    lv_flex_set_flow(obj, UInt8(LV_FLEX_FLOW_ROW))
    lv_flex_set_align(obj, UInt8(LV_FLEX_ALIGN_CENTER), UInt8(LV_FLEX_ALIGN_CENTER), UInt8(LV_FLEX_ALIGN_CENTER))
    
    // Clear LVGL default padding to match SwiftUI more closely, though buttons often have SOME padding.
    // Let's leave a small padding to mimic a standard button.
    lv_obj_set_style_pad_all(obj, 8, UInt32(LV_PART_MAIN))
    
    // Register the action in our global registry
    EventRegistry.register(obj: obj, action: action)
    
    // Attach the C-level callback. 
    // We cannot use a capturing Swift closure directly, so we use a @_cdecl C function.
    lv_obj_add_event_cb(obj, tokmak_lvgl_event_handler, LV_EVENT_CLICKED, nil)
    
    return obj
  }
}

public extension Button where Label == Text {
  init(_ title: StringProtocol, action: @escaping () -> Void) {
    self.init(action: action) { Text(title) }
  }
}
