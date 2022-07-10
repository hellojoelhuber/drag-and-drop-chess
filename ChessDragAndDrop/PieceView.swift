
import SwiftUI

struct PieceView: View {
    let piece: Piece
    
    var body: some View {
        pieceImage()
            .resizableToFit()
            .blending(color: Color(piece.color == .home ? .red : .black))
    }
    
    func pieceImage() -> Image {
        switch piece.type {
        case .queen:
            return Image("chess-queen")
        case .king:
            return Image("chess-king")
        case .rook:
            return Image("chess-rook")
        case .bishop:
            return Image("chess-bishop")
        case .knight:
            return Image("chess-knight")
        case .pawn:
            return Image("chess-pawn")
        }
    }
}

struct PieceView_Previews: PreviewProvider {
    static var previews: some View {
        PieceView(piece: Piece(type: .bishop, color: .home, square: 0))
    }
}
