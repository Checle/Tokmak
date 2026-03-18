// Copyright 2020 Tokamak contributors
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
//  Created by Carson Katri on 7/16/20.
//

struct _TupleScene<T>: Scene, GroupScene {
  let value: T

  init(_ value: T) {
    self.value = value
  }

  public var children: [_AnyScene] {
    if let v = value as? (any Scene, any Scene) {
      return [_AnyScene(v.0), _AnyScene(v.1)]
    } else if let v = value as? (any Scene, any Scene, any Scene) {
      return [_AnyScene(v.0), _AnyScene(v.1), _AnyScene(v.2)]
    } else if let v = value as? any Scene {
      return [_AnyScene(v)]
    }
    return []
  }

  public func walk<V: SceneWalker>(_ visitor: inout V) {
    if let v = value as? (any Scene, any Scene) {
      v.0.walk(&visitor)
      v.1.walk(&visitor)
    } else if let v = value as? (any Scene, any Scene, any Scene) {
      v.0.walk(&visitor)
      v.1.walk(&visitor)
      v.2.walk(&visitor)
    } else if let v = value as? any Scene {
      v.walk(&visitor)
    }
  }

  var body: Never {
    neverScene("_TupleScene")
  }
}
