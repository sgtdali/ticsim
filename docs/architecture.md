# Architecture

> **Durum (2026-10-29):** Bu belge yeni üretim/lojistik tycoon için **planlanan** mimariyi tanımlar. Yeni kod henüz yazılmadı. Eski ortaçağ prototipinin kodu ve varlıkları 2026-10-29'da repodan silindi (sadece git geçmişinde). Kod yazıldıkça bu belge gerçek yapıya göre güncellenir.
>
> Tasarım gerekçeleri: `docs/design/` (özellikle `performance.md`, `logistics.md`, `observation.md`).

## Katmanlar

| Katman | Teknoloji | Sorumluluk | Kural |
|--------|-----------|------------|-------|
| **Sim** | C# (Godot'tan bağımsız) | Dünya verisi + tüm sistemler | Godot node'u yok; headless çalışır; deterministik |
| **Viewer** | Godot 4 + C# | Debug viewer (sonra oyun UI'ı) | Sim durumunu sadece okur |
| **Tools** | C# headless runner + Python | Toplu koşu, metrik CSV, analiz | Sim'i kütüphane olarak kullanır |

## Klasör Yapısı (planlanan)

```
sim/
  Core/        World, Clock, Ids, Rng, Money, Profiler
  Data/        Struct tabloları (Tiles, Chunks, Households, Facilities, Stores,
               Exchanges, Vehicles, Companies, Lots)
  Defs/        Tanım yükleyiciler (goods, recipes, facility/vehicle types, needs)
  Systems/
    MapGen/        Yükseklik, iklim, nehir, kaynak, şehir, kamu ağı
    Population/    Barlar, tüketim, meslek geçişi, büyüme, göç
    Production/    Birim akışları, reçete döngüleri, işgücü darboğazı, kalite, bakım/arıza, inşaat
    Market/        Retail (mağaza seçimi), Exchange (emir eşleşme), Import
    Logistics/     NetworkGraph, Pathfinding, Dispatch, Movement, Congestion (BPR), Terminals, FreightMarket, Tolls
    CompanyAI/     Strategic, Tactical, Lifecycle (iflas/girişim)
    Research/      Seviyeler, kilitler, patent
    Finance/       Bankalar (mevduat, kredi), merkez bankası, hisse borsası, devralma
    Management/    Kademeler, yönetim puanı, yöneticiler, tesis deneyimi
    Public/        Vergi, şehir bütçesi, kamu hizmetleri
    Environment/   Kirlilik ve gürültü alanları
    Season/        Mevsim döngüsü
    Observation/   Metrikler, alarmlar
  Save/        Tam durum snapshot (kaydet/yükle)
viewer/        Godot sahneleri ve viewer scriptleri
tools/
  headless/    Komut satırı runner (seed × süre × ayar → CSV)
  analysis/    Python karşılaştırma scriptleri
data/defs/     Mal, reçete, tesis, araç, ihtiyaç tanımları ve ayar dosyaları
```

## Core

- **World:** Tüm tabloların sahibi; sistemler World üzerinden okur/yazar.
- **Clock:** 1 tick = 1 oyun saati; gün/hafta/ay/mevsim türetilir.
- **Ids:** Her tablo için `int` ID; silinen kayıtlar serbest listeye döner.
- **Rng:** Sistem başına seed'li akış; dünya seed'inden türetilir.
- **Money:** `long` (kuruş). Float para yok.
- **Profiler:** Sistem başına tick süresi.

## Veri Tabloları (ana alanlar)

| Tablo | Ana alanlar |
|-------|-------------|
| Tile | arazi tipi, yükseklik, biyom, kaynak tipi + zenginlik, içerik (boş/şehir karosu/tesis/altyapı), sahip, kiracı, arazi değeri, kirlilik, gürültü |
| Chunk | 64×64 karo, kirli bayrağı |
| City | karolar, nüfus, meslek bazında maaş ve işgücü, konut kapasitesi, borsa ID |
| Household | şehir, konut karosu, kişi sayısı, çalışanlar (meslek, işyeri), gelir, birikim, ihtiyaç barları, dayanıklı mallar, memnuniyet |
| Facility | tip, boyut, karolar, sahip şirket, birim slotları, inşaat durumu |
| Unit | tesis, slot, tip (satın alma/üretim/depo/satış/çıkarım/raf/reklam), reçete, bağlantılar ve bölme oranları, stok, kapasite, meslek bazında işgücü, deneyim, durum |
| Store | şehir, karo, sahip, raflar (kategori, stok, fiyat), kapsama yarıçapı |
| Exchange | şehir, depo partileri, alış/satış emir defterleri, son işlem fiyat/hacim |
| Lot (mal partisi) | mal, adet, kalite, üretici şirket, yaş (bozulma) |
| Vehicle | tip, kargo sınıfı, kapasite, konum (grafik kenarı + ilerleme), yük, aktif bacak, bağlı depo, ömür |
| TransportJob / Leg | mal, adet, kaynak, hedef, son tarih / mod, başlangıç-bitiş düğümü, atanmış araç |
| Company | nakit, kişilik, kademe, yönetim puanı, yöneticiler, tesisler, mağazalar, araçlar, teknoloji seviyeleri, patentler, marka değerleri, krediler, hisse yapısı, ana/bağlı şirket |
| Manager | rol, uzmanlıklar, beceri, kişilik, maaş, devredilen birimler, yetki ayarları |
| Bank | mevduatlar, krediler, sermaye, faiz marjları |
| Loan | borçlu, banka, anapara, faiz |
| Shareholding | şirket, sahip (hane/şirket/fon), adet |

## Lojistik Ağı

- Grid inşa ve çizim içindir. Altyapı değiştiğinde **ağ grafiği** yeniden türetilir: kavşak ve terminaller düğüm, kesimler kenar (mod, uzunluk, kapasite, kamu/özel, ücret).
- A* grafikte çalışır; rotalar önbelleğe alınır; tıkanıklık kenar maliyetini birkaç saatte bir günceller.

## Tick Programı

| Sıklık | İşler (sıra) |
|--------|--------------|
| Her tick | 1. Araç hareketi ve teslimat → 2. Terminal kuyrukları → 3. Üretim döngüleri |
| Günlük (tick'lere yayılır) | Bar düşüşü ve hane alışverişi, mağaza satışı, bozulma, mal borsası ve hisse borsası eşleşmesi, kirlilik/gürültü güncellemesi, metrik kaydı |
| Haftalık | Şirket taktik kararları (fiyat, emir, prim), maaş güncellemesi, memnuniyet hesabı |
| Aylık | Şirket stratejik kararları, göç, meslek geçişi, girişim/iflas, Ar-Ge ilerlemesi, politika faizi, vergi ve kamu bütçesi |
| Birkaç saatte bir | Tıkanıklık maliyeti ve rota önbelleği yenileme |

## Determinizm Kuralları

- Global `Random` yok; sistem başına seed'li RNG.
- Paralel işler kendi tamponlarına yazar, sonuçlar sabit sırayla birleşir.
- Dictionary/HashSet iterasyon sırasına bağlı mantık yok.
- Gerçek zaman (wall clock) mantığa girmez.
- Kaydet/yükle tam snapshot; yüklenen dünya birebir aynı devam eder.

## Performans

- Hedef ölçek: ~2500² karo, ~25–35 bin hane, birkaç bin araç.
- Bütçe: 4x hızda tick < 16 ms.
- Tick içinde bellek tahsisi yok; bağımsız işler worker thread'lerde, ortak kaynaklara yazanlar sıralı.

## Viewer

- Harita katmanları: arazi/kaynak, şehir/yoğunluk, tesisler (şirket rengi), araçlar, tıkanıklık ısı haritası.
- Tıklanabilir inceleme paneli, zaman serisi grafikleri, hız kontrolü (duraklat, 1x–64x), seed seçimi.
- Harita çizimi chunk bazında kodla yapılır; paneller `.tscn` sahneleri olarak kurulur.
