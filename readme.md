# MacOS 万年历需求文档（PRD）

## 1. 产品概述

开发一款运行在 MacOS 上的万年历应用。应用以系统状态栏工具的形式常驻运行，主界面默认不在桌面显示，用户通过点击状态栏中的图标或文字打开万年历窗口。

## 2. 产品目标

- 提供常驻系统状态栏的万年历查看能力。
- 支持用户按偏好自定义状态栏显示内容。
- 提供清晰直观的公历、农历、节气、节日、休班信息展示。
- 提供与示意图一致的简洁日历弹窗体验。

## 3. 使用场景

- 用户开机后无需手动启动应用，即可在状态栏查看日期信息。
- 用户可直接从状态栏快速查看当天时间、星期、农历信息。
- 用户点击状态栏内容后，可查看当月完整日历，并切换年月。
- 用户可通过日历界面查看节假日、调休日、节气及农历日期。

## 4. 功能需求

### 4.1 开机自启动

1. 应用支持 MacOS 开机自动运行。
2. 系统启动后，应用主界面默认不主动显示。
3. 应用启动后仅在系统状态栏中显示图标或文字。

### 4.2 状态栏显示

状态栏显示内容支持用户自定义，包括以下选项：

1. **显示图标**
   - 勾选后，状态栏只显示图标，不显示文字。
   - 未勾选时，以下文字配置选项才生效。

2. **显示农历**
   - 勾选后，状态栏显示中文农历日期，例如：九月初一。
   - 未勾选时，状态栏显示公历日期，例如：9月1日。

3. **显示时间**
   - 勾选后，状态栏追加显示时间，格式为：xx:xx:xx。

4. **显示星期**
   - 勾选后，状态栏追加显示星期，格式为：周x。

### 4.3 主窗口打开方式

1. 点击状态栏上本软件显示的图标或文字，可弹出万年历主窗口。

## 5. 万年历主窗口需求

### 5.1 整体布局

1. 主窗口分为上下两部分：
   - 顶部为按钮栏。
   - 下部为日历网格区域。
2. 日历区域整体为 7 列 × 7 行布局：
   - 第 1 行为星期表头。
   - 第 2 至第 7 行为日期内容区。

### 5.2 顶部按钮栏

1. 顶部按钮栏背景为蓝色。
2. 顶部按钮栏从左到右依次包括：
   - 年份下拉选择框
   - 上一个日期按钮
   - 当前日期显示区域
   - 下一个日期按钮
   - “返回今天”按钮
3. 年份通过下拉框切换。
4. 月份或日期通过左右箭头切换。
5. 中间区域显示当前选中的日期信息。
6. 当切换年份或月份时，下部日历区域需要同步刷新。
7. 当点击“返回今天”按钮时，下部界面需切换回今天所在的年月，并选中今天对应的日期。

### 5.3 星期表头

1. 星期表头显示为：周日、周一、周二、周三、周四、周五、周六。
2. 周日和周六使用红色文字显示。
3. 周一到周五使用深灰色文字显示。

### 5.4 日期网格展示

1. 日期内容区共显示六行，按周展示日期。
2. 日期内容区需要同时展示：
   - 上月末日期
   - 当月日期
   - 下月初日期
3. 每个日期占据一个独立单元格。

### 5.5 单元格信息结构

每个日期单元格包含以下信息层级：

1. 左上角：状态角标。
2. 中间：公历日期（阿拉伯数字）。
3. 下方：农历日期、节气或节日文字。

具体要求如下：

1. 公历日期使用阿拉伯数字显示，字号较大。
2. 农历日期使用中文显示，字号较小。
3. 若当天为节气日或节日，则下方优先显示节气或节日名称。

### 5.6 休息日与调休日标识

1. 当天为休息日时，单元格左上角显示“休”角标。
2. “休”角标样式为红底白字。
3. 当天为调休上班日时，单元格左上角显示“班”角标。
4. “班”角标样式为灰底白字。
5. 普通日期不显示角标。

### 5.7 颜色与状态规则

1. 当前月份中的周末日期（周日、周六），公历数字使用红色显示。
2. 当前月份中的工作日日期，公历数字使用深色显示。
3. 对于上月末和下月初的日期单元格，公历数字和下方文字均使用浅灰色显示。
4. 非当月日期如果存在节假日或调休信息，仍需显示对应的“休”“班”角标及节日/节气文字。

### 5.8 选中态要求

1. 当前被选中的日期单元格需要有明显高亮效果。
2. 参考示意图，选中单元格使用黄色背景。
3. 选中单元格内的公历日期与下方文字使用白色显示。

### 5.9 视觉层级要求

日期单元格内的视觉优先级应清晰，建议遵循以下层级：

1. 选中背景
2. “休 / 班”角标
3. 公历日期
4. 农历 / 节气 / 节日文字

### 5.10 视觉风格要求

1. 整体界面风格应尽量贴近示意图。
2. 风格需简洁、清晰。
3. 需要符合 MacOS 状态栏应用弹窗的视觉感受。

## 6. 非功能要求

1. 应用运行于 MacOS。
2. 应用需适合作为状态栏常驻工具使用。
3. 主窗口界面需信息清晰、识别成本低。

## 7. 设计参考

以提供的示意图 `2.png` 作为界面视觉与布局参考。

## 8. 交互流程与状态说明

### 8.1 应用启动流程

1. 用户开机后，应用随系统自动启动。
2. 应用启动后不主动展示主窗口。
3. 应用仅在系统状态栏中显示图标或文字信息。
4. 用户可随时通过状态栏入口打开主窗口。

### 8.2 状态栏展示逻辑

1. 当“显示图标”被勾选时：
   - 状态栏仅显示应用图标。
   - 日期、时间、星期等文字不显示。
2. 当“显示图标”未勾选时：
   - 状态栏按配置显示文字内容。
   - “显示农历”决定显示农历日期还是公历日期。
   - “显示时间”决定是否追加时间。
   - “显示星期”决定是否追加星期。

### 8.3 主窗口打开流程

1. 用户点击状态栏中的应用图标或文字。
2. 系统弹出万年历主窗口。
3. 主窗口默认展示当前选中日期所在月份的日历内容。
4. 若无其他选中状态，默认选中今天。

### 8.4 年月切换流程

1. 用户通过年份下拉框切换年份。
2. 用户通过左右箭头切换月份或相邻日期区间。
3. 切换后，顶部日期显示与下部日历网格需同步更新。
4. 切换到新的年月后，界面需保持一个明确的当前选中日期。

### 8.5 返回今天流程

1. 用户点击“返回今天”按钮。
2. 界面立即跳转到今天所在的年月。
3. 今天对应的日期单元格进入选中态。
4. 顶部中间日期显示同步更新为今天的信息。

### 8.6 日期选中状态

1. 任意时刻仅允许存在一个选中的日期单元格。
2. 当前选中单元格需有显著高亮背景。
3. 选中单元格中的文字颜色需与普通状态明显区分。
4. 当用户切换年月或返回今天时，选中状态需同步更新。

### 8.7 日期显示状态说明

1. **当月普通工作日**
   - 公历数字使用深色显示。
   - 下方显示农历、节气或节日。
2. **当月周末**
   - 公历数字使用红色显示。
   - 下方仍显示农历、节气或节日。
3. **休息日**
   - 左上角显示“休”角标。
4. **调休上班日**
   - 左上角显示“班”角标。
5. **非当月日期**
   - 公历数字与下方文字统一使用浅灰色显示。
   - 如有节假日或调休信息，仍需显示角标与对应文字。
6. **选中日期**
   - 单元格背景高亮。
   - 公历与下方文字转为高对比色显示。

## 9. 开发任务拆解

### 9.1 状态栏应用能力

1. 实现 MacOS 状态栏常驻入口。
2. 实现应用开机自启动能力。
3. 实现状态栏图标显示。
4. 实现状态栏文字内容拼接与刷新逻辑。
5. 实现状态栏配置项保存与读取。

### 9.2 日期与历法数据能力

1. 实现公历日期计算。
2. 实现农历日期转换。
3. 实现星期信息生成。
4. 实现节气、节日信息映射。
5. 实现休息日、调休日数据支持。
6. 实现当月视图所需的上月末、本月、下月初日期补齐逻辑。

### 9.3 主窗口与交互能力

1. 实现点击状态栏后弹出主窗口。
2. 实现顶部按钮栏布局。
3. 实现年份下拉切换能力。
4. 实现左右切换按钮交互。
5. 实现“返回今天”按钮交互。
6. 实现日期单元格选中态切换。
7. 实现日历网格刷新逻辑。

### 9.4 界面展示能力

1. 实现星期表头展示与周末配色。
2. 实现日期单元格三层信息展示。
3. 实现节气/节日优先显示逻辑。
4. 实现“休 / 班”角标展示样式。
5. 实现非当月日期灰显样式。
6. 实现选中单元格高亮样式。
7. 实现整体界面贴近设计示意图的视觉风格。

### 9.5 配置与状态管理

1. 管理状态栏显示配置。
2. 管理当前展示年月状态。
3. 管理当前选中日期状态。
4. 管理主窗口显示/隐藏状态。
5. 确保状态切换后界面与显示内容同步刷新。

### 9.6 测试与验收建议

1. 验证开机后应用是否自动启动。
2. 验证状态栏图标模式与文字模式是否切换正常。
3. 验证农历、公历、时间、星期显示组合是否正确。
4. 验证年份切换、左右切换、返回今天是否正确刷新界面。
5. 验证日期网格是否始终保持 7 列 × 7 行结构。
6. 验证周末、节日、节气、休班、非当月日期样式是否正确。
7. 验证选中态是否唯一且样式明显。

## 10. 技术解决方案

### 10.1 技术栈选型

1. 开发语言建议使用 **Swift**。
2. 界面层建议使用 **SwiftUI** 实现。
3. 状态栏入口建议优先使用 **SwiftUI MenuBarExtra**。
4. 如遇到状态栏弹窗控制、窗口行为或兼容性限制，可通过 **AppKit** 进行补充，例如结合 `NSStatusItem`、`NSPopover`、`NSWindow` 做能力扩展。
5. 日期计算、格式化、本地化能力建议优先基于 **Foundation** 提供的 `Date`、`Calendar`、`DateComponents`、`DateFormatter` 实现。

### 10.2 总体架构方案

建议采用分层架构，降低界面、数据和系统能力之间的耦合。

建议拆分为以下模块：

1. **MenuBar 模块**
   - 负责状态栏图标/文字展示。
   - 负责点击后弹出主窗口。
   - 负责状态栏展示内容刷新。

2. **Calendar UI 模块**
   - 负责顶部工具栏与日历网格展示。
   - 负责日期选中、年月切换、返回今天等交互。

3. **Calendar Engine 模块**
   - 负责公历月份数据生成。
   - 负责生成 7 × 7 日历展示结构。
   - 负责补齐上月末、本月、下月初日期。

4. **Lunar / Festival 模块**
   - 负责农历日期转换。
   - 负责节气、传统节日、公历节日计算或映射。

5. **Holiday Service 模块**
   - 负责获取当年的法定节假日与调休数据。
   - 负责本地缓存、远程同步与数据解析。

6. **Settings 模块**
   - 负责用户配置读写。
   - 负责状态栏展示选项持久化。

### 10.3 状态栏与窗口实现方案

1. 应用以状态栏应用形态运行，主窗口默认不在 Dock 中主动展示。
2. 状态栏入口支持两种展示模式：
   - 图标模式
   - 文字模式
3. 当用户关闭“显示图标”后，状态栏文字由以下数据动态拼接：
   - 公历日期或农历日期
   - 时间
   - 星期
4. 状态栏文字应支持按秒或按分钟刷新，至少保证时间展示准确。
5. 点击状态栏入口后，弹出万年历主窗口。
6. 主窗口建议使用 SwiftUI 视图实现，顶部栏和日期网格由统一状态驱动刷新。

### 10.4 日历数据生成方案

1. 公历日期数据使用 `Calendar(identifier: .gregorian)` 生成。
2. 月视图生成逻辑如下：
   - 计算当前展示年月的第一天是星期几。
   - 计算当前月总天数。
   - 向前补齐上月末日期。
   - 向后补齐下月初日期。
   - 最终输出固定 42 个日期单元，用于填满 6 行日期区域。
3. 每个日期单元建议统一抽象为结构化数据对象，至少包含以下字段：
   - `date`
   - `isCurrentMonth`
   - `isSelected`
   - `isWeekend`
   - `solarText`
   - `lunarText`
   - `holidayMarker`
   - `festivalText`

### 10.5 农历、节气与节日实现方案

1. 农历日期建议优先基于系统日历能力实现，可评估 `Calendar(identifier: .chinese)` 满足基础农历转换需求。
2. 若系统能力无法完整满足节气、传统节日或显示规则要求，可引入独立的农历/节气计算库，统一封装在 `Lunar / Festival` 模块中，对界面层屏蔽实现细节。
3. 节日展示建议分三类处理：
   - **公历节日**：通过固定月日映射。
   - **农历节日**：通过农历月日映射。
   - **节气**：通过计算结果或节气数据表映射。
4. 日期下方展示文案优先级建议如下：
   - 节日
   - 节气
   - 农历日期

### 10.6 节假日与调休数据方案

#### 10.6.1 数据来源原则

1. 中国大陆法定节假日与调休安排以 **国务院办公厅每年发布的节假日安排通知** 为准。
2. 国务院官方公告是权威来源，但通常不直接提供稳定的机器可读 REST API。
3. 技术实现上建议采用：
   - **官方公告作为权威依据**
   - **第三方机读 JSON 数据源作为程序拉取接口**
   - **本地缓存/内置数据作为离线兜底**

#### 10.6.2 推荐接口方案

推荐优先使用按年份返回 JSON 的静态数据接口。

主接口建议：

`GET https://cdn.jsdelivr.net/gh/NateScarlet/holiday-cn@master/{year}.json`

示例：

`GET https://cdn.jsdelivr.net/gh/NateScarlet/holiday-cn@master/2026.json`

该接口的特点：

1. 按年份获取节假日数据。
2. 数据来源跟随国务院节假日安排更新。
3. 无需 API Key，接入简单。
4. 适合本项目按“年度拉取 + 本地缓存”的方式使用。

可选备用接口：

`GET https://timor.tech/api/holiday/year/{year}`

备用接口适用于以下场景：

1. 主接口访问失败。
2. 需要更丰富的字段信息。
3. 后续需支持服务端代理或多数据源容灾。

#### 10.6.3 接口调用时机

1. 应用首次启动时，读取当前年份，例如 2026。
2. 若本地不存在该年份的节假日缓存，则主动发起接口请求。
3. 若本地已存在缓存，可先使用本地缓存，再异步检查远端是否有更新。
4. 当用户切换到其他年份时，如本地无对应年份数据，则按需拉取该年份数据。
5. 建议在每次应用启动时执行一次轻量更新检查。

#### 10.6.4 本地缓存策略

1. 节假日与调休数据建议缓存到本地文件或数据库中。
2. 缓存粒度建议按年份存储，例如：
   - `holiday_2025.json`
   - `holiday_2026.json`
3. 应用安装包中建议内置当前年与下一年的默认节假日数据，以保证离线可用。
4. 当远程接口不可用时，界面应继续使用本地缓存数据，不影响基础日历展示。

#### 10.6.5 数据字段映射方案

以按年份返回的节假日 JSON 为例，建议在应用内部统一转换为以下结构：

```json
{
  "date": "2026-01-01",
  "name": "元旦",
  "isOffDay": true,
  "isWorkdayOverride": false
}
```

应用内部可进一步抽象为：

- `date`: 日期
- `name`: 节假日或调休说明
- `type`: `holiday` / `workday`

字段转换逻辑建议如下：

1. 当接口返回日期存在，且表示该日为放假日时：
   - 标记为 `holiday`
   - UI 左上角显示“休”
2. 当接口返回日期存在，且表示该日为调休上班日时：
   - 标记为 `workday`
   - UI 左上角显示“班”
3. 若接口未返回该日期：
   - 不显示“休/班”角标
   - 周末仅按周末配色处理，不自动显示“休”

#### 10.6.6 节假日查询流程

建议流程如下：

1. 进入应用或切换年份时，得到目标年份 `year`。
2. 先读取本地缓存：`holiday_{year}.json`。
3. 若缓存存在，先完成界面渲染。
4. 后台请求远程接口：`GET /{year}.json`。
5. 请求成功后解析并覆盖本地缓存。
6. 刷新对应年份所有日期单元格的“休 / 班”状态。
7. 若请求失败，则继续使用本地缓存或空数据运行。

伪代码示例：

```swift
func loadHolidayData(for year: Int) async -> [HolidayItem] {
    if let cached = loadLocalHolidayFile(year: year) {
        Task {
            let remote = try? await fetchHolidayFile(year: year)
            if let remote {
                saveLocalHolidayFile(year: year, data: remote)
            }
        }
        return cached
    }

    if let remote = try? await fetchHolidayFile(year: year) {
        saveLocalHolidayFile(year: year, data: remote)
        return remote
    }

    return []
}
```

### 10.7 配置与状态管理方案

1. 配置项建议使用 `UserDefaults` 持久化。
2. 至少保存以下配置：
   - 是否显示图标
   - 是否显示农历
   - 是否显示时间
   - 是否显示星期
3. 运行时状态建议集中管理以下内容：
   - 当前展示年月
   - 当前选中日期
   - 当前状态栏显示文本
   - 当前年份节假日数据
4. 推荐使用 MVVM 模式管理界面状态与业务逻辑。

### 10.8 错误处理与降级策略

1. 节假日接口请求失败时，不应导致应用不可用。
2. 当远程节假日数据获取失败时：
   - 优先使用本地缓存
   - 无缓存时仅显示基础日历内容，不显示“休 / 班”角标
3. 农历或节气计算异常时，界面至少保证公历日期正常显示。
4. 状态栏刷新异常时，不应影响主窗口展示。

### 10.9 推荐开发顺序

1. 先完成状态栏应用骨架与主窗口弹出能力。
2. 再完成公历月视图与 7 × 7 网格生成。
3. 然后补充农历、节气、节日展示能力。
4. 接着接入年度节假日与调休查询接口。
5. 最后完善缓存、配置管理、异常处理与样式细节。

## 11. 接口与数据结构定义

### 11.1 节假日远程接口定义

主接口：

`GET https://cdn.jsdelivr.net/gh/NateScarlet/holiday-cn@master/{year}.json`

请求参数：

1. `year`：目标年份，例如 `2026`。

请求示例：

`GET https://cdn.jsdelivr.net/gh/NateScarlet/holiday-cn@master/2026.json`

预期返回结构示意：

```json
{
  "year": 2026,
  "papers": [
    "https://www.gov.cn/..."
  ],
  "days": [
    {
      "name": "元旦",
      "date": "2026-01-01",
      "isOffDay": true
    },
    {
      "name": "元旦后补班",
      "date": "2026-01-04",
      "isOffDay": false
    }
  ]
}
```

字段说明：

1. `year`：年份。
2. `papers`：对应国务院或权威来源文件链接列表。
3. `days`：该年份内需要特殊标识的日期集合。
4. `name`：节假日或调休名称。
5. `date`：日期，格式为 `yyyy-MM-dd`。
6. `isOffDay`：
   - `true` 表示休息日
   - `false` 表示调休上班日

### 11.2 应用内部节假日模型

建议在应用内部统一抽象节假日数据模型，避免 UI 直接依赖第三方接口结构。

Swift Model 示例：

```swift
struct HolidaySourceResponse: Codable {
    let year: Int
    let papers: [String]?
    let days: [HolidaySourceDay]
}

struct HolidaySourceDay: Codable {
    let name: String
    let date: String
    let isOffDay: Bool
}

enum HolidayType: String, Codable {
    case holiday
    case workday
}

struct HolidayItem: Codable, Identifiable {
    var id: String { date }
    let date: String
    let name: String
    let type: HolidayType
}
```

转换规则：

1. 当 `isOffDay == true` 时，映射为 `HolidayType.holiday`。
2. 当 `isOffDay == false` 时，映射为 `HolidayType.workday`。

### 11.3 日历单元格数据模型

建议将日历视图每个格子的展示信息统一为 ViewModel 或 DTO。

Swift Model 示例：

```swift
struct CalendarDayItem: Identifiable {
    let id: String
    let date: Date
    let solarText: String
    let lunarText: String
    let festivalText: String?
    let isCurrentMonth: Bool
    let isWeekend: Bool
    let isSelected: Bool
    let holidayType: HolidayType?
}
```

字段说明：

1. `solarText`：公历日期显示文本，例如 `3`。
2. `lunarText`：农历显示文本，例如 `十六`。
3. `festivalText`：节气或节日显示文本。
4. `isCurrentMonth`：是否属于当前展示月份。
5. `isWeekend`：是否为周末。
6. `isSelected`：是否为当前选中日期。
7. `holidayType`：是否为休息日或调休上班日。

### 11.4 用户配置数据模型

状态栏配置建议统一封装，便于持久化和恢复。

Swift Model 示例：

```swift
struct MenuBarDisplaySettings: Codable {
    let showIcon: Bool
    let showLunar: Bool
    let showTime: Bool
    let showWeekday: Bool
}
```

### 11.5 本地缓存文件结构建议

建议按年份缓存节假日文件，并保留统一目录。

示例：

```text
Application Support/
└── LunaCalendar/
    └── holidays/
        ├── holiday_2025.json
        └── holiday_2026.json
```

本地缓存 JSON 建议结构：

```json
{
  "year": 2026,
  "updatedAt": "2026-01-01T12:00:00Z",
  "items": [
    {
      "date": "2026-01-01",
      "name": "元旦",
      "type": "holiday"
    },
    {
      "date": "2026-01-04",
      "name": "元旦后补班",
      "type": "workday"
    }
  ]
}
```

## 12. 工程目录结构设计

### 12.1 推荐目录结构

```text
LunaCalendar/
├── App/
│   ├── LunaCalendarApp.swift
│   ├── AppDelegate.swift
│   └── AppEnvironment.swift
├── Features/
│   ├── MenuBar/
│   │   ├── MenuBarScene.swift
│   │   ├── MenuBarViewModel.swift
│   │   └── MenuBarFormatter.swift
│   ├── Calendar/
│   │   ├── Views/
│   │   │   ├── CalendarWindowView.swift
│   │   │   ├── CalendarToolbarView.swift
│   │   │   ├── CalendarGridView.swift
│   │   │   └── CalendarDayCellView.swift
│   │   ├── ViewModels/
│   │   │   └── CalendarViewModel.swift
│   │   └── Models/
│   │       └── CalendarDayItem.swift
│   └── Settings/
│       ├── SettingsStore.swift
│       └── MenuBarDisplaySettings.swift
├── Services/
│   ├── CalendarEngine/
│   │   └── CalendarEngine.swift
│   ├── Lunar/
│   │   ├── LunarService.swift
│   │   └── FestivalService.swift
│   ├── Holiday/
│   │   ├── HolidayService.swift
│   │   ├── HolidayAPIClient.swift
│   │   ├── HolidayCacheStore.swift
│   │   └── Models/
│   │       ├── HolidaySourceResponse.swift
│   │       └── HolidayItem.swift
│   └── System/
│       ├── LaunchAtLoginService.swift
│       └── StatusBarService.swift
├── Resources/
│   ├── Assets.xcassets
│   └── Seed/
│       ├── holiday_2025.json
│       └── holiday_2026.json
├── Shared/
│   ├── Extensions/
│   ├── Utils/
│   └── Constants/
└── Tests/
    ├── UnitTests/
    └── SnapshotTests/
```

### 12.2 目录职责说明

1. `App/`
   - 存放应用入口、生命周期、全局环境装配。

2. `Features/`
   - 按功能拆分界面与交互逻辑。
   - 包含 MenuBar、Calendar、Settings 等业务模块。

3. `Services/`
   - 存放纯业务能力、系统能力和远程数据能力。
   - 便于 UI 层复用与单元测试。

4. `Resources/`
   - 存放图标、颜色资源、默认节假日种子数据。

5. `Shared/`
   - 存放通用扩展、工具类、常量定义。

6. `Tests/`
   - 存放单元测试、快照测试或视图测试。

### 12.3 模块依赖建议

1. `Features` 依赖 `Services` 与 `Shared`。
2. `Services` 不依赖 `Features`。
3. 节假日接口、缓存和数据转换逻辑集中在 `Services/Holiday` 中。
4. Calendar UI 不直接依赖第三方接口返回结构，只依赖内部统一模型。

## 13. MVP 范围定义

### 13.1 MVP 目标

第一版目标是在 MacOS 上交付一个可用的状态栏万年历应用，满足基础查看、切换和节假日展示能力。

### 13.2 MVP 必做范围

1. 支持应用开机自启动。
2. 支持应用在状态栏常驻。
3. 支持状态栏图标模式与文字模式切换。
4. 支持状态栏显示公历/农历、时间、星期的基础组合。
5. 支持点击状态栏打开万年历主窗口。
6. 支持顶部栏的年份切换、左右切换、返回今天。
7. 支持 7 × 7 日历网格展示。
8. 支持上月末、本月、下月初日期补齐。
9. 支持公历日期、农历日期展示。
10. 支持节气/节日优先显示。
11. 支持周末高亮、非当月灰显。
12. 支持“休 / 班”标记展示。
13. 支持按年份拉取节假日与调休数据。
14. 支持本地缓存节假日数据。
15. 支持选中态高亮。

### 13.3 MVP 可延后范围

以下内容可放入后续版本，不阻塞首版上线：

1. 节假日数据的多源容灾切换。
2. 手动触发“检查节假日更新”入口。
3. 更复杂的动画与弹窗转场效果。
4. 更丰富的设置页面与高级配置项。
5. 多语言支持。
6. iCloud 或跨设备配置同步。
7. 节假日说明详情页或日期详情面板。

### 13.4 MVP 验收标准

1. 安装后可正常驻留状态栏。
2. 可按需求显示图标或文字。
3. 点击状态栏可打开日历窗口。
4. 日历窗口可正确展示当月及前后补齐日期。
5. 农历、节气、节日显示正确。
6. 节假日与调休接口接入成功，能正确显示“休 / 班”。
7. 断网情况下，如本地已有缓存，仍可正常显示节假日标记。
8. 返回今天、切换年份、切换月份行为正常。

## 14. Widget 实现设计

### 14.1 设计目标

在现有 MacOS 状态栏万年历应用之外，增加系统 Widget（小组件）能力，用于在桌面或通知中心中快速展示日期信息，提升用户无需打开主窗口时的可见性与使用效率。

Widget 设计目标如下：

1. 展示当天核心日期信息。
2. 展示农历、星期、节气/节日、节假日/调休状态。
3. 与主应用保持数据一致。
4. 尽量减少资源消耗，符合 WidgetKit 的刷新限制。

### 14.2 技术方案选型

1. Widget 建议使用 **WidgetKit + SwiftUI** 实现。
2. Widget 作为独立 Extension 存在，与主应用分开构建和发布。
3. Widget 展示层使用 SwiftUI 视图。
4. Widget 数据来源通过 **App Group** 与主应用共享。

### 14.3 Widget 形态规划

建议首期支持以下 Widget 形态：

1. **小尺寸 Widget**
   - 展示当天公历日期。
   - 展示农历日期。
   - 展示星期。
   - 展示节日或节气。

2. **中尺寸 Widget**
   - 展示当天日期信息。
   - 展示当月简化日历视图。
   - 高亮今天。
   - 标识“休 / 班”状态。

3. **大尺寸 Widget（可选）**
   - 展示更完整的月历视图。
   - 展示更多节日/节气信息。
   - 可作为后续版本扩展，不强制纳入 MVP。

### 14.4 Widget 展示内容设计

#### 14.4.1 小尺寸 Widget

建议展示以下内容：

1. 当前日期数字。
2. 当前年月。
3. 星期信息。
4. 农历日期。
5. 节气或节日（若有）。
6. 当天为休息日或调休时，显示“休 / 班”标记。

#### 14.4.2 中尺寸 Widget

建议展示以下内容：

1. 顶部显示当前年月。
2. 中部显示简化月历网格。
3. 高亮当天日期。
4. 当月周末使用差异化颜色。
5. 休息日和调休日显示“休 / 班”标记。
6. 下方可显示当天农历或节日摘要。

### 14.5 Widget 与主应用的数据共享设计

1. Widget 不应直接依赖主应用运行时内存状态。
2. 主应用与 Widget 通过 **App Group 容器**共享配置和缓存数据。
3. 建议共享以下数据：
   - 状态栏显示配置中的通用偏好（如是否显示农历）
   - 当年节假日与调休缓存数据
   - 当天或当前月所需的预计算展示数据
4. 共享数据可存储在以下位置：
   - `UserDefaults(suiteName:)`
   - App Group 共享目录文件

### 14.6 Widget 数据流设计

建议数据流如下：

1. 主应用启动后，完成节假日数据拉取与本地缓存。
2. 主应用将最新节假日缓存写入 App Group 共享目录。
3. Widget 在 `TimelineProvider` 中读取共享数据。
4. Widget 结合系统当前日期生成当天或当月展示模型。
5. 当主应用完成数据更新后，可触发 Widget 刷新。

### 14.7 Widget 时间线与刷新策略

1. Widget 使用 `TimelineProvider` 或 `AppIntentTimelineProvider` 提供数据。
2. 刷新策略建议如下：
   - 到整点或零点时刷新日期展示。
   - 当节假日缓存更新后，主动触发刷新。
   - 避免高频刷新，遵守 WidgetKit 限制。
3. 对于日期类应用，建议至少保证以下刷新节点：
   - 每日 00:00 后刷新
   - 应用更新节假日缓存后刷新

可通过以下方式触发刷新：

```swift
WidgetCenter.shared.reloadAllTimelines()
```

或按 Widget Kind 精确刷新：

```swift
WidgetCenter.shared.reloadTimelines(ofKind: "LunaCalendarWidget")
```

### 14.8 Widget 数据模型建议

Widget 内部建议定义独立展示模型，避免直接复用主应用复杂 ViewModel。

Swift Model 示例：

```swift
struct CalendarWidgetEntry: TimelineEntry {
    let date: Date
    let displayDateText: String
    let displayMonthText: String
    let weekdayText: String
    let lunarText: String
    let festivalText: String?
    let holidayType: HolidayType?
    let monthGrid: [CalendarDayItem]
}
```

字段建议：

1. `displayDateText`：当天公历日期大字。
2. `displayMonthText`：当前年月。
3. `weekdayText`：星期。
4. `lunarText`：农历文本。
5. `festivalText`：节气或节日文本。
6. `holidayType`：休息日或调休状态。
7. `monthGrid`：中尺寸或大尺寸 Widget 使用的简化月历数据。

### 14.9 Widget 目录结构建议

建议在工程中增加独立 Widget Extension：

```text
LunaCalendar/
├── WidgetExtension/
│   ├── LunaCalendarWidgetBundle.swift
│   ├── LunaCalendarWidget.swift
│   ├── Providers/
│   │   └── CalendarWidgetTimelineProvider.swift
│   ├── Views/
│   │   ├── SmallCalendarWidgetView.swift
│   │   └── MediumCalendarWidgetView.swift
│   ├── Models/
│   │   └── CalendarWidgetEntry.swift
│   └── Shared/
│       └── WidgetDataLoader.swift
```

### 14.10 Widget 能力边界与限制

1. Widget 不适合承载复杂实时交互。
2. Widget 不应依赖秒级刷新。
3. Widget 不适合完整替代主应用月历窗口。
4. Widget 更适合作为“信息快览入口”，而非完整操作入口。
5. 如果需要复杂交互，建议通过点击 Widget 跳转主应用处理。

### 14.11 Widget 点击跳转设计

1. 用户点击 Widget 后，建议跳转到主应用。
2. 跳转后可定位到：
   - 今天所在月份
   - 当前选中日期
   - 对应日期详情（若后续扩展支持）
3. 跳转参数可通过 URL Scheme 或 App Intent 传递。

示例：

```text
luna-calendar://open?date=2026-04-03
```

### 14.12 Widget MVP 建议范围

首版 Widget 建议纳入以下能力：

1. 小尺寸 Widget。
2. 中尺寸 Widget。
3. 当天公历、农历、星期展示。
4. 节气/节日展示。
5. “休 / 班”标识展示。
6. 点击后唤起主应用。

以下内容建议后续版本再做：

1. 大尺寸完整月历 Widget。
2. 可配置 Widget 展示样式。
3. 多种主题皮肤。
4. 更复杂的交互式 Widget 行为。
