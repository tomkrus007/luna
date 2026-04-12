# MenuBarSymbol 生成说明

当前菜单栏图标资源支持通过脚本自动生成 PNG 和 PDF：

```bash
swift Scripts/generate_menu_bar_symbol.swift
```

会生成：

- `Resources/Assets.xcassets/MenuBarSymbol.imageset/menu-bar-calendar.png`

当前 `Contents.json` 默认引用 `menu-bar-calendar.png`。

图标风格与 AppIcon 保持同一套日历语言，适合作为状态栏模板图标使用。
