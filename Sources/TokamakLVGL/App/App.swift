// Copyright 2020-2021 Tokamak contributors
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
import TokamakCore

public extension App {
  static func _launch(_ app: Self, with configuration: _AppConfiguration) {
    // Initialize LVGL
    lv_init()
    
    // Create a simple display driver (this is a minimal implementation)
    // In a real implementation, you would set up a proper display driver
    // based on your target platform (embedded Linux, microcontroller, etc.)
    
    _ = Unmanaged.passRetained(LVGLRenderer(app, configuration.rootEnvironment))
  }

  static func _setTitle(_ title: String) {
    // LVGL doesn't have a traditional title concept,
    // but this could be used to set a label or display name if desired
  }

  var _phasePublisher: AnyPublisher<ScenePhase, Never> {
    CurrentValueSubject(.active).eraseToAnyPublisher()
  }

  var _colorSchemePublisher: AnyPublisher<ColorScheme, Never> {
    CurrentValueSubject(.light).eraseToAnyPublisher()
  }
}
