// Copyright 2026 Tokamak contributors
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

/// A visitor that can traverse a `View` tree without type erasure or reflection.
/// Renderers implement this to handle primitive views.
public protocol StaticVisitor {
  mutating func visit<V: View>(_ view: V)
}

/// A `View` that supports static tree traversal for Embedded Swift.
public protocol StaticView: View {
  func walk<V: StaticVisitor>(_ visitor: inout V)
}

/// A visitor that supports reconciliation by tracking current fibers.
public protocol StaticReconciliationVisitor: StaticVisitor {
  var currentFiber: (any AnyStaticFiber)? { get set }
}

public extension StaticView {
  func walk<V: StaticVisitor>(_ visitor: inout V) {
    if let staticBody = body as? any StaticView {
      staticBody.walk(&visitor)
    } else {
      visitor.visit(body)
    }
  }
}

/// A marker for views that are terminal primitives in a specific renderer.
public protocol StaticPrimitiveView: StaticView {}

public extension StaticPrimitiveView {
  func walk<V: StaticVisitor>(_ visitor: inout V) {
    visitor.visit(self)
  }
}
