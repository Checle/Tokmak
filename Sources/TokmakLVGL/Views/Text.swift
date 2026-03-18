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
import Foundation
import TokmakCore

extension Text: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let proxy = _TextProxy(self)
    let label = lv_label_create(parent)!
    
    let text = proxy.rawText
    text.withCString { cString in
      lv_label_set_text(label, cString)
    }
    
    return label
  }

  func update(widget: LVGLWidget) {
    if case let .widget(w) = widget.storage {
      let text = _TextProxy(self).rawText
      text.withCString { cString in
        lv_label_set_text(w, cString)
      }
    }
  }
}
