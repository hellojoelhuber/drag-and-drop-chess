# Chess

This project was created as a samplie implementation of [SwiftUI Drag-and-Drop](https://github.com/hellojoelhuber/swiftui-drag-and-drop) library. This README is a mirror of my [personal website](https://www.joelhuber.com/documentation/documentation-chess-drag-and-drop).


![Chess Drag-And-Drop Demo](https://github.com/hellojoelhuber/swiftui-drag-and-drop/blob/main/assets/media/documentation-dragdrop-chess-demo.gif)

# Overview.

The Chess project is a barebones chess implementation. It features only the most basic movement rules, no checking, no castling, no _en passant_. The chess board is modeled following [the discussion in this post](https://www.joelhuber.com/posts/2022-05-16-modeling-the-chess-board).

For the drag-and-drop library:
* Each chess board square is a `DropReceiver`, organized in an array.
* Each Piece is a `Dragable` object.


## Protocol: Dragable

In chess, only the Piece is draggable. 

```swift
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
```

An interesting issue with the zIndex appeared: when moving a Piece, it was possible to see the Piece _under_ another Piece, instead of on top of it. This is because the Piece is rendered on a SquareView, and the SquareView is rendered on a row, and the rows are rendered in a VStack. The zIndex is only applicable to the current ZStack, so the `.zIndex` of the dragged Piece had to be modified on both the SquareView in the row and the row in the VStack.

```swift
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
```

## ViewModifier: .dragable(...)

The PieceView is rendered on the SquareView, if the Square contains the Piece. The PieceView is marked `.dragable(...)`

```swift
    ZStack {
        Rectangle()
            .checkered(id: square.id, color: .gray)
            .dropReceiver(for: model.chessBoard[square.id],
                      model: model)

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
```

#### onDragged

```swift
    func onDragPiece(piece: Dragable, position: CGPoint) -> DragState {
        if model.pieceDidMoveFrom == nil {
            model.setPieceOrigin((piece as! Piece).square)
            model.setLegalDropTargets()
        }
        return .none
    }
```

The method always returns `.none` as the `DragState`, resulting in no shadow around the dragged piece. The rationale here is that the pieces are small the iPhone 12 mini, and it may be difficult to see the shadow through one's thumb. Instead, I wrote the `setLegalDropTargets()` method to update each square's property `legalDropTarget: DragState` to `.accepted` or `.rejected`, and if the former, surround the square in a thick green border. 

```swift
    Rectangle()
        .checkered(id: square.id, color: .gray)
        .dropReceiver(for: model.chessBoard[square.id],
                      model: model)
    Rectangle()
        .strokeBorder(Color.green, lineWidth: 4)
        .opacity(square.legalDropTarget == .accepted ? 1 : 0)
```

Technically, this method fires every time the `DragGesture` position changes, but by wrapping the `setPieceOrigin()` and `setLegalDropTargets()` methods in a logical check (is the piece origin nil?), we reduce our `setLegalDropTargets` loop to two calls: when the piece starts dragging and when the piece drops. I further discuss the `setLegalDropTargets()` method below.

#### onDropObject

Notice the piece is using the `.dragable(object:onDragObject:onDropped:)` variant. The `onDropped` method looks like this:

```swift
    func onDropPiece(position: CGPoint) -> Bool {
        if model.movePiece(location: position) {
            return true
        } else {
            model.clearPieceOrigin()
            model.setLegalDropTargets()
            return false
        }
    }
```

The `onDragObject` method is setting a value in the ViewModel, `pieceDidMoveFrom`, which the `movePiece(location:)` method is using. Since the `Piece` is holding the index (`Int`) of its current position, we could simply pass the `Piece` in to the `onDragObject` method and forgo usage of `pieceDidMoveFrom`. That implementation may even be preferable! 

However, I chose this implementation to illustrate an alternative, in case your project has additional constraints that make this option preferable. 

## Protocol: DropReceiver

The individual square is marked as the `DropReceiver`.

```swift
struct ChessBoardSquare: Identifiable, DropReceiver {
    let id: Int
    var dropArea: CGRect? = nil
    
    var piece: Piece? = nil
    var legalDropTarget: DragState = .none
}
```

## Protocol: DropReceivableObservableObject

The `DropReceivableObservableObject` defines the `typealias DropReceivable` as the `ChessBoardSquare` and holds the drop receivers in an array `@Published var chessBoard: [ChessBoardSquare]`. It also defines methods `setDropArea(_:on:)` to simply access the array at the index of the square id (squares are guaranteed to be id'd 0...63) and update the drop area property.

```swift
class ChessViewModel: DropReceivableObservableObject {
    typealias DropReceivable = ChessBoardSquare
    @Published var chessBoard: [ChessBoardSquare]
    
    func setDropArea(_ dropArea: CGRect, on dropReceiver: ChessBoardSquare) {
        chessBoard[dropReceiver.id].updateDropArea(with: dropArea)
    }
    ...
}
```

A number of other methods are defined in the ViewModel to help the app tick:
```swift
// Returns an array of 8 squares for the ChessBoardView's ForEach ViewBuilder.
func getRowOfSquares(rowNumber: Int) -> [ChessBoardSquare] { ... }

// Sets the pieceDidMoveFrom property to the square id
func setPieceOrigin(_ square: Int) { ... }

// Clears the pieceDidMoveFrom property 
func clearPieceOrigin() { ... }

// Add the piece to the drop location and then removes the piece from the origin
func movePiece(location: CGPoint) -> Bool { ... }
```

And one more method to discuss in depth: `setLegalDropTargets()`. It very bluntly iterates over the entire chess board array to check if each square is a legal move for the piece being dragged. It leverages `getDropLegalState(at:)` to handle the different piece movement rules.

```swift
func setLegalDropTargets() { 
    for index in 0..<chessBoard.count {
        chessBoard[index].legalDropTarget = getDropLegalState(at: index)
    }
}
```

We could make this method more efficient, by filtering the possible indices to check based on the movement rules of the dragged piece. Considering there are numerous chess implementations online that a reader can study, I accepted a bluntly written method here since the only purpose of this project is to demonstrate the drag-and-drop library. This method has no bearing on the drag-and-drop functionality beyond its adjustment to state, so we can accept a little inefficiency.

## ViewModifier: .dropReceiver(for:model:)

The ViewModifier `.dropReceiver` was applied to a `Rectangle()` to represent the Square. It is the bottom layer of a `ZStack` which also holds the Piece (if a piece exists on that square).

As shown above, this chess implementation shows how the same View can hold both a drop receiver and a draggable object at the same time. 

```swift
    var body: some View {
        ZStack {
            Rectangle()
                .checkered(id: square.id, color: .gray)
                .dropReceiver(for: model.chessBoard[square.id],
                          model: model)
            
            switch square.piece {
            ...
            case .some(let piece):
                PieceView(piece: piece)
                    .dragable(...)
            }
        }
    }
```

The ViewModel method `getDropLegalState(at:)` checks if the square index is the same as the square the piece moved from, specifically, the square cannot be the same: `square != origin`. 

This is how the ZStack that holds both draggable object and drop receiver can ensure the player does not drop the piece onto its current position as a move.
