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


public struct _ForegroundStyleLayout: ViewModifier {
  public let color: Color

  public init(_ color: Color) {
    self.color = color
  }

  public func body(content: Content) -> some View {
    _ForegroundStyleView(content: content, color: color)
  }
}

public struct _ForegroundStyleView<Content: View>: View {
  public let content: Content
  public let color: Color

  public var body: Content { content }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitForegroundStyleView(self)
  }


}

public extension View {
  func foregroundStyle(_ color: Color) -> some View {
    modifier(_ForegroundStyleLayout(color))
  }
}


