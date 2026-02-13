import Foundation

// MARK: - 计分管理器
class ScoreManager: ObservableObject {
    // 分数
    @Published var score: Int = 0

    // 金币
    @Published var coins: Int = 0

    // 距离
    @Published var distance: Float = 0

    // 分数乘数
    var scoreMultiplier: Float = 1.0

    init() {}

    // 重置
    func reset() {
        score = 0
        coins = 0
        distance = 0
        scoreMultiplier = 1.0
    }

    // 更新（每帧调用）
    func update(deltaTime: Float, speed: Float) {
        // 基于距离计算分数
        distance += speed * deltaTime

        // 距离分数：每米 1 分
        let distanceScore = Int(distance / 10)

        // 实际分数 = 距离分 + 基础分
        score = distanceScore + Int(Float(coins) * 10)
    }

    // 添加金币
    func addCoins(_ amount: Int) {
        coins += amount
    }

    // 设置分数乘数
    func setMultiplier(_ multiplier: Float) {
        scoreMultiplier = multiplier
    }
}
