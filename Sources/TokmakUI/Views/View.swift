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

import CLVGL

/// A visitor that can traverse a `View` tree without type erasure or reflection.
/// Renderers implement this to handle primitive views.
public protocol ViewWalker {
  mutating func visit<V: View>(_ view: V)
  mutating func visitText(_ view: Text)
  mutating func visitVStack<V: View>(_ view: VStack<V>)
  mutating func visitHStack<V: View>(_ view: HStack<V>)
  mutating func visitZStack<V: View>(_ view: ZStack<V>)
  mutating func visitButton<V: View>(_ view: Button<V>)
  mutating func visitSpacer(_ view: Spacer)
  mutating func visitDivider(_ view: Divider)
  mutating func visitImage(_ view: Image)
  mutating func visitTextField(_ view: TextField)
  mutating func visitForEach<Data, ID, Content>(_ view: ForEach<Data, ID, Content>)
  mutating func visitGroup<V: View>(_ view: Group<V>)
  mutating func visitScrollView<V: View>(_ view: ScrollView<V>)
  mutating func visitScrollViewReader<V: View>(_ view: ScrollViewReader<V>)
  mutating func visitContentUnavailableView(_ view: ContentUnavailableView)
  mutating func visitIdentifiedView<V: View>(_ view: _IdentifiedView<V>)
  mutating func visitFrameView<V: View>(_ view: _FrameView<V>)
  mutating func visitPaddingView<V: View>(_ view: _PaddingView<V>)
  mutating func visitClipShapeView<V: View, S: Shape>(_ view: _ClipShapeView<V, S>)
  mutating func visitBackgroundView<V: View>(_ view: _BackgroundView<V>)
  mutating func visitForegroundStyleView<V: View>(_ view: _ForegroundStyleView<V>)
  mutating func visitButtonStyleView<V: View, S: ButtonStyle>(_ view: _ButtonStyleView<V, S>)
}/// A visitor that supports reconciliation by tracking current fibers.
public protocol ReconciliationWalker: ViewWalker {
  var currentFiber: FiberNode? { get set }
}

/// A visitor that can traverse the dynamic properties of a `View`.
public protocol PropertyVisitor {
  mutating func visit<P: DynamicProperty>(_ property: inout P)
  mutating func visitState<V>(_ state: inout State<V>)
  mutating func visitBinding<V>(_ binding: inout Binding<V>)
}
public protocol View {
  associatedtype Body: View

  @ViewBuilder
  var body: Self.Body { get }

  /// Traverse the view tree statically.
  func walk<V: ViewWalker>(_ visitor: inout V)

  /// Traverse the dynamic properties of this view.
  mutating func visitProperties<V: PropertyVisitor>(_ visitor: inout V)

  /// Dispatch to a specialized visitor method.
  func _visit<V: ViewWalker>(_ visitor: inout V)

  /// Returns the identity of this view for reconciliation.
  var reconciliationIdentity: TokmakIdentityKey? { get }

  /// Returns the scroll target ID of this view.
  var scrollTargetID: TokmakIdentityKey? { get }

  /// Creates a new target for this view if it's a primitive.
  func _createTarget(renderer: LVGLRenderer, parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>?

  /// Returns the content parent for this view if it's a container.
  func _contentParent(for target: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>?
}

public extension View {
  func walk<V: ViewWalker>(_ visitor: inout V) {
    visitor.visit(self)
  }

  mutating func visitProperties<V: PropertyVisitor>(_ visitor: inout V) {}

  func _visit<V: ViewWalker>(_ visitor: inout V) {
    // Default implementation for non-primitive views
    self.body.walk(&visitor)
  }

  var reconciliationIdentity: TokmakIdentityKey? { nil }
  var scrollTargetID: TokmakIdentityKey? { nil }

  func _createTarget(renderer: LVGLRenderer, parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>? {
    nil
  }

  func _contentParent(for target: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>? {
    nil
  }
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
public protocol _PrimitiveView: View where Body == Never {
  func _visit<V: ViewWalker>(_ visitor: inout V)
}

public extension _PrimitiveView {
  @_spi(TokmakUI)
  var body: Never {
    neverBody("PrimitiveView")
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
