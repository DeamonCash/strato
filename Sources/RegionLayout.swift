import Foundation
import CoreGraphics

enum SplitDirection: String, CaseIterable {
    case automatic, rows, columns
}

/// Shared integer edges keep thirds contiguous even when a display's size isn't divisible by 3.
enum RegionLayout {
    static func fractions(size: CGSize, count: Int, direction: SplitDirection) -> [CGRect] {
        precondition(count == 2 || count == 3)
        let rows = direction == .rows || (direction == .automatic && size.height > size.width)
        return (0..<count).map { index in
            let start = CGFloat(index) / CGFloat(count)
            let end = CGFloat(index + 1) / CGFloat(count)
            return rows
                ? CGRect(x: 0, y: start, width: 1, height: end - start)
                : CGRect(x: start, y: 0, width: end - start, height: 1)
        }
    }

    static func rect(in bounds: CGRect, fraction: CGRect) -> CGRect {
        let x0 = (fraction.minX * bounds.width).rounded()
        let x1 = (fraction.maxX * bounds.width).rounded()
        let y0 = (fraction.minY * bounds.height).rounded()
        let y1 = (fraction.maxY * bounds.height).rounded()
        return CGRect(x: bounds.minX + x0, y: bounds.minY + y0,
                      width: x1 - x0, height: y1 - y0)
    }
}
