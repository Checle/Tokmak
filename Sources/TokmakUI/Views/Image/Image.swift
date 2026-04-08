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

struct _ImageProxy {
  let subject: Image

  init(_ subject: Image) {
    self.subject = subject
  }

  var source: String {
    subject.source
  }
}
