import XCTest
@testable import SwiftUI

final class StateTests: XCTestCase {
  func testStatePersistsAcrossViewRecreation() {
    let fiber = FiberNode()
    var redraws = 0

    let first = State(
      wrappedValue: 0,
      fileID: "StateTests",
      line: 1,
      column: 1
    )
    withStateContext(fiber: fiber, redraw: { redraws += 1 }) {
      XCTAssertEqual(first.wrappedValue, 0)
      first.wrappedValue = 42
    }

    let second = State(
      wrappedValue: 0,
      fileID: "StateTests",
      line: 1,
      column: 1
    )
    withStateContext(fiber: fiber, redraw: { redraws += 1 }) {
      XCTAssertEqual(second.wrappedValue, 42)
    }

    XCTAssertEqual(redraws, 1)
  }

  func testStateDeclarationsUseIndependentSlots() {
    let fiber = FiberNode()
    let first = State(wrappedValue: 1, fileID: "StateTests", line: 2, column: 1)
    let second = State(wrappedValue: 2, fileID: "StateTests", line: 3, column: 1)

    withStateContext(fiber: fiber, redraw: {}) {
      first.wrappedValue = 10
      second.wrappedValue = 20
    }

    XCTAssertEqual(first.wrappedValue, 10)
    XCTAssertEqual(second.wrappedValue, 20)
    XCTAssertEqual(fiber.stateSlots.count, 2)
  }
}
