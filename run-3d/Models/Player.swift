import Foundation
import SceneKit

// MARK: - 玩家状态
enum PlayerState {
    case running
    case jumping
    case falling
}

// MARK: - 玩家类
class Player: ObservableObject {
    // 位置
    @Published var position: SCNVector3 = SCNVector3(0, 0.5, 0)
    @Published var velocityY: Float = 0

    // 状态
    @Published var state: PlayerState = .running
    @Published var health: Int = 3
    @Published var isDead: Bool = false

    // 道具状态
    @Published var hasShield: Bool = false
    @Published var isInvincible: Bool = false
    @Published var hasMagnet: Bool = false
    @Published var hasSpeedBoost: Bool = false
    @Published var hasCoinMultiplier: Bool = false

    // 道具持续时间计时器
    var shieldTimer: Float = 0
    var invincibleTimer: Float = 0
    var magnetTimer: Float = 0
    var speedBoostTimer: Float = 0
    var coinMultiplierTimer: Float = 0

    // 移动参数
    var lanePosition: Int = 0 // -1: 左, 0: 中, 1: 右
    let laneWidth: Float = 2.5

    // 物理参数
    let gravity: Float = -25.0
    let jumpForce: Float = 10.0
    let moveSpeed: Float = 15.0
    var baseSpeed: Float = 20.0
    var currentSpeed: Float = 20.0

    // SceneKit 节点
    var node: SCNNode?

    init() {
        createNode()
    }

    // 创建玩家 3D 模型
    func createNode() {
        // 身体
        let bodyGeometry = SCNBox(width: 0.8, height: 1.2, length: 0.5, chamferRadius: 0.1)
        let bodyMaterial = SCNMaterial()
        bodyMaterial.diffuse.contents = NSColor(red: 0, green: 0.8, blue: 1, alpha: 1)
        bodyMaterial.emission.contents = NSColor(red: 0, green: 0.4, blue: 0.6, alpha: 1)
        bodyGeometry.materials = [bodyMaterial]

        let bodyNode = SCNNode(geometry: bodyGeometry)
        bodyNode.name = "body"

        // 头部
        let headGeometry = SCNSphere(radius: 0.35)
        let headMaterial = SCNMaterial()
        headMaterial.diffuse.contents = NSColor(red: 1, green: 0.8, blue: 0, alpha: 1)
        headMaterial.emission.contents = NSColor(red: 0.5, green: 0.4, blue: 0, alpha: 1)
        headGeometry.materials = [headMaterial]

        let headNode = SCNNode(geometry: headGeometry)
        headNode.position = SCNVector3(0, 0.9, 0)
        headNode.name = "head"

        // 发光效果
        let glowGeometry = SCNBox(width: 1.0, height: 1.4, length: 0.7, chamferRadius: 0.15)
        let glowMaterial = SCNMaterial()
        glowMaterial.diffuse.contents = NSColor.clear
        glowMaterial.emission.contents = NSColor(red: 0, green: 0.8, blue: 1, alpha: 0.3)
        glowGeometry.materials = [glowMaterial]

        let glowNode = SCNNode(geometry: glowGeometry)
        glowNode.name = "glow"

        // 组装节点
        node = SCNNode()
        node?.addChildNode(bodyNode)
        node?.addChildNode(headNode)
        node?.addChildNode(glowNode)
        node?.name = "player"
        node?.position = position
    }

    // 跳跃
    func jump() {
        if state == .running {
            state = .jumping
            velocityY = jumpForce
        }
    }

    // 左右移动
    func moveLeft() {
        if lanePosition > -1 {
            lanePosition -= 1
        }
    }

    func moveRight() {
        if lanePosition < 1 {
            lanePosition += 1
        }
    }

    // 更新玩家
    func update(deltaTime: Float) {
        // 处理移动（平滑过渡到目标车道）
        let targetX = CGFloat(Float(lanePosition) * laneWidth)
        let diff = targetX - position.x
        position.x = position.x + diff * CGFloat(10.0 * deltaTime)

        // 重力
        if state != .running {
            velocityY += gravity * deltaTime
            position.y = position.y + CGFloat(velocityY * deltaTime)

            // 地面检测
            if position.y <= 0.5 {
                position.y = 0.5
                velocityY = 0
                state = .running
            }
        }

        // 更新节点位置
        node?.position = position

        // 更新道具计时器
        updatePowerUpTimers(deltaTime: deltaTime)

        // 速度处理
        currentSpeed = hasSpeedBoost ? baseSpeed * 1.5 : baseSpeed
    }

    // 更新道具持续时间
    private func updatePowerUpTimers(deltaTime: Float) {
        if shieldTimer > 0 {
            shieldTimer -= deltaTime
            if shieldTimer <= 0 {
                hasShield = false
            }
        }

        if invincibleTimer > 0 {
            invincibleTimer -= deltaTime
            if invincibleTimer <= 0 {
                isInvincible = false
            }
        }

        if magnetTimer > 0 {
            magnetTimer -= deltaTime
            if magnetTimer <= 0 {
                hasMagnet = false
            }
        }

        if speedBoostTimer > 0 {
            speedBoostTimer -= deltaTime
            if speedBoostTimer <= 0 {
                hasSpeedBoost = false
            }
        }

        if coinMultiplierTimer > 0 {
            coinMultiplierTimer -= deltaTime
            if coinMultiplierTimer <= 0 {
                hasCoinMultiplier = false
            }
        }
    }

    // 激活道具
    func activateShield() {
        hasShield = true
        shieldTimer = 5.0
    }

    func activateInvincible() {
        isInvincible = true
        invincibleTimer = 3.0
    }

    func activateMagnet() {
        hasMagnet = true
        magnetTimer = 8.0
    }

    func activateSpeedBoost() {
        hasSpeedBoost = true
        speedBoostTimer = 5.0
    }

    func activateCoinMultiplier() {
        hasCoinMultiplier = true
        coinMultiplierTimer = 10.0
    }

    // 受到伤害
    func takeDamage() {
        if isInvincible || hasShield {
            if hasShield {
                hasShield = false
                shieldTimer = 0
            }
            return
        }

        health -= 1
        if health <= 0 {
            isDead = true
        }
    }

    // 重置
    func reset() {
        position = SCNVector3(0, 0.5, 0)
        velocityY = 0
        state = .running
        health = 3
        isDead = false
        lanePosition = 0
        currentSpeed = baseSpeed

        hasShield = false
        isInvincible = false
        hasMagnet = false
        hasSpeedBoost = false
        hasCoinMultiplier = false

        shieldTimer = 0
        invincibleTimer = 0
        magnetTimer = 0
        speedBoostTimer = 0
        coinMultiplierTimer = 0
    }
}
