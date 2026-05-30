# Progression Design

## Rank Sistemi (Karar verilmiş)

5 rank: Peddler → Trader → Merchant → Guild Master → Patrician.
Patrician = win condition. Oyun burada bitiyor.

Rank atlamak için tüm koşulların aynı anda sağlanması gerekiyor + debt olmamalı.

| Rank | Gold | Faction | Diğer | Unlock |
|------|------|---------|-------|--------|
| Trader | 500 | 1 Friendly | — | Caravan upgrades, 1 master |
| Merchant | 1.500 | 2 Friendly | — | Trading Posts, 2 master |
| Guild Master | 4.000 | 3 Friendly | 2 Post + 1 Growing city | Urgent contracts, +%50 rep bonus, 4 master |
| Patrician | 10.000 | 3 Allied | 3 Prosperous city | Win (6 master) |

- Friendly = rep ≥ 30, Allied = rep ≥ 60.
- Growing city = prosperity ≥ 30, Prosperous city = prosperity ≥ 65.
- Debt varken rank atlanamıyor.
- Patrician'ın upkeep'i sıfır (oyun bittiği için baskı kaldırılmış, kasıtlı).

## Unlock Kapıları (Karar verilmiş)

- Caravan upgrade → Trader gerekiyor.
- Trading Post → Merchant gerekiyor.
- Trading Post sayısı ilk kez Guild Master koşulunda gereksinim oluyor. (Merchant açıyor ama Merchant koşulu post istemez — bu tutarlı, tasarımsal karar.)
- Urgent contracts → Guild Master.
- Caravan Master cap rank'a göre: 0/1/2/4/6.

## Açık Sorular

**Oyun bitiş ekranı?**
Patrician rank'ına ulaşınca gerçek bir bitiş sahnesi/kutlama/özet ekranı var mı planlıyor musunuz?

**Rank gereksinimleri dengeli mi?**
Peddler→Trader arası hızlı, Trader→Merchant orta, Merchant→Guild Master daha uzun, Guild Master→Patrician uzun. Bu ritim kasıtlı. Ama 3 Allied faction (rep ≥ 60) oldukça zor bir çıta — özellikle 3 factiondan biri Thieves Brotherhood'sa ve onunla etkileşim kısıtlıysa. `factions.md`'deki soru bunu direkt etkiliyor.

**"Aynı anda" koşulu tasarımsal olarak doğru mu?**
Tüm koşullar aynı anda karşılanmak zorunda. Yani 10.000 gold'un olması ama allied faction'ların eksik olması rank'ı engelliyor. Bu özellikle geç oyunda "en son ne lazım" sorusunu doğruyor. İstenen zorluk seviyesi bu mu?

## Gerilimler

**Thieves Brotherhood ve Allied koşulu**
Patrician için 3 Allied faction gerekiyor. 3 faction var: Northern Kingdom, Merchants Guild, Thieves Brotherhood. Thieves Brotherhood ile rep kazanmak başkafaksiyon ile çatışıyor (her ikisiyle olumsuz ilişki). Bu kasıtlı bir gerilim mi ("hepsini memnun etmek zordur"), yoksa pratik bir engel mi?

**Prosperity koşulunun oyuncu kontrolü**
3 Prosperous city (prosperity ≥ 65) koşulu direkt oyuncu yatırımına bağlı. Ama prosperity aynı zamanda survival malı stokuyla otomatik artıyor/azalıyor. Oyuncu kasıtlı yatırım yapmazsa bile sistematik beslemesiyle bu koşul sağlanabilir mi?

## Tartışma Notları

*(Boş)*
