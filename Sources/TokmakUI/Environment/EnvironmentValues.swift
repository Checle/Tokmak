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

public struct EnvironmentValues: CustomStringConvertible {
  public var description: String {
    "EnvironmentValues"
  }

  public var isEnabled = true
  public var measureText: (Text, ProposedViewSize, EnvironmentValues) -> CGSize = { _, _, _ in .zero }
  public var colorScheme: ColorScheme = .light
  public var accentColor: Color?
  public var foregroundColor: Color?
  public var controlSize: ControlSize = .regular
  public var headerProminence: Prominence = .standard
  public var fontPath: [Font] = []
  public var layoutDirection: LayoutDirection = .leftToRight
  public var multilineTextAlignment: TextAlignment = .leading

  public init() {}

  @_spi(TokmakUI)
  public mutating func merge(_ other: Self?) {
    if let other = other {
      self = other
    }
  }

  @_spi(TokmakUI)
  public func merging(_ other: Self?) -> Self {
    var merged = self
    merged.merge(other)
    return merged
  }
}

struct _EnvironmentValuesWritingModifier: ViewModifier, _EnvironmentModifier {
  let transform: (inout EnvironmentValues) -> ()

  func body(content: Content) -> some View {
    content
  }

  func modifyEnvironment(_ values: inout EnvironmentValues) {
    transform(&values)
  }
}

public extension View {
  func environmentValues(_ values: EnvironmentValues) -> some View {
    modifier(_EnvironmentValuesWritingModifier {
      $0 = values
    })
  }

  func transformEnvironment(
    _ transform: @escaping (inout EnvironmentValues) -> ()
  ) -> some View {
    modifier(_EnvironmentValuesWritingModifier(transform: transform))
  }
}
