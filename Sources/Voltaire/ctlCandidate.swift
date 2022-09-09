// Copyright (c) 2011 and onwards The OpenVanilla Project (MIT License).
// All possible vChewing-specific modifications are of:
// (c) 2021 and onwards The vChewing Project (MIT-NTL License).
/*
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

1. The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

2. No trademark license is granted to use the trade names, trademarks, service
marks, or product names of Contributor, except as required to fulfill notice
requirements above.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Cocoa

public class CandidateKeyLabel: NSObject {
  public private(set) var key: String
  public private(set) var displayedText: String

  public init(key: String, displayedText: String) {
    self.key = key
    self.displayedText = displayedText
    super.init()
  }
}

public protocol ctlCandidateDelegate: AnyObject {
  func candidateCountForController(_ controller: ctlCandidate) -> Int
  func ctlCandidate(_ controller: ctlCandidate, candidateAtIndex index: Int)
    -> String
  func ctlCandidate(
    _ controller: ctlCandidate, didSelectCandidateAtIndex index: Int
  )
}

public class ctlCandidate: NSWindowController {
  public enum Layout {
    case horizontal
    case vertical
  }

  public var currentLayout: Layout = .horizontal
  public weak var delegate: ctlCandidateDelegate? {
    didSet {
      reloadData()
    }
  }

  public var selectedCandidateIndex: Int = .max
  public var visible: Bool = false {
    didSet {
      NSObject.cancelPreviousPerformRequests(withTarget: self)
      if visible {
        window?.perform(#selector(NSWindow.orderFront(_:)), with: self, afterDelay: 0.0)
      } else {
        window?.perform(#selector(NSWindow.orderOut(_:)), with: self, afterDelay: 0.0)
      }
    }
  }

  public var windowTopLeftPoint: NSPoint {
    get {
      guard let frameRect = window?.frame else {
        return NSPoint.zero
      }
      return NSPoint(x: frameRect.minX, y: frameRect.maxY)
    }
    set {
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
        self.set(windowTopLeftPoint: newValue, bottomOutOfScreenAdjustmentHeight: 0)
      }
    }
  }

  public var keyLabels: [CandidateKeyLabel] = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    .map {
      CandidateKeyLabel(key: $0, displayedText: $0)
    }

  public var keyLabelFont: NSFont = NSFont.monospacedDigitSystemFont(
    ofSize: 14, weight: .medium
  )
  public var candidateFont: NSFont = NSFont.systemFont(ofSize: 18)
  public var tooltip: String = ""

  public func reloadData() {}

  public func showNextPage() -> Bool {
    false
  }

  public func showPreviousPage() -> Bool {
    false
  }

  public func highlightNextCandidate() -> Bool {
    false
  }

  public func highlightPreviousCandidate() -> Bool {
    false
  }

  public func candidateIndexAtKeyLabelIndex(_: Int) -> Int {
    Int.max
  }

  /// Sets the location of the candidate window.
  ///
  /// Please note that the method has side effects that modifies
  /// `windowTopLeftPoint` to make the candidate window to stay in at least
  /// in a screen.
  ///
  /// - Parameters:
  ///   - windowTopLeftPoint: The given location.
  ///   - height: The height that helps the window not to be out of the bottom
  ///     of a screen.
  public func set(windowTopLeftPoint: NSPoint, bottomOutOfScreenAdjustmentHeight height: CGFloat) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
      self.doSet(
        windowTopLeftPoint: windowTopLeftPoint, bottomOutOfScreenAdjustmentHeight: height
      )
    }
  }

  func doSet(windowTopLeftPoint: NSPoint, bottomOutOfScreenAdjustmentHeight heightDelta: CGFloat) {
    guard let window = window else { return }
    let windowSize = window.frame.size

    var adjustedPoint = windowTopLeftPoint
    var delta = heightDelta
    var screenFrame = NSScreen.main?.visibleFrame ?? NSRect.zero
    for frame in NSScreen.screens.map(\.visibleFrame).filter({ !$0.contains(windowTopLeftPoint) }) {
      screenFrame = frame
      break
    }

    if delta > screenFrame.size.height / 2.0 { delta = 0.0 }

    adjustedPoint.y = min(max(adjustedPoint.y, screenFrame.minY + windowSize.height + delta), screenFrame.maxY - 1.0)
    adjustedPoint.x = min(max(adjustedPoint.x, screenFrame.minX), screenFrame.maxX - windowSize.width - 1.0)

    window.setFrameTopLeftPoint(adjustedPoint)
  }
}
