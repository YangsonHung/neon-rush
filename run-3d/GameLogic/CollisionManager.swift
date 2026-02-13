import Foundation
import SceneKit

// MARK: - 碰撞管理器
class CollisionManager: ObservableObject {
    weak var player: Player?
    weak var gameManager: GameManager?

    // 碰撞检测
    func checkCollisions(obstacles: [Obstacle], powerUps: [PowerUp], coins: [Coin]) {
        guard let player = player else { return }

        let playerPos = player.position

        // 检测与障碍物的碰撞
        for obstacle in obstacles {
            if !obstacle.isActive { continue }
            if checkObstacleCollision(playerPos: playerPos, obstacle: obstacle) {
                handleObstacleCollision(obstacle)
            }
        }

        // 检测与道具的碰撞
        for powerUp in powerUps {
            if powerUp.isActive && checkPowerUpCollision(playerPos: playerPos, powerUp: powerUp) {
                handlePowerUpCollision(powerUp)
            }
        }

        // 检测与金币的碰撞
        for coin in coins {
            if coin.isActive && checkCoinCollision(playerPos: playerPos, coin: coin) {
                handleCoinCollision(coin)
            }
        }
    }

    // 检测障碍物碰撞
    private func checkObstacleCollision(playerPos: SCNVector3, obstacle: Obstacle) -> Bool {
        let dx = Float(playerPos.x - obstacle.position.x)
        let dz = Float(playerPos.z - obstacle.position.z)
        let dy = Float(playerPos.y - obstacle.position.y)

        let horizontalDist = sqrt(dx * dx + dz * dz)
        let verticalDist = abs(dy)

        // 检查是否在碰撞范围内
        let radiusSum = obstacle.collisionRadius + 0.4 // 玩家半径约 0.4

        return horizontalDist < radiusSum && verticalDist < obstacle.collisionHeight
    }

    // 处理障碍物碰撞
    private func handleObstacleCollision(_ obstacle: Obstacle) {
        guard let player = player else { return }

        // 检查是否可以跳过（只有栏杆和木箱可以跳过去）
        if obstacle.type == .barrier || obstacle.type == .crate {
            // 如果玩家正在跳跃且高度足够，可以不被阻挡
            if Float(player.position.y) > obstacle.collisionHeight + 0.3 {
                return
            }
        }

        // 尖刺和岩石碰到就受伤
        if !player.isInvincible {
            player.takeDamage()

            // 移除障碍物
            if let gameManager {
                gameManager.removeObstacle(obstacle)
            } else {
                obstacle.remove()
            }
        }
    }

    // 检测道具碰撞
    private func checkPowerUpCollision(playerPos: SCNVector3, powerUp: PowerUp) -> Bool {
        let dx = Float(playerPos.x - powerUp.position.x)
        let dz = Float(playerPos.z - powerUp.position.z)

        let distance = sqrt(dx * dx + dz * dz)

        return distance < powerUp.collisionRadius + 0.5
    }

    // 处理道具碰撞
    private func handlePowerUpCollision(_ powerUp: PowerUp) {
        gameManager?.applyPowerUp(powerUp)
        powerUp.remove()
    }

    // 检测金币碰撞
    private func checkCoinCollision(playerPos: SCNVector3, coin: Coin) -> Bool {
        let dx = Float(playerPos.x - coin.position.x)
        let dz = Float(playerPos.z - coin.position.z)
        let dy = Float(playerPos.y - coin.position.y)

        let horizontalDist = sqrt(dx * dx + dz * dz)

        return horizontalDist < coin.collisionRadius + 0.5 && abs(dy) < 1.5
    }

    // 处理金币碰撞
    private func handleCoinCollision(_ coin: Coin) {
        gameManager?.collectCoin(coin)
        coin.remove()
    }
}
