
import SwiftUI
import DragAndDrop

struct SquareView: View {
    @EnvironmentObject var model: ChessViewModel
    
    let square: ChessBoardSquare
    
    var body: some View {
        ZStack {
            Rectangle()
                .checkered(id: square.id, color: .gray)
                .overlay(Color.green.opacity(square.legalDropTarget == .accepted ? 0.3 : 0))
                .dropReceiver(for: model.chessBoard[square.id],
                              model: model)
            Rectangle()
                .strokeBorder(Color.green, lineWidth: 4)
                .opacity(square.legalDropTarget == .accepted ? 1 : 0)
            switch square.piece {
            case .none:
                EmptyView()
            case .some(let piece):
                PieceView(piece: piece)
                    .dragable(object: piece,
                              onDragObject: onDragPiece,
                              onDropped: onDropPiece)
            }
        }
        .scaledToFit()
    }
    
    func onDragPiece(piece: Dragable, position: CGPoint) -> DragState {
        if model.pieceDidMoveFrom == nil {
            model.setPieceOrigin((piece as! Piece).square)
            model.setLegalDropTargets()
        }
        return .none
    }
    
    func onDropPiece(position: CGPoint) -> Bool {
        if model.movePiece(location: position) {
            return true
        } else {
            model.clearPieceOrigin()
            model.setLegalDropTargets()
            return false
        }
    }
}

struct SquareView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject var model = ChessViewModel()
        
        let square = ChessBoardSquare(id: 0, dropArea: nil, piece: Piece(type: .bishop, color: .home, square: 0))
        
        var body: some View {
            SquareView(square: square)
                .environmentObject(model)
        }
    }
    
    static var previews: some View {
        Preview()
    }
}

