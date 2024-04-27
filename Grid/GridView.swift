// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit

class GridView {
    let camera: SKCameraNode
    let cellSizeInPixels: CGSize
    let grid: Grid<GridCell>
    let gridLinesRootNode: SKNode
    let originPositionInScene: CGPoint
    let rootNode: SKNode

    let gridLineSprites: [SKSpriteNode]

    init(scene: SSMScene, grid: Grid<GridCell>, cellSizeInPixels: CGSize, camera: SKCameraNode, rootNode: SKNode) {
        self.camera = camera
        self.cellSizeInPixels = cellSizeInPixels
        self.grid = grid
        self.rootNode = rootNode

        let gridLinesRootNode = SKNode()
        rootNode.addChild(gridLinesRootNode)

        let gridWidthInPixels = Double(grid.size.width) * cellSizeInPixels.width
        let gridHeightInPixels = Double(grid.size.height) * cellSizeInPixels.height

        let ww = Double(grid.size.width) / 2
        let verticals = stride(from: -ww, through: ww, by: 1).map { x in
            let sprite = SKSpriteNode(imageNamed: "pixel_1x1")
            sprite.size.height = gridHeightInPixels
            sprite.position.x = x * cellSizeInPixels.width
            sprite.color = .yellow
            gridLinesRootNode.addChild(sprite)
            return sprite
        }

        let hh = Double(grid.size.height) / 2
        let horizontals = stride(from: -hh, through: hh, by: 1).map { y in
            let sprite = SKSpriteNode(imageNamed: "pixel_1x1")
            sprite.size.width = gridWidthInPixels
            sprite.position.y = y * cellSizeInPixels.height
            sprite.color = .yellow
            gridLinesRootNode.addChild(sprite)
            return sprite
        }

        self.gridLineSprites = verticals + horizontals
        self.gridLinesRootNode = gridLinesRootNode

        switch grid.origin {
        case .center:
            originPositionInScene = .zero
        case .lowerLeft:
            originPositionInScene = CGPoint(scene.size / 2) + CGPoint(x: -gridWidthInPixels / 2, y: -gridHeightInPixels / 2)
        case .upperLeft:
            originPositionInScene = CGPoint(scene.size / 2) + CGPoint(x: -gridWidthInPixels / 2, y: gridHeightInPixels / 2)
        }
    }

    func convertPointFromScene(position: CGPoint) -> GridPoint? {
        let x: Double
        if grid.size.width.isMultiple(of: 2) {
            x = (position.x / cellSizeInPixels.width).rounded(.awayFromZero)
        } else {
            let halfACellWidth = -sign(position.x) * cellSizeInPixels.width / 2
            x = ((position.x - halfACellWidth) / cellSizeInPixels.width).rounded(.towardZero)
        }

        let y: Double
        if grid.size.width.isMultiple(of: 2) {
            y = (position.y / cellSizeInPixels.height).rounded(.awayFromZero)
        } else {
            let halfACellHeight = -sign(position.y) * cellSizeInPixels.height / 2
            y = ((position.y - halfACellHeight) / cellSizeInPixels.height).rounded(.towardZero)
        }

        let yFlip: Double = (grid.yAxis == .upIsPositive) ? -1 : 1
        let gridPoint = GridPoint(x: Int(x), y: Int(y * yFlip))

        let shiftedForOriginAndYAxis = (grid.origin == .center) ?
            gridPoint : gridPoint + GridPoint(x: grid.size.width / 2, y: grid.size.height / 2)

        return grid.isOnGrid(shiftedForOriginAndYAxis) ? shiftedForOriginAndYAxis : nil
    }

    func showGridLines(_ show: Bool) {
        gridLinesRootNode.isHidden = !show
    }
}
