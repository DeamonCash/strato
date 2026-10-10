import Foundation
import CoreGraphics

var cases = 0
for size in [CGSize(width: 2880, height: 5120), CGSize(width: 1440, height: 2560),
             CGSize(width: 1920, height: 1080), CGSize(width: 1081, height: 1921),
             CGSize(width: 1200, height: 1200)] {
    for count in [2, 3] {
        for direction in SplitDirection.allCases {
            let bounds = CGRect(origin: CGPoint(x: -1440, y: -117), size: size)
            let fractions = RegionLayout.fractions(size: size, count: count, direction: direction)
            let rects = fractions.map { RegionLayout.rect(in: bounds, fraction: $0) }
            let rows = direction == .rows || (direction == .automatic && size.height > size.width)
            assert(rects.count == count)
            assert(rects.first!.origin == bounds.origin)
            assert(rects.last!.maxX == bounds.maxX && rects.last!.maxY == bounds.maxY)
            for (i, rect) in rects.enumerated() {
                assert(rect.width > 0 && rect.height > 0)
                assert(rect.width.rounded() == rect.width && rect.height.rounded() == rect.height)
                assert(bounds.contains(rect))
                if rows { assert(rect.minX == bounds.minX && rect.width == bounds.width) }
                else { assert(rect.minY == bounds.minY && rect.height == bounds.height) }
                if i > 0 {
                    assert(rows ? rects[i - 1].maxY == rect.minY : rects[i - 1].maxX == rect.minX)
                }
            }
            let lengths = rects.map { rows ? $0.height : $0.width }
            assert(lengths.max()! - lengths.min()! <= 1)
            cases += 1
        }
    }
}
let portrait = CGRect(x: 0, y: 0, width: 2880, height: 5120)
let thirds = RegionLayout.fractions(size: portrait.size, count: 3, direction: .rows)
    .map { RegionLayout.rect(in: portrait, fraction: $0) }
assert(thirds.map(\.height) == [1707, 1706, 1707])
print("Passed \(cases) layout cases; 5120-high thirds cover 1707 + 1706 + 1707 without gaps or overlaps.")
