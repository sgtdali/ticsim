# Implementation Sync

Bu dosya tasarım kararlarının ileride kod, mekanik ve UI tarafına yansıması gereken borçlarını takip eder.
Buradaki maddeler doğrudan kod yazma talimatı değildir; tasarım modu kapandıktan sonra implementation checklist'i olarak kullanılmalıdır.

## Kullanım

- Karar kaynağı ilgili tasarım dosyasında kalır.
- Bu dosya yalnızca "bu karar koda/mekaniğe yansıyacak mı, ne zaman?" sorusunu takip eder.
- MVP kapsamı değişirse bu dosyadaki sınıflandırma da güncellenmelidir.
- Bir madde implement edilince ilgili kodla birlikte `docs/mechanics.md` veya `docs/architecture.md` gerekip gerekmediği ayrıca kontrol edilmelidir.

## MVP Öncesi Zorunlu Senkronlar
 
- [x] **CSVLoader Yardımcı Sınıfının Eklenmesi (Veri Entegrasyonu).** `res://scripts/utils/CSVLoader.gd` oluşturulup, standart Godot `FileAccess.get_csv_line()` fonksiyonu kullanılarak CSV dosyalarını `Array[Dictionary]` biçimine dönüştürmesi sağlanacak. (Faz 3)
 
- [x] **EconomyManager Veri-Güdümlü Hale Getirilmesi (Veri Entegrasyonu).** `_load_items_data()` ve `_init_towns()` metodları refaktör edilerek veriler hardcoded sözlükler/kaynak dosyaları yerine `items.csv`, `towns.csv`, `town_stocks.csv`, `production.csv`, `recipes.csv` ve `routes.csv` dosyalarından yüklenecek. `ItemData` nesneleri dinamik olarak instantiate edilecek. (Faz 3)
 
- [x] **RankManager Veri-Güdümlü Hale Getirilmesi (Veri Entegrasyonu).** Rank atlama gereksinimleri `ranks.csv` dosyasından okunacak. (Faz 3)
 
- [x] **CaravanMasterManager Veri-Güdümlü Hale Getirilmesi (Veri Entegrasyonu).** Caravan master tipleri, stat katsayıları ve günlük ücretleri `automation.csv` dosyasından okunacak. (Faz 3)
 
- [x] **Fiyat Eğrileri ve Mevsimsel Katsayılar Entegrasyonu (Veri Entegrasyonu).** Kategori bazlı fiyat eğrileri `price_curves.csv` ve mevsimsel üretim katsayıları `season_modifiers.csv` dosyalarından okunacak. (Faz 3)
 
- [x] **NPC relation koddan kaldırılacak.** Kontrat tamamlanınca NPC relation artıran veri/field/metotlar ve UI gösterimleri temizlenecek. Aldric, Mira ve Torben şehir/faksiyon temsilcisi olarak kalacak; mekanik ilişki faction rep üzerinden çalışacak. Kaynak: `factions.md`, `contracts.md`, `mvp_scope.md`.
 
- [x] **RankManager.gd faction koşulları kaldırılacak.** `get_rank_requirements()` içindeki `friendly_factions` ve `allied_factions` alanları kaldırılacak. `get_progress_data()` içindeki faction sayım kodu kaldırılacak. Rank koşulları gold + şehir prosperity bazlı yeniden yazılacak. Kaynak: `progression.md`, `mvp_scope.md`.
 
- [x] **Town stock cap davranışı kodla senkronlanacak.** Cap üstü stok tutulmayacak; üretim fazlası waste olacak; manuel satış, Trading Post auto-sell, NPC trader satışı ve kontrat teslimi sadece boş kapasite kadar gerçekleşecek. Yer yoksa Trading Post rule status `waiting_market` bekleme durumuna geçecek; cap doluluğu ekstra fiyat çarpanı yaratmayacak. Kaynak: `economy_market.md`, `mvp_scope.md`.
 
- [x] **Delivery kontratları MVP kapsamına sadeleştirilecek.** MVP'de yalnızca tek tier Delivery kontratı olacak. Procurement/Urgent ve tier balance MVP dışı kalacak. Kontrat fail olursa oyuncu ödülden mahrum kalacak ve küçük faction rep cezası alacak. Kaynak: `contracts.md`, `mvp_scope.md`.
 
- [x] **Victory summary ve devam edebilme akışı eklenecek.** Patrician'a ulaşınca victory summary ekranı tetiklenecek; oyuncu isterse oyuna devam edebilecek. Sinematik/narrative ending MVP dışı kalacak. Kaynak: `progression.md`, `ux.md`, `mvp_scope.md`.
 
- [ ] **Basic Caravan Master hiring şehir bazlı 0-2 aday olacak.** Tavern/TownUI üzerinden şehir bazlı aday havuzu kurulacak. MVP'de aday refresh, archetype numeric balance ve gelişmiş aday çeşitliliği sade tutulabilir. Kaynak: `caravan_master_hiring.md`, `mvp_scope.md`.
 
- [ ] **Automation gross/upkeep/net margin UI gösterilecek.** Automation kârlılığı yalnızca gross margin olarak gösterilmeyecek; gross margin, upkeep ve net margin birlikte görünecek. MVP'de sade bir panel/satır düzeni yeterli. Kaynak: `trading_post.md`, `ux.md`, `mvp_scope.md`.
 
- [x] **Debt modelindeki auto-trade durdurma/suspend davranışı kaldırılacak.** `PlayerData.gd` içinde `DEBT_REP_PENALTY_DAYS=14` değeri yeni debt modeline göre güncellenecek; `DEBT_POST_TRADE_STOP_DAYS` ve `should_stop_trading_post_auto_trade()` kaldırılacak. `_apply_debt_duration_penalties()` içindeki `suspend_most_valuable_post()` çağrısı kaldırılacak; 60. günde game over tetiklenecek. `TradingPostManager.gd` içinde `suspended` field, `suspend_most_valuable_post()`, `has_post()` içindeki suspended kontrolü ve `process_day()` içindeki `debt_stops_all_trade` kontrolü kaldırılacak. Kaynak: `trading_post_debt.md`, `mvp_scope.md`.
 
- [x] **Game over ekranı eklenecek.** `debt_days >= 60` olunca oyunu sonlandıran bir game over ekranı/akışı oluşturulacak. Kaynak: `trading_post_debt.md`, `ux.md`, `mvp_scope.md`.

- [ ] **Günlük prosperity clamp sayısı netleşince koda bağlanacak.** Temel demand satisfaction MVP'de olduğu için otomatik prosperity değişiminin günlük min/max sınırı implementation sırasında kesinleştirilecek. Kaynak: `economy_prosperity.md`, `mvp_scope.md`.

## MVP İçin Basitleştirilebilir Senkronlar

- [ ] **Automation fixed cost için geçici ama tutarlı MVP sayıları belirlenecek.** Trading Post temel upkeep, Caravan Master daily upkeep ve varsa basit upgrade upkeep değerleri MVP'de çalışır olmalı. Trading Post upgrade upkeep'i, depot expansion upkeep'i, Caravan Master wage çarpanları ve high-tier master maliyetleri detaylı balance aşamasına kalabilir. Kaynak: `economy_prosperity.md`, `trading_post.md`, `caravan_master_hiring.md`.

- [ ] **Geç oyun para yakıcılarının MVP kısmı uygulanacak.** Trading Post upkeep şehir prosperity'sine göre otomatik artmayacak; upkeep yalnızca post/depot upgrade'leriyle artabilecek. Depot expansion tek seferlik maliyet + küçük upkeep yaratacak. High-tier master ekonomisi MVP'de sınırlı tutulabilir. Kaynak: `economy_prosperity.md`, `trading_post.md`, `caravan_master_hiring.md`.

- [x] **Thieves Brotherhood koddan kaldırılacak veya MVP'de görünmez/pasif olduğu doğrulanacak.** Eğer faction listesinde aktif çelişki yaratıyorsa MVP öncesi temizlenmeli. Pasif ve görünmezse tam cleanup MVP sonrasına kalabilir. Kaynak: `factions.md`.

- [x] **Event sistemi MVP'de pasif olmalı.** Event sistemi MVP dışı. Kodda ekonomiyi etkiliyorsa kaldırılmalı veya devre dışı bırakılmalı. Pasif referanslar tam cleanup'a kalabilir. Tasarım referansı korunur. Kaynak: `economy_events.md`, `mvp_scope.md`.

## MVP Sonrası / Full Scope Senkronları

- [ ] **CaravanMasterManager.gd route rule terminolojisi tam tasarıma taşınacak.** Rule type `"buy"`/`"sell"` yerine `"load"`/`"unload"` olacak. Route kurallarındaki `type` field değerleri ve `_process_stop()` mantığı Load/Unload terminolojisine taşınacak. Kaynak: `caravan_master_routes.md`.

- [ ] **CaravanMasterManager.gd route kurallarından price_limit kaldırılacak.** Caravan Master kuralında fiyat limiti yok; fiyat kararları Trading Post'a ait. Route rule dict'inden `price_limit` alanı ve bunu kullanan `_process_stop()` kontrolü kaldırılacak. Kaynak: `caravan_master_routes.md`.

- [ ] **CaravanMasterManager.gd Load davranış modları eklenecek.** Load Available / Wait Until Full / Wait Until Amount / Take Exact Amount modları uygulanacak. Kaynak: `caravan_master_routes.md`.

- [ ] **CaravanMasterManager.gd durak çalışma sırası zorlanacak.** Tasarıma göre önce tüm Unload kuralları, sonra tüm Load kuralları çalışmalı; oyuncunun ekleme sırasından bağımsız olmalı. Kaynak: `caravan_master_routes.md`.

- [ ] **CaravanMasterManager.gd cargo uyumluluk kontrolü eklenecek.** `set_route()` ve `start_route()` sırasında master üzerinde cargo varsa yeni rotada Unload karşılığı aranacak; yoksa kritik uyarı gösterilecek. Kaynak: `caravan_master_routes.md`.

- [ ] **CaravanMasterManager.gd canlı rota düzenleme davranışı düzeltilecek.** `set_route()` mevcut seyahati bozmayacak; değişiklikler master'ın bir sonraki şehre varışıyla uygulanacak. Kaynak: `caravan_master_routes.md`.

- [ ] **CaravanMasterManager.gd reposition seyahati eklenecek.** İlk durak master'ın bulunduğu şehirden farklıysa master önce ilk durağa boş seyahat yapacak, sonra rota kuralları işlemeye başlayacak. Kaynak: `caravan_master_routes.md`.

- [ ] **CaravanMasterManager.gd Temporary Unload sistemi eklenecek.** Cargo uyumsuzluğu durumunda geçici Unload durağı/kuralı, cargo boşalınca otomatik kaldırma ve partial unload desteği uygulanacak. Kaynak: `caravan_master_routes.md`.

- [ ] **CaravanMaster.gd seviye atlayınca özellik puanı sistemi eklenecek.** `add_xp()` yalnızca level artırmakla kalmayacak; oyuncunun speed/capacity/bargaining/courage'a dağıtabileceği özellik puanı kazanılacak. Kaynak: `caravan_master_hiring.md`.

- [ ] **NPC trader okunabilirlik modeli koda/UI'a genişletilecek.** MVP'de NPC trader arka plan stok dalgalandırıcıdır. Tam sürümde rotaları/etkileri oyuncuya ne kadar gösterilecekse ekonomi + UX tasarımına göre uygulanacak. Kaynak: `economy_prosperity.md`, `ux.md`.

## Tartışma Notları

- [2026-06-05] MVP senkron paketinde NPC relation koddan temizlendi; Thieves Brotherhood faction tanımından kaldırıldı; kontratlar tek tier Delivery üretimine indirildi; stock cap kontrat teslimi dahil tüm stok ekleme yollarında korunacak şekilde doğrulandı; EventManager MVP için no-op yapıldı; Patrician victory summary + devam et akışı eklendi.
- [2026-06-04] Implementation senkronu `_index.md` içinden ayrıldı. MVP öncesi zorunlu, MVP için basitleştirilebilir ve MVP sonrası/full scope olarak sınıflandırıldı. Bu dosya tasarım kararlarının kod/mekanik/UI tarafına yansıma borçlarını takip edecek.
