import Foundation
import SceneKit

// MARK: - 障碍物类型
enum ObstacleType: Int, CaseIterable {
    case spike = 0    // 尖刺
    case barrier = 1  // 栏杆
    case rock = 2     // 岩石
    case crate = 3    // 木箱

    var name: String {
        switch self {
        case .spike: return "尖刺"
        case .barrier: return "栏杆"
        case .rock: return "岩石"
        case .crate: return "木箱"
        }
    }
}

// MARK: - 障碍物类
class Obstacle: ObservableObject, Identifiable {
    let id = UUID()
    let type: ObstacleType

    @Published var position: SCNVector3
    @Published var isActive: Bool = true

    var node: SCNNode?
    var lanePosition: Int // 所在车道: -1, 0, 1

    // 碰撞体积
    var collisionRadius: Float {
        switch type {
        case .spike: return 0.5
        case .barrier: return 0.3
        case .rock: return 0.8
        case .crate: return 0.7
        }
    }

    var collisionHeight: Float {
        switch type {
        case .spike: return 0.5
        case .barrier: return 1.2
        case .rock: return 1.0
        case .crate: return 1.0
        }
    }

    init(type: ObstacleType, lane: Int, zPosition: Float) {
        self.type = type
        self.lanePosition = lane
        self.position = SCNVector3(Float(lane) * 2.5, 0, zPosition)
        createNode()
    }

    // 创建障碍物 3D 模型
    func createNode() {
        switch type {
        case .spike:
            createSpike()
        case .barrier:
            createBarrier()
        case .rock:
            createRock()
        case .crate:
            createCrate()
        }
    }

    private func createSpike() {
        // 尖刺 - 三角形锥体
        let geometry = SCNCone(topRadius: 0, bottomRadius: 0.5, height: 1.0)
        let material = SCNMaterial()
        material.diffuse.contents = NSColor(red: 1, green: 0.2, blue: 0.2, alpha: 1)
        material.emission.contents = NSColor(red: 0.8, green: 0, blue: 0, alpha: 1)
        geometry.materials = [material]

        node = SCNNode(geometry: geometry)
        node?.position = SCNVector3(0, 0.5, 0)
        node?.name = "obstacle_spike"
    }

    private func createBarrier() {
        // 栏杆 - 长方体
        let geometry = SCNBox(width: 2.0, height: 1.2, length: 0.2, chamferRadius: 0.05)
        let material = SCNMaterial()
        material.diffuse.contents = NSColor(red: 1, green: 0.5, blue: 0, alpha: 1)
        material.emission.contents = NSColor(red: 0.6, green: 0.2, blue: 0, alpha: 1)
        geometry.materials = [material]

        node = SCNNode(geometry: geometry)
        node?.position = SCNVector3(0, 0.6, 0)
        node?.name = "obstacle_barrier"

        // 添加霓虹灯效果
        let glowGeometry = SCNBox(width: 2.2, height: 1.4, length: 0.3, chamferRadius: 0.08)
        let glowMaterial = SCNMaterial()
        glowMaterial.diffuse.contents = NSColor.clear
        glowMaterial.emission.contents = NSColor(red: 1, green: 0.3, blue: 0, alpha: 0.5)
        glowGeometry.materials = [glowMaterial]

        let glowNode = SCNNode(geometry: glowGeometry)
        node?.addChildNode(glowNode)
    }

    private func createRock() {
        // 岩石 - 使用不规则形状
        let geometry = SCNBox(width: 1.4, height: 1.0, length: 1.2, chamferRadius: 0.3)
        let material = SCNMaterial()
        material.diffuse.contents = NSColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1)
        material.emission.contents = NSColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1)
        geometry.materials = [material]

        node = SCNNode(geometry: geometry)
        node?.position = SCNVector3(0, 0.5, 0)
        node?.name = "obstacle_rock"
        node?.scale = SCNVector3(1.2, 0.8, 1.0)
    }

    private func createCrate() {
        // 木箱
        let geometry = SCNBox(width: 1.2, height: 1.0, length: 1.2, chamferRadius: 0.05)
        let material = SCNMaterial()
        material.diffuse.contents = NSColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1)
        material.emission.contents = NSColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1)
        geometry.materials = [material]

        node = SCNNode(geometry: geometry)
        node?.position = SCNVector3(0, 0.5, 0)
        node?.name = "obstacle_crate"

        // 添加边框
        let edgeGeometry = SCNBox(width: 1.25, height: 1.05, length: 1.25, chamferRadius: 0.08)
        let edgeMaterial = SCNMaterial()
        edgeMaterial.diffuse.contents = NSColor.clear
        edgeMaterial.emission.contents = NSColor(red: 0.8, green: 0.6, blue: 0.3, alpha: 0.8)
        edgeGeometry.materials = [edgeMaterial]

        let edgeNode = SCNNode(geometry: edgeGeometry)
        node?.addChildNode(edgeNode)
    }

    // 更新位置
    func update(speed: Float, deltaTime: Float) {
        let newZ = position.z + CGFloat(speed * deltaTime)
        position = SCNVector3(CGFloat(Float(lanePosition) * 2.5), position.y, newZ)
        node?.position = position

        // 旋转效果
        if type == .rock {
            node?.eulerAngles.y += CGFloat(deltaTime * 0.5)
        }
    }

    // 检查是否超出范围
    func isOutOfRange() -> Bool {
        // 障碍物会在 z = -50 生成，只需要在通过玩家后再移除
        return position.z > 20
    }

    // 移除节点
    func remove() {
        node?.removeFromParentNode()
        isActive = false
    }
}

// MARK: - 障碍物工厂
class ObstacleFactory {
    static func createRandom(lane: Int, zPosition: Float) -> Obstacle {
        let types = ObstacleType.allCases
        let randomType = types.randomElement() ?? .crate
        return Obstacle(type: randomType, lane: lane, zPosition: zPosition)
    }

    static func create(type: ObstacleType, lane: Int, zPosition: Float) -> Obstacle {
        return Obstacle(type: type, lane: lane, zPosition: zPosition)
    }
}
