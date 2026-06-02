# UX & Flow Design

## Mevcut Akış (Karar verilmiş)

- Ana ekran: harita. Oyuncu kasabalara tıklayarak seyahat ediyor.
- Kasabaya varınca TownUI açılıyor (tab yapısı): Market, Info, Invest, Contracts, NPC, Post, Upgrade.
- Haritada üst bar: gold, gün, rank.
- Haritada sağ panel: finans özeti, rank progress, aktif kontratlar.
- Haritada alt panel: event log.
- NPC trader'lar haritada label ile görünüyor.
- Seyahat sırasında oyuncu kasabaya giremez, risk animasyonu var.
- Caravan Master / Trade Route yönetimi world map üzerinden açılan ayrı `Trade Routes` panelinde yapılır.

## Bilgi Sunumu (Karar verilmiş)

- Market tablosunda: fiyat, stok, trend, kâr/zarar fırsatı (ortalama alış fiyatına göre).
- Risk tooltip haritada gösteriliyor.
- Trading Post rule'larının durumu (active/waiting_price/vb.) UI'da gösteriliyor.
- Rank progress ekranında her koşul için current/required gösteriliyor.
- Trade Routes paneli route odaklıdır; route listesi, bağlı master, status, cargo özeti ve route uyarılarını gösterir.
- Trade Routes panelinde şehirleri, yolları, route çizgilerini ve master konumlarını gösteren interaktif mini map bulunur.
- Mini mapte tüm aktif route'lar çizilir; seçili route güçlü şekilde vurgulanır.
- Yeni route oluştururken şehirler mini map üzerinden sırayla tıklanarak seçilir.

## Açık Sorular

**Mevsim bilgisi oyuncuya ulaşıyor mu?**
Mevsim çarpanları ekonomiyi etkiliyor ama oyuncu hangi mevsimde olduğunu nerede görüyor? Top bar'da mı, haritada mı, yoksa hiç yok mu?

**Kontrat deadline takibi**
Aktif kontratlar sağ panelde görünüyor. Deadline yaklaştığında oyuncuyu uyaran bir mekanizma var mı (renk değişimi, uyarı)?

**Oyun bitiş ekranı yok**
Patrician'a ulaşınca ne oluyor? Sessizce rank atlanıyor mu?

**Kasabadan kasabaya karşılaştırma**
Oyuncu "hangi kasabada buğday daha ucuz?" sorusunu yanıtlamak için kasabayı açıp bakması gerekiyor. Trade Routes panelindeki mini map route planlamasını destekler; ancak genel fiyat karşılaştırmasını karşılayıp karşılamadığı hâlâ net değil.

## Gerilimler

**Derin ama öğretilmemiş sistemler**
Post+Master zinciri, mevsim etkileri, rivalry penalty gibi derin mekanikler oyuncuya nasıl öğretiliyor? Şu an tutorial yok gibi görünüyor. Organik keşif mi hedefleniyor?

**Çok fazla tab**
TownUI'da 7 tab var. Yeni başlayan oyuncu için bunaltıcı olabilir. Rank ilerledikçe tablar açılsa (Merchant olmadan Post tab görünmese) daha yönetilebilir olabilir.

**Trade Routes mini map kalabalığı**
Trade Routes panelinde tüm route'ların aynı anda çizilmesi lojistik ağı okumayı güçlendirebilir; ancak route sayısı arttıkça mini map kalabalıklaşabilir. Seçili route vurgusu güçlü olmalı; gerekirse ileride filtre/layer seçenekleri değerlendirilebilir.

## Tartışma Notları

- [2026-06-02] Trade Routes paneli world map üzerinden açılan ayrı bir yönetim paneli olarak kararlaştırıldı. Panel route odaklı olacak, içinde interaktif mini map bulunacak. Mini mapte şehirler, yollar, aktif route çizgileri ve master konumları gösterilecek. Yeni route oluştururken şehirler mini map üzerinden sırayla tıklanarak seçilecek. Mini mapte tüm route'lar görünecek, seçili route vurgulanacak.
