# Progression Design

## MVP Kapsamı

MVP'de tam rank ladder korunacak:

- Peddler.
- Trader.
- Merchant.
- Guild Master.
- Patrician.
- Rank koşulları gold + şehir prosperity bazlı çalışacak.
- Faction rep rank koşulu olmayacak.
- Rank unlock'ları çalışacak: caravan upgrade, Trading Post, Caravan Master cap, urgent kontrat kapısı tasarımda kalsa da MVP kontrat kapsamı minimal Delivery ile sınırlı olacak.
- Patrician'a ulaşınca victory summary ekranı tetiklenecek.
- Victory summary sonrası oyuncu devam edebilir.

MVP'de sade tutulacak:

- Rank requirement sayıları ve prosperity eşikleri balance açısından değişebilir.
- Rank ekranı okunabilir olmalı; görsel polish MVP dışıdır.

MVP dışı:

- Prestige/rank upkeep.
- Rank tören maliyeti.
- Narrative rank eventleri.
- Sinematik victory sahnesi.

Tam progression kararları aşağıda korunur; MVP implementasyonu için bu kapsam önceliklidir.

## Rank Sistemi (Karar verilmiş)

5 rank: Peddler → Trader → Merchant → Guild Master → Patrician.
Patrician = win condition. Oyun burada bitiyor.

Rank atlamak için tüm koşulların aynı anda sağlanması gerekiyor + debt olmamalı.

| Rank | Gold | Şehir Koşulu | Diğer | Unlock |
|------|------|-------------|-------|--------|
| Trader | 500 | — | — | Caravan upgrades, 1 master |
| Merchant | 1.500 | 1 Growing city | — | Trading Posts, 2 master |
| Guild Master | 4.000 | 2 Growing + 1 Prosperous | 2 Post | Urgent contracts, +%50 rep bonus, 4 master |
| Patrician | 10.000 | 3 Prosperous city | — | Win (6 master) |

- Growing city = prosperity ≥ 30, Prosperous city = prosperity ≥ 65.
- Faksiyon rep koşulu rank sisteminden kaldırıldı. Rep yalnızca spread bonusu verir (alım/satım optimizasyonu), rank kapısı değildir.
- Debt varken rank atlanamıyor.
- Patrician'ın upkeep'i sıfır (oyun bittiği için baskı kaldırılmış, kasıtlı).
- Şehir sayısı ilerleyen versiyonlarda artarsa Patrician koşulu "X şehirden Y tanesi Prosperous" şeklinde kolayca güncellenebilir.

## Unlock Kapıları (Karar verilmiş)

- Caravan upgrade → Trader gerekiyor.
- Trading Post → Merchant gerekiyor.
- Trading Post sayısı ilk kez Guild Master koşulunda gereksinim oluyor. (Merchant açıyor ama Merchant koşulu post istemez — bu tutarlı, tasarımsal karar.)
- Urgent contracts → Guild Master.
- Caravan Master cap rank'a göre: 0/1/2/4/6.

## Açık Sorular

**"Aynı anda" koşulu tasarımsal olarak doğru mu?**
Tüm koşullar aynı anda karşılanmak zorunda. Yani 10.000 gold'un olması ama Prosperous city eksik olması rank'ı engelliyor. Bu özellikle geç oyunda "en son ne lazım" sorusunu doğuruyor. İstenen zorluk seviyesi bu mu?

## Gerilimler

**Prosperity koşulunun oyuncu kontrolü**
3 Prosperous city (prosperity ≥ 65) koşulu direkt oyuncu yatırımına bağlı. Ama prosperity aynı zamanda survival malı stokuyla otomatik artıyor/azalıyor. Oyuncu kasıtlı yatırım yapmazsa bile sistematik beslemesiyle bu koşul sağlanabilir mi? Bu istenen bir şey mi yoksa oyuncunun aktif çaba göstermesi mi bekleniyor?

## Tartışma Notları

- [2026-06-02] Rank sistemi sadeleştirildi. Faksiyon rep koşulu tamamen kaldırıldı. Rank için artık gold + şehir prosperity koşulları geçerli. Rep yalnızca alım/satım spread bonusu olarak kalmaya devam ediyor. Şehir sayısı ilerleyen versiyonlarda artarsa Patrician koşulu kolayca güncellenebilir. Thieves Brotherhood'un kaldırılması ve 2 faksiyon kalmasıyla birlikte bu sadeleştirme hem zorunlu hem de tasarımsal olarak daha temiz hale geldi.
- [2026-06-04] MVP bitiş davranışı netleşti. Patrician'a ulaşınca victory summary ekranı gösterilecek; oyuncu isterse devam edebilecek. Sinematik kutlama ve narrative ending MVP dışı kalacak.
