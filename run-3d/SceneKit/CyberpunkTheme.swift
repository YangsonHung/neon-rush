import Foundation
import SceneKit

// MARK: - 赛博朋克主题
class CyberpunkTheme {
    // 主题颜色
    let primaryCyan = NSColor(red: 0, green: 1, blue: 1, alpha: 1)
    let primaryMagenta = NSColor(red: 1, green: 0, blue: 1, alpha: 1)
    let primaryPink = NSColor(red: 1, green: 0, blue: 0.5, alpha: 1)
    let primaryOrange = NSColor(red: 1, green: 0.5, blue: 0, alpha: 1)
    let primaryPurple = NSColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1)
    let primaryYellow = NSColor(red: 1, green: 0.9, blue: 0, alpha: 1)
    let primaryGreen = NSColor(red: 0, green: 1, blue: 0.5, alpha: 1)

    // 背景色
    let backgroundDark = NSColor(red: 0.02, green: 0.02, blue: 0.05, alpha: 1)
    let backgroundMedium = NSColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1)

    // 霓虹色数组（用于随机选择）
    var neonColors: [NSColor] {
        [primaryCyan, primaryMagenta, primaryPink, primaryOrange, primaryPurple, primaryYellow, primaryGreen]
    }

    init() {}

    // 获取随机霓虹色
    func randomNeonColor() -> NSColor {
        neonColors.randomElement() ?? primaryCyan
    }

    // 创建霓虹材质
    func createNeonMaterial(color: NSColor, emissionIntensity: CGFloat = 1.0) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.emission.contents = color
        material.emission.intensity = emissionIntensity
        return material
    }

    // 创建发光材质
    func createGlowMaterial(color: NSColor, glowIntensity: CGFloat = 0.5) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = NSColor.clear
        material.emission.contents = color.withAlphaComponent(glowIntensity)
        return material
    }

    // 创建赛博朋克文字样式
    func createCyberpunkTextStyle() -> [NSAttributedString.Key: Any] {
        let shadow = NSShadow()
        shadow.shadowColor = primaryCyan
        shadow.shadowBlurRadius = 10

        return [
            .font: NSFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: NSColor.white,
            .shadow: shadow
        ]
    }

    // 渐变色
    var uiGradientColors: [NSColor] {
        [primaryCyan, primaryMagenta]
    }

    // HUD 背景色
    let hudBackground = NSColor.black.withAlphaComponent(0.6)

    // 边框颜色
    let borderColor = NSColor(white: 0.3, alpha: 1)

    // 文字颜色
    let textPrimary = NSColor.white
    let textSecondary = NSColor.gray
}
