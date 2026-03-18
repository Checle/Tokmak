// Copyright 2020 Tokamak contributors
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

public struct _TupleScene<T>: Scene {
  public let scenes: T

  public init(_ scenes: T) {
    self.scenes = scenes
  }

  public var body: Never {
    neverScene("_TupleScene")
  }

  public func walk<V: SceneWalker>(_ visitor: inout V) {
    visitor.visit(self)
    // In a full implementation, we would reflect over the tuple and walk each scene.
    // For a minimal app, we might not need this to do much yet.
  }
}

extension _TupleScene: ParentScene {
  public var children: [_AnyScene] {
    // This is a bit complex to implement without reflection. 
    // For a minimal Hello World, we might be able to get away with an empty list 
    // or a simple manual implementation for 2-element tuples if needed.
    []
  }
}
