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
//  Created by Max Desiatov on 08/04/2020.
//

import CLVGL

/// A view that displays one or more lines of read-only text.
///
/// You can choose a font using the `font(_:)` view modifier.
///
///     Text("Hello World")
///       .font(.title)
///
/// There are a variety of modifiers available to fully customize the type:
///
///     Text("Hello World")
///       .foregroundColor(.blue)
///       .bold()
///       .italic()
///       .underline(true, color: .red)
public struct Text: _PrimitiveView, Equatable {
  let storage: _Storage
  let modifiers: [_Modifier]
  var environment = EnvironmentValues()

  public static func == (lhs: Text, rhs: Text) -> Bool {
    lhs.storage == rhs.storage
      && lhs.modifiers == rhs.modifiers
  }

  public enum _Storage: Equatable {
    case verbatim(String)
    case segmentedText([(storage: _Storage, modifiers: [_Modifier])])

    public static func == (lhs: Text._Storage, rhs: Text._Storage) -> Bool {
      switch lhs {
      case let .verbatim(lhsVerbatim):
        guard case let .verbatim(rhsVerbatim) = rhs else { return false }
        return lhsVerbatim == rhsVerbatim
      case let .segmentedText(lhsSegments):
        guard case let .segmentedText(rhsSegments) = rhs,
              lhsSegments.count == rhsSegments.count else { return false }
        return lhsSegments.enumerated().allSatisfy {
          $0.element.0 == rhsSegments[$0.offset].0
            && $0.element.1 == rhsSegments[$0.offset].1
        }
      }
    }
  }

  public enum _Modifier: Equatable {
    case color(Color?)
    case font(Font?)
    case italic
    case weight(Font.Weight?)
    case kerning(CGFloat)
    case tracking(CGFloat)
    case baseline(CGFloat)
    case rounded
    case strikethrough(Bool, Color?) // Note: Not in SwiftUI
    case underline(Bool, Color?) // Note: Not in SwiftUI
  }

  init(storage: _Storage, modifiers: [_Modifier] = []) {
    if case let .segmentedText(segments) = storage {
      self.storage = .segmentedText(segments.map {
        ($0.0, Text.mergedModifiers(prefix: modifiers, suffix: $0.1))
      })
    } else {
      self.storage = storage
    }
    self.modifiers = modifiers
  }

  public init(verbatim content: String) {
    self.init(storage: .verbatim(content))
  }

  public init<S>(_ content: S) where S: StringProtocol {
    self.init(storage: .verbatim(String(content)))
  }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitText(self)
  }

  public func _createTarget(renderer: LVGLRenderer, parent: UnsafeMutablePointer<lv_obj_t>) -> UnsafeMutablePointer<lv_obj_t>? {
    lv_label_create(parent)
  }
}

public extension Text._Storage {
  var rawText: String {
    switch self {
    case let .segmentedText(segments):
      return segments
        .map { $0.0.rawText }
        .reduce("", +)
    case let .verbatim(text):
      return text
    }
  }
}

/// This is a helper type that works around absence of "package private" access control in Swift
public struct _TextProxy {
  public let subject: Text

  public init(_ subject: Text) {
    self.subject = subject
  }

  public var storage: Text._Storage { subject.storage }

  public var rawText: String { subject.storage.rawText }

  public var modifiers: [Text._Modifier] {
    var modifiers: [Text._Modifier] = []
    modifiers.reserveCapacity(subject.modifiers.count + 2)
    modifiers.append(.font(subject.environment.font))
    modifiers.append(.color(subject.environment.foregroundColor))
    modifiers.append(contentsOf: subject.modifiers)
    return modifiers
  }

  public var environment: EnvironmentValues { subject.environment }
}

public extension Text {
  private static func appending(_ modifier: _Modifier, to modifiers: [_Modifier]) -> [_Modifier] {
    var updated = modifiers
    updated.append(modifier)
    return updated
  }

  private static func mergedModifiers(prefix: [_Modifier], suffix: [_Modifier]) -> [_Modifier] {
    var merged: [_Modifier] = []
    merged.reserveCapacity(prefix.count + suffix.count)
    merged.append(contentsOf: prefix)
    merged.append(contentsOf: suffix)
    return merged
  }

  func font(_ font: Font?) -> Text {
    .init(storage: storage, modifiers: Self.appending(.font(font), to: modifiers))
  }

  func foregroundColor(_ color: Color?) -> Text {
    .init(storage: storage, modifiers: Self.appending(.color(color), to: modifiers))
  }

  func fontWeight(_ weight: Font.Weight?) -> Text {
    .init(storage: storage, modifiers: Self.appending(.weight(weight), to: modifiers))
  }

  func bold() -> Text {
    .init(storage: storage, modifiers: Self.appending(.weight(.bold), to: modifiers))
  }

  func italic() -> Text {
    .init(storage: storage, modifiers: Self.appending(.italic, to: modifiers))
  }

  func strikethrough(_ active: Bool = true, color: Color? = nil) -> Text {
    .init(storage: storage, modifiers: Self.appending(.strikethrough(active, color), to: modifiers))
  }

  func underline(_ active: Bool = true, color: Color? = nil) -> Text {
    .init(storage: storage, modifiers: Self.appending(.underline(active, color), to: modifiers))
  }

  func kerning(_ kerning: CGFloat) -> Text {
    .init(storage: storage, modifiers: Self.appending(.kerning(kerning), to: modifiers))
  }

  func tracking(_ tracking: CGFloat) -> Text {
    .init(storage: storage, modifiers: Self.appending(.tracking(tracking), to: modifiers))
  }

  func baselineOffset(_ baselineOffset: CGFloat) -> Text {
    .init(storage: storage, modifiers: Self.appending(.baseline(baselineOffset), to: modifiers))
  }
}

public extension Text {
  static func _concatenating(lhs: Self, rhs: Self) -> Self {
    .init(storage: .segmentedText([
      (lhs.storage, lhs.modifiers),
      (rhs.storage, rhs.modifiers),
    ]))
  }
}

extension Text: Layout {
  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    environment.measureText(self, proposal, environment)
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    for subview in subviews {
      subview.place(at: bounds.origin, proposal: proposal)
    }
  }
}
