import SwiftUI
import SceneKit
import AppKit

struct GameView: NSViewRepresentable {
    @EnvironmentObject var gameManager: GameManager

    func makeNSView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = gameManager.gameScene
        scnView.backgroundColor = .black
        scnView.allowsCameraControl = false
        scnView.antialiasingMode = .multisampling4X
        scnView.preferredFramesPerSecond = 60
        scnView.rendersContinuously = true
        scnView.isPlaying = true

        // 设置相机
        if let cameraNode = gameManager.gameScene.rootNode.childNode(withName: "camera", recursively: true) {
            scnView.pointOfView = cameraNode
        }

        // 让 scnView 可以接收键盘事件（窗口挂载后再设置）
        DispatchQueue.main.async {
            scnView.window?.makeFirstResponder(scnView)
        }

        return scnView
    }

    func updateNSView(_ nsView: SCNView, context: Context) {
        // 保持场景和渲染状态，避免进入开始游戏后画面静止
        if nsView.scene !== gameManager.gameScene {
            nsView.scene = gameManager.gameScene
        }
        nsView.isPlaying = true
    }
}
