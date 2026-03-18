// Copyright 2018-2020 Tokamak contributors
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
//
//  Created by Max Desiatov on 07/10/2018.
//

/** Renderer protocol that renderers for all platforms must implement.
 */
public protocol Renderer: AnyObject {
  /** Views are rendered to platform-specific targets with a renderer.
   */
  associatedtype TargetType: Target

  func render<V: View>(_ view: V)
}
