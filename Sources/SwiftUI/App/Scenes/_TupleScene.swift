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
    walkTupleScenes(scenes, &visitor)
  }
}

extension _TupleScene: ParentScene {
  public var children: [_AnyScene] {
    []
  }
}

private func walkTupleScenes<V: SceneWalker, T>(_ scenes: T, _ visitor: inout V) {
  #if hasFeature(Embedded)
  // No-op in Embedded Swift (dynamic casting of existentials is not supported)
  #else
  if let scenes = scenes as? (any Scene, any Scene) {
    walkAnyScene(scenes.0, &visitor)
    walkAnyScene(scenes.1, &visitor)
  } else if let scenes = scenes as? (any Scene, any Scene, any Scene) {
    walkAnyScene(scenes.0, &visitor)
    walkAnyScene(scenes.1, &visitor)
    walkAnyScene(scenes.2, &visitor)
  } else if let scenes = scenes as? (any Scene, any Scene, any Scene, any Scene) {
    walkAnyScene(scenes.0, &visitor)
    walkAnyScene(scenes.1, &visitor)
    walkAnyScene(scenes.2, &visitor)
    walkAnyScene(scenes.3, &visitor)
  } else if let scenes = scenes as? (any Scene, any Scene, any Scene, any Scene, any Scene) {
    walkAnyScene(scenes.0, &visitor)
    walkAnyScene(scenes.1, &visitor)
    walkAnyScene(scenes.2, &visitor)
    walkAnyScene(scenes.3, &visitor)
    walkAnyScene(scenes.4, &visitor)
  } else if let scenes = scenes as? (any Scene, any Scene, any Scene, any Scene, any Scene, any Scene) {
    walkAnyScene(scenes.0, &visitor)
    walkAnyScene(scenes.1, &visitor)
    walkAnyScene(scenes.2, &visitor)
    walkAnyScene(scenes.3, &visitor)
    walkAnyScene(scenes.4, &visitor)
    walkAnyScene(scenes.5, &visitor)
  } else if let scenes = scenes as? (any Scene, any Scene, any Scene, any Scene, any Scene, any Scene, any Scene) {
    walkAnyScene(scenes.0, &visitor)
    walkAnyScene(scenes.1, &visitor)
    walkAnyScene(scenes.2, &visitor)
    walkAnyScene(scenes.3, &visitor)
    walkAnyScene(scenes.4, &visitor)
    walkAnyScene(scenes.5, &visitor)
    walkAnyScene(scenes.6, &visitor)
  } else if let scenes = scenes as? (any Scene, any Scene, any Scene, any Scene, any Scene, any Scene, any Scene, any Scene) {
    walkAnyScene(scenes.0, &visitor)
    walkAnyScene(scenes.1, &visitor)
    walkAnyScene(scenes.2, &visitor)
    walkAnyScene(scenes.3, &visitor)
    walkAnyScene(scenes.4, &visitor)
    walkAnyScene(scenes.5, &visitor)
    walkAnyScene(scenes.6, &visitor)
    walkAnyScene(scenes.7, &visitor)
  } else if let scenes = scenes as? (any Scene, any Scene, any Scene, any Scene, any Scene, any Scene, any Scene, any Scene, any Scene) {
    walkAnyScene(scenes.0, &visitor)
    walkAnyScene(scenes.1, &visitor)
    walkAnyScene(scenes.2, &visitor)
    walkAnyScene(scenes.3, &visitor)
    walkAnyScene(scenes.4, &visitor)
    walkAnyScene(scenes.5, &visitor)
    walkAnyScene(scenes.6, &visitor)
    walkAnyScene(scenes.7, &visitor)
    walkAnyScene(scenes.8, &visitor)
  } else if let scenes = scenes as? (any Scene, any Scene, any Scene, any Scene, any Scene, any Scene, any Scene, any Scene, any Scene, any Scene) {
    walkAnyScene(scenes.0, &visitor)
    walkAnyScene(scenes.1, &visitor)
    walkAnyScene(scenes.2, &visitor)
    walkAnyScene(scenes.3, &visitor)
    walkAnyScene(scenes.4, &visitor)
    walkAnyScene(scenes.5, &visitor)
    walkAnyScene(scenes.6, &visitor)
    walkAnyScene(scenes.7, &visitor)
    walkAnyScene(scenes.8, &visitor)
    walkAnyScene(scenes.9, &visitor)
  }
  #endif
}

private func walkAnyScene<V: SceneWalker>(_ scene: Any, _ visitor: inout V) {
  #if hasFeature(Embedded)
  // No-op in Embedded Swift
  #else
  if let scene = scene as? any Scene {
    scene.walk(&visitor)
  }
  #endif
}
