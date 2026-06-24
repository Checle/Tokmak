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

public typealias CGFloat = Double

public struct CGPoint: Equatable {
  public var x: CGFloat
  public var y: CGFloat
  public init(x: CGFloat, y: CGFloat) {
    self.x = x
    self.y = y
  }
  public static let zero = CGPoint(x: 0, y: 0)
}

public struct CGSize: Equatable {
  public var width: CGFloat
  public var height: CGFloat
  public init(width: CGFloat, height: CGFloat) {
    self.width = width
    self.height = height
  }
  public static let zero = CGSize(width: 0, height: 0)
}

public struct CGRect: Equatable {
  public var origin: CGPoint
  public var size: CGSize
  public init(origin: CGPoint, size: CGSize) {
    self.origin = origin
    self.size = size
  }
  public static let zero = CGRect(origin: .zero, size: .zero)
}
