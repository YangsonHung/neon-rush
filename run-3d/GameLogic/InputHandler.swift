import Foundation
import AppKit
import Combine

// MARK: - 输入处理器
class InputHandler: ObservableObject {
    weak var player: Player?

    // 按键状态
    @Published var leftPressed: Bool = false
    @Published var rightPressed: Bool = false
    @Published var jumpPressed: Bool = false
    @Published var pausePressed: Bool = false

    // 回调
    var onPauseToggle: (() -> Void)?

    // 按键映射
    private let leftKeys: Set<UInt16> = [0x7B, 0x00]  // Left Arrow, A
    private let rightKeys: Set<UInt16> = [0x7C, 0x02] // Right Arrow, D
    private let jumpKey: UInt16 = 0x31                 // Space
    private let pauseKey: UInt16 = 0x23                 // P

    init() {}

    // 处理按键按下
    func handleKeyDown(_ event: NSEvent) {
        let keyCode = event.keyCode

        // 暂停
        if keyCode == pauseKey {
            pausePressed = true
            onPauseToggle?()
            return
        }

        // 左移
        if leftKeys.contains(keyCode) && !leftPressed {
            leftPressed = true
            player?.moveLeft()
        }

        // 右移
        if rightKeys.contains(keyCode) && !rightPressed {
            rightPressed = true
            player?.moveRight()
        }

        // 跳跃
        if keyCode == jumpKey && !jumpPressed {
            jumpPressed = true
            player?.jump()
        }
    }

    // 处理按键释放
    func handleKeyUp(_ event: NSEvent) {
        let keyCode = event.keyCode

        if leftKeys.contains(keyCode) {
            leftPressed = false
        }

        if rightKeys.contains(keyCode) {
            rightPressed = false
        }

        if keyCode == jumpKey {
            jumpPressed = false
        }
    }

    // 重置输入状态
    func reset() {
        leftPressed = false
        rightPressed = false
        jumpPressed = false
        pausePressed = false
    }
}
