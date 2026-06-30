# Kayıt / Yükleme Sistemi Tasarımı

Bu dosya kayıt/yükleme sisteminin tasarım kararlarını ve gerekçelerini tutar. Kod tarafı için `docs/architecture.md` içindeki "Save System" bölümüne bakın.

## Temel Kararlar

- **Tek slot.** Oyun tek bir kayıt dosyası kullanır (`user://saves/savegame.json`); birden fazla kayıt slotu MVP kapsamı dışıdır.
- **Format JSON.** Godot'un `ConfigFile` veya Resource serileştirmesi yerine düz `JSON.stringify`/`JSON.parse_string` kullanılır; insan tarafından okunabilir ve hata ayıklaması kolay olduğu için tercih edildi.
- **Otomatik kayıt her gün tick'inde.** Oyuncunun manuel kayıt yapmayı unutup ilerleme kaybetmesini önlemek için her `WorldMap._on_day_tick()` çağrısının sonunda (varış günü dahil) otomatik kayıt tetiklenir.
- **Manuel kayıt butonu.** `TopBar` üzerinde bir "SAVE" butonu, oyuncunun istediği an kayıt almasını sağlar. Bu, otomatik kaydı tamamlayan ama ona bağımlı olmayan ikinci bir güvenlik katmanıdır.
- **Continue akışı.** Ana menüde kayıt varsa bir "Continue" butonu görünür; "New Game" ayrı bir seçim olarak kalır ve eski kaydı silmez (bir sonraki otomatik kayıt onun üzerine yazar).
- **Game Over'da kayıt silinir.** `debt_days >= 60` eşiğine ulaşıldığında (bkz. `trading_post_debt.md`) kayıt dosyası silinir; böylece "Continue" hiçbir zaman kazanılamaz bir kaybetme durumuna geri yüklemez.

## Kapsam: Ne Kaydedilir

Tüm kalıcı oyun durumu: `PlayerData` (altın, borç, envanter, kervan, faksiyon itibarı, gün, finans kovaları), `EconomyManager.towns` (konum hariç), `RankManager.current_rank_index`, `ContractManager.contracts` + id sayacı, `TradingPostManager.posts`, `CaravanMasterManager.masters` + `.routes`, `TraderManager.traders`, ve `WorldMap`'in seyahat/hız/zafer durumu.

## Kapsam Dışı Bırakılanlar ve Gerekçe

- **Şehir `position` (Vector2).** JSON'a doğrudan serileştirilemez; zaten sahne anchor'larından deterministik olarak yeniden türetiliyor (`WorldMap._sync_town_positions_from_anchors()`), bu yüzden kaydetmeye gerek yok.
- **`CaravanMasterManager.town_candidates`.** Bunlar oyuncuya ait olmayan, henüz işe alınmamış aday havuzudur. `CaravanMasterManager._ready()` zaten `call_deferred("refresh_all_candidates")` ile bu havuzu her sahne yüklemesinde yeniden üretiyor. Kaydetmemek, yükleme sırasında olası bir `call_deferred` sıralama sorununu da tamamen ortadan kaldırıyor — daha basit ve daha sağlam bir çözüm.
- **`master_templates` ve tüm CSV tabanlı balance verisi.** Statik veridir, her `_ready()` çağrısında `data/balance/*.csv` dosyalarından yeniden yüklenir.
- **`FactionManager.npcs`.** Statik veridir, `_init_npcs()` içinde her seferinde yeniden inşa edilir.
- **`TravelRiskManager`.** Tamamen stateless'tir, saklanacak bir şeyi yoktur.
- **Seyahat sırasındaki ham `Vector2` pozisyonları (`travel_start_map_pos`/`travel_end_map_pos`).** Bunlar da JSON-safe değildir; yükleme sırasında `_economy.towns` pozisyonlarından (kaydedilen `travel_destination` ve seyahat sırasında `_player_data.current_town`'ın her zaman çıkış şehrini tutması invariant'ı kullanılarak) yeniden hesaplanır.

## CaravanMaster Serileştirme

`CaravanMaster` bir `Resource` alt sınıfıdır ve doğrudan JSON'a yazılamaz. Bunun yerine `SaveManager` içinde elle yazılmış `_master_to_dict()` / `_dict_to_master()` dönüştürücüleri kullanılır (id, display_name, speed, capacity, bargaining, courage, xp, level, hire_cost, daily_wage alanları).

## Zafer Durumu Kenar Durumu

Eğer oyuncu zafer ekranı (`victory_summary_shown`) açıkken kayıt alırsa, yükleme sırasında sadece bayrak geri yüklenmekle kalmaz, `_day_timer` da duraklatılır — çünkü orijinal zafer ekranı dinamik olarak oluşturulan bir overlay'dir ve yüklemede otomatik olarak yeniden kurulmaz; günün durması olmadan oyun zafer sonrası durumda akmaya devam ederdi.

## Tartışma Notları

- [2026-06-30] Kayıt/yükleme sistemi tasarlandı ve uygulandı. Tek slot JSON format, gün tick'i + manuel buton otomatik kayıt politikası, game over'da kayıt silme ve `town_candidates`/pozisyon/CSV verisi gibi türetilebilir durumun kapsam dışı bırakılması kararlaştırıldı. Detaylı kapsam ve yükleme akışı `architecture.md`'nin "Save System" bölümüne, oyuncuya yönelik özet `mechanics.md` bölüm 16'ya işlendi.
