# BIAIMX

BIAIMX 是一款用 Flutter 编写的金融指南 App，聚合主流数字资产交易所信息、行情 K 线、评级与风险提示，帮助用户在进入市场前做出更理性的判断。应用支持 English（默认）与繁體中文，可在「我的 → 语言」中切换，选择结果保存在本机。

> 当前版本使用本地内置数据，行情、评分与资讯仅供参考，不构成任何投资建议。

## 功能

| 模块 | 说明 |
| --- | --- |
| 首页 | 市场概况卡片、风险提示横幅、优选交易所、热门币种、行业动态 |
| 交易所 | 30 家交易所列表，支持「全部 / 高评分 / 低风险 / 现货 / 合约 / 已收藏」筛选，展示评分、风险等级与 24h 成交额 |
| 交易所详情 | 综合评分与五维评分拆解（安全性、流动性、费率、体验、客服）、点击星星为本平台打分（保存在本机）、风险提示与风险标签、平台简介、标签、交易费率、支持币种 |
| 行情 | 币种列表（币安 / 火币公开接口的实时价格、涨跌幅、迷你走势图）、市值 / 24h 成交额概览、涨跌榜与筛选、下拉刷新 |
| 币种详情 | 自绘 K 线图（K 线来自币安 / 火币公开接口）：蜡烛、成交量、MA5/MA10/MA20 均线、触摸十字光标；15m/1h/4h/1D 周期切换；24h 高低/成交额/市值 |
| 资讯 | 行业动态列表，按「行业 / 政策 / 交易所 / 项目」分类，含 HOT 标记与阅读时长 |
| 资讯详情 | 正文、标签、免责声明、相关推荐 |
| 搜索 | 交易所与币种联合搜索，支持热门搜索词与历史记录 |
| 我的 | 自选交易所 / 自选币种、语言切换（English / 繁體中文）、风险提示与免责声明、关于、数据与隐私、版本信息 |
| 我的收藏 | 集中查看收藏的交易所与自选币种，可直接取消收藏、进入详情 |
| 外链 WebView | 交易所官网在应用内 WebView 打开，带加载进度、刷新、系统浏览器跳转与失败重试 |
| 收藏提醒 | 收藏会写入本地缓存；再次打开 App 时若检测到收藏，弹出模糊背景提示，可一键直达收藏页或回到首页 |

其他细节：深色金融风主题、自选收藏（Provider 全局状态 + `shared_preferences` 持久化）、风险等级配色、K 线十字光标、统一的空态与加载态、桌面浏览器下自动限制为手机宽度预览。

## 运行

```bash
cd biaimx
flutter pub get

# 移动端 / 桌面
flutter run

# Web 预览（浏览器里以 430px 手机宽度居中显示）
flutter run -d chrome

# 产物构建
flutter build apk --release
flutter build ios --release
flutter build web --release
```

## 技术栈

- Flutter 3.47 / Dart 3.13
- 状态管理：`provider`
- 多语言：`flutter_localizations` + 自建 `AppStrings`（English / 繁體中文，默认 English）
- 本地缓存：`shared_preferences`（收藏、评分、语言）
- 应用内外链：`webview_flutter`（Android / iOS / macOS），`url_launcher`（Web 与系统浏览器回退）
- K 线：`CustomPainter` 手绘，无第三方图表依赖
- 行情数据：币安 / 火币公开 REST 接口（无需 API Key），并发请求取最快结果，失败时回退内置数据；K 线按周期按需拉取
- 数据层：`Repository` 单例缓存 + 本地数据兜底（`lib/data/`），替换数据源只需改这一层

## 目录结构

```
lib/
├── main.dart                # 入口（恢复收藏缓存后启动）
├── app.dart                 # MaterialApp、主题、Web 手机宽度预览
├── models/                  # Exchange / Coin / Candle / News 数据模型与双语文案（L10nText）
├── data/                    # 本地数据、Repository 与币安 / 火币行情接口
├── state/                   # AppState（自选收藏 + 本地持久化）
├── screens/                 # 首页、交易所、行情、资讯、搜索、收藏、WebView、我的
├── widgets/                 # K 线图、交易所卡片、币种行、新闻卡片、通用 UI
├── l10n/                    # AppStrings：English / 繁體中文文案
├── theme/                   # 深色主题与配色
└── utils/                   # 价格 / 市值 / 时间格式化

assets/branding/logo.png     # 品牌徽标（应用内 BrandMark 与启动图标同源）
```

## 接入真实数据

币种行情已经接入免费的公开接口，代码位于 `lib/data/live_market_feed.dart`：

- 行情：优先 `data-api.binance.vision` / `api.binance.com` 的 `/api/v3/ticker/24hr`，失败后请求火币 `/market/tickers`。
- K 线：`/api/v3/klines` 或火币 `/market/history/kline`，支持 15m / 1h / 4h / 1d。
- 每次刷新只请求 App 内展示的 10 个 USDT 交易对；接口全部不可用时由 `Repository` 回退到 `lib/data/mock_coins.dart`，页面不会空白。

`Repository` 目前对交易所数据、币种行情与 K 线都做了内存缓存，并保留统一的数据源标记（`coinsFromRemote` / `coinSource` / `lastCoinError`），方便界面或日志排查当前是否在用实时数据。新闻仍使用 `lib/data/mock_news.dart`。

交易所列表则通过 `ExchangeFeed` 拉取远端 JSON 并回退 CSV，接入其他后端时同样只需替换 `Repository` 内部实现。

## 声明

展示的评分、行情与资讯仅供参考，不构成任何投资建议。数字资产价格波动剧烈，请勿使用杠杆或借贷资金参与。
