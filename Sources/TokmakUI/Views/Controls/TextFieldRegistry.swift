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

final class TextFieldBox {
  let update: (String) -> Void

  init(update: @escaping (String) -> Void) {
    self.update = update
  }
}

struct TextFieldRegistry {
  static var fields: [UnsafeMutableRawPointer: TextFieldBox] = [:]

  static func register(obj: UnsafeMutablePointer<lv_obj_t>, text: Binding<String>) {
    fields[UnsafeMutableRawPointer(obj)] = TextFieldBox { newValue in
      text.wrappedValue = newValue
    }
    lv_obj_add_event_cb(obj, tokmak_lvgl_textfield_handler, LV_EVENT_ALL, nil)
  }

  static func unregister(obj: UnsafeMutablePointer<lv_obj_t>) {
    fields.removeValue(forKey: UnsafeMutableRawPointer(obj))
  }
}

@_cdecl("tokmak_lvgl_textfield_handler")
func tokmak_lvgl_textfield_handler(e: UnsafeMutablePointer<lv_event_t>?) {
  guard let e else { return }
  guard let obj = lv_event_get_target(e) else { return }

  let code = lv_event_get_code(e)
  let key = UnsafeMutableRawPointer(obj)

  if code == LV_EVENT_VALUE_CHANGED {
    guard let box = TextFieldRegistry.fields[key] else { return }
    let value = String(cString: lv_textarea_get_text(obj))
    box.update(value)
  } else if code == LV_EVENT_DELETE {
    TextFieldRegistry.unregister(obj: obj)
  }
}
