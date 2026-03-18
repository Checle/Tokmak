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
import Dispatch
import OpenCombineShim
import TokmakCore

public extension App {
  static func _launch(_ app: Self, with configuration: _AppConfiguration) {
    // Initialize LVGL
    lv_init()
    
    // Create a specialized renderer for Embedded Swift that uses static dispatch.
    let renderer = LVGLRenderer()
    
    // Start the rendering process by traversing the App hierarchy.
    renderer.render(app)
  }

  static func _setTitle(_ title: String) {
  }

  var _colorSchemePublisher: AnyPublisher<ColorScheme, Never> {
    CurrentValueSubject(.light).eraseToAnyPublisher()
  }
}
