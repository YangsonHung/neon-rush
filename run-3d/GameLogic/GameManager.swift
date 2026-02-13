import Foundation
import SceneKit
import Combine
import AppKit

// MARK: - 游戏状态
enum GameState {
    case idle
    case running
    case paused
    case gameOver
}

// MARK: - 游戏管理器
class GameManager: ObservableObject {
    // 游戏状态
    @Published var gameState: GameState = .idle

    // 游戏组件
    let player = Player()
    let levelManager = LevelManager()
    let scoreManager = ScoreManager()
    let inputHandler = InputHandler()
    let collisionManager = CollisionManager()

    // SceneKit 场景
    @Published var gameScene: SCNScene!

    // 游戏对象
    var obstacles: [Obstacle] = []
    var powerUps: [PowerUp] = []
    var coins: [Coin] = []

    // 生成计时器
    private var obstacleSpawnTimer: Float = 0
    private var powerUpSpawnTimer: Float = 0
    private var coinSpawnTimer: Float = 0
    private var gameLoopTimer: Timer?
    private let fixedDeltaTime: Float = 1.0 / 60.0

    // 游戏场景设置
    private var sceneSetup: SceneSetup!

    var currentLevel: Int {
        levelManager.currentLevel
    }

    init() {
        setupGame()
    }

    // 初始化游戏
    func setupGame() {
        // 创建 SceneKit 场景
        gameScene = SCNScene()
        sceneSetup = SceneSetup(scene: gameScene)
        sceneSetup.setupScene()

        // 添加玩家
        if let playerNode = player.node {
            gameScene.rootNode.addChildNode(playerNode)
        }

        // 绑定输入
        inputHandler.player = player

        // 绑定碰撞检测
        collisionManager.player = player
        collisionManager.gameManager = self

        // 启动主循环（只创建一次）
        startGameLoopIfNeeded()
    }

    private func startGameLoopIfNeeded() {
        guard gameLoopTimer == nil else { return }

        gameLoopTimer = Timer(timeInterval: TimeInterval(fixedDeltaTime), repeats: true) { [weak self] _ in
            self?.update(deltaTime: self?.fixedDeltaTime ?? (1.0 / 60.0))
        }

        if let timer = gameLoopTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    // 开始游戏
    func startGame() {
        // 重置所有状态
        player.reset()
        levelManager.reset()
        scoreManager.reset()
        inputHandler.reset()

        // 清除所有障碍物和道具
        clearGameObjects()

        // 重置计时器
        // 让开局尽快有可见对象，避免“看起来没动”
        obstacleSpawnTimer = levelManager.currentConfig.obstacleSpawnInterval
        powerUpSpawnTimer = 3.0
        coinSpawnTimer = 0.5

        // 设置游戏速度
        player.baseSpeed = levelManager.currentConfig.speed

        gameState = .running
    }

    // 暂停游戏
    func pauseGame() {
        if gameState == .running {
            gameState = .paused
        }
    }

    // 继续游戏
    func resumeGame() {
        if gameState == .paused {
            gameState = .running
        }
    }

    // 结束游戏
    func gameOver() {
        gameState = .gameOver
    }

    // 清除游戏对象
    private func clearGameObjects() {
        obstacles.forEach { $0.remove() }
        powerUps.forEach { $0.remove() }
        coins.forEach { $0.remove() }

        obstacles.removeAll()
        powerUps.removeAll()
        coins.removeAll()
    }

    // 游戏主循环
    func update(deltaTime: Float) {
        guard gameState == .running else { return }

        // 更新玩家
        player.update(deltaTime: deltaTime)

        // 更新关卡
        levelManager.update(deltaTime: deltaTime)

        // 更新游戏速度
        player.baseSpeed = levelManager.currentConfig.speed

        // 生成障碍物
        spawnObstacles(deltaTime: deltaTime)

        // 生成道具
        spawnPowerUps(deltaTime: deltaTime)

        // 生成金币
        spawnCoins(deltaTime: deltaTime)

        // 更新游戏对象
        updateGameObjects(deltaTime: deltaTime)

        // 碰撞检测
        collisionManager.checkCollisions(
            obstacles: obstacles,
            powerUps: powerUps,
            coins: coins
        )

        // 检查玩家状态
        if player.isDead {
            gameOver()
        }

        // 更新分数
        scoreManager.update(deltaTime: deltaTime, speed: player.currentSpeed)
    }

    // 生成障碍物
    private func spawnObstacles(deltaTime: Float) {
        obstacleSpawnTimer += deltaTime

        let config = levelManager.currentConfig
        if obstacleSpawnTimer >= config.obstacleSpawnInterval {
            obstacleSpawnTimer = 0

            // 随机选择车道
            let lanes = [-1, 0, 1]
            let selectedLanes = lanes.shuffled().prefix(Int.random(in: 1...2))

            for lane in selectedLanes {
                let obstacle = ObstacleFactory.createRandom(
                    lane: lane,
                    zPosition: -35
                )
                obstacles.append(obstacle)

                if let node = obstacle.node {
                    gameScene.rootNode.addChildNode(node)
                }
            }
        }
    }

    // 生成道具
    private func spawnPowerUps(deltaTime: Float) {
        powerUpSpawnTimer += deltaTime

        // 每隔一段时间尝试生成道具
        if powerUpSpawnTimer > 3.0 {
            powerUpSpawnTimer = 0

            let config = levelManager.currentConfig
            if Float.random(in: 0...1) < config.powerUpSpawnChance {
                let lane = Int.random(in: -1...1)
                let powerUp = PowerUpFactory.createRandom(lane: lane, zPosition: -35)
                powerUps.append(powerUp)

                if let node = powerUp.node {
                    gameScene.rootNode.addChildNode(node)
                }
            }
        }
    }

    // 生成金币
    private func spawnCoins(deltaTime: Float) {
        coinSpawnTimer += deltaTime

        let config = levelManager.currentConfig
        if coinSpawnTimer >= 0.5 {  // 每 0.5 秒尝试生成金币
            coinSpawnTimer = 0

            if Float.random(in: 0...1) < config.coinSpawnChance {
                let lane = Int.random(in: -1...1)

                // 生成一排金币（3-5个）
                let coinCount = Int.random(in: 3...5)
                for i in 0..<coinCount {
                    let coin = Coin(lane: lane, zPosition: -35 - Float(i) * 1.5)
                    coins.append(coin)

                    if let node = coin.node {
                        gameScene.rootNode.addChildNode(node)
                    }
                }
            }
        }
    }

    // 更新游戏对象
    private func updateGameObjects(deltaTime: Float) {
        let speed = player.currentSpeed * levelManager.currentConfig.obstacleSpeedMultiplier

        // 更新障碍物
        obstacles.forEach { obstacle in
            obstacle.update(speed: speed, deltaTime: deltaTime)
        }

        // 移除超出范围的障碍物
        obstacles.removeAll { obstacle in
            if obstacle.isOutOfRange() {
                obstacle.remove()
                return true
            }
            return false
        }

        // 更新道具
        powerUps.forEach { powerUp in
            powerUp.update(speed: speed, deltaTime: deltaTime)
        }

        // 移除超出范围的道具
        powerUps.removeAll { powerUp in
            if powerUp.isOutOfRange() {
                powerUp.remove()
                return true
            }
            return false
        }

        // 更新金币
        coins.forEach { coin in
            // 磁铁效果：金币向玩家移动
            if player.hasMagnet {
                let dx = player.position.x - coin.position.x
                let dz = player.position.z - coin.position.z
                let distance = sqrt(dx * dx + dz * dz)

                if distance < 8 {
                    coin.position.x += dx * 0.1
                }
            }

            coin.update(speed: speed, deltaTime: deltaTime)
        }

        // 移除超出范围的金币
        coins.removeAll { coin in
            if coin.isOutOfRange() {
                coin.remove()
                return true
            }
            return false
        }
    }

    // 应用道具效果
    func applyPowerUp(_ powerUp: PowerUp) {
        switch powerUp.type {
        case .speedBoost:
            player.activateSpeedBoost()
        case .shield:
            player.activateShield()
        case .magnet:
            player.activateMagnet()
        case .invincible:
            player.activateInvincible()
        case .coinMultiplier:
            player.activateCoinMultiplier()
        }
    }

    // 统一移除障碍物，确保场景和数据同步
    func removeObstacle(_ obstacle: Obstacle) {
        obstacle.remove()
        obstacles.removeAll { $0.id == obstacle.id }
    }

    // 收集金币
    func collectCoin(_ coin: Coin) {
        let multiplier = player.hasCoinMultiplier ? 2 : 1
        scoreManager.addCoins(1 * multiplier)
    }

    deinit {
        gameLoopTimer?.invalidate()
    }
}
