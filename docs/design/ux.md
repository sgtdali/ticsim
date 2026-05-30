# UX & Flow Design

## Mevcut Akış (Karar verilmiş)

- Ana ekran: harita. Oyuncu kasabalara tıklayarak seyahat ediyor.
- Kasabaya varınca TownUI açılıyor (tab yapısı): Market, Info, Invest, Contracts, NPC, Post, Upgrade.
- Haritada üst bar: gold, gün, rank.
- Haritada sağ panel: finans özeti, rank progress, aktif kontratlar.
- Haritada alt panel: event log.
- NPC trader'lar haritada label ile görünüyor.
- Seyahat sırasında oyuncu kasabaya giremez, risk animasyonu var.

## Bilgi Sunumu (Karar verilmiş)

- Market tablosunda: fiyat, stok, trend, kâr/zarar fırsatı (ortalama alış fiyatına göre).
- Risk tooltip haritada gösteriliyor.
- Trading Post rule'larının durumu (active/waiting_price/vb.) UI'da gösteriliyor.
- Rank progress ekranında her koşul için current/required gösteriliyor.

## Açık Sorular

**Mevsim bilgisi oyuncuya ulaşıyor mu?**
Mevsim çarpanları ekonomiyi etkiliyor ama oyuncu hangi mevsimde olduğunu nerede görüyor? Top bar'da mı, haritada mı, yoksa hiç yok mu?

**Kontrat deadline takibi**
Aktif kontratlar sağ panelde görünüyor. Deadline yaklaştığında oyuncuyu uyaran bir mekanizma var mı (renk değişimi, uyarı)?

**Oyun bitiş ekranı yok**
Patrician'a ulaşınca ne oluyor? Sessizce rank atlanıyor mu?

**Kasabadan kasabaya karşılaştırma**
Oyuncu "hangi kasabada buğday daha ucuz?" sorusunu yanıtlamak için kasabayı açıp bakması gerekiyor. Haritadan kasabalar arası fiyat karşılaştırması yapılabilmeli mi? Trade Route Panel bunu karşılıyor mu?

## Gerilimler

**Derin ama öğretilmemiş sistemler**
Post+Master zinciri, mevsim etkileri, rivalry penalty gibi derin mekanikler oyuncuya nasıl öğretiliyor? Şu an tutorial yok gibi görünüyor. Organik keşif mi hedefleniyor?

**Çok fazla tab**
TownUI'da 7 tab var. Yeni başlayan oyuncu için bunaltıcı olabilir. Rank ilerledikçe tablar açılsa (Merchant olmadan Post tab görünmese) daha yönetilebilir olabilir.

## Tartışma Notları

*(Boş)*
