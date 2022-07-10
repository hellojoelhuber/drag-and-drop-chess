
import SwiftUI

struct ChessView: View {
    @StateObject var model = ChessViewModel()
    
    var body: some View {
        ChessBoardView()
            .environmentObject(model)
    }
}

struct ChessView_Previews: PreviewProvider {
    static var previews: some View {
        ChessView()
    }
}
