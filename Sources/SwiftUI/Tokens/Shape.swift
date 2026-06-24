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


public protocol Shape {}

public struct _FilledShape<S: Shape>: _PrimitiveView, _ShapeFrameSizedControl {
  public let shape: S
  public let color: Color

  public func _visit<V: ViewWalker>(_ visitor: inout V) {
    visitor.visitFilledShape(self)
  }


}

public struct Circle: Shape {
  public init() {}
}

public struct RoundedRectangle: Shape {
  public let cornerRadius: CGFloat

  public init(cornerRadius: CGFloat) {
    self.cornerRadius = cornerRadius
  }
}

public struct Capsule: Shape {
  public init() {}
}

public extension Shape {
  func fill(_ color: Color) -> _FilledShape<Self> {
    _FilledShape(shape: self, color: color)
  }
}

public extension View {
  func cornerRadius(_ radius: CGFloat) -> some View {
    clipShape(RoundedRectangle(cornerRadius: radius))
  }
}
