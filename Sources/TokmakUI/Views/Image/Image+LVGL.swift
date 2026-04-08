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

extension Image: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer, _ parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t> {
    let obj = lv_img_create(parent)!

    lv_img_set_size_mode(obj, lv_img_size_mode_t(LV_IMG_SIZE_MODE_REAL))
    updateImage(obj)

    return obj
  }

  func updateImage(_ obj: UnsafeMutablePointer<lv_obj_t>) {
    let proxy = _ImageProxy(self)
    proxy.source.withCString { cString in
      lv_img_set_src(obj, cString)
    }
  }
}
