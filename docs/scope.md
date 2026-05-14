# Merchant's Road — v0.1 Scope

## VAR (canlı sistemler)
- 3 şehir: Ashford, Ironmere, Stonebridge
- WorldMap: harita, şehir butonları, seyahat, gün döngüsü
- TownUI: market, people, info, contracts sekmeleri
- Cargo limiti: 20 birim
- Day timer + speed control (0/1/2x)
- EconomyManager: production_plan, consumption_rules, season, stock_cap
- ContractManager: procurement & delivery, basic/standard/urgent
- FactionManager: 3 faction, NPC listesi, reputation
- TopBar UI
- TravelRiskManager: bandit attacks, cargo-based risk
- EventManager: random town events (festival, famine, demand surge, bumper crop, plague)
- EconomyManager: prosperity system (invest gold 25:1 → city grows → production/price bonus)
- Investment Limit: Şehir başına günlük max 50 prosperity puanı
- Goal system: Reach Patrician Rank → win
- Caravan upgrade: Donkey Cart (20) → Horse Cart (35) → Small Caravan (50)
- Market Tracking: Ağırlıklı ortalama alış fiyatı takibi ve kâr/zarar göstergesi
- TradingPostManager: Kalıcı depolar (50 stok) ve otomatik alış/satış kuralları (Merchant rank'ta açılır)
- RankManager: 5 rank (Peddler → Patrician). Şartlara göre açılan özellikler (Upgrade, Trading Post, Urgent Contracts).

## YOK (ileride bakılır, şu an yazma)
- 4. ve 5. şehir
- CaravanSystem.gd (paralel sistem, silinecek)
- Dükkân sahipliği (owned_shops)
- Tax sistemi
- NPC ile diyalog
- Black market

## v0.1 HEDEFİ
Oyuncu 400 gold ile başlar (Peddler). Ticaret ve kontratlarla altın ve faction reputation biriktirip rank atlar. Patrician rank'ına ulaştığında oyun biter.
30-45 dk'lık bir oturum içinde tamamlanabilir olmalı.

## v0.1 OUT-OF-SCOPE KARARI
Yeni özellik eklenmeyecek. Mevcut sistemler (market, contract, faction) cilalanacak.
Yeni mekanik isteği geldiğinde bu dosyaya yaz, **hemen kodlama**.

## v0.1 TAMAMLANDI
Tüm temel sistemler kuruldu ve çalışıyor:
- Al-sat döngüsü
- Risk sistemi (bandit saldırıları)
- Event sistemi (5 olay tipi)
- Prosperity sistemi (25 gold : 1 puan, günlük 50 puan sınırı)
- Caravan upgrade
- Goal panel + win condition
- Harita tooltips + cargo panel
- Market UI Cilası: Buy/Sell 1-5-MAX butonları ve kâr/zarar takibi

Oyun zevki testi v0.2'ye ertelendi.
Sebep: "Dünya yaşamıyor" problemi ancak
canlı dünya sistemiyle test edilebilir.

## v0.2 HEDEFİ: Yaşayan Dünya
