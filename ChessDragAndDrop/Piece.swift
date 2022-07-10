
import Foundation
import DragAndDrop

struct Piece: Dragable {
    var type: PieceType
    var color: PieceColor
    var square: Int
    
    enum PieceColor {
        case home
        case visitor
    }
    
    enum PieceType {
        case king
        case queen
        case rook
        case bishop
        case knight
        case pawn
    }
}
