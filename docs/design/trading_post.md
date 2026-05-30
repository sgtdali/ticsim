# Trading Post & Caravan Master Design

## Trading Post (Karar verilmiş)

- Açılış: Merchant rank, 300 gold.
- Depo kapasitesi: 50 birim.
- Upkeep: 8 gold/gün.
- Debt 30 günde auto-trade durur. 60 günde en değerli post suspended olur.
- Trading Post şehir içi market otomasyonudur: bulunduğu şehirde market ile oyuncu deposu arasında al/sat kurallarını işletir.

**Otomasyon mantığı:**
Buy rule: fiyat limitin altındaysa + depot_limit dolmadıysa + markette stok varsa → alır.
Sell rule: fiyat limitin üstündeyse + depot_limit aşıldıysa + markette yer varsa → satar.

Her rule her gün bir status alır (active, waiting_price, waiting_stock, waiting_market, depot_full, depot_empty). Sadece active olanlar işlem yapar.

## Caravan Master Temel Rolü (Karar verilmiş)

- Caravan Master, Patrician serisindeki trade route/convoy otomasyonundan ilham alır; fakat birebir kopyalamaz.
- Master şehirler arası lojistik otomasyonudur: Trading Post depoları arasında mal taşır.
- Master doğrudan marketten alım-satım yapmaz. Market otomasyonu Trading Post'un rolüdür.
- Master'ın rota kuralları depot-to-depot akışı kurar: kaynak post deposundan alır, hedef post deposuna bırakır.
- Rota en az 2 duraktan oluşur.
- Her durakta Trading Post şarttır.
- Her durakta "al" veya "sat" kuralı vardır: hangi mal, fiyat limiti ve max miktar görünür olmalıdır.
- Master özellikleri korunur: Hız, Kapasite, Pazarlık, Cesaret.
- XP ve rank cap sistemi korunur.

**Master özellikleri (1-5 arası, seviye atladıkça):**
- Hız: -%10/puan (max -%40 seyahat süresi)
- Kapasite: 15 + 5/puan
- Pazarlık: +%0.5/puan alım indirimi & satış bonusu
- Cesaret: -%3/puan saldırı riski

XP: durak başına 25, seviye başına level×100 threshold. Max seviye 5.

**Rank cap:** 0 / 1 / 2 / 4 / 6 (Peddler→Patrician).

## Patrician'dan Alınan Tasarım Dersleri

- Güçlü trade route hissi, oyuncunun her şehir/mal kombinasyonunu sürekli elle takip etmek zorunda kalmamasından gelir.
- Ancak bu oyunda otomasyon iki ayrı role bölünmelidir:
  - Trading Post: şehir içi market ↔ depo otomasyonu.
  - Caravan Master: şehirler arası depo ↔ depo lojistiği.
- Bu ayrım korunmalıdır; Master doğrudan markete girerse Trading Post'un stratejik rolü zayıflar.
- Oyuncu öğrenme sırası şu şekilde olmalıdır:
  1. Manuel ticaretle fiyat/şehir/mal mantığını öğrenir.
  2. Trading Post ile şehir içi otomasyon kurar.
  3. Caravan Master ile şehirler arası otomasyon kurar.
- Caravan Master sistemi bu nedenle mid-game otomasyon katmanı olarak tasarlanmalıdır; erken oyunun temel ticaret öğrenimini atlatan bir kestirme olmamalıdır.

## Caravan Master Aday Sistemi (Karar verilmiş)

- Tek sabit master yerine aday havuzu kullanılacak.
- Aynı anda 3 aday gösterilecek.
- Adaylar her 30 günde bir yenilenecek.
- Adayların stat dağılımı, hire cost ve daily upkeep değerleri farklı olacak.
- Rank yükseldikçe daha kaliteli adayların çıkma ihtimali artacak.
- Eski tek sabit aday yaklaşımı (120g hire + 4g/gün) yerine bu aday havuzu kararı geçerlidir.
- Aday sistemi oyuncuya gerçek bir tercih sunmalıdır:
  - Ucuz ama zayıf apprentice almak mı?
  - Hızlı ama riskli runner almak mı?
  - Pahalı ama güvenli guarded master almak mı?
  - Bekleyip daha iyi aday aramak mı?

## Master Archetype Yönleri

Bu archetype'lar kesin numeric balance değildir; sadece tasarım yönünü tarif eder. Sayısal değerler mechanics/balance aşamasında netleştirilebilir.

- **Apprentice:** Ucuz, düşük stat, erken otomasyon için uygun.
- **Runner:** Hızlı, düşük kapasite ve düşük cesaret.
- **Hauler:** Yüksek kapasite, düşük hız.
- **Guarded Master:** Yüksek cesaret, yüksek upkeep.
- **Broker:** Yüksek pazarlık, orta kapasite.
- **Veteran:** Pahalı, yüksek toplam stat, late-game için uygun.

## UI / Okunabilirlik Notları

- Rota sistemi şehir/durak bazlı ve mal bazlı okunmalıdır.
- Her durakta hangi maldan ne kadar alınacağı/satılacağı ve fiyat limitinin ne olduğu net görünmelidir.
- Oyuncuya otomasyon zinciri açıkça gösterilmelidir.
- Örnek okunabilir zincir:
  - “Ironmere Post buys Bread under 22g → Master carries Bread to Stonebridge → Stonebridge Post sells Bread over 31g → Expected margin: +9g/unit”
- Bu zincir görünürlüğü, Post ve Master sistemlerinin ayrı UI'lardan yönetilmesinin yaratacağı zihinsel yükü azaltmak için ana çözüm yönüdür.

## Açık Sorular

**Post+Master koordinasyonu okunabilirliği**
Trading Post buy rule mal satın alıp depoya koyuyor. Caravan Master da depodaki malı başka depoya taşıyor. Bu iki sistem ayrı UI'dan yönetiliyor. Oyuncu bu zinciri zihinsel olarak kurabilmeli; zincir ve beklenen margin yeterince görünür mü?

**Suspend sonrası yeniden açış**
Debt 60 günde post suspended olunca oyuncu onu tekrar açmak için 300 gold daha ödemek zorunda mı? Evet — bu recover yolunu kasıtlı olarak zorlaştırıyor.

## Gerilimler

**Otomasyon karmaşıklığı**
Post buy/sell kuralları + master rota kuralları + master özellik sistemi birlikte oldukça derin. Erken oyuncunun bunu kavraması zor olabilir. Çözüm yönü: UI'da otomasyon zinciri, rota durakları, mal miktarları, fiyat limitleri ve beklenen margin açık gösterilmeli.

**Master ve player yarışması**
Oyuncu bir kasabada ucuz malı bulmak isterken post buy rule'u o malı zaten almış olabilir. Ya da tam tersi — master bir malı taşırken oyuncu onu başka yere satmak isteyebilir. Bu çatışma kasıtlı mı (kaynak yönetimi), rahatsız edici mi?

## Tartışma Notları

- [2026-05-31] Caravan Master sistemi Patrician trade route yaklaşımından ilhamla netleştirildi. Master doğrudan markete girmeyecek; Trading Post şehir içi otomasyon, Caravan Master şehirler arası depot-to-depot lojistik olarak konumlandı. Tek sabit aday yerine 3 adaylı, 30 günde yenilenen aday havuzu kararı alındı.
