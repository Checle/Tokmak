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

import CoreGraphics

public protocol Layout {
  typealias Subviews = [LayoutSubview]
  
  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  )
}

public extension Layout {
  func makeCache(subviews: Subviews) -> () { () }
  func updateCache(_ cache: inout (), subviews: Subviews) {}
}

public struct LayoutSubview {
  public func sizeThatFits(proposal: ProposedViewSize) -> CGSize { .zero }
  public func place(at: CGPoint, anchor: Alignment = .center, proposal: ProposedViewSize) {}
}
