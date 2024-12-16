//
//  Untitled.swift
//  Recordiary
//
//  Created by RulerOfCakes on 12/10/24.
//

import SceneKit
import SwiftUI

let baseWallColor = UIColor(red: 0.8, green: 0.7, blue: 0.6, alpha: 1.0) // Light beige color

struct RoomView: View {
    @State private var scene = createBaseRoom()

    var body: some View {
        ZStack {
            SceneView(scene: scene) // 생성된 씬을 전달
                .frame(height: 500)
                .onAppear {
                    Task {
                        await loadFurnitureIntoScene(
                            scene: scene,
                            userId: "90ed0a4a-5b48-496d-844b-64f4b29c2b3b",
                            year: 2024,
                            month: 11
                        )
                    }
                }
        }
    }

    func loadFurnitureIntoScene(
        scene: SCNScene,
        userId: String,
        year: Int32,
        month: Int32
    ) async {
        let result = await apiClient.getRoom(userId: userId, year: year, month: month)
        
        switch result {
        case .success(let furnitureModels):
            for furniture in furnitureModels {
                addFurnitureToScene(scene: scene, furniture: furniture)
            }
        case .failure(let error):
            print("Failed to load room: \(error)")
        }
    }

    func addFurnitureToScene(scene: SCNScene, furniture: UserFurnitureModel) {
        guard let coordinates = furniture.coordinates else {
            print("No coordinates provided for furniture: \(furniture.name)")
            return
        }
        
        let furnitureNode = createNode(from: furniture)
        
        // 위치 및 회전 적용
        furnitureNode.position = SCNVector3(
            x: Float(coordinates.x),
            y: Float(coordinates.y),
            z: Float(coordinates.z)
        )
        furnitureNode.eulerAngles = SCNVector3(
            x: 0,
            y: Float(coordinates.orientation) * Float.pi / 180, // Orientation in degrees
            z: 0 // z 회전은 기본값 유지
        )
        
        // 씬에 추가
        scene.rootNode.addChildNode(furnitureNode)
    }

    func createNode(from furniture: UserFurnitureModel) -> SCNNode {
        let node = SCNNode()
        
        // `assetLink`를 통해 모델 불러오기
        if let url = URL(string: furniture.assetLink) {
            let assetScene = try? SCNScene(url: url, options: nil)
            if let modelNode = assetScene?.rootNode.childNodes.first {
                node.addChildNode(modelNode)
            } else {
                print("Failed to load model from asset link: \(furniture.assetLink)")
            }
        } else {
            print("Invalid asset link: \(furniture.assetLink)")
        }
        return node
    }
}


// Empty room layout with walls and default lighting
func createBaseRoom() -> SCNScene {
    guard let url = Bundle.main.url(forResource: "InteriorRoom", withExtension: "usdz") else {
        fatalError("Could not find InteriorRoom.usdz")
    }
    let scene = try! SCNScene(url: url, options: nil)
    let roomSize: Float = 15
    let wallThickness: CGFloat = 0.5  // Adjust as needed
    
    let wallMaterial = SCNMaterial()
    wallMaterial.diffuse.contents = baseWallColor
    wallMaterial.roughness.contents = 0.5
    wallMaterial.metalness.contents = 0.1
    wallMaterial.lightingModel = .physicallyBased // Add this line
    wallMaterial.isDoubleSided = true

    // Left wall
    let leftWallGeometry = SCNBox(
        width: wallThickness, height: CGFloat(roomSize), length: CGFloat(roomSize),
        chamferRadius: 0)
    let leftWallNode = SCNNode(geometry: leftWallGeometry)
    leftWallNode.position = SCNVector3(x: -roomSize / 2, y: 0, z: 0)
    // scene.rootNode.addChildNode(leftWallNode)

    // Bottom wall
    let bottomWallGeometry = SCNBox(
        width: CGFloat(roomSize), height: wallThickness, length: CGFloat(roomSize),
        chamferRadius: 0)
    let bottomWallNode = SCNNode(geometry: bottomWallGeometry)
    bottomWallNode.position = SCNVector3(x: 0, y: -roomSize / 2, z: 0)
    // scene.rootNode.addChildNode(bottomWallNode)

    // Back wall
    let backWallGeometry = SCNBox(
        width: CGFloat(roomSize), height: CGFloat(roomSize), length: wallThickness,
        chamferRadius: 0)
    let backWallNode = SCNNode(geometry: backWallGeometry)
    backWallNode.position = SCNVector3(x: 0, y: 0, z: -roomSize / 2)
    // scene.rootNode.addChildNode(backWallNode)

    // --- Add color to the walls ---
    
    leftWallGeometry.materials = [wallMaterial]
    bottomWallGeometry.materials = [wallMaterial]
    backWallGeometry.materials = [wallMaterial]

    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.position = SCNVector3(x: roomSize*0.8, y: roomSize, z: roomSize*0.8)  // Moved camera up
    cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
    //scene.rootNode.addChildNode(cameraNode)

    // --- Add more realistic lighting ---
    let ambientLightNode = SCNNode()
    ambientLightNode.light = SCNLight()
    ambientLightNode.light!.type = .ambient
    ambientLightNode.light!.color = UIColor(white: 0.3, alpha: 1.0) // Dimmer ambient light
    scene.rootNode.addChildNode(ambientLightNode)

    let directionalLightNode = SCNNode()
    directionalLightNode.light = SCNLight()
    directionalLightNode.light!.type = .directional
    directionalLightNode.light!.castsShadow = true
    directionalLightNode.light?.categoryBitMask = -1
    directionalLightNode.light!.shadowMode = .deferred  // For smoother shadows
    directionalLightNode.light!.intensity = 3000 // Brighter light
    
    directionalLightNode.position = SCNVector3(x: roomSize/2, y: roomSize, z: roomSize/2)
    directionalLightNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
    scene.rootNode.addChildNode(directionalLightNode)
    return scene
}

struct SceneView: UIViewRepresentable {
    let scene: SCNScene

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.allowsCameraControl = true
        // disable user panning the camera
        scnView.cameraControlConfiguration.allowsTranslation = false
        scnView.backgroundColor = .clear
        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        // ... update the view if needed ...
    }
}

#Preview {
    RoomView()
}
