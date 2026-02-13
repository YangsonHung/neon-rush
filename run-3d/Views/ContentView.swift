import SwiftUI
import SceneKit
import AppKit

struct ContentView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var isMonitoring = false
    @State private var keyDownMonitor: Any?
    @State private var keyUpMonitor: Any?

    var body: some View {
        ZStack {
            // 3D 游戏视图
            GameView()
                .environmentObject(gameManager)
                .onAppear {
                    startKeyboardMonitoring()
                }
                .onDisappear {
                    stopKeyboardMonitoring()
                }

            // HUD 覆盖层
            HUDView()
                .environmentObject(gameManager)
        }
        .background(Color.black)
    }

    private func startKeyboardMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        // 本地键盘监听（不依赖辅助功能权限）
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // P 键按住时会触发重复 keyDown，避免连续切换暂停/继续
            if event.keyCode == 0x23 && event.isARepeat {
                return event
            }

            self.gameManager.inputHandler.handleKeyDown(event)

            // 处理暂停
            if event.keyCode == 0x23 { // P 键
                if self.gameManager.gameState == .running {
                    self.gameManager.pauseGame()
                } else if self.gameManager.gameState == .paused {
                    self.gameManager.resumeGame()
                }
            }

            return event
        }

        keyUpMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyUp) { event in
            self.gameManager.inputHandler.handleKeyUp(event)
            return event
        }
    }

    private func stopKeyboardMonitoring() {
        guard isMonitoring else { return }
        isMonitoring = false

        if let keyDownMonitor {
            NSEvent.removeMonitor(keyDownMonitor)
            self.keyDownMonitor = nil
        }

        if let keyUpMonitor {
            NSEvent.removeMonitor(keyUpMonitor)
            self.keyUpMonitor = nil
        }
    }
}
