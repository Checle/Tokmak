import XCTest
import SwiftUI
import TokmakStaticHTML

final class HTMLRendererTests: XCTestCase {
  func testRendersAndUpdatesState() {
    struct Counter: View {
      @State var count = 0

      var body: some View {
        Button("Count: \(count)") {
          count += 1
        }
      }
    }

    let renderer = HTMLRenderer()
    XCTAssertTrue(renderer.render(Counter()).contains("Count: 0"))
    XCTAssertTrue(renderer.perform(action: 0)?.contains("Count: 1") == true)
  }
}
