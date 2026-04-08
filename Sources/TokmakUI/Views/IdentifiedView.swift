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

public struct TokmakIdentityKey: Hashable {
  private enum Storage: Hashable {
    case int(Int)
    case uint(UInt)
    case string(String)
    case bool(Bool)
    case raw(valueHash: Int)
  }

  private let storage: Storage

  init<ID: Hashable>(_ value: ID) {
    if let value = value as? Int {
      storage = .int(value)
    } else if let value = value as? UInt {
      storage = .uint(value)
    } else if let value = value as? String {
      storage = .string(value)
    } else if let value = value as? Bool {
      storage = .bool(value)
    } else {
      var valueHasher = Hasher()
      value.hash(into: &valueHasher)

      storage = .raw(valueHash: valueHasher.finalize())
    }
  }
}

protocol ScrollTargetView {
  var scrollTargetID: TokmakIdentityKey { get }
}

protocol ReconciliationIdentityView {
  var reconciliationIdentity: TokmakIdentityKey { get }
}

struct _IdentifiedView<Content: View>: View, AnyLVGLWidget, ScrollTargetView, ReconciliationIdentityView {
  let content: Content
  let scrollTargetID: TokmakIdentityKey

  var reconciliationIdentity: TokmakIdentityKey {
    scrollTargetID
  }

  var body: Content { content }

  func new(
    _ renderer: LVGLRenderer,
    _ parent: UnsafeMutablePointer<lv_obj_t>
  ) -> UnsafeMutablePointer<lv_obj_t> {
    let obj = lv_obj_create(parent)!
    lv_obj_set_width(obj, tokmakLVSizeContent)
    lv_obj_set_height(obj, tokmakLVSizeContent)
    lv_obj_set_style_pad_all(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_border_width(obj, 0, UInt32(LV_PART_MAIN))
    lv_obj_set_style_bg_opa(obj, 0, UInt32(LV_PART_MAIN))
    return obj
  }
}

public extension View {
  func id<ID>(_ id: ID) -> some View where ID: Hashable {
    _IdentifiedView(content: self, scrollTargetID: TokmakIdentityKey(id))
  }
}
