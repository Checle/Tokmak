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

// A class to box the Swift closure so it can be passed through LVGL's user_data.
// This requires the object to be retained for the lifetime of the widget.
final class ActionBox {
    let action: () -> Void
    init(action: @escaping () -> Void) {
        self.action = action
    }
}

// Global lookup table for mapping LVGL objects back to their Swift actions.
// In a true memory-constrained environment, this could be attached directly
// via `user_data` if no other pointer is needed, but a global registry is safer
// when `user_data` might be used for other structural mappings.
struct EventRegistry {
    static var actions: [UnsafeMutableRawPointer: ActionBox] = [:]
    
    static func register(obj: UnsafeMutablePointer<lv_obj_t>, action: @escaping () -> Void) {
        let box = ActionBox(action: action)
        actions[UnsafeMutableRawPointer(obj)] = box
        lv_obj_add_event_cb(obj, tokmak_lvgl_event_handler, LV_EVENT_ALL, nil)
    }
    
    static func unregister(obj: UnsafeMutablePointer<lv_obj_t>) {
        let key = UnsafeMutableRawPointer(obj)
        actions.removeValue(forKey: key)
    }
}

// The raw C callback triggered by LVGL
@_cdecl("tokmak_lvgl_event_handler")
func tokmak_lvgl_event_handler(e: UnsafeMutablePointer<lv_event_t>?) {
    guard let e = e else { return }
    let obj = lv_event_get_current_target(e)
    let code = lv_event_get_code(e)
    
    if code == LV_EVENT_CLICKED {
        if let obj = obj, let box = EventRegistry.actions[UnsafeMutableRawPointer(obj)] {
            box.action()
        }
    } else if code == LV_EVENT_DELETE {
        if let obj = obj {
            EventRegistry.unregister(obj: obj)
        }
    }
}
