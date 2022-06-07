@testable import Voltaire
import XCTest

class ctlCandidateUniversalTests: XCTestCase {
  class Mock: ctlCandidateDelegate {
    let candidates = ["A", "B", "C", "D", "E", "F", "G", "H"]
    var selected: String?

    func candidateCountForController(_: ctlCandidate) -> Int {
      Int(candidates.count)
    }

    func ctlCandidate(_: ctlCandidate, candidateAtIndex index: Int) -> String {
      candidates[Int(index)]
    }

    func ctlCandidate(_: ctlCandidate, didSelectCandidateAtIndex index: Int) {
      selected = candidates[Int(index)]
    }
  }

  func testPositioning1() {
    let controller = ctlCandidateUniversal()
    let mock = Mock()
    controller.delegate = mock
    controller.keyLabels = ["1", "2", "3", "4"].map {
      CandidateKeyLabel(key: $0, displayedText: $0)
    }
    controller.reloadData()
    controller.visible = true
    controller.set(windowTopLeftPoint: NSPoint(x: -100, y: 0), bottomOutOfScreenAdjustmentHeight: 10)
    let exp = expectation(description: "wait")
    _ = XCTWaiter.wait(for: [exp], timeout: 0.2)
    XCTAssert(controller.window?.frame.minX ?? -1 >= 0)
  }

  func testPositioning2() {
    let controller = ctlCandidateUniversal()
    let mock = Mock()
    controller.delegate = mock
    controller.keyLabels = ["1", "2", "3", "4"].map {
      CandidateKeyLabel(key: $0, displayedText: $0)
    }
    controller.reloadData()
    controller.visible = true
    let screenRect = NSScreen.main?.frame ?? NSRect.zero
    controller.set(windowTopLeftPoint: NSPoint(x: screenRect.maxX + 100, y: screenRect.maxY + 100), bottomOutOfScreenAdjustmentHeight: 10)
    let exp = expectation(description: "wait")
    _ = XCTWaiter.wait(for: [exp], timeout: 0.2)
    XCTAssert(controller.window?.frame.maxX ?? CGFloat.greatestFiniteMagnitude <= screenRect.maxX)
    XCTAssert(controller.window?.frame.maxY ?? CGFloat.greatestFiniteMagnitude <= screenRect.maxY)
  }

  func testReloadData() {
    let controller = ctlCandidateUniversal()
    let mock = Mock()
    controller.delegate = mock
    controller.keyLabels = ["1", "2", "3", "4"].map {
      CandidateKeyLabel(key: $0, displayedText: $0)
    }
    controller.reloadData()
    XCTAssert(controller.selectedCandidateIndex == 0)
  }

  func testHighlightNextCandidate() {
    let controller = ctlCandidateUniversal()
    let mock = Mock()
    controller.keyLabels = ["1", "2", "3", "4"].map {
      CandidateKeyLabel(key: $0, displayedText: $0)
    }
    controller.delegate = mock
    var result = controller.highlightNextCandidate()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 1)
    result = controller.highlightNextCandidate()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 2)
    result = controller.highlightNextCandidate()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 3)
    result = controller.highlightNextCandidate()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 4)
    result = controller.highlightNextCandidate()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 5)
    result = controller.highlightNextCandidate()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 6)
    result = controller.highlightNextCandidate()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 7)
    result = controller.highlightNextCandidate()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 0)
  }

  func testHighlightPreviousCandidate() {
    let controller = ctlCandidateUniversal()
    let mock = Mock()
    controller.keyLabels = ["1", "2", "3", "4"].map {
      CandidateKeyLabel(key: $0, displayedText: $0)
    }
    controller.delegate = mock
    _ = controller.showNextPage()
    XCTAssert(controller.selectedCandidateIndex == 4)
    var result = controller.highlightPreviousCandidate()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 3)
    result = controller.highlightPreviousCandidate()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 2)
    result = controller.highlightPreviousCandidate()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 1)
    result = controller.highlightPreviousCandidate()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 0)
    result = controller.highlightPreviousCandidate()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 7)
  }

  func testShowNextPage() {
    let controller = ctlCandidateUniversal()
    let mock = Mock()
    controller.keyLabels = ["1", "2", "3", "4"].map {
      CandidateKeyLabel(key: $0, displayedText: $0)
    }
    _ = controller.delegate = mock
    var result = controller.showNextPage()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 4)
    result = controller.showNextPage()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 0)
  }

  func testShowPreviousPage() {
    let controller = ctlCandidateUniversal()
    let mock = Mock()
    controller.keyLabels = ["1", "2", "3", "4"].map {
      CandidateKeyLabel(key: $0, displayedText: $0)
    }
    controller.delegate = mock
    _ = controller.showNextPage()
    var result = controller.showPreviousPage()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 0)
    result = controller.showPreviousPage()
    XCTAssert(result == true)
    XCTAssert(controller.selectedCandidateIndex == 4)
  }
}
