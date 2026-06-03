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

## Çelişkiler / Gerilimler

- **Merchants Guild iki kasabada.** Rep artık rank kapısı olmadığı için eskisi kadar kritik değil; ama spread bonusu optimizasyonu açısından Merchants Guild hâlâ çok kolay kazanılıyor. `factions.md`
- **Patrician upkeep sıfır.** Kazandıktan sonra baskı kalkmış — ama oyun zaten bitiyor. Bu tutarlı. `progression.md`

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

- [2026-06-03] Ekonomi fiyat omurgası netleştirildi. Model stok öncelikli hibrit olacak; kategori bazlı fiyat eğrileri, nüfus/prosperity/demand tag tüketimi, quote/spread sınırları ve herkes için marginal pricing kararları `economy.md` dosyasına işlendi.
- [2026-06-03] Market fiyat bilgi UI'ı detaylandırıldı. Ürün satırında toplam fiyat yönü ikonu olacak; referans MVP'de base_price. Hover tooltip sadece %5 üzeri aktif fiyat etkilerini gösterecek, %15 üzeri etkiler çift okla belirtilecek ve etkiler güç sırasına dizilecek. Yerel normal fiyat referansı ileride değerlendirilecek.
- [2026-06-03] Ekonomi bilgisi görünürlüğü kararlaştırıldı. Fiyat formülü oyuncuya gösterilmeyecek; market UI fiyat etkilerini kısa, okunabilir tooltip satırlarıyla açıklayacak. Mevsim etkisi de bu tooltip sistemiyle görünür olacak.
- [2026-06-02] Caravan Master / Trading Post kod-tasarım farkları tespit edildi. Yapılacaklar listesine eklendi.
- [2026-06-02] Event sistemi MVP'den çıkarıldı. Temel dinamizm stok/NPC/mevsimden geliyor; event'ler bu aşamada gereksiz karmaşıklık. Koddan temizlenmesi yapılacaklara eklendi. Tasarım referansı `economy.md`'de korunuyor.
- [2026-06-02] Debt modeli yeniden tasarlandı. Eski "30 günde auto-trade durur, 60 günde suspended" ve "60 günde upkeep durur, master unpaid, route pause" kararlarının ikisi de iptal edildi. Yeni model üç bölgeli: 0-30 gün kurtarılabilir, 30-60 gün kritik ama çıkış var, 60. günde game over. Otomasyon hiçbir zaman sistem tarafından durdurulmaz. Bkz. `trading_post.md`.
- [2026-06-02] Vergi mekaniği kapatıldı. Ayrı bir tax rate uygulanmayacak; spread + faction rep etkisi yeterli. Bkz. `economy.md`.
- [2026-06-02] Thieves Brotherhood kaldırıldı. Agent tarafından eklenmiş, hiçbir tasarım temeli yok. Koddan temizlenmesi yapılacaklara eklendi.
- [2026-06-02] Rank sistemi sadeleştirildi. Faksiyon rep koşulu tamamen kaldırıldı; rank artık gold + şehir prosperity bazlı. Rep yalnızca spread bonusu olarak kalıyor. RankManager.gd güncellenmesi yapılacaklara eklendi.
