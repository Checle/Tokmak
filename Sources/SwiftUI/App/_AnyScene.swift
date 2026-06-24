// Copyright 2020-2021 Tokamak contributors
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
//  Created by Carson Katri on 7/19/20.
//

 #if hasFeature(Embedded)
public struct _AnyScene: Scene {
  init<S: Scene>(_ scene: S) {}

  public func walk<V: SceneWalker>(_ visitor: inout V) {
    fatalError("_AnyScene is unavailable in embedded builds.")
  }

  @_spi(Tokmak)
  public var body: Never {
    neverScene("_AnyScene")
  }
}
#else
public struct _AnyScene: Scene {
  /// The actual `Scene` value wrapped within this `_AnyScene`.
  var scene: Any

  /// The type of the underlying `scene`
  let type: Any.Type

  let walkClosure: (inout any SceneWalker, Any) -> ()

  init<S: Scene>(_ scene: S) {
    if let anyScene = scene as? _AnyScene {
      self = anyScene
    } else {
      self.scene = scene
      type = S.self
      walkClosure = { visitor, scene in
        var v = visitor
        (scene as! S).walk(&v)
        visitor = v
      }
    }
  }

  public func walk<V: SceneWalker>(_ visitor: inout V) {
    var anyVisitor: any SceneWalker = visitor
    walkClosure(&anyVisitor, scene)
    visitor = anyVisitor as! V
  }

  @_spi(Tokmak)
  public var body: Never {
    neverScene("_AnyScene")
  }
}
#endif
