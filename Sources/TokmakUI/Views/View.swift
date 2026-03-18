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
//  Created by Max Desiatov on 07/04/2020.
//

/// A visitor that can traverse a `View` tree without type erasure or reflection.
/// Renderers implement this to handle primitive views.
public protocol ViewWalker {
  mutating func visit<V: View>(_ view: V)
}

/// A visitor that supports reconciliation by tracking current fibers.
public protocol ReconciliationWalker: ViewWalker {
  var currentFiber: (any AnyFiber)? { get set }
}

/// A visitor that can traverse the dynamic properties of a `View`.
public protocol PropertyVisitor {
  mutating func visit<P: DynamicProperty>(_ property: inout P)
}

public protocol View {
  associatedtype Body: View

  @ViewBuilder
  var body: Self.Body { get }

  /// Traverse the view tree statically.
  func walk<V: ViewWalker>(_ visitor: inout V)

  /// Traverse the dynamic properties of this view.
  mutating func visitProperties<V: PropertyVisitor>(_ visitor: inout V)
}

public extension View {
  func walk<V: ViewWalker>(_ visitor: inout V) {
    body.walk(&visitor)
  }

  mutating func visitProperties<V: PropertyVisitor>(_ visitor: inout V) {}
}

public extension Never {
  @_spi(TokmakUI)
  var body: Never {
    fatalError()
  }
}

extension Never: View {
  public func walk<V: ViewWalker>(_ visitor: inout V) {}
}

/// A `View` that offers primitive functionality, which renders its `body` inaccessible.
public protocol _PrimitiveView: View where Body == Never {}

public extension _PrimitiveView {
  @_spi(TokmakUI)
  var body: Never {
    neverBody(String(reflecting: Self.self))
  }

  func walk<V: ViewWalker>(_ visitor: inout V) {
    visitor.visit(self)
  }
}

/// A marker for views that are terminal primitives in a specific renderer.
public typealias PrimitiveView = _PrimitiveView

/// A `View` type that renders with subviews, usually specified in the `Content` type argument
public protocol ParentView {
  var children: [AnyView] { get }
}

/// A `View` type that is not rendered but "flattened", rendering all its children instead.
protocol GroupView: ParentView {}

/// Calls `fatalError` with an explanation that a given `type` is a primitive `View`
public func neverBody(_ type: String) -> Never {
  fatalError("\(type) is a primitive `View`, you're not supposed to access its `body`.")
}
