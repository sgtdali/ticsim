# Architecture

> **Durum (2026-10-29):** Bu belge yeni üretim/lojistik tycoon için **planlanan** mimariyi tanımlar. Yeni kod henüz yazılmadı. Repodaki `scripts/`, `scenes/`, `data/` ve `tools/balance_sim/` eski ortaçağ prototipine aittir (legacy) ve bu mimarinin parçası değildir. Kod yazıldıkça bu belge gerçek yapıya göre güncellenir.
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
    Production/    Reçete döngüleri, işgücü, kalite
    Market/        Retail (mağaza seçimi), Exchange (emir eşleşme), Import
    Logistics/     NetworkGraph, Pathfinding, Dispatch, Movement, Congestion
    CompanyAI/     Strategic, Tactical, Lifecycle (iflas/girişim)
    Research/      Seviyeler, kilitler, patent
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
| Tile | arazi tipi, yükseklik, biyom, kaynak tipi + zenginlik, içerik (boş/şehir karosu/tesis/altyapı), sahip |
| Chunk | 64×64 karo, kirli bayrağı |
| City | karolar, nüfus, meslek bazında maaş ve işgücü, konut kapasitesi, borsa ID |
| Household | şehir, konut karosu, kişi sayısı, çalışanlar (meslek, işyeri), gelir, birikim, ihtiyaç barları, dayanıklı mallar, memnuniyet |
| Facility | tip, karolar, sahip şirket, reçete durumu, girdi/çıktı stokları, kapasite, işgücü |
| Store | şehir, karo, sahip, raflar (kategori, stok, fiyat), kapsama yarıçapı |
| Exchange | şehir, depo partileri, alış/satış emir defterleri, son işlem fiyat/hacim |
| Lot (mal partisi) | mal, adet, kalite, üretici şirket, yaş (bozulma) |
| Vehicle | tip, kargo sınıfı, kapasite, konum (grafik kenarı + ilerleme), yük, aktif bacak, bağlı depo, ömür |
| TransportJob / Leg | mal, adet, kaynak, hedef, son tarih / mod, başlangıç-bitiş düğümü, atanmış araç |
| Company | nakit, kişilik, tesisler, mağazalar, araçlar, teknoloji seviyeleri, patentler, marka değerleri |

## Lojistik Ağı

- Grid inşa ve çizim içindir. Altyapı değiştiğinde **ağ grafiği** yeniden türetilir: kavşak ve terminaller düğüm, kesimler kenar (mod, uzunluk, kapasite, kamu/özel, ücret).
- A* grafikte çalışır; rotalar önbelleğe alınır; tıkanıklık kenar maliyetini birkaç saatte bir günceller.

## Tick Programı

| Sıklık | İşler (sıra) |
|--------|--------------|
| Her tick | 1. Araç hareketi ve teslimat → 2. Terminal kuyrukları → 3. Üretim döngüleri |
| Günlük (tick'lere yayılır) | Bar düşüşü ve hane alışverişi, mağaza satışı, bozulma, borsa eşleşmesi, metrik kaydı |
| Haftalık | Şirket taktik kararları, maaş güncellemesi |
| Aylık | Şirket stratejik kararları, göç, meslek geçişi, girişim/iflas, Ar-Ge ilerlemesi |
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
