import Foundation

// MARK: - 关卡配置
struct LevelConfig {
    let level: Int
    let speed: Float
    let obstacleSpawnInterval: Float  // 障碍物生成间隔（秒）
    let powerUpSpawnChance: Float     // 道具生成概率 (0-1)
    let coinSpawnChance: Float        // 金币生成概率 (0-1)
    let obstacleSpeedMultiplier: Float // 障碍物速度乘数
    let duration: Float              // 关卡持续时间（秒）

    static let levels: [LevelConfig] = [
        // Level 1 - 简单
        LevelConfig(
            level: 1,
            speed: 15,
            obstacleSpawnInterval: 2.5,
            powerUpSpawnChance: 0.15,
            coinSpawnChance: 0.3,
            obstacleSpeedMultiplier: 1.0,
            duration: 30
        ),

        // Level 2
        LevelConfig(
            level: 2,
            speed: 17,
            obstacleSpawnInterval: 2.2,
            powerUpSpawnChance: 0.18,
            coinSpawnChance: 0.32,
            obstacleSpeedMultiplier: 1.05,
            duration: 35
        ),

        // Level 3
        LevelConfig(
            level: 3,
            speed: 19,
            obstacleSpawnInterval: 2.0,
            powerUpSpawnChance: 0.2,
            coinSpawnChance: 0.35,
            obstacleSpeedMultiplier: 1.1,
            duration: 35
        ),

        // Level 4
        LevelConfig(
            level: 4,
            speed: 21,
            obstacleSpawnInterval: 1.8,
            powerUpSpawnChance: 0.22,
            coinSpawnChance: 0.35,
            obstacleSpeedMultiplier: 1.15,
            duration: 40
        ),

        // Level 5
        LevelConfig(
            level: 5,
            speed: 23,
            obstacleSpawnInterval: 1.6,
            powerUpSpawnChance: 0.25,
            coinSpawnChance: 0.38,
            obstacleSpeedMultiplier: 1.2,
            duration: 40
        ),

        // Level 6
        LevelConfig(
            level: 6,
            speed: 25,
            obstacleSpawnInterval: 1.5,
            powerUpSpawnChance: 0.25,
            coinSpawnChance: 0.4,
            obstacleSpeedMultiplier: 1.25,
            duration: 45
        ),

        // Level 7
        LevelConfig(
            level: 7,
            speed: 27,
            obstacleSpawnInterval: 1.4,
            powerUpSpawnChance: 0.28,
            coinSpawnChance: 0.4,
            obstacleSpeedMultiplier: 1.3,
            duration: 45
        ),

        // Level 8
        LevelConfig(
            level: 8,
            speed: 29,
            obstacleSpawnInterval: 1.3,
            powerUpSpawnChance: 0.3,
            coinSpawnChance: 0.42,
            obstacleSpeedMultiplier: 1.35,
            duration: 50
        ),

        // Level 9
        LevelConfig(
            level: 9,
            speed: 31,
            obstacleSpawnInterval: 1.2,
            powerUpSpawnChance: 0.32,
            coinSpawnChance: 0.45,
            obstacleSpeedMultiplier: 1.4,
            duration: 50
        ),

        // Level 10 - 最终关卡
        LevelConfig(
            level: 10,
            speed: 35,
            obstacleSpawnInterval: 1.0,
            powerUpSpawnChance: 0.35,
            coinSpawnChance: 0.5,
            obstacleSpeedMultiplier: 1.5,
            duration: 60
        )
    ]

    static func getConfig(for level: Int) -> LevelConfig {
        if level <= 0 { return levels[0] }
        if level > levels.count { return levels[levels.count - 1] }
        return levels[level - 1]
    }
}

// MARK: - 关卡管理器
class LevelManager: ObservableObject {
    @Published var currentLevel: Int = 1
    @Published var levelTime: Float = 0
    @Published var isLevelComplete: Bool = false

    var currentConfig: LevelConfig {
        LevelConfig.getConfig(for: currentLevel)
    }

    func reset() {
        currentLevel = 1
        levelTime = 0
        isLevelComplete = false
    }

    func update(deltaTime: Float) {
        levelTime += deltaTime

        // 检查是否完成当前关卡
        if levelTime >= currentConfig.duration {
            if currentLevel < 10 {
                // 进入下一关
                currentLevel += 1
                levelTime = 0
            } else {
                // 最后一关完成后继续游戏（可以重置或保持）
                isLevelComplete = true
            }
        }
    }

    func nextLevel() {
        if currentLevel < 10 {
            currentLevel += 1
            levelTime = 0
        }
    }
}
