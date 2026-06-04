# Design Index

Bu klasör oyunun tasarım kararlarını, açık sorularını ve çelişkilerini tutar.
Her dosya bir konuya odaklanır. Kodlama kararları için `docs/architecture.md`, mekanik detaylar için `docs/mechanics.md`.

## Dosyalar

| Dosya | Konu |
|-------|------|
| [economy.md](economy.md) | Fiyat sistemi, üretim/tüketim dengesi, piyasa davranışı |
| [progression.md](progression.md) | Rank sistemi, unlock kapıları, oyun temposu |
| [factions.md](factions.md) | Faksiyon, NPC ilişkileri, reputasyon mekaniğinin genişlemesi |
| [world.md](world.md) | Kasabalar, harita, seyahat, dünya büyümesi |
| [contracts.md](contracts.md) | Kontrat tipleri, zorluk dengesi, ödül tasarımı |
| [trading_post.md](trading_post.md) | Trading Post + Caravan Master sistemi |
| [ux.md](ux.md) | Oyuncu akışı, bilgi sunumu, UI kararları |

---

## Açık Sorular (Yanıtsız)

- [ ] **NPC relation ne işe yarıyor?** Şu an kontratla artıyor ama hiçbir sistem bunu okumuyor. Kapı açacak mı, indirim mi, özel kontrat mı? `factions.md`
- [ ] **Kaç kasaba olacak?** Şu an 3 kasaba hardcode. 4-5'e çıkma planı var mı, yoksa 3 kasaba bitiş vizyonu mu? `world.md`
- [ ] **Oyun bitiş ekranı var mı?** Patrician'a ulaşıldığında gerçek bir bitiş sahnesi/kutlama var mı? `progression.md`
- [ ] **Şehir ekonomik kimlikleri nasıl tanımlanacak?** Her şehrin üretim karakteri, tüketim karakteri ve ticaret rolü netleşmeli mi? Örnek: maden, tarım, sanayi, refah/luxury tüketim şehri. `economy.md`
- [ ] **Ekonomik fırsatlar oyuncuya nasıl gösterilecek?** Stok, mevsim, NPC hareketi ve prosperity değişimi fırsat üretecekse tooltip yeterli mi, yoksa trade hint/rumor/şehir uyarısı/rota tavsiyesi gibi katmanlar gerekli mi? `economy.md`
- [ ] **Stok kapasitesi dolunca sistem nasıl davranacak?** Town stock cap dolduğunda üretim, oyuncu satışı, NPC satışı ve Trading Post auto-sell tamamen engellenecek mi, fiyat mı düşecek, yoksa başka hedef/uyarı sistemi mi çalışacak? `economy.md`
- [ ] **Geç oyun para yakıcıları ne olacak?** Trading Post, Caravan Master ve prosperity yatırımları snowball yaratınca bunu dengeleyecek wage/upkeep/depot expansion/diminishing return/prestige maliyeti gibi mekanikler nasıl kurulacak? `economy.md`
- [ ] **Demand tag MVP kalibrasyonu nasıl yapılacak?** Her item için `category`, `base_price`, `base_daily_demand_per_1000_pop` ve `demand_tags` yeterli mi; şehir bazlı özel katsayılar gerekecek mi? `economy.md`
- [ ] **NPC trader oyuncunun stratejik olarak takip edebileceği bir aktör mü olacak?** NPC'ler sadece arka plan stok değiştirici mi kalacak, yoksa rotaları/etkileri oyuncu tarafından okunabilir olacak mı? `economy.md`
- [ ] **Günlük prosperity clamp değeri ne olacak?** Yeni demand satisfaction modelinde kategori etkileri toplanacak; otomatik prosperity değişiminin min/max günlük sınırı hâlâ kararsız. `economy.md`

## Çelişkiler / Gerilimler

- **Merchants Guild iki kasabada.** Rep artık rank kapısı olmadığı için eskisi kadar kritik değil; ama spread bonusu optimizasyonu açısından Merchants Guild hâlâ çok kolay kazanılıyor. `factions.md`
- **Patrician upkeep sıfır.** Kazandıktan sonra baskı kalkmış — ama oyun zaten bitiyor. Bu tutarlı. `progression.md`
- **3 kasaba ekonomisinin sınırları.** Sadece 3 kasabayla ticaret rotaları hızlı ezberlenebilir. 3 kasaba MVP'de kalacaksa NPC hareketi, mevsim ve prosperity değişimi rota ezberini kıracak kadar görünür olmalı. `economy.md`
- **Bolluk spiraline karşı mekanizma.** Oyuncu para kazandıkça prosperity yatırımı yapıp daha çok kazanıyor. Kabul edilen çözüm yönü: prosperity ihtiyaç seviyesi artacak, eksik tedarik growth stop/düşüş etkisi yaratabilecek, prosperity yatırım maliyeti kademeli artacak, automation fixed cost anlamlı olacak, NPC trader ekonomi dalgalanması yaratacak. Detay mekanikler sonraki tasarım yapılacaklarında ele alınacak. `economy.md`

## Tasarım Yapılacakları

### Bolluk Spirali / Prosperity Ekonomisi
- [ ] **Prosperity ihtiyaç bandı tasarlanacak.** Her prosperity aralığında hangi mal sınıfları ve demand tag'lerin güçleneceği belirlenecek. `economy.md`
- [ ] **Tedarik eksikliği ve prosperity etkisi birlikte yeniden değerlendirilecek.** Mevcut daily demand, demand tag, prosperity growth/decline ve rank koşulu bölümleri beraber okunarak tek tutarlı model çıkarılacak. `economy.md`, `progression.md`
- [ ] **Prosperity yatırım maliyeti formülü belirlenecek.** Düz maliyet yerine kademeli veya eğimli maliyet modeli seçilecek. `economy.md`
- [ ] **Automation fixed cost modeli detaylandırılacak.** Trading Post upkeep, Caravan Master wage, depot expansion ve high-tier master maliyetleri birlikte ele alınacak. `economy.md`, `trading_post.md`
- [ ] **NPC trader okunabilirlik modeli detaylandırılacak.** NPC hareketlerinin oyuncuya ne kadar ve hangi UI katmanından gösterileceği ekonomi + UX dokümanlarıyla birlikte değerlendirilecek. `economy.md`, `ux.md`
- [ ] **Bolluk spirali test senaryoları hazırlanacak.** Oyuncunun post/master ağı kurduğu, prosperity yatırımı yaptığı ve 3 şehirli MVP ekonomisinde snowball'a girip girmediği örnek senaryolarla kontrol edilecek. `economy.md`

## Yapılacaklar / Implementation Senkronu

### Debt & Game Over
- [ ] **PlayerData.gd: Debt sabitleri ve davranışları güncellenecek.** `DEBT_REP_PENALTY_DAYS=14` → 30 olacak. `DEBT_POST_TRADE_STOP_DAYS` ve `should_stop_trading_post_auto_trade()` kaldırılacak (auto-trade artık durmuyor). `_apply_debt_duration_penalties()` içindeki `suspend_most_valuable_post()` çağrısı kaldırılacak; 60. günde game over tetiklenecek.
- [ ] **TradingPostManager.gd: suspended mekanik kaldırılacak.** `suspended` field, `suspend_most_valuable_post()`, `has_post()` içindeki suspended kontrolü ve `process_day()` içindeki `debt_stops_all_trade` kontrolü kaldırılacak.
- [ ] **Game over ekranı eklenecek.** `debt_days >= 60` olunca oyunu sonlandıran bir game over ekranı/akışı oluşturulacak. Şu an hiç yok.

### Rank Sistemi
- [ ] **RankManager.gd: Faksiyon koşulları kaldırılacak.** `get_rank_requirements()` içindeki `friendly_factions` ve `allied_factions` alanları kaldırılacak. `get_progress_data()` içindeki faction sayım kodu kaldırılacak. Koşullar gold + şehir prosperity bazlı yeniden yazılacak. Bkz. `progression.md`.
- [ ] **Thieves Brotherhood koddan kaldırılacak.** `FactionManager.gd` içindeki `FACTIONS` dict'inden `"Thieves Brotherhood"` girdisi ve diğer faksiyonların `relations` alanındaki Thieves referansları silinecek.

### Event Sistemi
- [ ] **Event sistemi koddan kaldırılacak.** `EventManager.gd` ve event tetikleme/uygulama kodları kaldırılacak. Event UI bildirimleri de temizlenecek. Tasarım referansı `economy.md`'de korunuyor.

### Caravan Master — Route Kuralları
- [ ] **CaravanMasterManager.gd: Rule type "buy"/"sell" → "load"/"unload" olacak.** Route kurallarındaki `type` field değerleri ve buna bağlı tüm `_process_stop()` mantığı Load/Unload terminolojisine taşınacak. Bkz. `trading_post.md`.
- [ ] **CaravanMasterManager.gd: Route kurallarından price_limit kaldırılacak.** Caravan Master kuralında fiyat limiti yok; fiyat kararları Trading Post'a ait. Route rule dict'inden `price_limit` alanı ve bunu kullanan `_process_stop()` kontrolü kaldırılacak.
- [ ] **CaravanMasterManager.gd: Load davranış modları eklenecek.** Load Available / Wait Until Full / Wait Until Amount / Take Exact Amount. Şu an sadece "depoda ne varsa al" mantığı var; bekleme/koşul modları hiç yok.
- [ ] **CaravanMasterManager.gd: Durak çalışma sırası zorlanacak.** `_process_stop()` şu an kuralları array sırasına göre işliyor. Tasarıma göre önce tüm Unload kuralları, sonra tüm Load kuralları çalışmalı; oyuncunun ekleme sırasından bağımsız.

### Caravan Master — Route Yaşam Döngüsü
- [ ] **CaravanMasterManager.gd: Cargo uyumluluk kontrolü eklenecek.** `set_route()` ve `start_route()` sırasında master üzerinde cargo varsa yeni rotada Unload karşılığı aranacak. Yoksa kritik uyarı gösterilecek, `Proceed Anyway` olmadan rota aktifleşmeyecek. Aynı kontrol canlı düzenlemeyi de kapsayacak.
- [ ] **CaravanMasterManager.gd: Canlı rota düzenleme davranışı düzeltilecek.** `set_route()` şu an `current_stop_index=0` yapıyor — bu master'ı ışınlar. Tasarıma göre değişiklikler master'ın bir sonraki şehre varışıyla uygulanmalı; mevcut seyahat bozulmamalı.
- [ ] **CaravanMasterManager.gd: Reposition seyahati eklenecek.** `start_route()` sırasında ilk durak master'ın bulunduğu şehirden farklıysa master önce ilk durağa boş seyahat yapacak, sonra rota kuralları işlemeye başlayacak. Şu an yok.
- [ ] **CaravanMasterManager.gd: Temporary Unload sistemi eklenecek.** Cargo uyumsuzluğu durumunda geçici Unload durağı/kuralı mekanizması; cargo boşalınca otomatik kaldırma; partial unload desteği. Tamamen eksik.

### Caravan Master — Aday & Seviye Sistemi
- [ ] **CaravanMasterManager.gd + CaravanMaster.gd: Aday havuzu sistemi eklenecek.** Şu an `hire_master()` tek bir master nesnesi alıyor. Tasarıma göre 3 adaylı, 30 günde yenilenen, archetype bazlı farklı stat/maliyet/wage dağılımına sahip bir aday havuzu olacak. Bkz. `trading_post.md` Master Archetype Yönleri.
- [ ] **CaravanMaster.gd: Seviye atlayınca özellik puanı sistemi eklenecek.** `add_xp()` şu an sadece `level` artırıyor. Tasarıma göre her seviye atlamada oyuncunun harcayabileceği bir özellik puanı kazanılacak (speed/capacity/bargaining/courage'a dağıtılacak).

## Son Tartışma Notları

- [2026-06-03] Ekonomi daily tick ve demand satisfaction kararları eklendi. Şehir simülasyonu ticaretten önce çalışacak; oyuncu otomasyonu NPC'lerden önce işlem yapacak; survival/luxury/industry/raw eksikliklerinin şehir etkileri ayrıştırıldı. Günlük prosperity clamp değeri açık soru olarak bırakıldı.
- [2026-06-03] Bolluk spirali için kabul edilen çözüm yönleri index'e eklendi. Prosperity ihtiyaç bandı, tedarik eksikliğinin prosperity etkisi, kademeli yatırım maliyeti, automation fixed cost, NPC trader okunabilirliği ve bolluk spirali test senaryoları ayrı tasarım yapılacakları olarak kaydedildi.
- [2026-06-03] Ekonomi geliştirme başlıkları açık soru/gerilim olarak kaydedildi. Şehir ekonomik kimlikleri, ekonomik fırsatların oyuncuya gösterilmesi, stok kapasitesi dolunca davranış, geç oyun para yakıcıları, demand tag MVP kalibrasyonu ve NPC trader'ın okunabilir aktör olup olmayacağı index'e eklendi.
- [2026-06-03] Ekonomi fiyat omurgası netleştirildi. Model stok öncelikli hibrit olacak; kategori bazlı fiyat eğrileri, nüfus/prosperity/demand tag tüketimi, quote/spread sınırları ve herkes için marginal pricing kararları `economy.md` dosyasına işlendi.
- [2026-06-03] Market fiyat bilgi UI'ı detaylandırıldı. Ürün satırında toplam fiyat yönü ikonu olacak; referans MVP'de base_price. Hover tooltip sadece %5 üzeri aktif fiyat etkilerini gösterecek, %15 üzeri etkiler çift okla belirtilecek ve etkiler güç sırasına dizilecek. Yerel normal fiyat referansı ileride değerlendirilecek.
- [2026-06-03] Ekonomi bilgisi görünürlüğü kararlaştırıldı. Fiyat formülü oyuncuya gösterilmeyecek; market UI fiyat etkilerini kısa, okunabilir tooltip satırlarıyla açıklayacak. Mevsim etkisi de bu tooltip sistemiyle görünür olacak.
- [2026-06-02] Caravan Master / Trading Post kod-tasarım farkları tespit edildi. Yapılacaklar listesine eklendi.
- [2026-06-02] Event sistemi MVP'den çıkarıldı. Temel dinamizm stok/NPC/mevsimden geliyor; event'ler bu aşamada gereksiz karmaşıklık. Koddan temizlenmesi yapılacaklara eklendi. Tasarım referansı `economy.md`'de korunuyor.
- [2026-06-02] Debt modeli yeniden tasarlandı. Eski "30 günde auto-trade durur, 60 günde suspended" ve "60 günde upkeep durur, master unpaid, route pause" kararlarının ikisi de iptal edildi. Yeni model üç bölgeli: 0-30 gün kurtarılabilir, 30-60 gün kritik ama çıkış var, 60. günde game over. Otomasyon hiçbir zaman sistem tarafından durdurulmaz. Bkz. `trading_post.md`.
- [2026-06-02] Vergi mekaniği kapatıldı. Ayrı bir tax rate uygulanmayacak; spread + faction rep etkisi yeterli. Bkz. `economy.md`.
- [2026-06-02] Thieves Brotherhood kaldırıldı. Agent tarafından eklenmiş, hiçbir tasarım temeli yok. Koddan temizlenmesi yapılacaklara eklendi.
- [2026-06-02] Rank sistemi sadeleştirildi. Faksiyon rep koşulu tamamen kaldırıldı; rank artık gold + şehir prosperity bazlı. Rep yalnızca spread bonusu olarak kalıyor. RankManager.gd güncellenmesi yapılacaklara eklendi.
