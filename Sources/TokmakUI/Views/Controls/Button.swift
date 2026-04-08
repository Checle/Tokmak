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
    lv_obj_set_layout(obj, tokmakLVLayout(LV_LAYOUT_FLEX))
    lv_obj_set_flex_flow(obj, LV_FLEX_FLOW_ROW)
    lv_obj_set_flex_align(obj, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER)
    
    // Clear LVGL default padding to match SwiftUI more closely, though buttons often have SOME padding.
    // Let's leave a small padding to mimic a standard button.
    lv_obj_set_style_pad_all(obj, 8, UInt32(LV_PART_MAIN))
    
    // Register the action in our global registry
    EventRegistry.register(obj: obj, action: action)
    
    return obj
  }
}

public extension Button where Label == Text {
  init<S>(_ title: S, action: @escaping () -> Void) where S: StringProtocol {
    self.init(action: action) { Text(title) }
  }
}
