# AppIcon 占位说明

当前 `AppIcon.appiconset` 已补齐 macOS 所需的标准尺寸声明，并可通过脚本自动生成一套占位 PNG。

## 自动生成占位图标

在仓库根目录运行：

```bash
swift Scripts/generate_app_icons.swift
```

脚本会自动生成以下文件：

- `AppIcon-16.png`
- `AppIcon-16@2x.png`
- `AppIcon-32.png`
- `AppIcon-32@2x.png`
- `AppIcon-128.png`
- `AppIcon-128@2x.png`
- `AppIcon-256.png`
- `AppIcon-256@2x.png`
- `AppIcon-512.png`
- `AppIcon-512@2x.png`

生成结果为一套蓝色日历风格的占位图标，可直接用于本地开发与 Xcode 工程联调。

脚本已修复像素尺寸问题，输出尺寸与 `Contents.json` 中声明的 macOS iconset 尺寸一致。

## 手动替换

请补入以下文件：

- `AppIcon-16.png`
- `AppIcon-16@2x.png`
- `AppIcon-32.png`
- `AppIcon-32@2x.png`
- `AppIcon-128.png`
- `AppIcon-128@2x.png`
- `AppIcon-256.png`
- `AppIcon-256@2x.png`
- `AppIcon-512.png`
- `AppIcon-512@2x.png`

建议图标风格：

- 蓝底或白底
- 中心使用日历符号
- 与当前主界面蓝色工具栏风格一致
