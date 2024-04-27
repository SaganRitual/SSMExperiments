// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation

protocol GridCellContentsProtocol: AnyObject {
    
}

protocol GridCellProtocol: AnyObject {
    var gridPosition: GridPoint { get }
    init(_ gridPosition: GridPoint)
}

class GridCell: GridCellProtocol {
    let gridPosition: GridPoint
    var contents: GridCellContentsProtocol?
    required init(_ gridPosition: GridPoint) { self.gridPosition = gridPosition }
}
