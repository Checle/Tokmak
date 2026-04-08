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

/// A view that renders an LVGL image source.
///
/// The source string is forwarded directly to LVGL and can be a file path
/// or an LVGL symbol name.
public struct Image: _PrimitiveView, Equatable {
  let source: String

  public init(_ name: String) {
    source = name
  }

  public init(path: String) {
    source = path
  }

  public init(systemName: String) {
    source = systemName
  }

  public var body: Never {
    neverBody("Image")
  }
}

public extension Image {
  enum Symbol {
    public static let warning = "\u{f071}"
    public static let image = "\u{f03e}"
    public static let list = "\u{f00b}"
    public static let file = "\u{f15b}"
    public static let directory = "\u{f07b}"
    public static let up = "\u{f077}"
    public static let down = "\u{f078}"
    public static let left = "\u{f053}"
    public static let right = "\u{f054}"
    public static let edit = "\u{f304}"
    public static let download = "\u{f019}"
    public static let upload = "\u{f093}"
    public static let ok = "\u{f00c}"
    public static let close = "\u{f00d}"
  }

  static func system(_ symbol: String) -> Image {
    Image(systemName: symbol)
  }
}

struct _ImageProxy {
  let subject: Image

  init(_ subject: Image) {
    self.subject = subject
  }

  var source: String {
    subject.source
  }
}
