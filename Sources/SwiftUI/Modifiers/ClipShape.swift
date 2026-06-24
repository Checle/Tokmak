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


public struct _ClipShapeLayout<S: Shape>: ViewModifier {
  public let shape: S

  public init(_ shape: S) {
    self.shape = shape
  }

  public func body(content: Content) -> some View {
    _ClipShapeView(content: content, shape: shape)
  }
}

public struct _ClipShapeView<Content: View, S: Shape>: View {
  public let content: Content
  public let shape: S

  public var body: Content { content }

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitClipShapeView(self)
  }


}

public extension View {
  func clipShape<S: Shape>(_ shape: S) -> some View {
    modifier(_ClipShapeLayout(shape))
  }
}


