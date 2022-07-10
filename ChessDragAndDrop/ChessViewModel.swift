
import SwiftUI
import DragAndDrop

class ChessViewModel: DropReceivableObservableObject {
    typealias DropReceivable = ChessBoardSquare
    @Published var chessBoard: [ChessBoardSquare]
    
    @Published var pieceDidMoveFrom: Int? = nil
    
    func setDropArea(_ dropArea: CGRect, on dropReceiver: ChessBoardSquare) {
        chessBoard[dropReceiver.id].updateDropArea(with: dropArea)
    }
    
    func getRowOfSquares(rowNumber: Int) -> [ChessBoardSquare] {
        var squares = [ChessBoardSquare]()
        let reverseRowNumber = (7-rowNumber)
        
        // rowNumber will build the board with upper-left corner == white rook.
        // reverseRowNumber will build the board with upper-left corner == black rook, as expected.
        for index in (reverseRowNumber*8)..<(reverseRowNumber*8 + 8) {
            squares.append(chessBoard[index])
        }
        return squares
    }
    
    func setLegalDropTargets() {
        for index in 0..<chessBoard.count {
            chessBoard[index].legalDropTarget = getDropLegalState(at: index)
        }
    }
    
    private func getDropLegalState(at square: Int) -> DragState {
        if let origin = pieceDidMoveFrom,
            square != origin,
            let piece = chessBoard[origin].piece {
            switch piece.type {
            case .rook:
                if square % 8 == origin % 8 || (Int(origin / 8) == Int(square / 8))
                { return .accepted } else { return .rejected }
            case .king:
                if [origin+1, origin-1, origin+7, origin+8, origin+9, origin-7, origin-8, origin-9].contains(square)
                { return .accepted } else { return .rejected }
            case .queen:
                if ((square - origin) % 7 == 0) || ((square - origin) % 9 == 0) || ((square - origin) % 8 == 0) || (Int(origin / 8) == Int(square / 8))
                { return .accepted } else { return .rejected }
            case .bishop:
                if ((square - origin) % 7 == 0) || ((square - origin) % 9 == 0)
                { return .accepted } else { return .rejected }
            case .knight:
                if [origin + 6, origin + 10, origin + 15, origin + 17, origin - 6, origin - 10, origin - 15, origin - 17].contains(square)
                { return .accepted } else { return .rejected }
            case .pawn:
                if square == origin + (piece.color == .home ? 8 : -8)
                { return .accepted } else { return .rejected }
            }
        }
        return .none
    }
    
    func movePiece(location: CGPoint) -> Bool {
        if let index = chessBoard.firstIndex(where: {$0.getDropArea()!.contains(location)}),
            chessBoard[index].legalDropTarget == .accepted,
            let movingPiece = chessBoard[pieceDidMoveFrom!].piece {
            chessBoard[index].piece = Piece(type: movingPiece.type, color: movingPiece.color, square: index)
            chessBoard[pieceDidMoveFrom!].piece = nil
            clearPieceOrigin()
            setLegalDropTargets()
            return true
        }
        return false
    }
    
    func setPieceOrigin(_ square: Int) {
        if pieceDidMoveFrom == nil {
            pieceDidMoveFrom = square
        }
    }
    
    func clearPieceOrigin() {
        pieceDidMoveFrom = nil
    }
    
    
    init() {
        chessBoard = []
        chessBoard.append(ChessBoardSquare(id: 0, piece: Piece(type: .rook, color: .home, square: 0)))
        chessBoard.append(ChessBoardSquare(id: 1, piece: Piece(type: .knight, color: .home, square: 1)))
        chessBoard.append(ChessBoardSquare(id: 2, piece: Piece(type: .bishop, color: .home, square: 2)))
        chessBoard.append(ChessBoardSquare(id: 3, piece: Piece(type: .queen, color: .home, square: 3)))
        chessBoard.append(ChessBoardSquare(id: 4, piece: Piece(type: .king, color: .home, square: 4)))
        chessBoard.append(ChessBoardSquare(id: 5, piece: Piece(type: .bishop, color: .home, square: 5)))
        chessBoard.append(ChessBoardSquare(id: 6, piece: Piece(type: .knight, color: .home, square: 6)))
        chessBoard.append(ChessBoardSquare(id: 7, piece: Piece(type: .rook, color: .home, square: 7)))
        
        for index in 8..<16 {
            chessBoard.append(ChessBoardSquare(id: index, piece: Piece(type: .pawn, color: .home, square: index)))
        }
        
        for index in 16..<48 {
            chessBoard.append(ChessBoardSquare(id: index, piece: nil))
        }
        
        for index in 48..<56 {
            chessBoard.append(ChessBoardSquare(id: index, piece: Piece(type: .pawn, color: .visitor, square: index)))
        }
        
        chessBoard.append(ChessBoardSquare(id: 56, piece: Piece(type: .rook, color: .visitor, square: 56)))
        chessBoard.append(ChessBoardSquare(id: 57, piece: Piece(type: .knight, color: .visitor, square: 57)))
        chessBoard.append(ChessBoardSquare(id: 58, piece: Piece(type: .bishop, color: .visitor, square: 58)))
        chessBoard.append(ChessBoardSquare(id: 59, piece: Piece(type: .queen, color: .visitor, square: 59)))
        chessBoard.append(ChessBoardSquare(id: 60, piece: Piece(type: .king, color: .visitor, square: 60)))
        chessBoard.append(ChessBoardSquare(id: 61, piece: Piece(type: .bishop, color: .visitor, square: 61)))
        chessBoard.append(ChessBoardSquare(id: 62, piece: Piece(type: .knight, color: .visitor, square: 62)))
        chessBoard.append(ChessBoardSquare(id: 63, piece: Piece(type: .rook, color: .visitor, square: 63)))
    }
}
