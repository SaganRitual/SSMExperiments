// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit
import SwiftUI

class SSMObjects: ObservableObject {
    @Published var scene: SSMScene
    @Published var selectioner: Selectioner

    init(scene: SSMScene) {
        self.scene = scene
        self.selectioner = Selectioner(scene: scene)
    }
}

struct ContentView: View {
    @ObservedObject private var ssmObjects = SSMObjects(scene: SSMScene())

    @State private var hoverLocation: CGPoint = .zero
    @State private var isHovering = false
    @State private var sceneSize: CGSize = .zero

    // With eternal gratitude to
    // https://forums.developer.apple.com/forums/profile/billh04
    // Adding a nearly invisible view to make DragGesture() respond
    // https://forums.developer.apple.com/forums/thread/724082
    let glassPaneColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.01)

    var body: some View {
        HStack(alignment: .top) {
            ZStack {
                SpriteView(scene: ssmObjects.scene)
                Color(cgColor: glassPaneColor)
                    .background() {
                        GeometryReader { geometry in
                            Path { _ in
                                DispatchQueue.main.async {
                                    if self.sceneSize != geometry.size {
                                        self.sceneSize = geometry.size
                                    }
                                }
                            }
                        }
                    }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        hoverLocation = value.location
                        isHovering = true

                        ssmObjects.selectioner.dragging(startVertex: value.startLocation, endVertex: value.location)
                    }
                    .onEnded   { value in
                        hoverLocation = value.location
                        ssmObjects.selectioner.notDragging()
                    }
            )

            // With eternal gratitude to Natalia Panferova
            // Using .onContinuousHover to track mouse position
            // https://nilcoalescing.com/blog/TrackingHoverLocationInSwiftUI/
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    hoverLocation = location
                    isHovering = true
                case .ended:
                    hoverLocation = .zero
                    isHovering = false
                }
            }

            // With eternal gratitude to
            // https://www.hackingwithswift.com/users/Magdi
            // Mouse wheel handling that plays nice with drag gesture and continuous hover modifiers
            // https://www.hackingwithswift.com/forums/swiftui/how-to-use-mouse-wheel-movement-event-to-call-a-function/21006/26666
            .onAppear(perform:{
                NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                    ssmObjects.scene.scrollWheel(with: event)
                    return event
                }
            })

            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text("Grid Library")
                    Spacer()
                }
                .padding(.bottom)

                HStack {
                    Spacer()
                    Text("Size").underline()
                    Spacer()
                }
                .padding(.bottom)

                HStack {
                    Text("Scene/View")
                    Spacer()
                    Text("\(sceneSize)")
                }

                HStack {
                    Text("Grid")
                    Spacer()

                    if let grid = ssmObjects.scene.grid {
                        Text("\(grid.size)")
                    } else {
                        Text("N/A")
                    }
                }
                .padding(.bottom)

                Text("Zoom \(String(format: "%.2f", ssmObjects.scene.cameraScale).padLeft(targetLength: 6))")
                    .padding(.bottom)

                HStack {
                    Spacer()
                    Text("Mouse").underline()
                    Spacer()
                }
                .padding(.bottom)

                if isHovering {
                    HStack {
                        Text("View")
                        Spacer()
                        Text("\(getMousePositionString(positionInView: hoverLocation))")
                    }

                    HStack {
                        Text("Scene")
                        Spacer()
                        Text("\(getMousePositionString(forScene: ssmObjects.scene, positionInView: hoverLocation))")
                    }

                    HStack {
                        Text("Grid")
                        Spacer()
                        Text("\(getMousePositionStringForGrid(scene: ssmObjects.scene, positionInView: hoverLocation))")
                    }
                    .padding(.bottom, 10)
                } else {
                    Text("N/A")
                        .padding(.bottom, 10 + 16 + 16)
                }

                Toggle(isOn: $ssmObjects.scene.showMainBorder) {
                    Text("Show main border")
                }
                .toggleStyle(.checkbox)
                .onChange(of: ssmObjects.scene.showMainBorder) {
                    ssmObjects.scene.redrawRequired = true
                }

                Toggle(isOn: $ssmObjects.scene.showGridLines) {
                    Text("Show grid lines")
                }
                .toggleStyle(.checkbox)
                .onChange(of: ssmObjects.scene.showGridLines) {
                    ssmObjects.scene.redrawRequired = true
                }

                Spacer()

                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()
            .monospaced()
            .frame(width: 250)
        }
    }
}

#Preview {
    ContentView()
}
