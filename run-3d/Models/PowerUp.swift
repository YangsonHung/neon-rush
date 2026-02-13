import Foundation
import SceneKit

// MARK: - 道具类型
enum PowerUpType: Int, CaseIterable {
    case speedBoost = 0   // 加速
    case shield = 1       // 护盾
    case magnet = 2       // 磁铁
    case invincible = 3   // 无敌
    case coinMultiplier = 4 // 金币翻倍

    var name: String {
        switch self {
        case .speedBoost: return "加速"
        case .shield: return "护盾"
        case .magnet: return "磁铁"
        case .invincible: return "无敌"
        case .coinMultiplier: return "金币翻倍"
        }
    }

    var icon: String {
        switch self {
        case .speedBoost: return "bolt.fill"
        case .shield: return "shield.fill"
        case .magnet: return "hexagon.fill"
        case .invincible: return "star.fill"
        case .coinMultiplier: return "2.circle.fill"
        }
    }

    var color: NSColor {
        switch self {
        case .speedBoost: return NSColor(red: 1, green: 0.6, blue: 0, alpha: 1) // 橙色
        case .shield: return NSColor(red: 0, green: 0.5, blue: 1, alpha: 1) // 蓝色
        case .magnet: return NSColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1) // 紫色
        case .invincible: return NSColor(red: 1, green: 0.9, blue: 0, alpha: 1) // 黄色
        case .coinMultiplier: return NSColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1) // 绿色
        }
    }
}

// MARK: - 道具类
class PowerUp: ObservableObject, Identifiable {
    let id = UUID()
    let type: PowerUpType

    @Published var position: SCNVector3
    @Published var isActive: Bool = true

    var node: SCNNode?
    var lanePosition: Int

    var collisionRadius: Float = 0.8

    init(type: PowerUpType, lane: Int, zPosition: Float) {
        self.type = type
        self.lanePosition = lane
        self.position = SCNVector3(Float(lane) * 2.5, 0.8, zPosition)
        createNode()
    }

    // 创建道具 3D 模型
    func createNode() {
        // 底座
        let baseGeometry = SCNCylinder(radius: 0.5, height: 0.1)
        let baseMaterial = SCNMaterial()
        baseMaterial.diffuse.contents = NSColor(white: 0.2, alpha: 1)
        baseMaterial.emission.contents = NSColor(white: 0.1, alpha: 1)
        baseGeometry.materials = [baseMaterial]

        let baseNode = SCNNode(geometry: baseGeometry)
        baseNode.position = SCNVector3(0, -0.5, 0)

        // 主体 - 发光球体
        let sphereGeometry = SCNSphere(radius: 0.4)
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = type.color
        sphereMaterial.emission.contents = type.color.withAlphaComponent(0.8)
        sphereGeometry.materials = [sphereMaterial]

        let sphereNode = SCNNode(geometry: sphereGeometry)

        // 外发光
        let glowGeometry = SCNSphere(radius: 0.55)
        let glowMaterial = SCNMaterial()
        glowMaterial.diffuse.contents = NSColor.clear
        glowMaterial.emission.contents = type.color.withAlphaComponent(0.4)
        glowGeometry.materials = [glowMaterial]

        let glowNode = SCNNode(geometry: glowGeometry)

        // 组装
        node = SCNNode()
        node?.addChildNode(baseNode)
        node?.addChildNode(sphereNode)
        node?.addChildNode(glowNode)

        node?.position = position
        node?.name = "powerup_\(type.rawValue)"
    }

    // 更新位置和动画
    func update(speed: Float, deltaTime: Float) {
        let newZ = position.z + CGFloat(speed * deltaTime)
        position = SCNVector3(CGFloat(Float(lanePosition) * 2.5), position.y, newZ)
        node?.position = position

        // 旋转动画
        node?.eulerAngles.y += CGFloat(deltaTime * 2.0)

        // 悬浮动画
        let bounce = sin(Float(Date().timeIntervalSince1970) * 3) * 0.1
        node?.position.y = position.y + CGFloat(bounce)
    }

    // 检查是否超出范围
    func isOutOfRange() -> Bool {
        // 道具在远处生成，经过玩家后再回收
        return position.z > 20
    }

    // 移除节点
    func remove() {
        node?.removeFromParentNode()
        isActive = false
    }
}

// MARK: - 道具工厂
class PowerUpFactory {
    static func createRandom(lane: Int, zPosition: Float) -> PowerUp {
        let types = PowerUpType.allCases
        let randomType = types.randomElement() ?? .speedBoost
        return PowerUp(type: randomType, lane: lane, zPosition: zPosition)
    }

    static func create(type: PowerUpType, lane: Int, zPosition: Float) -> PowerUp {
        return PowerUp(type: type, lane: lane, zPosition: zPosition)
    }
}

// MARK: - 金币类
class Coin: ObservableObject, Identifiable {
    let id = UUID()

    @Published var position: SCNVector3
    @Published var isActive: Bool = true

    var node: SCNNode?
    var lanePosition: Int
    var collisionRadius: Float = 0.5

    init(lane: Int, zPosition: Float, offsetY: Float = 0) {
        self.lanePosition = lane
        self.position = SCNVector3(Float(lane) * 2.5, 1.0 + offsetY, zPosition)
        createNode()
    }

    func createNode() {
        // 金币 - 扁平圆柱体
        let geometry = SCNCylinder(radius: 0.35, height: 0.08)
        let material = SCNMaterial()
        material.diffuse.contents = NSColor(red: 1, green: 0.85, blue: 0, alpha: 1)
        material.emission.contents = NSColor(red: 0.8, green: 0.6, blue: 0, alpha: 1)
        material.specular.contents = NSColor.white
        geometry.materials = [material]

        node = SCNNode(geometry: geometry)
        node?.position = position
        node?.name = "coin"
    }

    func update(speed: Float, deltaTime: Float) {
        let newZ = position.z + CGFloat(speed * deltaTime)
        position = SCNVector3(CGFloat(Float(lanePosition) * 2.5), position.y, newZ)
        node?.position = position

        // 旋转动画
        node?.eulerAngles.y += CGFloat(deltaTime * 3.0)
    }

    func isOutOfRange() -> Bool {
        // 金币在远处生成，经过玩家后再回收
        return position.z > 20
    }

    func remove() {
        node?.removeFromParentNode()
        isActive = false
    }
}
