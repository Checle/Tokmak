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

import Foundation

/// A view that arranges its children in a vertical line.
///
///     VStack {
///       Text("Hello")
///       Text("World")
///     }
public struct VStack<Content>: View, _PrimitiveView where Content: View {
  public let alignment: HorizontalAlignment

  @_spi(TokmakCore)
  public let spacing: CGFloat?

  public let content: Content

  public func walk<V: ViewWalker>(_ visitor: inout V) {
    visitor.visit(self)
    content.walk(&visitor)
  }

  public init(
    alignment: HorizontalAlignment = .center,
    spacing: CGFloat? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }

  public var body: Never {
    neverBody("VStack")
  }
}

extension VStack: ParentView {
  @_spi(TokmakCore)
  public var children: [AnyView] {
    (content as? GroupView)?.children ?? [AnyView(content)]
  }
}

public struct _VStackProxy<Content> where Content: View {
  public let subject: VStack<Content>

  public init(_ subject: VStack<Content>) { self.subject = subject }

  public var spacing: CGFloat { subject.spacing ?? defaultStackSpacing }
}
