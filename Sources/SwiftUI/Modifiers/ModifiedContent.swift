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

protocol ModifiedContentProtocol {}

/// A value with a modifier applied to it.
public struct ModifiedContent<Content, Modifier>: ModifiedContentProtocol {
  public var environment = EnvironmentValues()

  public typealias Body = Never
  public private(set) var content: Content
  public private(set) var modifier: Modifier

  public init(content: Content, modifier: Modifier) {
    self.content = content
    self.modifier = modifier
  }
}

extension ModifiedContent: EnvironmentReader where Modifier: EnvironmentReader {
  mutating func setContent(from values: EnvironmentValues) {
    modifier.setContent(from: values)
  }
}

extension ModifiedContent: View, GroupView, ParentView where Content: View, Modifier: ViewModifier {
  public var body: Body {
    neverBody("ModifiedContent<View, ViewModifier>")
  }

  public var children: [AnyView] {
    [AnyView(content)]
  }

  public func walk<V: ViewWalker>(_ visitor: inout V) {
    #if hasFeature(Embedded)
    if let background = modifier as? _BackgroundLayout {
      let wrapper = _BackgroundView(content: content, color: background.color)
      visitor.visitBackgroundView(wrapper)
    } else if let padding = modifier as? _PaddingLayout {
      let wrapper = _PaddingView(content: content, edges: padding.edges, insets: padding.insets)
      visitor.visitPaddingView(wrapper)
    } else if let frame = modifier as? _FrameLayout {
      let wrapper = _FrameView(
        content: content,
        width: frame.width,
        height: frame.height,
        fillWidth: frame.fillWidth,
        fillHeight: frame.fillHeight,
        alignment: frame.alignment
      )
      visitor.visitFrameView(wrapper)
    } else if let foreground = modifier as? _ForegroundStyleLayout {
      let wrapper = _ForegroundStyleView(content: content, color: foreground.color)
      visitor.visitForegroundStyleView(wrapper)
    } else if let alignment = modifier as? _MultilineTextAlignmentLayout {
      let wrapper = _MultilineTextAlignmentView(content: content, alignment: alignment.alignment)
      visitor.visitMultilineTextAlignmentView(wrapper)
    } else if let clip = modifier as? _ClipShapeLayout<Circle> {
      visitor.visitClipShapeView(_ClipShapeView(content: content, shape: clip.shape))
    } else if let clip = modifier as? _ClipShapeLayout<RoundedRectangle> {
      visitor.visitClipShapeView(_ClipShapeView(content: content, shape: clip.shape))
    } else if let clip = modifier as? _ClipShapeLayout<Capsule> {
      visitor.visitClipShapeView(_ClipShapeView(content: content, shape: clip.shape))
    } else if let buttonStyle = modifier as? _ButtonStyleLayout<PlainButtonStyle> {
      visitor.visitButtonStyleView(_ButtonStyleView(content: content, style: buttonStyle.style))
    } else {
      // Embedded cannot decompose an unknown generic modifier via existentials, so any
      // modifier without a case above is walked through transparently (the modifier is a no-op).
      // _ClipShapeLayout / _ButtonStyleLayout are generic; the concrete shape/style specializations
      // actually used by the app are matched explicitly above.
      content.walk(&visitor)
    }
    #else
    if Modifier.Body.self == Never.self {
      content.walk(&visitor)
    } else {
      modifier.body(content: .init(modifier: modifier, view: content)).walk(&visitor)
    }
    #endif
  }
}

extension ModifiedContent: ViewModifier where Content: ViewModifier, Modifier: ViewModifier {
  public func body(content: _ViewModifier_Content<Self>) -> Never {
    neverBody("ModifiedContent<ViewModifier, ViewModifier>")
  }
}

public extension ViewModifier {
  func concat<T>(_ modifier: T) -> ModifiedContent<Self, T> where T: ViewModifier {
    .init(content: self, modifier: modifier)
  }
}
