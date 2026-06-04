# UX & Flow Design

## MVP Kapsamı

MVP'de UI okunabilir ama sade olacak:

- Market fiyat/stok görünürlüğü.
- Fiyat yönü ikonu.
- Tooltip'te anlamlı fiyat nedenleri.
- Basit şehir uyarıları.
- Trading Post rule status.
- Caravan Master route status.
- Debt uyarısı.
- Game over ekranı.
- Victory summary ekranı.
- Victory summary sonrası devam edebilme.
- Temel rank/progression görünürlüğü.

MVP'de sade/opsiyonel:

- Route chain görünürlüğü.
- Caravan Master hiring UI polish.
- Prosperity uyarıları.
- Mevsim bilgisi top bar veya market tooltip düzeyinde gösterilebilir.

MVP dışı:

- Tam ekonomik rapor ekranı.
- Gelişmiş dashboard.
- Trade rumor UI.
- Tam interaktif route mini-map polish.
- Sinematik/victory kutlama sahnesi.

Aşağıdaki UX kararları tam vizyonu korur; MVP implementasyonu için bu kapsam önceliklidir.

## Mevcut Akış (Karar verilmiş)

- Ana ekran: harita. Oyuncu kasabalara tıklayarak seyahat ediyor.
- Kasabaya varınca TownUI açılıyor (tab yapısı): Market, Info, Invest, Contracts, NPC, Post, Upgrade.
- Haritada üst bar: gold, gün, rank.
- Haritada sağ panel: finans özeti, rank progress, aktif kontratlar.
- Haritada alt panel: event log.
- NPC trader'lar haritada label ile görünüyor.
- Seyahat sırasında oyuncu kasabaya giremez, risk animasyonu var.
- Caravan Master / Trade Route yönetimi world map üzerinden açılan ayrı `Trade Routes` panelinde yapılır.
- Caravan Master işe alma TownUI içinden açılan ayrı `Tavern` panelinde yapılır.

## Bilgi Sunumu (Karar verilmiş)

- Market tablosunda: fiyat, stok, trend, kâr/zarar fırsatı (ortalama alış fiyatına göre).
- Risk tooltip haritada gösteriliyor.
- Trading Post rule'larının durumu (active/waiting_price/vb.) UI'da gösteriliyor.
- Rank progress ekranında her koşul için current/required gösteriliyor.
- Trade Routes paneli route odaklıdır; route listesi, bağlı master, status, cargo özeti ve route uyarılarını gösterir.
- Trade Routes panelinde şehirleri, yolları, route çizgilerini ve master konumlarını gösteren interaktif mini map bulunur.
- Mini mapte tüm aktif route'lar çizilir; seçili route güçlü şekilde vurgulanır.
- Route çizgileri route kimliğine göre otomatik farklı renk alır; renkler taşıdığı mala göre belirlenmez.
- Seçili route çizgisi kalınlaşır, diğer route'lar soluklaşır.
- Seçili route'un durak sırası mini map üzerinde küçük sıra numaralarıyla gösterilir.
- Yeni route oluştururken şehirler mini map üzerinden sırayla tıklanarak seçilir.
- Tavern paneli şehirdeki Caravan Master adaylarını gösterir.
- Tavern panelinde aday adı, archetype, hire cost, daily upkeep, Speed, Capacity, Bargain ve Courage net görünmelidir.
- Aday yoksa Tavern paneli oyuncuya başka şehir kontrol etmesini veya daha sonra dönmesini söylemelidir.

## Açık Sorular

**Mevsim bilgisi oyuncuya ulaşıyor mu?**
Mevsim çarpanları ekonomiyi etkiliyor ama oyuncu hangi mevsimde olduğunu nerede görüyor? Top bar'da mı, haritada mı, yoksa hiç yok mu?

**Kontrat deadline takibi**
Aktif kontratlar sağ panelde görünüyor. Deadline yaklaştığında oyuncuyu uyaran bir mekanizma var mı (renk değişimi, uyarı)?

**Kasabadan kasabaya karşılaştırma**
Oyuncu "hangi kasabada buğday daha ucuz?" sorusunu yanıtlamak için kasabayı açıp bakması gerekiyor. Trade Routes panelindeki mini map route planlamasını destekler; ancak genel fiyat karşılaştırmasını karşılayıp karşılamadığı hâlâ net değil.

## Gerilimler

**Derin ama öğretilmemiş sistemler**
Post+Master zinciri, mevsim etkileri, rivalry penalty gibi derin mekanikler oyuncuya nasıl öğretiliyor? Şu an tutorial yok gibi görünüyor. Organik keşif mi hedefleniyor?

**Çok fazla tab**
TownUI'da 7 tab var. Yeni başlayan oyuncu için bunaltıcı olabilir. Rank ilerledikçe tablar açılsa (Merchant olmadan Post tab görünmese) daha yönetilebilir olabilir.

**Trade Routes mini map kalabalığı**
Trade Routes panelinde tüm route'ların aynı anda çizilmesi lojistik ağı okumayı güçlendirebilir; ancak route sayısı arttıkça mini map kalabalıklaşabilir. Seçili route vurgusu güçlü olmalı; gerekirse ileride filtre/layer seçenekleri değerlendirilebilir.

**Tavern aday belirsizliği**
Caravan Master adaylarının her şehirde garanti çıkmaması arama hissi oluşturur; ancak oyuncu çok uzun süre aday bulamazsa sinir bozucu olabilir. Bu ihtimal balance aşamasında kontrol edilmelidir.

## Tartışma Notları

- [2026-06-02] Caravan Master işe alma akışı TownUI içinden açılan ayrı Tavern paneline bağlandı. Tavern paneli MarketUI gibi ayrı bir panel olarak açılacak; şehir bazlı adayları gösterecek. Adaylar her zaman çıkmayacak ve aday kalitesi oyuncu rank'ına göre değişecek.
- [2026-06-02] Trade Routes mini map route gösterimi netleştirildi. Route çizgileri route kimliğine göre otomatik farklı renk alacak; mal bazlı renk kullanılmayacak. Seçili route kalın çizilecek, diğer route'lar soluklaşacak. Seçili route'un durak sırası küçük sıra numaralarıyla gösterilecek.
- [2026-06-02] Trade Routes paneli world map üzerinden açılan ayrı bir yönetim paneli olarak kararlaştırıldı. Panel route odaklı olacak, içinde interaktif mini map bulunacak. Mini mapte şehirler, yollar, aktif route çizgileri ve master konumları gösterilecek. Yeni route oluştururken şehirler mini map üzerinden sırayla tıklanarak seçilecek. Mini mapte tüm route'lar görünecek, seçili route vurgulanacak.
- [2026-06-04] MVP UI kapsamı netleşti. Victory summary ekranı ve sonrasında devam edebilme MVP'de olacak; automation gross/upkeep/net margin UI da MVP kapsamına alındı. Tam ekonomik dashboard ve sinematik victory polish MVP dışı kalacak.
