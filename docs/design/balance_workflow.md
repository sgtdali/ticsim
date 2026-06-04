# Balance Workflow Design

Bu dosya MVP ve sonrası için sayısal balans değerlerinin nasıl tasarlanacağını, nerede tutulacağını, nasıl test edileceğini ve oyuna nasıl aktarılacağını tanımlar.

Bu doküman doğrudan ürün fiyatı, şehir nüfusu, üretim sayısı veya route mesafesi gibi final değerleri belirlemez. Bunun yerine bu değerleri sağlıklı şekilde belirlemek için kullanılacak çalışma modelini tarif eder.

---

## Temel Problem

Ironmere ekonomisinde çok sayıda sayısal değer vardır:

- Ürünlerin base price değerleri.
- Ürün kategorileri ve fiyat eğrileri.
- Şehirler arası mesafe ve seyahat süresi.
- Şehir başlangıç nüfusları.
- Nüfus artış/azalış oranları.
- Başlangıç prosperity değerleri.
- Günlük üretim miktarları.
- Günlük tüketim ve demand değerleri.
- Başlangıç stokları.
- Stok kapasiteleri.
- Kontrat miktarları ve ödülleri.
- Rank gold/prosperity eşikleri.
- Trading Post açılış maliyeti, depo kapasitesi ve upkeep değeri.
- Caravan Master hire cost, upkeep, capacity, speed ve stat değerleri.
- NPC trader stok dalgalandırma gücü.
- Mevsimsel üretim çarpanları.
- Prosperity yatırım maliyetleri.

Bu değerler tek tek elle seçilemez. Çünkü her sayı diğer sistemleri etkiler.

Örnek:

```text
Bread base price artarsa
-> Bread ticareti daha kârlı hale gelir
-> Delivery kontrat ödülü artabilir
-> Survival shortage daha pahalı hissedilir
-> Ashford ekonomisi güçlenir
-> Oyuncu daha hızlı Trader/Merchant olabilir
-> 120-180 gün victory hedefi bozulabilir
```

Bu nedenle sayısal balans, tek tek değer seçme işi değil; veriye dayalı test edilen bir sistem tasarımı olarak ele alınmalıdır.

---

## Ana Yaklaşım

Önerilen çalışma modeli:

```text
Excel / CSV = Sayısal değerleri düzenleme yeri
Python = Bu değerlerin 120-180 günlük ekonomide ne sonuç verdiğini test eden simülasyon
Godot = Sadece onaylanmış değerleri kullanan oyun tarafı
```

Yani tek başına Excel yeterli değildir. Tek başına Python da doğru çalışma ortamı değildir.

Doğru rol ayrımı:

| Katman | Rol |
|-------|-----|
| Excel / CSV | Değerleri tablo halinde düzenleme, gözle kontrol etme, hızlı değişiklik yapma. |
| Python simülasyon | 120-180 günlük ekonomi sonuçlarını, rank pacing'i, route kârlılığını ve prosperity davranışını test etme. |
| Godot | Test edilmiş ve onaylanmış verileri oyun içinde kullanma. |

---

## Neden Sadece Excel Yetmez?

Excel şu işler için çok uygundur:

- Ürün listesi tutmak.
- Base price değerleri girmek.
- Şehir başlangıç nüfuslarını karşılaştırmak.
- Üretim ve tüketim tablolarını görmek.
- Route mesafelerini düzenlemek.
- Kontrat ödül katsayılarını hızlı değiştirmek.
- Rank eşiklerini tek tabloda görmek.

Ancak Ironmere ekonomisi döngüsel çalışır:

```text
Üretim stoğu artırır
-> tüketim stoğu azaltır
-> stok fiyatı değiştirir
-> oyuncu veya otomasyon ticaret yapar
-> şehir stoğu tekrar değişir
-> demand satisfaction değişir
-> prosperity değişir
-> demand değişir
-> fiyat tekrar değişir
```

Bu döngüyü 120-180 gün boyunca takip etmek Excel'de hızla karmaşıklaşır.

Excel'de cevaplaması zorlaşan sorular:

- 180 gün sonunda oyuncu kaç gold'a ulaşır?
- Patrician victory 120-180 gün arasında geliyor mu?
- Bir şehir sürekli shortage döngüsüne giriyor mu?
- Ironmere çok fazla iron üretip fiyatı sürekli çökertiyor mu?
- Bread route'u oyunu kıracak kadar kârlı mı?
- Trading Post yatırımını 5 günde çıkarıp fazla mı güçlü oluyor?
- Caravan Master hiç kâra geçmiyor mu?
- Kontratlar manuel ticareti eziyor mu?
- Prosperity artışı çok hızlı mı, çok yavaş mı?

Bu sorular için simülasyon gerekir.

---

## Neden Sadece Python Yetmez?

Python simülasyon için çok uygundur ama tasarım değerlerini elle girmek, karşılaştırmak ve düzenlemek için Excel kadar rahat değildir.

Örneğin ürünleri şu şekilde görmek gerekir:

| Item | Category | Base Price | Daily Demand | Stock Cap | Produced In |
|------|----------|------------|--------------|-----------|-------------|
| Wheat | Raw | 8 | 12 | 300 | Ashford |
| Bread | Survival | 18 | 10 | 220 | Ashford |
| Iron Ore | Raw | 12 | 8 | 300 | Ironmere |
| Tool | Processed | 35 | 3 | 120 | Ironmere |
| Grapes | Raw | 10 | 9 | 260 | Stonebridge |
| Wine | Luxury | 45 | 2 | 100 | Stonebridge |

Bu tür değerleri Excel'de görmek ve değiştirmek daha hızlıdır.

Bu nedenle Python veri yazma yeri değil, test motoru olmalıdır.

---

## Önerilen Veri Akışı

İlk çalışma akışı:

```text
balance_data.xlsx
      ↓ export
items.csv / towns.csv / production.csv / routes.csv / etc.
      ↓
Python balance simulation
      ↓
raporlar ve problem listesi
      ↓
Excel/CSV değer revizyonu
      ↓
tekrar simülasyon
      ↓
onaylanmış değer seti
      ↓
Godot data dosyaları
```

Bu akışın amacı:

- Değerleri kolay düzenlemek.
- Simülasyonla etkilerini görmek.
- Hedef dışı sonuçları erkenden yakalamak.
- Godot tarafına yalnızca test edilmiş verileri taşımak.

---

## Excel / CSV Ana Veri Yapısı

Başlangıçta tek bir Excel dosyası kullanılabilir:

```text
balance_data.xlsx
```

Bu dosya daha sonra CSV olarak dışarı aktarılabilir:

```text
items.csv
towns.csv
town_stocks.csv
production.csv
recipes.csv
routes.csv
contracts.csv
ranks.csv
automation.csv
price_curves.csv
season_modifiers.csv
```

MVP aşamasında Excel insan tarafından düzenlenen ana kaynak olabilir. Godot entegrasyonu için CSV/JSON export tercih edilmelidir.

---

## Sekme 1 — Items

Ürünlerin temel değerleri burada tutulur.

| Alan | Açıklama |
|------|----------|
| item_id | Teknik ürün adı. Örnek: `bread`, `wheat`, `iron_ore`. |
| display_name | Oyunda görünen ad. |
| category | Survival, Raw Material, Processed, Luxury / Comfort. |
| base_price | 14 günlük stok seviyesinde normal fiyat. |
| base_daily_demand_per_1000_pop | 1000 nüfus başına günlük temel talep. |
| demand_tags | food, comfort, luxury, construction, industry, military gibi etiketler. |
| cargo_size | Kargo kapasitesi hesabı için birim yük. |
| stock_cap_base | Şehirde başlangıç stok kapasitesi. |
| is_tradeable | Oyuncu tarafından alınıp satılabilir mi? |
| notes | Tasarım notu. |

Örnek:

| item_id | category | base_price | base_daily_demand_per_1000_pop | demand_tags | stock_cap_base |
|---------|----------|------------|--------------------------------|-------------|----------------|
| wheat | Raw Material | 8 | 8 | food | 300 |
| bread | Survival | 18 | 10 | food | 220 |
| iron_ore | Raw Material | 12 | 5 | industry | 300 |
| tool | Processed | 35 | 3 | construction, industry | 120 |
| grapes | Raw Material | 10 | 6 | luxury | 260 |
| wine | Luxury / Comfort | 45 | 2 | comfort, luxury | 100 |

### Items Tablosunun Rolü

Bu tablo tüm ekonominin merkezidir.

- Fiyat hesapları `base_price` ile başlar.
- Tüketim `base_daily_demand_per_1000_pop` ile başlar.
- Demand satisfaction `demand_tags` üzerinden okunur.
- Market kapasitesi `stock_cap_base` ile başlar.
- Kontrat ödülleri ürün fiyatına bağlı olabilir.

---

## Sekme 2 — Towns

Şehirlerin başlangıç değerleri burada tutulur.

| Alan | Açıklama |
|------|----------|
| town_id | Teknik şehir adı. |
| display_name | Oyunda görünen şehir adı. |
| start_population | Başlangıç nüfusu. |
| start_prosperity | Başlangıç prosperity değeri. |
| faction | Şehrin bağlı olduğu faksiyon. |
| identity | Farming, mining, wine gibi ekonomik kimlik. |
| prosperity_band | Başlangıçta Poor / Growing / Prosperous gibi okunabilir sınıf. |
| notes | Tasarım notu. |

Örnek başlangıç yönü:

| town_id | population | prosperity | identity |
|---------|------------|------------|----------|
| ashford | 1200 | 25 | Farming / Bread |
| ironmere | 1000 | 22 | Mining / Iron |
| stonebridge | 900 | 28 | Grapes / Wine |

Bu değerler kesin final sayı değildir. Amaç 3 şehri benzer güçte ama farklı ekonomik karakterde başlatmaktır.

---

## Sekme 3 — Town Stocks

Her şehirde her ürünün başlangıç stoğu ve kapasitesi burada tutulur.

| Alan | Açıklama |
|------|----------|
| town_id | Şehir. |
| item_id | Ürün. |
| start_stock | Başlangıç stoğu. |
| stock_cap | Şehirdeki maksimum market stoğu. |
| target_stock_days | Bu ürün için hedef stok günü. MVP'de çoğunlukla 14 gün referans alınır. |
| notes | Tasarım notu. |

Örnek:

| town_id | item_id | start_stock | stock_cap |
|---------|---------|-------------|-----------|
| ashford | wheat | 180 | 300 |
| ashford | bread | 120 | 220 |
| ironmere | iron_ore | 180 | 300 |
| ironmere | tool | 50 | 120 |
| stonebridge | grapes | 140 | 260 |
| stonebridge | wine | 40 | 100 |

### Bu Sekmenin Önemi

Fiyatın ana gövdesi stok/günlük talep oranından geldiği için başlangıç stoğu ilk 20-40 günün ekonomik hissini belirler.

- Stok çok düşükse oyun hemen shortage ile başlar.
- Stok çok yüksekse ticaret fırsatı oluşmaz.
- Uzman şehir kendi malında fazla stokla başlamalıdır.
- İthal ürünlerde daha düşük stok olabilir.

---

## Sekme 4 — Production

Şehirlerin günlük üretim değerleri burada tutulur.

| Alan | Açıklama |
|------|----------|
| town_id | Üreten şehir. |
| item_id | Üretilen ürün. |
| base_daily_production | Günlük temel üretim. |
| requires_recipe | Recipe input gerekiyor mu? |
| season_profile | Mevsim etkisi var mı? |
| production_type | Natural resource / processed / abstract. |
| upgrade_group | İleride upgrade ile artacak üretim grubu. |
| notes | Tasarım notu. |

Örnek:

| town_id | item_id | base_daily_production | season_profile |
|---------|---------|-----------------------|----------------|
| ashford | wheat | 25 | grain_seasonal |
| ashford | bread | 12 | none |
| ironmere | iron_ore | 22 | none |
| ironmere | iron_bar | 8 | none |
| ironmere | tool | 5 | none |
| stonebridge | grapes | 20 | grape_seasonal |
| stonebridge | wine | 6 | none |

### Production Tasarım İlkesi

```text
Her şehir kendi uzman ürününde fazla üretmeli.
Kendi üretmediği ama ihtiyaç duyduğu ürünlerde dışa bağımlı olmalı.
```

Bu olmazsa ticaret sebebi doğmaz.

---

## Sekme 5 — Recipes

İşlenmiş ürünlerin input-output ilişkisi burada tutulur.

| Alan | Açıklama |
|------|----------|
| output_item_id | Üretilen ürün. |
| input_item_id | Gerekli input. |
| input_qty | Gerekli input miktarı. |
| output_qty | Üretilen output miktarı. |
| efficiency | Gerekirse verim katsayısı. |
| notes | Tasarım notu. |

Örnek:

| output | input | input_qty | output_qty |
|--------|-------|-----------|------------|
| bread | wheat | 2 | 1 |
| wine | grapes | 3 | 1 |
| iron_bar | iron_ore | 2 | 1 |
| tool | iron_bar | 2 | 1 |

### Recipe Tasarım İlkesi

Input eksikliği doğrudan fiyat çarpanı yaratmamalıdır. Input eksikliği output üretimini azaltır; output stoğu zamanla düşer; fiyat stok üzerinden dolaylı olarak yükselir.

---

## Sekme 6 — Routes

Şehirler arası mesafe, seyahat süresi ve risk burada tutulur.

| Alan | Açıklama |
|------|----------|
| from_town | Başlangıç şehri. |
| to_town | Hedef şehir. |
| distance | Soyut mesafe puanı. |
| travel_days | Seyahat süresi. |
| risk_level | low / medium / high. |
| attack_risk | Sayısal risk değeri. |
| route_type | road / river / mountain gibi ileride kullanılabilecek sınıf. |
| notes | Tasarım notu. |

MVP için önerilen basit yapı:

| Rota Tipi | Travel Days | Tasarım Yorumu |
|-----------|-------------|----------------|
| Yakın rota | 2 gün | Hızlı ticaret ve erken oyun için uygun. |
| Orta rota | 3 gün | Ana ticaret kararlarının çoğu için ideal. |
| Uzak rota | 4 gün | Daha fazla planlama ve kargo bağlama maliyeti yaratır. |

3 şehirli MVP için başlangıç önerisi:

| From | To | Travel Days | Risk |
|------|----|-------------|------|
| Ashford | Ironmere | 2 | low |
| Ironmere | Stonebridge | 2 | medium |
| Ashford | Stonebridge | 3 | medium |

### Route Tasarım İlkesi

- 1 günlük rota fazla hızlı olabilir; fiyat farkları çok kolay sömürülür.
- 5+ günlük rota MVP'de yavaş hissettirebilir.
- 2-4 gün arası, 3 şehirli MVP için yeterli ağırlık verir.

---

## Sekme 7 — Price Curves

Kategori bazlı fiyat eğrileri burada tutulur.

Mevcut tasarım yönü:

| Category | 0 Day Stock | 14 Day Stock | 42+ Day Stock | Karakter |
|----------|-------------|--------------|---------------|----------|
| Survival | x3.0 | x1.0 | x0.50 | Kıtlık sert, bolluk kontrollü. |
| Raw Material | x2.2 | x1.0 | x0.45 | Ticaret fırsatı var ama aşırı oynak değil. |
| Processed | x2.6 | x1.0 | x0.50 | Kıtlık primi yüksek. |
| Luxury / Comfort | x1.8 | x1.0 | x0.45 | Stok eğrisi daha yumuşak. |

Bu tablo MVP'de büyük ölçüde karar verilmiş fiyat omurgasını temsil eder. Balance testleriyle gerekirse çarpanlar revize edilebilir.

---

## Sekme 8 — Contracts

MVP Delivery kontratlarının miktar ve ödül değerleri burada tutulur.

| Alan | Açıklama |
|------|----------|
| rank_min | Kontratın çıkabileceği minimum rank. |
| min_qty | Minimum taşıma miktarı. |
| max_qty | Maksimum taşıma miktarı. |
| reward_multiplier | Gold ödül katsayısı. |
| rep_reward | Faction rep ödülü. |
| deadline_days | Deadline süresi. |
| fail_rep_penalty | Başarısızlık rep cezası. |
| notes | Tasarım notu. |

Başlangıç yönü:

| Rank | Min Qty | Max Qty | Ortalama Ödül Hissi |
|------|---------|---------|----------------------|
| Peddler | 8 | 15 | 35-75g |
| Trader | 12 | 22 | 60-120g |
| Merchant+ | 18 | 35 | 100-220g |

Ödül hedefi:

```text
Kontrat ödülü = aynı taşıma kapasitesiyle yapılabilecek normal ticaret kârının yaklaşık 1.2x - 1.5x'i
```

---

## Sekme 9 — Ranks

Rank eşikleri burada tutulur.

| Rank | Gold Required | City Requirement | Other Requirement | Unlock |
|------|---------------|------------------|-------------------|--------|
| Trader | 500 | - | - | Caravan upgrades, 1 master |
| Merchant | 1500 | 1 Growing city | - | Trading Posts, 2 master |
| Guild Master | 4000 | 2 Growing + 1 Prosperous | 2 Post | Urgent contracts later, 4 master |
| Patrician | 10000 | 3 Prosperous city | - | Victory, 6 master |

Bu değerler `mvp_balance.md` içindeki 120-180 gün victory hedefiyle test edilmelidir.

---

## Sekme 10 — Automation

Trading Post ve Caravan Master maliyetleri burada tutulur.

| Alan | Açıklama |
|------|----------|
| automation_type | trading_post, apprentice_master, runner, hauler, veteran vb. |
| unlock_rank | Açıldığı rank. |
| hire_or_build_cost | İşe alma veya kurulum maliyeti. |
| daily_upkeep | Günlük gider. |
| capacity | Depo veya taşıma kapasitesi. |
| speed | Master için hız. |
| bargain | Master için pazarlık statı. |
| courage | Master için risk/attack dayanımı. |
| notes | Tasarım notu. |

Başlangıç yönü:

| Type | Cost | Upkeep | Rol |
|------|------|--------|-----|
| Trading Post | 300 | 8/day | Şehir içi market-depo otomasyonu. |
| Apprentice Master | 120-180 | 3-4/day | İlk otomasyon denemesi. |
| Runner | 220-300 | 5-6/day | Hızlı ama düşük kapasite. |
| Hauler | 350-500 | 7-9/day | Yüksek kapasite. |
| Broker / Veteran | 700+ | 12+/day | Late-game optimizasyon. |

---

## Sekme 11 — Season Modifiers

Mevsimsel üretim ve tüketim etkileri burada tutulur.

| Alan | Açıklama |
|------|----------|
| season | spring / summer / autumn / winter. |
| item_id | Etkilenen ürün. |
| production_multiplier | Üretim çarpanı. |
| demand_multiplier | Gerekirse tüketim çarpanı. |
| notes | Tasarım notu. |

MVP'de mevsim fiyatı doğrudan çarpmamalıdır. Mevsim üretim veya tüketim akışını etkiler; fiyat stok üzerinden dolaylı değişir.

---

## Python Simülasyon Katmanı

Python tarafında başlangıç için 3 küçük araç yeterlidir.

Tasarım modu açısından bu bölüm kod yazma talimatı değildir. Yalnızca ileride kurulacak test aracının görevlerini tanımlar.

---

## Araç 1 — Balance Loader

Görevi:

```text
Excel / CSV dosyalarını okur
verileri doğrular
hatalı veya eksik değerleri raporlar
```

Kontrol etmesi gerekenler:

- Her item'ın `base_price` değeri var mı?
- Her item'ın category değeri geçerli mi?
- Her town için population ve prosperity var mı?
- Her town/item stok satırı geçerli bir item'a mı bağlı?
- Production satırındaki item gerçekten Items tablosunda var mı?
- Recipe input ve output item'ları mevcut mu?
- Route çift yönlü tanımlı mı veya sistem tek yönlü route'u bilinçli mi kullanıyor?
- Rank gold değerleri artan sırada mı?
- Automation cost/upkeep değerleri negatif değil mi?
- Contract quantity değerleri mantıklı mı?
- Her şehir en az bir üretim kimliğine sahip mi?

Bu araç olmadan yanlış veri sessizce simülasyonu bozabilir.

---

## Araç 2 — Economy Simulation

Görevi 120-180 günlük ekonomi akışını simüle etmektir.

Günlük akış mevcut tasarım kararlarıyla uyumlu şekilde şöyle olmalıdır:

```text
1. Player upkeep / debt
2. Şehir üretim fazı
3. Şehir tüketim fazı
4. Nüfus / prosperity güncellemesi
5. Market fiyatlarının güncellenmesi
6. Trading Post auto-trade
7. Caravan Master route işlemleri
8. NPC trader işlemleri
9. Kontrat / rank / gün sonu kontrolleri
```

Simülasyon şu verileri üretmelidir:

- Gün gün oyuncu gold değeri.
- Gün gün rank durumu.
- Hangi gün Trader / Merchant / Guild Master / Patrician olduğu.
- Her şehirde ürün stokları.
- Her şehirde fiyatlar.
- Her şehirde prosperity ve population değişimi.
- Her ürün için shortage/surplus günleri.
- Trading Post gross/upkeep/net sonucu.
- Caravan Master route gross/upkeep/net sonucu.
- Kontrat gelirleri.
- Debt'e girilen günler.
- Game over olup olmadığı.

---

## Araç 3 — Scenario Runner

Farklı oyuncu davranışlarını test eder.

Başlangıç senaryoları:

| Senaryo | Amaç |
|---------|------|
| Manual Trader | Oyuncu sadece manuel ticaretle ne kadar ilerliyor? |
| Contract Focused | Kontratlar fazla mı güçlü? |
| First Trading Post | İlk post yatırımını kaç günde çıkarıyor? |
| First Caravan Master | Master route kâra ne zaman geçiyor? |
| Full MVP Run | Patrician 120-180 gün arasında geliyor mu? |

Her senaryo aynı balance data dosyasını kullanmalı, sadece oyuncu davranışı farklı olmalıdır.

---

## Simülasyon Raporu Formatı

Başlangıçta grafik şart değildir. Basit metin/tablo raporu yeterlidir.

Örnek rapor:

```text
Scenario: Full MVP Run

Day to Trader: 14
Day to Merchant: 38
Day to Guild Master: 82
Day to Patrician: 147

Final Gold: 12,450
Total Trading Posts: 3
Total Caravan Masters: 2

Ashford Prosperity: 68
Ironmere Prosperity: 71
Stonebridge Prosperity: 66

Average Daily Net Profit:
Day 1-30: 32g
Day 31-60: 74g
Day 61-100: 143g
Day 101-150: 285g

Result:
PASS — Victory inside 120-180 day target.
```

Bu raporun amacı sayıları tartışmayı kolaylaştırmaktır.

---

## Parametre Taraması

Python'un en büyük faydası çok sayıda kombinasyonu hızlı denemektir.

Örnek taranabilecek değerler:

```text
Bread base_price: 16 / 18 / 20 / 22
Wheat production: 18 / 22 / 26
Trading Post upkeep: 6 / 8 / 10
Contract reward multiplier: 1.2 / 1.35 / 1.5
Travel days: 2 / 3 / 4
Prosperity clamp: -2/+1 veya -3/+2
```

Bu tarama sonucunda şu sorular cevaplanabilir:

- Hangi değer setinde Patrician 120-180 gün arasında geliyor?
- Hangi değer setinde ekonomi fazla hızlı büyüyor?
- Hangi değer setinde oyun gereksiz uzuyor?
- Hangi ürün veya route oyunu kırıyor?
- Hangi şehir sürekli geri kalıyor?
- Hangi automation cost değeri daha sağlıklı net margin üretiyor?

---

## Çıktıların Yorumlanması

Simülasyon tek başına karar vermez. Simülasyon yalnızca problemi görünür hale getirir.

Örnek yorumlar:

```text
Bu değerlerle oyun 96 günde bitiyor -> ekonomi fazla hızlı.
Bu değerlerle oyun 230 günde bitiyor -> ekonomi fazla yavaş.
Bu değerlerle Ironmere sürekli fakirleşiyor -> üretim/tüketim dengesiz.
Bu değerlerle Bread route aşırı güçlü -> fiyat/demand/üretim ayarı bozuk.
Bu değerlerle Trading Post 5 günde kendini çıkarıyor -> post fazla güçlü.
Bu değerlerle Caravan Master hiç kâra geçmiyor -> hire/upkeep veya route kârı zayıf.
```

Tasarım kararı bu yorumlardan sonra verilir.

---

## Önerilen Dosya Yapısı

İleride kodlama modunda uygulanacak olası yapı:

```text
docs/design/mvp_balance.md
docs/design/balance_workflow.md

balance_data.xlsx

data/balance/items.csv
data/balance/towns.csv
data/balance/town_stocks.csv
data/balance/production.csv
data/balance/recipes.csv
data/balance/routes.csv
data/balance/contracts.csv
data/balance/ranks.csv
data/balance/automation.csv
data/balance/price_curves.csv
data/balance/season_modifiers.csv

tools/balance_sim/balance_loader.py
tools/balance_sim/economy_sim.py
tools/balance_sim/scenario_runner.py
tools/balance_sim/reports/
```

Tasarım modu aktifken bu dosyalar oluşturulmayacak veya kod yazılmayacaktır. Bu bölüm yalnızca ilerideki uygulama yönünü tarif eder.

---

## Çalışma Sırası

### Aşama 1 — Master Balance Data Oluştur

İlk olarak tüm sayısal değerler tek yerde toplanır:

```text
items
towns
town_stocks
production
recipes
routes
contracts
ranks
automation
price_curves
season_modifiers
```

Bu aşamada mükemmel sayı aranmaz. Amaç sistemin çalışacağı makul ilk değerleri koymaktır.

### Aşama 2 — Excel Seviyesinde Hızlı Kontrol

Excel içinde gözle ve basit formüllerle kontrol edilir:

- 14 günlük stok karşılığı kaç ürün ediyor?
- Bir şehir günlük ne kadar tüketiyor?
- Üretim tüketimi karşılıyor mu?
- Bread normal fiyatı kaç?
- Ashford -> Ironmere route kârı yaklaşık kaç?
- Trading Post günlük upkeep'i kaç satışla kapanıyor?
- Bir kontrat ödülü manuel ticarete göre fazla mı güçlü?

### Aşama 3 — Python Simülasyon

Excel'de makul görünen değerler 120-180 günlük simülasyona sokulur.

Bu aşamada gerçek problemler görünür:

- Bir ürün 40. günden sonra sürekli sıfır stokta kalır.
- Bir şehir sürekli prosperity kaybeder.
- Bir route aşırı kâr üretir.
- Kontratlar rank atlamayı çok hızlandırır.
- Trading Post kendini çok erken çıkarır.
- Caravan Master hiç kâra geçmez.
- Victory hedef süreden erken veya geç gelir.

### Aşama 4 — Değer Revizyonu

Simülasyon sonucuna göre Excel/CSV değerleri revize edilir.

Örnek revizyonlar:

- Base price düşürme/artırma.
- Production değerini azaltma/artırma.
- Demand değerini değiştirme.
- Travel days değerini artırma.
- Contract multiplier düşürme.
- Trading Post upkeep artırma.
- Master hire cost düşürme.
- Prosperity clamp değiştirme.

### Aşama 5 — Onaylı Değerleri Oyuna Aktar

Playtest hedeflerine yakın sonuç veren değer seti Godot tarafına aktarılır.

Godot tarafında amaç sayıları tekrar tasarlamak değil, onaylanmış veriyi kullanmaktır.

---

## Temel Balance Felsefesi

Tek tek sayılar önce değil, hedefler önce belirlenmelidir.

Önce hedefler:

```text
Patrician 120-180 günde gelecek.
İlk Trading Post 15-30 günde kendini çıkaracak.
İlk Caravan Master 20-45 günde kendini çıkaracak.
İyi manuel rota %20-%45 brüt kâr verecek.
Kontrat normal ticaret kârının 1.2x-1.5x'i olacak.
```

Sonra değerler bu hedeflere göre ayarlanmalıdır.

Yanlış yaklaşım:

```text
Bread fiyatı 18 olsun mu 22 olsun mu?
```

Doğru yaklaşım:

```text
Bread fiyatı, Ashford -> Ironmere iyi rotasında %20-%45 brüt kâr üretiyor mu?
Bu rota oyuncuyu 120-180 gün victory hedefinden saptırıyor mu?
```

---

## MVP İçin İlk Net Karar

MVP balance sistemi için önerilen ana karar:

```text
Sayısal balance değerleri önce Excel/CSV tablolarında tutulacak.
Python bu değerleri okuyup 120-180 günlük simülasyon yapacak.
Godot tarafı en son onaylanmış CSV/JSON değerleri kullanacak.
```

Bu karar şu anda uygulama kararı değil, tasarım yönüdür.

---

## Açık Sorular

- Ana düzenleme formatı ilk aşamada Excel mi olacak, yoksa doğrudan CSV mi kullanılacak?
- `balance_data.xlsx` repo içinde tutulacak mı, yoksa sadece CSV exportları mı versiyonlanacak?
- Python simülasyon Godot'taki ekonomi kodunun birebir kopyası mı olacak, yoksa daha sade bağımsız test modeli mi olacak?
- Simülasyon hangi oyuncu davranışlarını modelleyecek?
- Full MVP Run senaryosunda oyuncu ne kadar optimal davranacak?
- NPC trader davranışı simülasyonda ne kadar detaylı temsil edilecek?
- Balance raporları sadece metin/tablo mu olacak, yoksa grafik/CSV çıktı da üretilecek mi?

---

## Tartışma Notları

- [2026-06-04] Sayısal balans değerlerinin tek tek elle seçilmemesi gerektiği, Excel/CSV + Python simülasyon + Godot veri akışıyla yönetilmesi gerektiği kaydedildi. Excel/CSV değer düzenleme ve gözle kontrol yeri; Python 120-180 günlük ekonomi simülasyonu ve senaryo testi yeri; Godot ise onaylanmış veriyi kullanan oyun tarafı olarak ayrıştırıldı. Items, Towns, Town Stocks, Production, Recipes, Routes, Price Curves, Contracts, Ranks, Automation ve Season Modifiers tabloları önerildi. Balance Loader, Economy Simulation ve Scenario Runner şeklinde üç parçalı Python test aracı yönü belirlendi. Bu doküman tasarım yönü niteliğindedir; tasarım modu aktifken kod veya data dosyası oluşturulmayacaktır.
