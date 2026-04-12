# LunaCalendar 工程生成说明

## 当前状态

仓库已整理为标准的 macOS App + Widget Extension 源码结构，并补充了 `project.yml` 与基础配置文件。

当前环境缺少完整 Xcode，因此本仓库内未直接生成 `.xcodeproj`。

## 目录结构

- `App/`：应用入口与 AppDelegate
- `Features/`：菜单栏、日历、设置界面
- `Services/`：历法、节假日、系统能力
- `Shared/`：共享模型
- `WidgetExtension/`：WidgetKit 扩展代码
- `Config/`：plist、entitlements
- `project.yml`：XcodeGen 配置

## 生成工程（推荐）

### 1. 安装完整 Xcode

确保本机安装的是完整 Xcode，而不是只有 Command Line Tools。

### 2. 安装 XcodeGen

```bash
brew install xcodegen
```

### 3. 生成工程

在仓库根目录执行：

```bash
xcodegen generate
```

执行成功后会生成：

```text
LunaCalendar.xcodeproj
```

### 4. 打开工程

```bash
open LunaCalendar.xcodeproj
```

## 打开工程后需要确认的事项

### 1. Signing & Capabilities

对 `LunaCalendar` 和 `LunaCalendarWidgetExtension` 两个 target：

- 选择你的 Team
- 确认 Bundle Identifier 可用
- 打开 App Sandbox
- 添加 App Groups
- App Groups 值需与代码一致：

```text
group.luna.calendar
```

### 2. Widget Extension

确认 widget target 已正确链接：

- `WidgetKit`
- `SwiftUI`

### 3. Launch at Login

当前代码使用 `SMAppService.mainApp`。

如果你要正式启用“开机自动运行”：

- 需要完整签名环境
- 某些发行方式下可能还需要进一步调整登录项策略

因此首轮联调时，可先只验证菜单栏、日历窗口和 widget。

## 推荐联调顺序

1. 先跑通主应用 target
2. 验证菜单栏入口和弹出窗口
3. 验证月份切换、返回今天、日期高亮
4. 验证节假日接口拉取与缓存
5. 再启用 Widget target 验证小组件

## 当前已具备的能力

- SwiftUI 菜单栏应用入口
- 状态栏动态文本/图标显示
- 月历主窗口 UI
- 7×7 日期网格
- 农历/节日/节气文本
- 年度节假日数据远程拉取与本地缓存
- Widget 小/中尺寸骨架

## 后续建议

生成工程后，我可以继续帮你做：

1. 修 UI 到更接近设计图
2. 补资源文件（AppIcon / AccentColor）
3. 增加年份/月切换的完整交互细节
4. 增加 App Group 配置后的 widget 数据联动验证
