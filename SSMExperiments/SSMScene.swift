// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI
import SpriteKit

final class SSMScene: SKScene, ObservableObject {
    static let MIN_ZOOM: CGFloat = 0.125
    static let MAX_ZOOM: CGFloat = 8
    static let paddingAllowance = 0.9

    @Published var cameraScale: CGFloat = 1
    @Published var showGridLines = true
    @Published var showMainBorder = true
    @Published var redrawRequired = true

    let cameraNode = SKCameraNode()
    let selectionViewNode = SKNode()
    let rootNode = SKNode()

    var centerDotSprite: SKSpriteNode!
    var circleSpriteTexture: SKTexture!
    var grid: Grid<GridCell>!
    var lastUpdateTime: TimeInterval = -1
    var pixelSpriteTexture: SKTexture!
    var selectionerView: SelectionerView!

    @Published var gridView: GridView!

    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        backgroundColor = .black

        addChild(cameraNode)
        camera = cameraNode

        addChild(rootNode)
        rootNode.addChild(selectionViewNode)

        centerDotSprite = SKSpriteNode(imageNamed: "circle_100x100")
        centerDotSprite.size *= 0.5
        centerDotSprite.colorBlendFactor = 1
        centerDotSprite.color = .yellow
        centerDotSprite.isHidden = true
        centerDotSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        cameraNode.position = CGPoint.zero
        cameraNode.setScale(cameraScale)

        grid = Grid(size: GridSize(width: 5, height: 5), origin: .center, yAxis: .upIsPositive)

        gridView = GridView(
            scene: self, grid: grid,
            cellSizeInPixels: CGSize(width: 10, height: 10),
            camera: cameraNode, rootNode: rootNode
        )

        selectionerView = SelectionerView(scene: self)

        redraw()
    }

    func drawRubberBand(from startVertex: CGPoint, to endVertex: CGPoint) {
        selectionerView?.drawRubberBand(from: startVertex, to: endVertex)
    }

    func hideRubberBand() {
        selectionerView?.reset()
    }

    func redraw() {
        gridView.showGridLines(showGridLines)
        redrawRequired = false
    }

    override func scrollWheel(with event: NSEvent) {
        setZoom(delta: -event.scrollingDeltaY * 0.1)
    }

    func setZoom(delta zoomDelta: CGFloat) {
        var newZoom = cameraNode.xScale + zoomDelta
        if newZoom < Self.MIN_ZOOM { newZoom = Self.MIN_ZOOM }
        else if newZoom > Self.MAX_ZOOM { newZoom = Self.MAX_ZOOM }

        cameraScale = newZoom
        cameraNode.setScale(cameraScale)
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == -1 {
            lastUpdateTime = currentTime
        }

        defer { lastUpdateTime = currentTime }

        if redrawRequired {
            redraw()
        }
    }
}
