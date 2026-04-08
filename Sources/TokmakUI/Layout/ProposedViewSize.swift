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

public struct ProposedViewSize: Equatable, Sendable {
  public var width: CGFloat?
  public var height: CGFloat?

  public init(width: CGFloat? = nil, height: CGFloat? = nil) {
    self.width = width
    self.height = height
  }

  public init(_ size: CGSize) {
    self.width = size.width
    self.height = size.height
  }

  public static let zero = Self(width: 0, height: 0)
  public static let infinity = Self(width: nil, height: nil)
  public static let unspecified = Self(width: nil, height: nil)

  public func replacingUnspecifiedDimensions(
    by size: CGSize = .init(width: 10, height: 10)
  ) -> CGSize {
    .init(width: width ?? size.width, height: height ?? size.height)
  }
}
