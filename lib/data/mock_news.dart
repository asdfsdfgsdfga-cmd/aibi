import '../models/localized_text.dart';
import '../models/news.dart';

/// 本地資訊資料，僅供參考。
List<NewsItem> buildMockNews() {
  final now = DateTime.now();
  NewsItem item({
    required String id,
    required L10nText title,
    required L10nText summary,
    required List<L10nText> content,
    required NewsCategory category,
    required L10nText source,
    required Duration ago,
    required int readMinutes,
    required List<L10nText> tags,
    bool hot = false,
  }) => NewsItem(
    id: id,
    title: title,
    summary: summary,
    content: content,
    category: category,
    source: source,
    publishedAt: now.subtract(ago),
    readMinutes: readMinutes,
    tags: tags,
    hot: hot,
  );

  return [
    item(
      id: 'n1',
      title: L10nText(
        'Institutional inflows continue as market structure shifts',
        '機構資金持續流入，數字資產市場結構悄然變化',
      ),
      summary: L10nText(
        'Spot and derivatives volumes are recovering together, with participation shifting from retail-led to a mix of institutions and professional traders.',
        '現貨與衍生品成交量同步回升，市場參與者結構正從散戶主導向機構與專業交易者並重轉變。',
      ),
      content: [
        L10nText(
          'Digital asset market activity has picked up, with spot and derivatives volumes rising together. Several research desks note that institutions are shifting from directional bets to more complex arbitrage, market making and risk management strategies.',
          '近期數字資產市場整體活躍度回升，現貨與衍生品成交量同步增長。多家研究機構指出，機構資金的參與方式正在發生變化，從單一的方向性交易轉向更複雜的套利、做市與風險管理策略。',
        ),
        L10nText(
          'Derivatives now account for a larger share of open interest, making funding rates and basis moves key sentiment indicators. Analysts warn that higher leverage amplifies price swings, so position sizing and liquidation risk deserve attention.',
          '從市場結構看，衍生品持倉佔比上升，資金費率與基差波動成為觀察市場情緒的重要指標。分析人士提醒，槓桿水平提升會放大價格波動，投資者應關注倉位管理與強平風險。',
        ),
        L10nText(
          'For most users, understanding liquidity, fee structures and risk controls matters more than chasing short-term prices. This article is not investment advice.',
          '對於普通使用者而言，理解交易所的流動性、費率結構與風控機制，比追逐短期價格更重要。以上內容不構成任何投資建議。',
        ),
      ],
      category: NewsCategory.industry,
      source: L10nText('BIAIMX Research', 'BIAIMX 研究'),
      ago: const Duration(minutes: 35),
      readMinutes: 4,
      tags: [
        L10nText('Institutions', '機構'),
        L10nText('Market structure', '市場結構'),
        L10nText('Derivatives', '衍生品'),
      ],
      hot: true,
    ),
    item(
      id: 'n2',
      title: L10nText(
        'Regulatory frameworks advance, compliance becomes the competitive edge',
        '多地監管框架推進，合規化成為交易平臺競爭焦點',
      ),
      summary: L10nText(
        'Licensing, custody and AML requirements keep tightening, and compliance investment is becoming a key selection factor for users.',
        '牌照、託管與反洗錢要求持續細化，交易平臺的合規投入正在成為使用者選擇的重要參考。',
      ),
      content: [
        L10nText(
          'As several jurisdictions advance digital asset frameworks, platforms are spending more on licensing, client asset custody and anti-money laundering. Compliance is moving from a bonus to a baseline.',
          '隨著多個司法轄區推進數字資產監管框架，交易平臺在牌照申請、客戶資產託管與反洗錢方面的投入明顯增加。合規能力逐漸從“加分項”變為“基礎項”。',
        ),
        L10nText(
          'Clearer rules reduce long-term uncertainty, but they also raise operating costs. For users, understanding where a platform is registered, its licences and custody arrangements is a core part of risk assessment.',
          '業內觀點認為，監管明確有助於降低長期不確定性，但也意味著平臺需要承擔更高的運營成本。對使用者而言，瞭解平臺註冊地、牌照資訊與資產託管安排，是評估風險的重要環節。',
        ),
        L10nText(
          'Regulatory details should always be checked against official sources.',
          '本文所涉資訊僅供參考，具體監管要求請以官方釋出為準。',
        ),
      ],
      category: NewsCategory.policy,
      source: L10nText('BIAIMX Insights', 'BIAIMX 觀察'),
      ago: const Duration(hours: 2),
      readMinutes: 5,
      tags: [
        L10nText('Regulation', '監管'),
        L10nText('Compliance', '合規'),
        L10nText('Licences', '牌照'),
      ],
      hot: true,
    ),
    item(
      id: 'n3',
      title: L10nText(
        'Major exchanges launch new Launchpool, focused on infrastructure',
        '主流交易所上線新一期 Launchpool，聚焦基礎設施賽道',
      ),
      summary: L10nText(
        'The latest campaigns centre on on-chain infrastructure projects, with participation through staking designated assets.',
        '新一期活動圍繞鏈上基礎設施專案展開，使用者可通過質押指定資產參與。',
      ),
      content: [
        L10nText(
          'Several platforms recently launched new Launchpool and token sale campaigns, focused on on-chain infrastructure, data services and cross-chain protocols.',
          '多家交易平臺近期上線新一期 Launchpool 與打新活動，專案方向集中在鏈上基礎設施、資料服務與跨鏈協議。',
        ),
        L10nText(
          'Taking part usually means locking platform tokens or stablecoins for a period and bearing price risk while locked. Read the rules, unlock schedule and project background carefully.',
          '參與此類活動通常需要鎖定一定數量的平臺幣或穩定幣，並承擔鎖倉期間的價格波動風險。使用者應仔細閱讀活動規則、解鎖週期與專案背景。',
        ),
        L10nText(
          'For reference only; not a recommendation to participate.',
          '僅供參考，不構成參與建議。',
        ),
      ],
      category: NewsCategory.exchange,
      source: L10nText('BIAIMX News', 'BIAIMX 快訊'),
      ago: const Duration(hours: 4),
      readMinutes: 3,
      tags: [
        L10nText('Launchpool', 'Launchpool'),
        L10nText('Infrastructure', '基礎設施'),
      ],
    ),
    item(
      id: 'n4',
      title: L10nText(
        'Layer 2 activity recovers as fees fall to multi-month lows',
        'Layer 2 生態交易活躍度回升，手續費降至階段低位',
      ),
      summary: L10nText(
        'Competition among rollups is cutting on-chain costs and lifting activity across ecosystem apps.',
        'Rollup 方案競爭加劇，鏈上互動成本下降，帶動生態應用活躍度提升。',
      ),
      content: [
        L10nText(
          'With several Layer 2 networks completing upgrades, on-chain fees have fallen to recent lows and activity across ecosystem apps has recovered.',
          '隨著多家 Layer 2 網路完成升級，鏈上交易手續費降至階段低位，生態內應用活躍度隨之回升。',
        ),
        L10nText(
          'Developers are shifting focus from raw throughput to user experience, interoperability and security. Bridge security remains a persistent industry concern.',
          '開發者關注點正從單純追求吞吐量，轉向使用者體驗、跨鏈互操作與安全性。與此同時，資產跨鏈橋的安全問題仍是行業需要持續關注的焦點。',
        ),
        L10nText('For reference only.', '僅供參考。'),
      ],
      category: NewsCategory.project,
      source: L10nText('BIAIMX Research', 'BIAIMX 研究'),
      ago: const Duration(hours: 6),
      readMinutes: 4,
      tags: [
        L10nText('Layer 2', 'Layer2'),
        L10nText('Rollup', 'Rollup'),
        L10nText('Ecosystem', '生態'),
      ],
    ),
    item(
      id: 'n5',
      title: L10nText(
        'Stablecoin market cap grows steadily as payments accelerate',
        '穩定幣市值穩步增長，支付場景應用加速落地',
      ),
      summary: L10nText(
        'Stablecoins are used more in cross-border payments and settlement, with transparency and reserve disclosure drawing more attention.',
        '穩定幣在跨境支付與結算場景中的使用增加，透明度與儲備披露受到更多關注。',
      ),
      content: [
        L10nText(
          'Total stablecoin market cap keeps growing, with use cases expanding from trading into cross-border payments, settlement and on-chain yield.',
          '穩定幣總市值保持增長態勢，應用場景從交易媒介逐步擴充套件至跨境支付、結算與鏈上理財。',
        ),
        L10nText(
          'Attention to reserve disclosure, audit frequency and redemption mechanics is rising. Transparency and compliance are key when choosing a stablecoin.',
          '市場對穩定幣發行方的儲備披露、審計頻率與贖回機制關注度上升。選擇穩定幣時，透明度與合規性是重要考量。',
        ),
        L10nText('For reference only; not investment advice.', '僅供參考，不構成投資建議。'),
      ],
      category: NewsCategory.industry,
      source: L10nText('BIAIMX Insights', 'BIAIMX 觀察'),
      ago: const Duration(hours: 9),
      readMinutes: 4,
      tags: [
        L10nText('Stablecoins', '穩定幣'),
        L10nText('Payments', '支付'),
        L10nText('Compliance', '合規'),
      ],
    ),
    item(
      id: 'n6',
      title: L10nText(
        'Regulatory sandboxes expand, custody standards in focus',
        '監管沙盒試點擴大，數字資產託管標準受關注',
      ),
      summary: L10nText(
        'Asset segregation, key management and audit processes are the main talking points.',
        '託管分離、私鑰管理與審計流程成為討論重點。',
      ),
      content: [
        L10nText(
          'Some jurisdictions are widening regulatory sandbox pilots, putting digital asset custody standards in focus. Client asset segregation, key management and third-party audits are receiving most attention.',
          '部分地區正在擴大監管沙盒試點範圍，數字資產託管標準成為討論重點。行業普遍關注客戶資產隔離、私鑰管理方案與第三方審計機制。',
        ),
        L10nText(
          'For platforms, a clear custody architecture builds trust; for users, understanding where assets are held and how withdrawals work matters just as much.',
          '對交易平臺而言，清晰的託管架構有助於提升信任度；對使用者而言，瞭解資產存放方式與提現規則同樣重要。',
        ),
        L10nText(
          'Refer to official sources for specific policy details.',
          '具體政策請以官方資訊為準。',
        ),
      ],
      category: NewsCategory.policy,
      source: L10nText('BIAIMX Insights', 'BIAIMX 觀察'),
      ago: const Duration(hours: 12),
      readMinutes: 5,
      tags: [L10nText('Custody', '託管'), L10nText('Sandbox', '監管沙盒')],
    ),
    item(
      id: 'n7',
      title: L10nText(
        'Transparency reports published as proof of reserves becomes standard',
        '交易所透明度報告發布，儲備證明成行業慣例',
      ),
      summary: L10nText(
        'More platforms now publish proof of reserves and security audit results on a regular basis.',
        '越來越多的平臺定期披露儲備證明與安全審計結果。',
      ),
      content: [
        L10nText(
          'Several platforms released transparency reports covering proof of reserves, hot and cold wallet arrangements and security audits. Proof of reserves is becoming an industry norm.',
          '多家交易平臺釋出透明度報告，披露儲備證明、冷熱錢包安排與安全審計結果。儲備證明逐漸成為行業慣例。',
        ),
        L10nText(
          'Note that proof of reserves only reflects assets at a point in time and does not fully cover liabilities or internal controls. Assess platform risk holistically.',
          '需要說明的是，儲備證明只能反映特定時點的資產狀況，並不能完全覆蓋負債與內部控制情況。使用者仍應綜合評估平臺風險。',
        ),
        L10nText('For reference only.', '僅供參考。'),
      ],
      category: NewsCategory.exchange,
      source: L10nText('BIAIMX News', 'BIAIMX 快訊'),
      ago: const Duration(hours: 16),
      readMinutes: 3,
      tags: [
        L10nText('Proof of reserves', '儲備證明'),
        L10nText('Security', '安全'),
        L10nText('Auditing', '審計'),
      ],
    ),
    item(
      id: 'n8',
      title: L10nText(
        'Cross-chain designs iterate as bridge security questioned again',
        '跨鏈互操作方案迭代，資產橋接安全性再受討論',
      ),
      summary: L10nText(
        'New designs add multi-party validation and risk isolation, but bridges remain a prime attack target.',
        '新方案引入多重驗證與風險隔離機制，但跨鏈仍是攻擊高發領域。',
      ),
      content: [
        L10nText(
          'Cross-chain protocols have iterated quickly, with multi-signature validation, light clients and risk isolation becoming common designs.',
          '跨鏈協議近期密集迭代，多籤驗證、輕客戶端與風險隔離成為常見設計。',
        ),
        L10nText(
          'Security researchers note that bridges remain a frequent target. Users should limit single-transaction amounts and check audits and incident history.',
          '安全研究人士指出，跨鏈橋仍然是攻擊高發領域，使用者在使用時應控制單次跨鏈金額，並關注協議審計與歷史安全記錄。',
        ),
        L10nText(
          'For reference only; not a recommendation.',
          '僅供參考，不構成任何操作建議。',
        ),
      ],
      category: NewsCategory.project,
      source: L10nText('BIAIMX Research', 'BIAIMX 研究'),
      ago: const Duration(days: 1, hours: 2),
      readMinutes: 4,
      tags: [L10nText('Cross-chain', '跨鏈'), L10nText('Security', '安全')],
    ),
    item(
      id: 'n9',
      title: L10nText(
        'Derivatives positioning shifts as hedging tools gain demand',
        '衍生品市場持倉結構變化，風險管理工具需求上升',
      ),
      summary: L10nText(
        'Interest in options and hedging strategies is rising; retail users need to understand leverage and liquidation.',
        '期權與對沖策略關注度提升，普通使用者需理解槓桿與強平機制。',
      ),
      content: [
        L10nText(
          'Derivatives positioning is shifting, with growing interest in options, basis trades and hedging strategies.',
          '衍生品市場持倉結構出現變化，期權、基差交易與對沖策略的關注度上升。',
        ),
        L10nText(
          'Leverage magnifies losses as well as gains. Liquidation mechanics, margin ratios and funding rates are basics every user should understand. Beginners should avoid high leverage.',
          '槓桿交易在放大收益的同時也會放大虧損，強平機制、保證金率與資金費率是必須理解的基礎概念。新手應謹慎使用高槓杆。',
        ),
        L10nText('Investing carries risk.', '投資有風險。'),
      ],
      category: NewsCategory.industry,
      source: L10nText('BIAIMX Research', 'BIAIMX 研究'),
      ago: const Duration(days: 1, hours: 6),
      readMinutes: 5,
      tags: [
        L10nText('Derivatives', '衍生品'),
        L10nText('Leverage', '槓桿'),
        L10nText('Risk', '風險'),
      ],
    ),
    item(
      id: 'n10',
      title: L10nText(
        'Platforms revamp fee schedules, market-maker incentives rise',
        '多家平臺最佳化費率體系，做市商激勵持續加碼',
      ),
      summary: L10nText(
        'Fee and rebate competition intensifies, widening the real cost gap between venues.',
        '交易費率與做市返佣競爭加劇，使用者實際成本差異擴大。',
      ),
      content: [
        L10nText(
          'To deepen liquidity, several platforms have adjusted fee schedules and increased market-maker incentives. Rates vary noticeably by VIP tier and volume.',
          '為提升流動性，多家交易平臺調整費率體系並加大對做市商的激勵。不同 VIP 等級與交易量檔位對應的費率差異明顯。',
        ),
        L10nText(
          'Beyond headline fees, consider slippage, depth and withdrawal costs when comparing total trading costs.',
          '使用者在選擇平臺時，除了關注掛牌費率，還應考慮滑點、深度與提現費用等綜合成本。',
        ),
        L10nText('For reference only.', '僅供參考。'),
      ],
      category: NewsCategory.exchange,
      source: L10nText('BIAIMX News', 'BIAIMX 快訊'),
      ago: const Duration(days: 2),
      readMinutes: 3,
      tags: [
        L10nText('Fees', '費率'),
        L10nText('Market making', '做市'),
        L10nText('Liquidity', '流動性'),
      ],
    ),
    item(
      id: 'n11',
      title: L10nText(
        'Tax reporting guidance updated; investors should mind obligations',
        '稅務申報指引更新，投資者需關注合規義務',
      ),
      summary: L10nText(
        'Some jurisdictions updated digital asset tax reporting rules, making record keeping more important.',
        '部分地區更新數字資產稅務申報要求，交易記錄留存變得更加重要。',
      ),
      content: [
        L10nText(
          'Some jurisdictions updated tax reporting guidance for digital assets, clarifying treatment of trading, staking and airdrops.',
          '部分地區更新了數字資產相關稅務申報指引，對交易、質押與空投等行為的稅務處理作出說明。',
        ),
        L10nText(
          'Investors should keep detailed records and consult a local tax professional. This article is not tax or legal advice.',
          '投資者應妥善儲存交易記錄，並諮詢當地專業稅務顧問。本文不構成稅務或法律建議。',
        ),
      ],
      category: NewsCategory.policy,
      source: L10nText('BIAIMX Insights', 'BIAIMX 觀察'),
      ago: const Duration(days: 2, hours: 8),
      readMinutes: 4,
      tags: [L10nText('Tax', '稅務'), L10nText('Compliance', '合規')],
    ),
    item(
      id: 'n12',
      title: L10nText(
        'AI and blockchain convergence draws attention as on-chain data demand grows',
        'AI 與區塊鏈結合受關注，鏈上資料需求增長',
      ),
      summary: L10nText(
        'Data availability and verification are the new focus, with infrastructure projects active.',
        '資料可用性與驗證機制成為新焦點，相關基礎設施專案活躍。',
      ),
      content: [
        L10nText(
          'The intersection of AI and blockchain continues to attract attention, with on-chain data collection, verification and incentive models under discussion.',
          'AI 與區塊鏈結合的方向持續受到關注，鏈上資料採集、驗證與激勵模型成為討論熱點。',
        ),
        L10nText(
          'The sector is early and technical and business models remain uncertain; participants should watch project risk.',
          '行業仍處於早期階段，技術路線與商業模式存在較大不確定性，參與者需注意專案風險。',
        ),
        L10nText('For reference only.', '僅供參考。'),
      ],
      category: NewsCategory.industry,
      source: L10nText('BIAIMX Research', 'BIAIMX 研究'),
      ago: const Duration(days: 3),
      readMinutes: 4,
      tags: [L10nText('AI', 'AI'), L10nText('On-chain data', '鏈上資料')],
    ),
  ];
}
