# Neon Rush（极限跑酷）

macOS 平台 3D 极限跑酷游戏

**[English](README.md)** | **中文**

## 项目简介

Neon Rush 是一个基于 SwiftUI + SceneKit 开发的 macOS 3D 跑酷游戏。  
玩家将在霓虹赛博风赛道中奔跑，躲避障碍、收集金币，并使用道具挑战更高分数。

## 游戏截图

![游戏截图](./view.png)

## 功能特性

- 三车道移动系统
- 跳跃与闪避机制
- 障碍物、金币与随机道具
- 暂停/继续流程
- 关卡推进与计分系统

## 操作说明

- `A / D` 或 `← / →`：左右移动
- `Space`：跳跃
- `P`：暂停/继续

## 本地运行

### 方式 1：使用 Xcode

1. 打开 `/Users/yangsonhung/Projects/personal/run-3d/run-3d.xcodeproj`
2. 选择 Scheme：`run-3d`
3. 运行程序（`Cmd + R`）

### 方式 2：命令行构建

```bash
xcodebuild -project run-3d.xcodeproj -scheme run-3d -configuration Debug -derivedDataPath build build
```

### 可选：重新生成 Xcode 工程

```bash
xcodegen generate
```

## 项目结构

- `run-3d/` - Swift 源码（App、Views、GameLogic、Models、SceneKit）
- `run-3d.xcodeproj/` - Xcode 工程
- `project.yml` - XcodeGen 配置
- `view.png` - README 中使用的游戏截图

## 许可证

本项目使用 [MIT License](LICENSE)。
