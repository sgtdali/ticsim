# Design Index

Bu klasör oyunun tasarım kararlarını, açık sorularını ve çelişkilerini tutar.
Her dosya bir konuya odaklanır. Kodlama kararları için `docs/architecture.md`, mekanik detaylar için `docs/mechanics.md`.

## Dosyalar

| Dosya | Konu |
|-------|------|
| [economy.md](economy.md) | Ekonomi tasarımı giriş kapısı |
| [economy_market.md](economy_market.md) | Fiyat sistemi, üretim/tüketim dengesi, piyasa davranışı |
| [economy_prosperity.md](economy_prosperity.md) | Demand satisfaction, şehir refahı, bolluk spirali |
| [economy_events.md](economy_events.md) | Ertelenmiş event sistemi referansı |
| [progression.md](progression.md) | Rank sistemi, unlock kapıları, oyun temposu |
| [factions.md](factions.md) | Faksiyon, NPC ilişkileri, reputasyon mekaniğinin genişlemesi |
| [world.md](world.md) | Kasabalar, harita, seyahat, dünya büyümesi |
| [contracts.md](contracts.md) | Kontrat tipleri, zorluk dengesi, ödül tasarımı |
| [mvp_scope.md](mvp_scope.md) | MVP kapsamı, MVP dışı bırakılanlar ve karar günlüğü |
| [implementation_sync.md](implementation_sync.md) | Tasarım kararlarının kod, mekanik ve UI senkron borçları |
| [trading_post.md](trading_post.md) | Trading Post + Caravan Master otomasyonu giriş kapısı |
| [trading_post_debt.md](trading_post_debt.md) | Debt, upkeep ve game over modeli |
| [caravan_master_routes.md](caravan_master_routes.md) | Caravan Master route, durak ve temporary unload sistemi |
| [caravan_master_hiring.md](caravan_master_hiring.md) | Tavern üzerinden Caravan Master işe alma ve aday sistemi |
| [ux.md](ux.md) | Oyuncu akışı, bilgi sunumu, UI kararları |

---

## Açık Sorular (MVP İçin)

- [ ] **Günlük prosperity clamp değeri ne olacak?** Temel demand satisfaction MVP'de uygulanacağı için otomatik prosperity değişiminin min/max günlük sınırı MVP implementasyonu sırasında netleşmeli. `economy_prosperity.md`

## Açık Sorular (Tam Sürüm / MVP Sonrası)

- [ ] **Şehir ekonomik kimlikleri nasıl derinleşecek?** MVP'de mevcut 3 üretim kimliği yeterli. Tam sürümde her şehrin üretim karakteri, tüketim karakteri ve ticaret rolü ayrıca netleştirilebilir. `economy_market.md`
- [ ] **Ekonomik fırsatlar MVP sonrası nasıl genişletilecek?** MVP'de market tooltip + basit şehir uyarıları yeterli. Tam sürümde trade hint, rumor, şehir uyarısı, rota tavsiyesi veya ekonomik rapor katmanları değerlendirilebilir. `economy_market.md`, `economy_prosperity.md`, `ux.md`
- [ ] **NPC trader stratejik aktöre dönüşecek mi?** MVP'de NPC trader arka plan stok dalgalandırıcı. Tam sürümde rotaları/etkileri oyuncu tarafından okunabilir rakip/aktör haline gelip gelmeyeceği ayrıca tasarlanacak. `economy_prosperity.md`
- [ ] **Demand tag sistemi MVP sonrası şehir bazlı genişleyecek mi?** MVP'de item bazlı `category`, `base_price`, `base_daily_demand_per_1000_pop`, `demand_tags` yeterli. Tam sürümde şehir bazlı özel katsayılar veya tam demand profilleri değerlendirilebilir. `economy_market.md`

## Çelişkiler / Gerilimler

- **Merchants Guild iki kasabada.** Rep artık rank kapısı olmadığı için eskisi kadar kritik değil; ama spread bonusu optimizasyonu açısından Merchants Guild hâlâ çok kolay kazanılıyor. `factions.md`
- **Patrician upkeep sıfır.** Kazandıktan sonra baskı kalkmış — ama oyun zaten bitiyor. Bu tutarlı. `progression.md`
- **3 kasaba ekonomisinin sınırları.** Sadece 3 kasabayla ticaret rotaları hızlı ezberlenebilir. 3 kasaba MVP'de kalacaksa NPC hareketi, mevsim ve prosperity değişimi rota ezberini kıracak kadar görünür olmalı. `economy_market.md`
- **Bolluk spiraline karşı mekanizma.** Oyuncu para kazandıkça prosperity yatırımı yapıp daha çok kazanıyor. Kabul edilen çözüm yönü: prosperity ihtiyaç seviyesi artacak, eksik tedarik growth stop/düşüş etkisi yaratabilecek, prosperity yatırım maliyeti kademeli artacak, automation fixed cost anlamlı olacak, NPC trader ekonomi dalgalanması yaratacak. Detay mekanikler sonraki tasarım yapılacaklarında ele alınacak. `economy_prosperity.md`

## Tasarım Yapılacakları

### Bolluk Spirali / Prosperity Ekonomisi
- [ ] **Prosperity ihtiyaç bandı tasarlanacak.** Her prosperity aralığında hangi mal sınıfları ve demand tag'lerin güçleneceği belirlenecek. `economy_prosperity.md`
- [ ] **Tedarik eksikliği ve prosperity etkisi birlikte yeniden değerlendirilecek.** Mevcut daily demand, demand tag, prosperity growth/decline ve rank koşulu bölümleri beraber okunarak tek tutarlı model çıkarılacak. `economy_market.md`, `economy_prosperity.md`, `progression.md`
- [ ] **Prosperity yatırım bandları ve sayıları belirlenecek.** Basamaklı band modeli seçildi; band aralıkları ve maliyet çarpanları balance edilecek. `economy_prosperity.md`
- [ ] **Automation fixed cost sayıları detaylandırılacak.** Model seçildi; Trading Post upgrade upkeep'i, depot expansion upkeep'i, Caravan Master wage çarpanları ve high-tier master maliyetleri sayısallaştırılacak. `economy_prosperity.md`, `trading_post.md`, `caravan_master_hiring.md`
- [ ] **NPC trader okunabilirlik modeli detaylandırılacak.** NPC hareketlerinin oyuncuya ne kadar ve hangi UI katmanından gösterileceği ekonomi + UX dokümanlarıyla birlikte değerlendirilecek. `economy_prosperity.md`, `ux.md`
- [ ] **Bolluk spirali test senaryoları hazırlanacak.** Oyuncunun post/master ağı kurduğu, prosperity yatırımı yaptığı ve 3 şehirli MVP ekonomisinde snowball'a girip girmediği örnek senaryolarla kontrol edilecek. `economy_prosperity.md`

## Implementation Senkronu

Tasarım kararlarının kod, mekanik ve UI tarafına yansıma borçları artık [implementation_sync.md](implementation_sync.md) içinde takip edilir.
Bu dosya MVP öncesi zorunlu, MVP için basitleştirilebilir ve MVP sonrası/full scope olarak ayrılmıştır.

## Son Tartışma Notları

- [2026-06-04] MVP açık kararları kapatıldı. Victory summary sonrası devam edilebilir; Delivery kontratları tek tier olacak; gross/upkeep/net margin UI MVP'ye alındı; Caravan Master hiring şehir bazlı 0-2 aday olacak; Delivery fail ödülden mahrum kalma + küçük faction rep cezası verecek. MVP için açık kalan tek kapsam kararı günlük prosperity clamp sayısıdır. Genel açık sorular MVP ve tam sürüm sonrası olarak ayrıldı.
- [2026-06-04] Implementation senkron maddeleri `_index.md` içinden ayrılıp `implementation_sync.md` dosyasına taşındı. Kod/mekanik/UI borçları MVP öncesi zorunlu, MVP için basitleştirilebilir ve MVP sonrası/full scope olarak sınıflandırıldı.
- [2026-06-04] Detay tasarım dosyalarına `MVP Kapsamı` blokları eklendi. `mvp_scope.md` ana karar haritası olarak kalacak; her konu dosyası kendi alanında MVP'de uygulanacak, sade tutulacak ve MVP dışı bırakılacak parçaları ayrıca gösterecek.
- [2026-06-04] MVP kapsamı ayrı doküman olarak çıkarıldı. MVP hedefi otomasyonlu ekonomi MVP'si olacak; detaylar `mvp_scope.md` içinde takip edilecek.
- [2026-06-04] Geç oyun para yakıcıları kapatıldı. Model prosperity investment, automation upkeep ve depot expansion arasında dengeli dağıtılacak; prestige/rank maliyeti MVP'de kullanılmayacak; automation UI gross + upkeep + net margin gösterecek. Sayısal balance maddeleri yapılacaklarda bırakıldı.
- [2026-06-04] Stok kapasitesi dolunca davranış kapatıldı. Town stock cap sert fiziksel sınır olacak; cap üstü stok tutulmayacak, üretim fazlası waste olacak, satış işlemleri yalnızca boş kapasite kadar çalışacak ve cap doluluğu ekstra fiyat çarpanı yaratmayacak. Kod senkronuna eklendi.
- [2026-06-04] Kasaba sayısı vizyonu kapatıldı. MVP 3 kasabayla tamamlanacak; ilk tam ekonomi hedefi en az 6 kasaba, uzun vadeli ideal 8-10 kasaba olacak. Harita ve ekonomi mimarisi bu genişlemeye uygun korunacak. Bkz. `world.md`.
- [2026-06-04] NPC relation kaldırma kararı alındı. NPC'ler rakip tüccar değil, şehir/faksiyon temsilcisi olduğu için ayrı NPC relation metriği faction rep ile örtüşüyordu. MVP'de tek mekanik ilişki sistemi faction rep olacak; kod senkronuna NPC relation temizliği eklendi.
- [2026-06-03] Ekonomi daily tick ve demand satisfaction kararları eklendi. Şehir simülasyonu ticaretten önce çalışacak; oyuncu otomasyonu NPC'lerden önce işlem yapacak; survival/luxury/industry/raw eksikliklerinin şehir etkileri ayrıştırıldı. Günlük prosperity clamp değeri açık soru olarak bırakıldı.
- [2026-06-04] Uzayan `economy.md` ve `trading_post.md` dokümanları konu dosyalarına ayrıldı. Ana dosyalar giriş kapısı olarak kaldı; pazar/fiyat, prosperity, event, debt, route ve hiring kararları yeni/ilgili dosyalara taşındı.
- [2026-06-03] Bolluk spirali için kabul edilen çözüm yönleri index'e eklendi. Prosperity ihtiyaç bandı, tedarik eksikliğinin prosperity etkisi, kademeli yatırım maliyeti, automation fixed cost, NPC trader okunabilirliği ve bolluk spirali test senaryoları ayrı tasarım yapılacakları olarak kaydedildi.
- [2026-06-03] Ekonomi geliştirme başlıkları açık soru/gerilim olarak kaydedildi. Şehir ekonomik kimlikleri, ekonomik fırsatların oyuncuya gösterilmesi, stok kapasitesi dolunca davranış, geç oyun para yakıcıları, demand tag MVP kalibrasyonu ve NPC trader'ın okunabilir aktör olup olmayacağı index'e eklendi.
- [2026-06-03] Ekonomi fiyat omurgası netleştirildi. Model stok öncelikli hibrit olacak; kategori bazlı fiyat eğrileri, nüfus/prosperity/demand tag tüketimi, quote/spread sınırları ve herkes için marginal pricing kararları artık `economy_market.md` dosyasında tutuluyor.
- [2026-06-03] Market fiyat bilgi UI'ı detaylandırıldı. Ürün satırında toplam fiyat yönü ikonu olacak; referans MVP'de base_price. Hover tooltip sadece %5 üzeri aktif fiyat etkilerini gösterecek, %15 üzeri etkiler çift okla belirtilecek ve etkiler güç sırasına dizilecek. Yerel normal fiyat referansı ileride değerlendirilecek.
- [2026-06-03] Ekonomi bilgisi görünürlüğü kararlaştırıldı. Fiyat formülü oyuncuya gösterilmeyecek; market UI fiyat etkilerini kısa, okunabilir tooltip satırlarıyla açıklayacak. Mevsim etkisi de bu tooltip sistemiyle görünür olacak.
- [2026-06-02] Caravan Master / Trading Post kod-tasarım farkları tespit edildi. Yapılacaklar listesine eklendi.
- [2026-06-02] Event sistemi MVP'den çıkarıldı. Temel dinamizm stok/NPC/mevsimden geliyor; event'ler bu aşamada gereksiz karmaşıklık. Koddan temizlenmesi yapılacaklara eklendi. Tasarım referansı `economy_events.md`'de korunuyor.
- [2026-06-02] Debt modeli yeniden tasarlandı. Eski "30 günde auto-trade durur, 60 günde suspended" ve "60 günde upkeep durur, master unpaid, route pause" kararlarının ikisi de iptal edildi. Yeni model üç bölgeli: 0-30 gün kurtarılabilir, 30-60 gün kritik ama çıkış var, 60. günde game over. Otomasyon hiçbir zaman sistem tarafından durdurulmaz. Bkz. `trading_post_debt.md`.
- [2026-06-02] Vergi mekaniği kapatıldı. Ayrı bir tax rate uygulanmayacak; spread + faction rep etkisi yeterli. Bkz. `economy_market.md`.
- [2026-06-02] Thieves Brotherhood kaldırıldı. Agent tarafından eklenmiş, hiçbir tasarım temeli yok. Koddan temizlenmesi yapılacaklara eklendi.
- [2026-06-02] Rank sistemi sadeleştirildi. Faksiyon rep koşulu tamamen kaldırıldı; rank artık gold + şehir prosperity bazlı. Rep yalnızca spread bonusu olarak kalıyor. RankManager.gd güncellenmesi yapılacaklara eklendi.
