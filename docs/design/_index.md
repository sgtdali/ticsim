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
- **Mevsim çarpanları var ama UI'da görünür değil.** Oyuncu mevsim etkisini fark edemiyor. `economy.md`

## Yapılacaklar / Implementation Senkronu

- [ ] **Debt modeli kod ve mekanik dokümanla senkronize edilecek.** Yeni model: 0-30 gün rep penalty + debt fee (otomasyon çalışır); 30-60 gün daha büyük rep penalty (otomasyon hâlâ çalışır); 60. günde game over ekranı. Eski `suspended`, `unpaid`, `route pause`, `auto-trade stop` mantıklarının tamamı kaldırılmalı. `docs/mechanics.md` ve ilgili debt/Trading Post/CaravanMaster kodları bu modele göre güncellenmeli. Bkz. `trading_post.md`.
- [ ] **Thieves Brotherhood koddan kaldırılacak.** `FactionManager.gd` içindeki `FACTIONS` dict'inden `"Thieves Brotherhood"` girdisi silinmeli. Northern Kingdom ve Merchants Guild'deki `relations` alanından da Thieves referansları temizlenmeli. Kodda başka yerlerde `"Thieves Brotherhood"` string'i geçiyorsa onlar da kaldırılmalı.
- [ ] **Rank sistemi kodu güncellenmeli.** `RankManager.gd` içindeki rank koşullarından faksiyon rep kontrolleri kaldırılmalı (Friendly/Allied eşik kontrolleri). Koşullar gold + şehir prosperity (Growing/Prosperous) bazlı olacak şekilde yeniden yazılmalı. Bkz. `progression.md` güncel rank tablosu.
- [ ] **Event sistemi koddan kaldırılacak.** `EventManager.gd` ve ilgili event tetikleme/uygulama kodları kaldırılmalı. Event UI bildirimleri de temizlenmeli. Tasarım referansı `economy.md`'de korunuyor.

## Son Tartışma Notları

- [2026-06-02] Event sistemi MVP'den çıkarıldı. Temel dinamizm stok/NPC/mevsimden geliyor; event'ler bu aşamada gereksiz karmaşıklık. Koddan temizlenmesi yapılacaklara eklendi. Tasarım referansı `economy.md`'de korunuyor.
- [2026-06-02] Debt modeli yeniden tasarlandı. Eski "30 günde auto-trade durur, 60 günde suspended" ve "60 günde upkeep durur, master unpaid, route pause" kararlarının ikisi de iptal edildi. Yeni model üç bölgeli: 0-30 gün kurtarılabilir, 30-60 gün kritik ama çıkış var, 60. günde game over. Otomasyon hiçbir zaman sistem tarafından durdurulmaz. Bkz. `trading_post.md`.
- [2026-06-02] Vergi mekaniği kapatıldı. Ayrı bir tax rate uygulanmayacak; spread + faction rep etkisi yeterli. Bkz. `economy.md`.
- [2026-06-02] Thieves Brotherhood kaldırıldı. Agent tarafından eklenmiş, hiçbir tasarım temeli yok. Koddan temizlenmesi yapılacaklara eklendi.
- [2026-06-02] Rank sistemi sadeleştirildi. Faksiyon rep koşulu tamamen kaldırıldı; rank artık gold + şehir prosperity bazlı. Rep yalnızca spread bonusu olarak kalıyor. RankManager.gd güncellenmesi yapılacaklara eklendi.
