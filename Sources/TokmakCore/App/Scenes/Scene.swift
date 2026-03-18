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
//
//  Created by Carson Katri on 7/16/20.
//

/// A visitor that can traverse a `Scene` tree.
public protocol SceneWalker: ViewWalker {
  mutating func visit<S: Scene>(_ scene: S)
}

public protocol Scene {
  associatedtype Body: Scene

  var body: Self.Body { get }

  /// Traverse the scene tree statically.
  func walk<V: SceneWalker>(_ visitor: inout V)

  /// Traverse the dynamic properties of this scene.
  mutating func visitDynamicProperties<V: DynamicPropertyVisitor>(_ visitor: inout V)
}

public extension Scene {
  func walk<V: SceneWalker>(_ visitor: inout V) {
    body.walk(&visitor)
  }

  mutating func visitDynamicProperties<V: DynamicPropertyVisitor>(_ visitor: inout V) {}
}

protocol TitledScene {
  var title: Text? { get }
}

protocol ParentScene {
  var children: [_AnyScene] { get }
}

protocol GroupScene: ParentScene {}

public protocol SceneDeferredToRenderer {
  var deferredBody: AnyView { get }
}

extension Never: Scene {
  public func walk<V: SceneWalker>(_ visitor: inout V) {}
  public mutating func visitDynamicProperties<V: DynamicPropertyVisitor>(_ visitor: inout V) {}
}

/// Calls `fatalError` with an explanation that a given `type` is a primitive `Scene`
public func neverScene(_ type: String) -> Never {
  fatalError("\(type) is a primitive `Scene`, you're not supposed to access its `body`.")
}
