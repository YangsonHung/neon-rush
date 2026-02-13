import Foundation
import SceneKit

// MARK: - 场景设置
class SceneSetup {
    let scene: SCNScene
    private let theme = CyberpunkTheme()

    init(scene: SCNScene) {
        self.scene = scene
    }

    // 设置完整场景
    func setupScene() {
        setupBackground()
        setupLighting()
        setupCamera()
        setupGround()
        setupEnvironment()
    }

    // 设置背景
    private func setupBackground() {
        // 黑色背景
        scene.background.contents = NSColor.black

        // 雾效 - 赛博朋克风格
        scene.fogStartDistance = 20
        scene.fogEndDistance = 80
        scene.fogColor = NSColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1)
    }

    // 设置光照
    private func setupLighting() {
        // 环境光
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = NSColor(white: 0.2, alpha: 1)
        ambientLight.name = "ambientLight"
        scene.rootNode.addChildNode(ambientLight)

        // 主方向光（模拟月光）
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.color = NSColor(white: 0.3, alpha: 1)
        directionalLight.light?.castsShadow = true
        directionalLight.position = SCNVector3(10, 20, 10)
        directionalLight.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
        directionalLight.name = "directionalLight"
        scene.rootNode.addChildNode(directionalLight)

        // 霓虹点光源
        let neonColors: [(SCNVector3, NSColor, Float)] = [
            (SCNVector3(-15, 5, -10), NSColor(red: 1, green: 0, blue: 0.5, alpha: 1), 30),  // 粉色
            (SCNVector3(15, 5, -10), NSColor(red: 0, green: 1, blue: 1, alpha: 1), 30),    // 青色
            (SCNVector3(0, 8, -25), NSColor(red: 1, green: 0, blue: 1, alpha: 1), 40),     // 紫色
            (SCNVector3(-10, 3, 0), NSColor(red: 1, green: 0.5, blue: 0, alpha: 1), 25),   // 橙色
            (SCNVector3(10, 3, 0), NSColor(red: 0, green: 1, blue: 0.5, alpha: 1), 25),    // 绿色
        ]

        for (index, (position, color, intensity)) in neonColors.enumerated() {
            let light = SCNNode()
            light.light = SCNLight()
            light.light?.type = .omni
            light.light?.color = color
            light.light?.intensity = CGFloat(intensity)
            light.light?.attenuationStartDistance = 5
            light.light?.attenuationEndDistance = 30
            light.position = position
            light.name = "neonLight_\(index)"
            scene.rootNode.addChildNode(light)
        }
    }

    // 设置相机
    private func setupCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 60
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 200

        // 相机位置：玩家后上方
        cameraNode.position = SCNVector3(0, 6, 12)
        cameraNode.eulerAngles = SCNVector3(-Float.pi / 8, 0, 0)
        cameraNode.name = "camera"

        scene.rootNode.addChildNode(cameraNode)
    }

    // 设置地面
    private func setupGround() {
        // 主地面 - 网格效果
        let groundGeometry = SCNPlane(width: 30, height: 200)
        let groundMaterial = SCNMaterial()

        // 创建网格纹理
        let gridImage = createGridImage()
        groundMaterial.diffuse.contents = gridImage
        groundMaterial.diffuse.wrapS = .repeat
        groundMaterial.diffuse.wrapT = .repeat
        groundMaterial.emission.contents = NSColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1)
        groundGeometry.materials = [groundMaterial]

        let groundNode = SCNNode(geometry: groundGeometry)
        groundNode.position = SCNVector3(0, 0, -50)
        groundNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        groundNode.name = "ground"
        scene.rootNode.addChildNode(groundNode)

        // 道路边缘 - 霓虹线条
        createRoadEdges()
    }

    // 创建道路边缘霓虹灯
    private func createRoadEdges() {
        let edgePositions: [SCNVector3] = [
            SCNVector3(-6, 0.05, 0),  // 左边缘
            SCNVector3(6, 0.05, 0),   // 右边缘
        ]

        let edgeColors: [NSColor] = [
            NSColor(red: 1, green: 0, blue: 0.5, alpha: 1),  // 粉色
            NSColor(red: 0, green: 1, blue: 1, alpha: 1),   // 青色
        ]

        for (index, (position, color)) in zip(edgePositions, edgeColors).enumerated() {
            // 发光线
            let lineGeometry = SCNPlane(width: 0.2, height: 200)
            let lineMaterial = SCNMaterial()
            lineMaterial.diffuse.contents = color
            lineMaterial.emission.contents = color
            lineMaterial.emission.intensity = 1.0
            lineGeometry.materials = [lineMaterial]

            let lineNode = SCNNode(geometry: lineGeometry)
            lineNode.position = position
            lineNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
            lineNode.name = "edge_\(index)"
            scene.rootNode.addChildNode(lineNode)

            // 底部光晕
            let glowGeometry = SCNPlane(width: 1, height: 200)
            let glowMaterial = SCNMaterial()
            glowMaterial.diffuse.contents = color.withAlphaComponent(0.2)
            glowMaterial.emission.contents = color.withAlphaComponent(0.3)
            glowGeometry.materials = [glowMaterial]

            let glowNode = SCNNode(geometry: glowGeometry)
            glowNode.position = SCNVector3(position.x, 0.02, 0)
            glowNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
            glowNode.name = "edgeGlow_\(index)"
            scene.rootNode.addChildNode(glowNode)
        }
    }

    // 创建网格图像
    private func createGridImage() -> NSImage {
        let size = NSSize(width: 100, height: 100)
        let image = NSImage(size: size)

        image.lockFocus()

        // 背景
        NSColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1).setFill()
        NSRect(origin: .zero, size: size).fill()

        // 网格线
        let gridColor = NSColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 1)
        gridColor.setStroke()

        let path = NSBezierPath()
        path.lineWidth = 1

        // 垂直线
        for x in stride(from: 0, through: size.width, by: 10) {
            path.move(to: NSPoint(x: x, y: 0))
            path.line(to: NSPoint(x: x, y: size.height))
        }

        // 水平线
        for y in stride(from: 0, through: size.height, by: 10) {
            path.move(to: NSPoint(x: 0, y: y))
            path.line(to: NSPoint(x: size.width, y: y))
        }

        path.stroke()

        image.unlockFocus()

        return image
    }

    // 设置环境装饰
    private func setupEnvironment() {
        // 远处建筑物剪影
        createBuildingSilhouettes()

        // 霓虹广告牌
        createNeonBillboards()
    }

    // 创建建筑物剪影
    private func createBuildingSilhouettes() {
        let buildingPositions: [(Float, Float, Float, Float)] = [
            (-15, 8, -30, 4),   // 左远
            (-12, 12, -40, 6),  // 左远
            (15, 10, -35, 5),   // 右远
            (18, 15, -45, 7),   // 右远
            (-20, 6, -50, 3),   // 左更远
            (20, 8, -55, 4),    // 右更远
        ]

        for (index, (x, height, z, width)) in buildingPositions.enumerated() {
            let buildingGeometry = SCNBox(width: CGFloat(width), height: CGFloat(height), length: 2, chamferRadius: 0)
            let buildingMaterial = SCNMaterial()
            buildingMaterial.diffuse.contents = NSColor(red: 0.02, green: 0.02, blue: 0.05, alpha: 1)
            buildingMaterial.emission.contents = NSColor(red: 0.02, green: 0.02, blue: 0.05, alpha: 1)
            buildingGeometry.materials = [buildingMaterial]

            let buildingNode = SCNNode(geometry: buildingGeometry)
            buildingNode.position = SCNVector3(x, Float(height) / 2, z)
            buildingNode.name = "building_\(index)"
            scene.rootNode.addChildNode(buildingNode)

            // 窗户灯光
            addWindowLights(to: buildingNode, width: width, height: height)
        }
    }

    // 添加窗户灯光
    private func addWindowLights(to building: SCNNode, width: Float, height: Float) {
        let windowColors: [NSColor] = [
            NSColor(red: 1, green: 0.8, blue: 0.3, alpha: 0.5),
            NSColor(red: 0, green: 0.8, blue: 1, alpha: 0.5),
            NSColor(red: 1, green: 0.3, blue: 0.5, alpha: 0.5),
        ]

        let rows = Int(height / 2)
        let cols = Int(width / 1.5)

        for row in 0..<rows {
            for col in 0..<cols {
                if Int.random(in: 0..<3) == 0 {  // 30% 概率亮灯
                    let windowGeometry = SCNPlane(width: 0.6, height: 0.8)
                    let color = windowColors.randomElement() ?? NSColor.yellow
                    let windowMaterial = SCNMaterial()
                    windowMaterial.diffuse.contents = color
                    windowMaterial.emission.contents = color.withAlphaComponent(0.8)
                    windowGeometry.materials = [windowMaterial]

                    let windowNode = SCNNode(geometry: windowGeometry)
                    let offsetX = Float(col) * 1.5 - Float(cols) * 0.75
                    let offsetY = Float(row) * 2.0 - Float(rows) + 1.0

                    windowNode.position = SCNVector3(offsetX, offsetY, -1.01)
                    building.addChildNode(windowNode)
                }
            }
        }
    }

    // 创建霓虹广告牌
    private func createNeonBillboards() {
        let billboardPositions: [(SCNVector3, String, NSColor)] = [
            (SCNVector3(-12, 6, -20), "CYBER", NSColor(red: 1, green: 0, blue: 0.5, alpha: 1)),
            (SCNVector3(12, 5, -25), "NEON", NSColor(red: 0, green: 1, blue: 1, alpha: 1)),
        ]

        for (index, (position, text, color)) in billboardPositions.enumerated() {
            let textGeometry = SCNText(string: text, extrusionDepth: 0.1)
            textGeometry.font = NSFont.systemFont(ofSize: 2, weight: .bold)
            textGeometry.flatness = 0.1

            let textMaterial = SCNMaterial()
            textMaterial.diffuse.contents = color
            textMaterial.emission.contents = color
            textMaterial.emission.intensity = 1.0
            textGeometry.materials = [textMaterial]

            let textNode = SCNNode(geometry: textGeometry)
            textNode.position = position

            // 计算文本中心以居中
            let (min, max) = textGeometry.boundingBox
            let textWidth = max.x - min.x
            textNode.position.x -= textWidth / 2

            textNode.name = "billboard_\(index)"
            scene.rootNode.addChildNode(textNode)
        }
    }
}
