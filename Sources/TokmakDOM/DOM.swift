import SwiftUI
import TokmakStaticHTML

private let renderer = HTMLRenderer()
private var html: [UInt8] = [0]

public func mount<V: View>(_ view: V) {
  update(renderer.render(view))
}

@_cdecl("tokmak_event")
public func tokmakEvent(_ action: Int32) {
  if let rendered = renderer.perform(action: Int(action)) {
    update(rendered)
  }
}

@_cdecl("tokmak_html")
public func tokmakHTML() -> UnsafePointer<UInt8> {
  html.withUnsafeBufferPointer { $0.baseAddress! }
}

@_cdecl("tokmak_html_length")
public func tokmakHTMLLength() -> Int32 {
  Int32(html.count - 1)
}

private func update(_ rendered: String) {
  html = Array(rendered.utf8)
  html.append(0)
}
