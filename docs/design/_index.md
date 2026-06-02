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

- [ ] **Debt cezası kod ve mekanik dokümanla senkronize edilecek.** Tasarım kararına göre Trading Post artık debt nedeniyle suspended olmayacak ve auto-trade 30 günde durmayacak. `docs/mechanics.md` ve ilgili kodlar, özellikle eski `suspended` mantığı içerebilecek Trading Post/debt kodları, yeni modele göre güncellenmeli: 30 günde reputation penalty + debt fee, 60 günde daha büyük reputation penalty + Caravan Master unpaid status + route pause; borç kapanınca route'lar kaldığı yerden devam etmeli.
- [ ] **Thieves Brotherhood koddan kaldırılacak.** `FactionManager.gd` içindeki `FACTIONS` dict'inden `"Thieves Brotherhood"` girdisi silinmeli. Northern Kingdom ve Merchants Guild'deki `relations` alanından da Thieves referansları temizlenmeli. Kodda başka yerlerde `"Thieves Brotherhood"` string'i geçiyorsa onlar da kaldırılmalı.
- [ ] **Rank sistemi kodu güncellenmeli.** `RankManager.gd` içindeki rank koşullarından faksiyon rep kontrolleri kaldırılmalı (Friendly/Allied eşik kontrolleri). Koşullar gold + şehir prosperity (Growing/Prosperous) bazlı olacak şekilde yeniden yazılmalı. Bkz. `progression.md` güncel rank tablosu.

## Son Tartışma Notları

- [2026-06-02] Debt cezası revize edildi. Trading Post suspended/auto-trade stop yaklaşımı tasarımda kaldırıldı. Kod ve mechanics dokümanında eski mantığın izleri olabileceği için implementation senkronu yapılacaklar listesine eklendi.
- [2026-06-02] Vergi mekaniği kapatıldı. Ayrı bir tax rate uygulanmayacak; spread + faction rep etkisi yeterli. Bkz. `economy.md`.
- [2026-06-02] Thieves Brotherhood kaldırıldı. Agent tarafından eklenmiş, hiçbir tasarım temeli yok. Koddan temizlenmesi yapılacaklara eklendi.
- [2026-06-02] Rank sistemi sadeleştirildi. Faksiyon rep koşulu tamamen kaldırıldı; rank artık gold + şehir prosperity bazlı. Rep yalnızca spread bonusu olarak kalıyor. RankManager.gd güncellenmesi yapılacaklara eklendi.
