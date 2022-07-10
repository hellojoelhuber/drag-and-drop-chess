
import SwiftUI

struct Checkered: ViewModifier {
    let squareId: Int
    let squareColor: Color
    // arrays start at 0, "evens" start at 0. Cell a2 == row 1, col 0.
    var isEvenRow: Bool { (squareId / 8) % 2 == 0 }
    var isEvenColumn: Bool { squareId % 2 == 0 }
    
    public func body(content: Content) -> some View {
        content
            .foregroundColor(squareColor)
            .brightness(isEvenRow
                        ? isEvenColumn ? DrawingConstants.lightSquare : DrawingConstants.darkSquare
                        : isEvenColumn ? DrawingConstants.darkSquare : DrawingConstants.lightSquare
            )
    }
    
    private struct DrawingConstants {
        static let darkSquare = 0.15
        static let lightSquare = 0.35
    }
}

extension View {
    func checkered(id: Int, color: Color) -> some View {
        modifier(Checkered(squareId: id, squareColor: color))
    }
}
