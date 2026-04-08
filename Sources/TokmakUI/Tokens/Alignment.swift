// Copyright 2022 Tokamak contributors
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
//  Created by Carson Katri on 2/18/22.
//

private enum HorizontalAlignmentID: Int {
  case leading = 1
  case center = 2
  case trailing = 3

  func defaultValue(in context: ViewDimensions) -> CGFloat {
    switch self {
    case .leading:
      return 0
    case .center:
      return context.width / 2
    case .trailing:
      return context.width
    }
  }
}

private enum VerticalAlignmentID: Int {
  case top = 4
  case center = 5
  case bottom = 6

  func defaultValue(in context: ViewDimensions) -> CGFloat {
    switch self {
    case .top:
      return 0
    case .center:
      return context.height / 2
    case .bottom:
      return context.height
    }
  }
}

public struct HorizontalAlignment: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }

  fileprivate let id: HorizontalAlignmentID

  private init(_ id: HorizontalAlignmentID) {
    self.id = id
  }
}

extension HorizontalAlignment {
  public static let leading = Self(.leading)
  public static let center = Self(.center)
  public static let trailing = Self(.trailing)
}

public struct VerticalAlignment: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }

  fileprivate let id: VerticalAlignmentID

  private init(_ id: VerticalAlignmentID) {
    self.id = id
  }
}

extension VerticalAlignment {
  public static let top = Self(.top)
  public static let center = Self(.center)
  public static let bottom = Self(.bottom)
}

public struct Alignment: Equatable {
  public var horizontal: HorizontalAlignment
  public var vertical: VerticalAlignment

  public init(
    horizontal: HorizontalAlignment,
    vertical: VerticalAlignment
  ) {
    self.horizontal = horizontal
    self.vertical = vertical
  }

  public static let topLeading = Self(horizontal: .leading, vertical: .top)
  public static let top = Self(horizontal: .center, vertical: .top)
  public static let topTrailing = Self(horizontal: .trailing, vertical: .top)
  public static let leading = Self(horizontal: .leading, vertical: .center)
  public static let center = Self(horizontal: .center, vertical: .center)
  public static let trailing = Self(horizontal: .trailing, vertical: .center)
  public static let bottomLeading = Self(horizontal: .leading, vertical: .bottom)
  public static let bottom = Self(horizontal: .center, vertical: .bottom)
  public static let bottomTrailing = Self(horizontal: .trailing, vertical: .bottom)
}

public struct ViewDimensions: Equatable {
  @_spi(TokmakUI)
  public let size: CGSize

  @_spi(TokmakUI)
  public let alignmentGuides: [Int: CGFloat]

  public var width: CGFloat { size.width }
  public var height: CGFloat { size.height }

  public subscript(guide: HorizontalAlignment) -> CGFloat {
    self[explicit: guide] ?? guide.id.defaultValue(in: self)
  }

  public subscript(guide: VerticalAlignment) -> CGFloat {
    self[explicit: guide] ?? guide.id.defaultValue(in: self)
  }

  public subscript(explicit guide: HorizontalAlignment) -> CGFloat? {
    alignmentGuides[guide.id.rawValue]
  }

  public subscript(explicit guide: VerticalAlignment) -> CGFloat? {
    alignmentGuides[guide.id.rawValue]
  }
}

/// The position of the `View` relative to its parent.
public struct ViewOrigin: Equatable {
  @_spi(TokmakUI)
  public let origin: CGPoint

  @_spi(TokmakUI)
  public var x: CGFloat { origin.x }
  @_spi(TokmakUI)
  public var y: CGFloat { origin.y }

  public init(origin: CGPoint) {
    self.origin = origin
  }
}
