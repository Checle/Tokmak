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

import CLVGL

private let tokmakLVCoordTypeShift: Int32 = MemoryLayout<lv_coord_t>.size == 2 ? 13 : 29
private let tokmakLVCoordMaxRaw: Int32 = (Int32(1) << tokmakLVCoordTypeShift) - 1

@inline(__always)
func tokmakLVCoord(_ value: CGFloat) -> lv_coord_t {
  if MemoryLayout<lv_coord_t>.size == 2 {
    let clamped = max(CGFloat(Int16.min), min(CGFloat(Int16.max), value.rounded()))
    return lv_coord_t(clamped)
  } else {
    let clamped = max(CGFloat(Int32.min), min(CGFloat(Int32.max), value.rounded()))
    return lv_coord_t(clamped)
  }
}

@inline(__always)
func tokmakLVLayout(_ value: UInt16) -> UInt32 {
  UInt32(value)
}

@inline(__always)
func tokmakLVGridFraction(_ value: Int32) -> lv_coord_t {
  lv_coord_t(tokmakLVCoordMaxRaw - 100 + value)
}

let tokmakLVSizeContent: lv_coord_t = lv_coord_t((Int32(1) << tokmakLVCoordTypeShift) | 2001)
let tokmakLVGridTemplateLast: lv_coord_t = lv_coord_t(tokmakLVCoordMaxRaw)
