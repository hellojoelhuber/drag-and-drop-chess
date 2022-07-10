
import SwiftUI

struct ChessBoardView: View {
    @EnvironmentObject var model: ChessViewModel
    
    private let rows = 8
    
    var body: some View {
        VStack {
            ForEach(0..<8) { row in
                HStack {
                    ForEach(model.getRowOfSquares(rowNumber: row), id:\.id) { square in
                        SquareView(square: square)
                            .zIndex(model.pieceDidMoveFrom == square.id ? 1 : 0)
                    }
                }
                .zIndex(model.getRowOfSquares(rowNumber: row).contains(where: { $0.id == model.pieceDidMoveFrom }) ? 1 : 0)
            }
        }
    }
}

struct ChessBoardView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject var model = ChessViewModel()
        
        var body: some View {
            ChessBoardView()
                .environmentObject(model)
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
