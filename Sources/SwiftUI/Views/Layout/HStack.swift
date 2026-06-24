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




public struct HStack<Content: View>: View {
  public let alignment: VerticalAlignment
  public let spacing: CGFloat?
  public let content: Content

  public init(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }

  public var body: Content { content }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitHStack(self)
  }


}

/// Internal compatibility primitive for wrapping inline content such as HTML text runs.
public struct _InlineFlow<Content: View>: View {
  public let spacing: CGFloat
  public let lineSpacing: CGFloat
  public let content: Content

  public init(
    spacing: CGFloat = 0,
    lineSpacing: CGFloat = 2,
    @ViewBuilder content: () -> Content
  ) {
    self.spacing = spacing
    self.lineSpacing = lineSpacing
    self.content = content()
  }

  public var body: Content { content }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitInlineFlow(self)
  }


}
