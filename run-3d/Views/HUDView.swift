import SwiftUI

struct HUDView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ZStack {
            // 开始界面
            if gameManager.gameState == .idle {
                startScreen
            }

            // 暂停界面
            if gameManager.gameState == .paused {
                pausedScreen
            }

            // 游戏结束界面
            if gameManager.gameState == .gameOver {
                gameOverScreen
            }

            // 游戏 HUD（运行时显示）
            if gameManager.gameState == .running {
                runningHUD
            }
        }
    }

    // MARK: - 开始界面
    private var startScreen: some View {
        ZStack {
            Color.black.opacity(0.8)

            VStack(spacing: 30) {
                Text("极限跑酷")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .pink, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .cyan, radius: 20)

                VStack(alignment: .leading, spacing: 15) {
                    Text("操作说明")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    HStack {
                        Text("← →")
                            .neonText(color: .cyan)
                        Text("或 A/D - 左右移动")
                            .foregroundColor(.white)
                    }

                    HStack {
                        Text("空格")
                            .neonText(color: .pink)
                        Text("跳跃")
                            .foregroundColor(.white)
                    }

                    HStack {
                        Text("P")
                            .neonText(color: .yellow)
                        Text("暂停")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)

                Button(action: {
                    gameManager.startGame()
                }) {
                    Text("开始游戏")
                        .font(.title.bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(30)
                        .shadow(color: .cyan, radius: 10)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 暂停界面
    private var pausedScreen: some View {
        ZStack {
            Color.black.opacity(0.7)

            VStack(spacing: 20) {
                Text("暂停")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow, radius: 10)

                Button(action: {
                    gameManager.resumeGame()
                }) {
                    Text("继续")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
                .buttonStyle(.plain)

                Button(action: {
                    gameManager.startGame()
                }) {
                    Text("重新开始")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.gray)
                        .cornerRadius(20)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 游戏结束界面
    private var gameOverScreen: some View {
        ZStack {
            Color.black.opacity(0.8)

            VStack(spacing: 25) {
                Text("游戏结束")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.red)
                    .shadow(color: .red, radius: 15)

                VStack(spacing: 10) {
                    Text("最终得分")
                        .font(.title2)
                        .foregroundColor(.white)

                    Text("\(gameManager.scoreManager.score)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .yellow, radius: 10)
                }

                HStack(spacing: 30) {
                    VStack {
                        Text("金币")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(gameManager.scoreManager.coins)")
                            .font(.title3.bold())
                            .foregroundColor(.yellow)
                    }

                    VStack {
                        Text("关卡")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(gameManager.currentLevel)")
                            .font(.title3.bold())
                            .foregroundColor(.cyan)
                    }
                }

                Button(action: {
                    gameManager.startGame()
                }) {
                    Text("再来一局")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(30)
                        .shadow(color: .cyan, radius: 10)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 运行中 HUD
    private var runningHUD: some View {
        VStack {
            // 顶部状态栏
            HStack {
                // 分数
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(gameManager.scoreManager.score)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.6))
                .cornerRadius(20)

                Spacer()

                // 关卡
                Text("关卡 \(gameManager.currentLevel)/10")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.cyan)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)

                Spacer()

                // 金币
                HStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.yellow)
                    Text("\(gameManager.scoreManager.coins)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.6))
                .cornerRadius(20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Spacer()

            // 底部道具栏
            HStack(spacing: 15) {
                // 护盾
                PowerUpIndicator(
                    icon: "shield.fill",
                    isActive: gameManager.player.hasShield,
                    color: .blue,
                    label: "护盾"
                )

                // 无敌
                PowerUpIndicator(
                    icon: "star.fill",
                    isActive: gameManager.player.isInvincible,
                    color: .yellow,
                    label: "无敌"
                )

                // 磁铁
                PowerUpIndicator(
                    icon: "hexagon.fill",
                    isActive: gameManager.player.hasMagnet,
                    color: .purple,
                    label: "磁铁"
                )

                // 加速
                PowerUpIndicator(
                    icon: "bolt.fill",
                    isActive: gameManager.player.hasSpeedBoost,
                    color: .orange,
                    label: "加速"
                )

                // 金币翻倍
                PowerUpIndicator(
                    icon: "2.circle.fill",
                    isActive: gameManager.player.hasCoinMultiplier,
                    color: .green,
                    label: "x2"
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - 道具指示器
struct PowerUpIndicator: View {
    let icon: String
    let isActive: Bool
    let color: Color
    let label: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isActive ? color : .gray)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(isActive ? color.opacity(0.3) : Color.gray.opacity(0.2))
                )
                .overlay(
                    Circle()
                        .stroke(isActive ? color : Color.gray, lineWidth: 2)
                )
                .shadow(color: isActive ? color : .clear, radius: 10)

            Text(label)
                .font(.caption2)
                .foregroundColor(isActive ? color : .gray)
        }
    }
}

// MARK: - 霓虹文字修饰器
struct NeonTextModifier: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .shadow(color: color, radius: 5)
    }
}

extension View {
    func neonText(color: Color) -> some View {
        modifier(NeonTextModifier(color: color))
    }
}
