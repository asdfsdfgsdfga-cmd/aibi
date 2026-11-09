import 'package:flutter/widgets.dart';

import '../models/exchange.dart';
import '../models/news.dart';

/// 应用文案：English（默认）+ 繁體中文。
class AppStrings {
  final Locale locale;
  const AppStrings(this.locale);

  bool get isZh => locale.languageCode == 'zh';

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings) ??
      const AppStrings(Locale('en'));

  String get appName => isZh ? 'BIAIMX' : 'BIAIMX';

  String get navHome => isZh ? '首頁' : 'Home';

  String get navExchanges => isZh ? '交易所' : 'Exchanges';

  String get navMarkets => isZh ? '行情' : 'Markets';

  String get navNews => isZh ? '資訊' : 'News';

  String get navProfile => isZh ? '我的' : 'Profile';

  String get searchHint => isZh ? '搜尋交易所或幣種' : 'Search exchanges or coins';

  String get searchHintLong => isZh ? '搜尋交易所 / 幣種' : 'Search exchanges / coins';

  String get viewAll => isZh ? '檢視全部' : 'View all';

  String get retry => isZh ? '重試' : 'Retry';

  String get refresh => isZh ? '重新整理' : 'Refresh';

  String get reload => isZh ? '重新載入' : 'Reload';

  String get loading => isZh ? '載入中…' : 'Loading…';

  String get riskTitle => isZh ? '風險提示' : 'Risk notice';

  String get aggregating => isZh ? '正在聚合市場資料…' : 'Aggregating market data…';

  String get featuredExchanges => isZh ? '優選交易所' : 'Top exchanges';

  String get topCoins => isZh ? '熱門幣種' : 'Trending coins';

  String get allMarkets => isZh ? '全部行情' : 'All markets';

  String get industryNews => isZh ? '行業動態' : 'Industry news';

  String get moreNews => isZh ? '更多資訊' : 'More news';

  String get tagline =>
      isZh ? '金融指南 · 理性決策' : 'Financial guide · rational decisions';

  String get marketOverview => isZh ? '市場概覽' : 'Market overview';

  String get high24 => isZh ? '24h 高' : '24h high';

  String get low24 => isZh ? '24h 低' : '24h low';

  String get vol24Short => isZh ? '24h 額' : '24h vol';

  String get riskBannerBody => isZh
      ? '數字資產價格波動劇烈，請勿使用槓桿或借貸資金參與。'
      : 'Digital assets are highly volatile. Avoid trading with leverage or borrowed money.';

  String get riskDisclaimerTitle => isZh ? '風險提示與免責宣告' : 'Risk disclosure';

  String get riskDisclaimerBody => isZh
      ? '1. 本應用展示的交易所評分、行情與資訊僅供參考，不構成投資建議。\n\n2. 數字資產價格波動劇烈，可能導致本金全部損失。請勿使用借貸資金或生活必需資金參與。\n\n3. 交易所的合規狀態、牌照與託管安排會隨時間變化，請以官方披露與當地監管資訊為準。\n\n4. 本應用不提供任何投資建議，也不構成對任何平臺的推薦或背書。'
      : '1. Ratings, prices and news in this app are for reference only and are not investment advice.\n\n2. Digital asset prices are highly volatile and can result in total loss of capital. Never trade with borrowed or essential funds.\n\n3. Compliance status, licences and custody arrangements change over time. Always verify with official disclosures and local regulators.\n\n4. BIAIMX does not provide investment advice and does not endorse any platform.';

  String get exchangesTitle => isZh ? '交易所' : 'Exchanges';

  String get ratingBadge => isZh ? '評級庫' : 'Rating hub';

  String get filterAll => isZh ? '全部' : 'All';

  String get filterTopRated => isZh ? '高評分' : 'Top rated';

  String get filterLowRisk => isZh ? '低風險' : 'Low risk';

  String get filterSpot => isZh ? '現貨' : 'Spot';

  String get filterFutures => isZh ? '合約' : 'Futures';

  String get filterFavorite => isZh ? '已收藏' : 'Saved';

  String get emptyExchanges =>
      isZh ? '該篩選條件下暫無交易所' : 'No exchanges match this filter';

  String get marketsTitle => isZh ? '行情' : 'Markets';

  String get filterGainers => isZh ? '漲幅榜' : 'Gainers';

  String get filterLosers => isZh ? '跌幅榜' : 'Losers';

  String get filterWatchlist => isZh ? '自選' : 'Watchlist';

  String get totalMarketCap => isZh ? '總市值' : 'Market cap';

  String get volume24h => isZh ? '24h 成交額' : '24h volume';

  String get upDown => isZh ? '漲 / 跌' : 'Up / Down';

  String get emptyWatchlist => isZh ? '暫無自選幣種' : 'No saved coins yet';

  String get exchangeDetail => isZh ? '交易所詳情' : 'Exchange details';

  String get loadingExchange => isZh ? '讀取交易所檔案…' : 'Loading exchange profile…';

  String get exchangeNotFound => isZh ? '未找到該交易所' : 'Exchange not found';

  String established(String year) => isZh ? '$year 年成立' : 'Founded $year';

  String get visitSite => isZh ? '訪問官網' : 'Visit website';

  String websiteTitle(String name) => isZh ? '$name 官網' : '$name website';

  String websiteSubtitle(String host) =>
      isZh ? '應用內預覽 · $host' : 'In-app preview · $host';

  String get supportedCoins => isZh ? '支援幣種' : 'Coins listed';

  String get country => isZh ? '註冊地' : 'Registered in';

  String get overallRating => isZh ? '綜合評分' : 'Overall rating';

  String get overallScore => isZh ? '綜合分' : 'Score';

  String get riskLowDesc => isZh
      ? '整體風險可控，仍需注意合規與地區限制'
      : 'Overall risk is manageable, but compliance and regional limits still apply.';

  String get riskMediumDesc => isZh
      ? '存在一定風險，參與前請充分了解產品機制'
      : 'Some risk is present. Understand the product mechanics before trading.';

  String get riskHighDesc => isZh
      ? '風險較高，請謹慎評估自身承受能力'
      : 'High risk. Carefully assess how much you can afford to lose.';

  String get riskTagsNote => isZh
      ? '風險標籤僅供參考，實際風險請以官方披露、監管資訊與獨立盡調為準。'
      : 'Risk tags are for reference only. Verify with official disclosures, regulators and your own due diligence.';

  String get intro => isZh ? '平臺簡介' : 'About';

  String get fees => isZh ? '交易費率' : 'Trading fees';

  String get makerFee => isZh ? '掛單 Maker' : 'Maker';

  String get takerFee => isZh ? '吃單 Taker' : 'Taker';

  String get breakdownSecurity => isZh ? '安全性' : 'Security';

  String get breakdownLiquidity => isZh ? '流動性' : 'Liquidity';

  String get breakdownFees => isZh ? '費率' : 'Fees';

  String get breakdownExperience => isZh ? '體驗' : 'Experience';

  String get breakdownSupport => isZh ? '客服' : 'Support';

  String get riskLow => isZh ? '低風險' : 'Low risk';

  String get riskMedium => isZh ? '中風險' : 'Medium risk';

  String get riskHigh => isZh ? '高風險' : 'High risk';

  String get myRating => isZh ? '我的評分' : 'My rating';

  String get tapToRate => isZh ? '點選星星評分' : 'Tap a star to rate';

  String ratingValue(String value) =>
      isZh ? '你的評分：$value' : 'Your rating: $value';

  String get ratingThanks => isZh ? '感謝你的評分' : 'Thanks for rating';

  String get ratingSaved =>
      isZh ? '評分儲存在本機' : 'Your rating is saved on this device';

  String get ratingUpdated => isZh ? '評分已更新' : 'Rating updated';

  String marketCapWithValue(String value) =>
      isZh ? '市值 $value' : 'Market cap $value';

  String get marketCapLabel => isZh ? '市值' : 'Market cap';

  String get longPressHint => isZh ? '長按檢視明細' : 'Long press for details';

  String coinSummary(String symbol, String change) => isZh
      ? '$symbol 近 24 小時波動 $change。'
      : '$symbol moved $change over the last 24 hours.';

  String get klineDisclaimer => isZh
      ? 'K 線與價格僅供參考，不構成投資建議。'
      : 'Charts and prices are for reference only and are not investment advice.';

  String get newsTitle => isZh ? '資訊' : 'News';

  String get emptyCategory => isZh ? '該分類下暫無資訊' : 'No news in this category';

  String get featured => isZh ? '焦點' : 'Featured';

  String readMinutes(int n) => isZh ? '$n 分鐘閱讀' : '$n min read';

  String get categoryAll => isZh ? '全部' : 'All';

  String get categoryIndustry => isZh ? '行業' : 'Industry';

  String get categoryPolicy => isZh ? '政策' : 'Policy';

  String get categoryExchange => isZh ? '交易所' : 'Exchanges';

  String get categoryProject => isZh ? '專案' : 'Projects';

  String get newsDetail => isZh ? '資訊詳情' : 'Article';

  String get newsNotFound => isZh ? '資訊不存在' : 'Article not found';

  String get newsDisclaimer => isZh
      ? '本文內容僅供參考，不構成投資建議。數字資產投資風險極高，請獨立判斷並謹慎決策。'
      : 'This article is for reference only and is not investment advice. Digital assets are extremely risky — do your own research and decide carefully.';

  String get readMoreNews => isZh ? '繼續閱讀更多行業動態' : 'More industry news';

  String get backToList => isZh ? '返回列表' : 'Back to list';

  String get noResults => isZh ? '沒有找到相關結果' : 'No results found';

  String get exchangesLabel => isZh ? '交易所' : 'Exchanges';

  String get coinsLabel => isZh ? '幣種' : 'Coins';

  String get hotSearches => isZh ? '熱門搜尋' : 'Popular searches';

  String get allExchanges => isZh ? '全部交易所' : 'All exchanges';

  String get favoritesTitle => isZh ? '我的收藏' : 'Favorites';

  String itemsCount(int n) => isZh ? '$n 項' : '$n items';

  String get loadingFavorites => isZh ? '讀取收藏…' : 'Loading favorites…';

  String get savedExchanges => isZh ? '收藏的交易所' : 'Saved exchanges';

  String get savedCoins => isZh ? '自選的幣種' : 'Watchlist coins';

  String get favoritesNote => isZh
      ? '收藏僅儲存在本機，解除安裝應用後會清除。收藏不代表推薦，請獨立判斷平臺風險。'
      : 'Favorites are stored on this device only and are cleared when the app is uninstalled. Saving is not an endorsement — assess platform risk yourself.';

  String favoritesSummary(int exchanges, int coins) => isZh
      ? '已收藏 $exchanges 家交易所 · $coins 個幣種'
      : '$exchanges exchanges · $coins coins saved';

  String get favoritesTapHint => isZh
      ? '點選卡片檢視詳情，點選金色星標可取消收藏'
      : 'Tap a card for details. Tap the gold star to remove.';

  String get emptyFavoritesTitle => isZh ? '還沒有收藏' : 'Nothing saved yet';

  String get emptyFavoritesBody => isZh
      ? '在交易所詳情或幣種詳情頁點選右上角星標，\n即可把關注的平臺和幣種收藏到這裡。'
      : 'Tap the star on an exchange or coin page to save it here.';

  String get backToBrowse => isZh ? '返回繼續瀏覽' : 'Back to browsing';

  String get savedLocally =>
      isZh ? '收藏與偏好儲存在本機' : 'Favorites and preferences stay on this device';

  String get statExchanges => isZh ? '收藏交易所' : 'Saved exchanges';

  String get statCoins => isZh ? '自選幣種' : 'Watchlist';

  String get myExchanges => isZh ? '我的交易所' : 'My exchanges';

  String get emptyMyExchanges => isZh
      ? '還沒有收藏交易所，去交易所頁新增'
      : 'No saved exchanges yet. Add some from Exchanges.';

  String get myCoins => isZh ? '我的自選幣種' : 'My watchlist';

  String get emptyMyCoins => isZh
      ? '還沒有自選幣種，去行情頁新增'
      : 'No watchlist coins yet. Add some from Markets.';

  String get more => isZh ? '更多' : 'More';

  String get about => isZh ? '關於 BIAIMX' : 'About BIAIMX';

  String get privacyTitle => isZh ? '資料與隱私說明' : 'Data & privacy';

  String get privacyBody => isZh
      ? '所有評分、行情、資訊均儲存在本機，不採集、不上傳任何個人資訊。'
      : 'All ratings, prices and news are stored locally. No personal data is collected or uploaded.';

  String get version => isZh ? '版本' : 'Version';

  String get language => isZh ? '語言' : 'Language';

  String get languageEnglish => isZh ? 'English' : 'English';

  String get languageTraditional => isZh ? '繁體中文' : '繁體中文';

  String get aboutBody => isZh
      ? 'BIAIMX 是一款金融指南應用，聚合交易所評級、幣種行情 K 線與行業資訊，幫助使用者更理性地瞭解數字資產市場。\n\nBIAIMX 不提供交易、資金託管或投資建議服務。'
      : 'BIAIMX is a financial guide that brings together exchange ratings, coin charts and industry news, helping people understand digital asset markets more rationally.\n\nBIAIMX does not offer trading, custody or investment advice.';

  String get previewTitle => isZh ? '外部連結預覽' : 'External link';

  String get loadFailed => isZh ? '網頁載入失敗' : 'Failed to load page';

  String get cannotOpenBrowser => isZh
      ? '無法開啟系統瀏覽器，請檢查連結是否有效'
      : 'Couldn\'t open the system browser. Please check the link.';

  String get openInBrowser => isZh ? '在系統瀏覽器開啟' : 'Open in system browser';

  String get unsupportedBody => isZh
      ? '當前環境不支援應用內網頁。\n在手機上會使用內建 WebView 直接開啟，並保持應用內瀏覽。'
      : 'In-app pages aren\'t available in this environment. On mobile, BIAIMX opens links in the built-in browser and keeps you inside the app.';

  String get openInBrowserCta => isZh ? '在瀏覽器中開啟' : 'Open in browser';

  String get regionHint => isZh
      ? '該站點可能受網路或地區限制，可嘗試重新整理或改用系統瀏覽器。'
      : 'This site may be blocked by network or regional restrictions. Try reloading, or open it in your system browser.';

  String get recommended => isZh ? '推薦' : 'Recommended';

  String reviewsShort(int n) => isZh ? '$n 評' : '$n reviews';

  String get footerDisclaimer => isZh
      ? '本應用展示的評分、行情與資訊僅供參考，不構成任何投資建議。數字資產風險極高，請謹慎決策。'
      : 'Ratings, prices and news are for reference only and are not investment advice. Digital assets are extremely risky — decide carefully.';

  String get candleOpen => isZh ? '開' : 'Open';

  String get candleHigh => isZh ? '高' : 'High';

  String get candleLow => isZh ? '低' : 'Low';

  String get candleClose => isZh ? '收' : 'Close';

  String get candleVolume => isZh ? '量' : 'Vol';

  String get timeJustNow => isZh ? '剛剛' : 'Just now';

  String timeMinutesAgo(int n) => isZh ? '$n 分鐘前' : '$n min ago';

  String timeHoursAgo(int n) => isZh ? '$n 小時前' : '$n h ago';

  String timeDaysAgo(int n) => isZh ? '$n 天前' : '$n d ago';

  String get welcomeBack => isZh ? '歡迎回來' : 'Welcome back';

  String welcomeBackBody(int exchanges) =>
      isZh ? '你收藏了 $exchanges 家交易所' : 'You have $exchanges exchanges saved.';

  String get backHome => isZh ? '回到首頁' : 'Back to home';

  String get favoritesPromptLabel => isZh ? '收藏提示' : 'Favorites prompt';

  String reviews(int count) => isZh ? '$count 條評價' : '$count reviews';

  String riskLevelLabel(RiskLevel level) => isZh
      ? switch (level) {
          RiskLevel.low => '低風險',
          RiskLevel.medium => '中風險',
          RiskLevel.high => '高風險',
        }
      : switch (level) {
          RiskLevel.low => 'Low risk',
          RiskLevel.medium => 'Medium risk',
          RiskLevel.high => 'High risk',
        };

  String newsCategoryLabel(NewsCategory category) => isZh
      ? switch (category) {
          NewsCategory.all => '全部',
          NewsCategory.industry => '行業',
          NewsCategory.policy => '政策',
          NewsCategory.exchange => '交易所',
          NewsCategory.project => '專案',
        }
      : switch (category) {
          NewsCategory.all => 'All',
          NewsCategory.industry => 'Industry',
          NewsCategory.policy => 'Policy',
          NewsCategory.exchange => 'Exchanges',
          NewsCategory.project => 'Projects',
        };
}

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'zh';

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}
