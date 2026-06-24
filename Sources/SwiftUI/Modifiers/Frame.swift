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




public enum TokmakFrameSizedTarget {
  case none
  case button
  case shape
  case text
}

protocol _ButtonFrameSizedControl {}
protocol _ShapeFrameSizedControl {}
protocol _TextFrameSizedControl {}

protocol _FrameSizedContent {
  var _frameSizedContent: AnyView { get }
}

public struct _FrameLayout: ViewModifier {
  public let width: CGFloat?
  public let height: CGFloat?
  public let fillWidth: Bool
  public let fillHeight: Bool
  public let alignment: Alignment

  public init(
    width: CGFloat? = nil,
    height: CGFloat? = nil,
    fillWidth: Bool = false,
    fillHeight: Bool = false,
    alignment: Alignment = .center
  ) {
    self.width = width
    self.height = height
    self.fillWidth = fillWidth
    self.fillHeight = fillHeight
    self.alignment = alignment
  }

  public func body(content: Content) -> some View {
    _FrameView(
      content: content,
      width: width,
      height: height,
      fillWidth: fillWidth,
      fillHeight: fillHeight,
      alignment: alignment
    )
  }
}

public struct _FrameView<Content: View>: View {
  public let content: Content
  public let width: CGFloat?
  public let height: CGFloat?
  public let fillWidth: Bool
  public let fillHeight: Bool
  public let alignment: Alignment

  public var body: Content { content }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitFrameView(self)
  }


}

public extension View {
  func frame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) -> some View {
    modifier(_FrameLayout(width: width, height: height, alignment: alignment))
  }

  func frame(
    minWidth: CGFloat? = nil,
    idealWidth: CGFloat? = nil,
    maxWidth: CGFloat? = nil,
    minHeight: CGFloat? = nil,
    idealHeight: CGFloat? = nil,
    maxHeight: CGFloat? = nil,
    alignment: Alignment = .center
  ) -> some View {
    modifier(_FrameLayout(
      width: idealWidth ?? fixedFrameValue(minWidth: minWidth, maxWidth: maxWidth),
      height: idealHeight ?? fixedFrameValue(minWidth: minHeight, maxWidth: maxHeight),
      fillWidth: maxWidth == .infinity,
      fillHeight: maxHeight == .infinity,
      alignment: alignment
    ))
  }
}

extension Button: _ButtonFrameSizedControl {
  public var tokmakFrameSizedTarget: TokmakFrameSizedTarget { .button }
}
extension Text: _TextFrameSizedControl {
  public var tokmakFrameSizedTarget: TokmakFrameSizedTarget { .text }
}
extension _FilledShape {
  public var tokmakFrameSizedTarget: TokmakFrameSizedTarget { .shape }
}

extension _ViewModifier_Content: _FrameSizedContent {
  var _frameSizedContent: AnyView { view }
  public var tokmakFrameSizedTarget: TokmakFrameSizedTarget { view.tokmakFrameSizedTarget }
}

extension ModifiedContent: _FrameSizedContent where Content: View, Modifier: ViewModifier {
  var _frameSizedContent: AnyView { AnyView(content) }
  public var tokmakFrameSizedTarget: TokmakFrameSizedTarget { content.tokmakFrameSizedTarget }
}

public func tokmakFrameSizedTarget<Content: View>(_ content: Content) -> TokmakFrameSizedTarget {
  #if hasFeature(Embedded)
  return content.tokmakFrameSizedTarget
  #else
  if content is _ButtonFrameSizedControl {
    return .button
  }

  if content is _ShapeFrameSizedControl {
    return .shape
  }

  if content is _TextFrameSizedControl {
    return .text
  }

  guard let framedContent = content as? _FrameSizedContent else {
    return .none
  }

  return tokmakAnyViewFrameSizedTarget(framedContent._frameSizedContent)
  #endif
}

private func tokmakAnyViewFrameSizedTarget(_ anyView: AnyView) -> TokmakFrameSizedTarget {
  #if hasFeature(Embedded)
  .none
  #else
  if anyView.view is _ButtonFrameSizedControl {
    return .button
  }

  if anyView.view is _ShapeFrameSizedControl {
    return .shape
  }

  if anyView.view is _TextFrameSizedControl {
    return .text
  }

  if let framedContent = anyView.view as? _FrameSizedContent {
    return tokmakAnyViewFrameSizedTarget(framedContent._frameSizedContent)
  }

  return .none
  #endif
}

private func fixedFrameValue(minWidth: CGFloat?, maxWidth: CGFloat?) -> CGFloat? {
  if let maxWidth, maxWidth != .infinity {
    return maxWidth
  }

  return minWidth
}
