
import SwiftUI

extension Image {
    func resizableToFit() -> some View {
        self
            .resizable()
            .scaledToFit()
   }
}
