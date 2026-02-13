# AGENTS.md

## Communication

- 默认使用中文沟通。

## Build & Run

- 工程文件：`run-3d.xcodeproj`
- Scheme：`run-3d`
- 命令行构建：

```bash
xcodebuild -project run-3d.xcodeproj -scheme run-3d -configuration Debug -derivedDataPath build build
```

- 可选：如需根据 `project.yml` 重新生成工程：

```bash
xcodegen generate
```

## Commit Workflow

- 提交前先确保可成功构建。
- 只提交与任务相关文件，避免提交临时产物。

## Repository Constraints

- 不要提交以下临时文件/目录：
  - `build/`
  - `DerivedData/`
  - `*.xcworkspace/xcuserdata/`
  - `*.xcodeproj/xcuserdata/`

## Documentation Rules

- 英文主文档使用 `README.md`。
- 中文文档使用 `README.zh-CN.md`。
- 需要展示游戏截图时，统一使用仓库根目录下的 `view.png`。
