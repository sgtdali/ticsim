# Design Index

Bu klasör oyunun tasarım kararlarını, açık sorularını ve çelişkilerini tutar.
Her dosya bir konuya odaklanır. Kodlama kararları için `docs/architecture.md`, mekanik detaylar için `docs/mechanics.md`.

## Dosyalar

| Dosya | Konu |
|-------|------|
| [economy.md](economy.md) | Fiyat sistemi, üretim/tüketim dengesi, piyasa davranışı |
| [progression.md](progression.md) | Rank sistemi, unlock kapıları, oyun temposu |
| [factions.md](factions.md) |faksiyon, NPC ilişkileri, reputasyon mekaniğinin genişlemesi |
| [world.md](world.md) | Kasabalar, harita, seyahat, dünya büyümesi |
| [contracts.md](contracts.md) | Kontrat tipleri, zorluk dengesi, ödül tasarımı |
| [trading_post.md](trading_post.md) | Trading Post + Caravan Master sistemi |
| [ux.md](ux.md) | Oyuncu akışı, bilgi sunumu, UI kararları |

---

## Açık Sorular (Yanıtsız)

- [ ] **Thieves Brotherhood'un kasabası yok.** Oyuncu bufaksiyon ile nasıl etkileşime giriyor? Rep nasıl kazanılıyor? `factions.md`
- [ ] **NPC relation ne işe yarıyor?** Şu an kontratla artıyor ama hiçbir sistem bunu okumuyor. Kapı açacak mı, indirim mi, özel kontrat mı? `factions.md`
- [ ] **Vergi mekanik olarak uygulanmıyor.** Faction rep'e bağlı tax rate hesaplanıyor ama al-sat fiyatını etkilemiyor (spread üzerinden etki var). Bu kasıtlı mı, geçici mi? `economy.md`
- [ ] **Kaç kasaba olacak?** Şu an 3 kasaba hardcode. 4-5'e çıkma planı var mı, yoksa 3 kasaba bitiş vizyonu mu? `world.md`
- [ ] **Oyun bitiş ekranı var mı?** Patrician'a ulaşıldığında gerçek bir bitiş sahnesi/kutlama var mı? `progression.md`

## Çelişkiler / Gerilimler

- **Merchants Guild iki kasabada.** Ironmere ve Stonebridge ikisi de Merchants Guildfaksiyon. Bufaksiyon ile ticaret yapmak her iki şehirde de aynı reputasyona gidiyor. Bilerek mi, ama Northern Kingdom ile dengeyi bozmuyor mu? `factions.md`
- **Patrician upkeep sıfır.** Kazandıktan sonra baskı kalkmış — ama oyun zaten bitiyor. Bu tutarlı. `progression.md`
- **Mevsim çarpanları var ama UI'da görünür değil.** Oyuncu mevsim etkisini fark edemiyor. `economy.md`

## Yapılacaklar / Implementation Senkronu

- [ ] **Debt cezası kod ve mekanik dokümanla senkronize edilecek.** Tasarım kararına göre Trading Post artık debt nedeniyle suspended olmayacak ve auto-trade 30 günde durmayacak. `docs/mechanics.md` ve ilgili kodlar, özellikle eski `suspended` mantığı içerebilecek Trading Post/debt kodları, yeni modele göre güncellenmeli: 30 günde reputation penalty + debt fee, 60 günde daha büyük reputation penalty + Caravan Master unpaid status + route pause; borç kapanınca route'lar kaldığı yerden devam etmeli.

## Son Tartışma Notları

- [2026-06-02] Debt cezası revize edildi. Trading Post suspended/auto-trade stop yaklaşımı tasarımda kaldırıldı. Kod ve mechanics dokümanında eski mantığın izleri olabileceği için implementation senkronu yapılacaklar listesine eklendi.
