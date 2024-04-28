// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation
import SpriteKit

class SSMCellContents: GridCellContentsProtocol {
    var selectionStageHiliteSprite: SKSpriteNode

    init(selectionStageHiliteSprite: SKSpriteNode) {
        self.selectionStageHiliteSprite = selectionStageHiliteSprite
    }
}
