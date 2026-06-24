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


/// A view that fully manages its own renderer-specific subtree.
/// Tokmak treats it as a leaf — no body, no child reconciliation.
///
/// The render hooks use opaque `UnsafeMutableRawPointer`s (renderer and native object)
/// so this protocol stays free of any renderer import. The renderer-specific module
/// (Graphics) provides the real implementations for its native views; embedded Swift can
/// then dispatch to them statically instead of casting to an existential renderer view.
public protocol NativeView: _PrimitiveView {
  func _nativeNew(_ renderer: UnsafeMutableRawPointer, _ parent: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer
  func _nativeUpdate(_ renderer: UnsafeMutableRawPointer, _ target: UnsafeMutableRawPointer)
}

public extension NativeView {
  func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitNativeView(self)
  }

  // Defaults for native views that don't build a renderer object.
  func _nativeNew(_ renderer: UnsafeMutableRawPointer, _ parent: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer { parent }
  func _nativeUpdate(_ renderer: UnsafeMutableRawPointer, _ target: UnsafeMutableRawPointer) {}
}

/// A visitor that can traverse a `View` tree without type erasure or reflection.
/// Renderers implement this to handle primitive views.
public protocol ViewWalker {
  mutating func visit<V: View>(_ view: V)
  mutating func visitNativeView<V: NativeView>(_ view: V)
  mutating func visitText(_ view: Text)
  mutating func visitVStack<V: View>(_ view: VStack<V>)
  mutating func visitHStack<V: View>(_ view: HStack<V>)
  mutating func visitZStack<V: View>(_ view: ZStack<V>)
  mutating func visitTabView<V: View>(_ view: TabView<V>)
  mutating func visitButton<V: View>(_ view: Button<V>)
  mutating func visitSpacer(_ view: Spacer)
  mutating func visitDivider(_ view: Divider)
  mutating func visitImage(_ view: Image)
  mutating func visitTextField(_ view: TextField)
  mutating func visitTextEditor(_ view: TextEditor)
  mutating func visitList<V: View>(_ view: List<V>)
  mutating func visitNavigationStack<V: View>(_ view: NavigationStack<V>)
  mutating func visitNavigationLink<L: View, D: View>(_ view: NavigationLink<L, D>)
  mutating func visitForEach<Data, ID, Content>(_ view: ForEach<Data, ID, Content>)
  mutating func visitGroup<V: View>(_ view: Group<V>)
  mutating func visitScrollView<V: View>(_ view: ScrollView<V>)
  mutating func visitScrollViewReader<V: View>(_ view: ScrollViewReader<V>)
  mutating func visitInlineFlow<V: View>(_ view: _InlineFlow<V>)
  mutating func visitContentUnavailableView(_ view: ContentUnavailableView)
  mutating func visitIdentifiedView<V: View>(_ view: _IdentifiedView<V>)
  mutating func visitFilledShape<S: Shape>(_ view: _FilledShape<S>)
  mutating func visitFrameView<V: View>(_ view: _FrameView<V>)
  mutating func visitPaddingView<V: View>(_ view: _PaddingView<V>)
  mutating func visitClipShapeView<V: View, S: Shape>(_ view: _ClipShapeView<V, S>)
  mutating func visitBackgroundView<V: View>(_ view: _BackgroundView<V>)
  mutating func visitForegroundStyleView<V: View>(_ view: _ForegroundStyleView<V>)
  mutating func visitButtonStyleView<V: View, S: ButtonStyle>(_ view: _ButtonStyleView<V, S>)
  mutating func visitMultilineTextAlignmentView<V: View>(_ view: _MultilineTextAlignmentView<V>)
}/// A visitor that supports reconciliation by tracking current fibers.
public extension ViewWalker {
  mutating func visitNativeView<V: NativeView>(_ view: V) {}
}

public protocol ReconciliationWalker: ViewWalker {
  var currentFiber: FiberNode? { get set }
}

public protocol View {
  associatedtype Body: View

  @ViewBuilder
  var body: Self.Body { get }

  /// Traverse the view tree statically.
  func walk<V: ViewWalker>(_ visitor: inout V)

  /// Dispatch to a specialized visitor method.
  func _visit<V: ViewWalker>(_ visitor: inout V)

  /// Returns the identity of this view for reconciliation.
  var reconciliationIdentity: TokmakIdentityKey? { get }

  /// Returns the scroll target ID of this view.
  var scrollTargetID: TokmakIdentityKey? { get }

  var isPrimitive: Bool { get }
  var isRendererView: Bool { get }
  var tokmakFrameSizedTarget: TokmakFrameSizedTarget { get }
}

public extension View {
  func walk<V: ViewWalker>(_ visitor: inout V) {
    visitor.visit(self)
  }

  func _visit<V: ViewWalker>(_ visitor: inout V) {
    // Default implementation for non-primitive views
    self.body.walk(&visitor)
  }

  var reconciliationIdentity: TokmakIdentityKey? { nil }
  var scrollTargetID: TokmakIdentityKey? { nil }
  var isPrimitive: Bool { false }
  var isRendererView: Bool { false }
  var tokmakFrameSizedTarget: TokmakFrameSizedTarget { .none }
}

public extension Never {
  @_spi(Tokmak)
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
  var isPrimitive: Bool { true }

  @_spi(Tokmak)
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
