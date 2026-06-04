# Trading Post & Caravan Master Design

Bu dosya Trading Post ve Caravan Master otomasyon tasarımının giriş kapısıdır. Ayrıntılı kararlar artık konu dosyalarına ayrılmıştır.

## Dosya Haritası

| Dosya | Kapsam |
|-------|--------|
| [trading_post.md](trading_post.md) | Trading Post temel rolü, market-depo otomasyonu ve genel otomasyon zinciri |
| [trading_post_debt.md](trading_post_debt.md) | Debt, upkeep ve game over modeli |
| [caravan_master_routes.md](caravan_master_routes.md) | Caravan Master rolü, route atama, durak kuralları, live edit, temporary unload, route UI |
| [caravan_master_hiring.md](caravan_master_hiring.md) | Tavern üzerinden şehir bazlı Caravan Master adayları, aday kalitesi, archetype yönleri |

## Trading Post (Karar verilmiş)

- Açılış: Merchant rank, 300 gold.
- Depo kapasitesi: 50 birim.
- Upkeep: 8 gold/gün.
- Debt cezası artık Trading Post'u suspended hale getirmez ve mevcut Post/Route ağını bozmaz. Debt cezası ayrı debt modeli üzerinden uygulanır.
- Trading Post şehir içi market otomasyonudur: bulunduğu şehirde market ile oyuncu deposu arasında al/sat kurallarını işletir.

**Otomasyon mantığı:**

- Buy rule: fiyat limitin altındaysa + depot_limit dolmadıysa + markette stok varsa -> alır.
- Sell rule: fiyat limitin üstündeyse + depot_limit aşıldıysa + markette yer varsa -> satar.
- Her rule her gün bir status alır: `active`, `waiting_price`, `waiting_stock`, `waiting_market`, `depot_full`, `depot_empty`.
- Sadece `active` olan rule'lar işlem yapar.

## Otomasyon Rol Ayrımı (Karar verilmiş)

- Trading Post şehir içi market <-> depo otomasyonudur.
- Caravan Master şehirler arası depo <-> depo lojistiğidir.
- Caravan Master doğrudan marketten alım-satım yapmaz; market otomasyonu Trading Post'un rolüdür.
- Bu ayrım korunmalıdır; Master doğrudan markete girerse Trading Post'un stratejik rolü zayıflar.

## Patrician'dan Alınan Tasarım Dersleri

- Güçlü trade route hissi, oyuncunun her şehir/mal kombinasyonunu sürekli elle takip etmek zorunda kalmamasından gelir.
- Ancak bu oyunda otomasyon iki ayrı role bölünmelidir:
  - Trading Post: şehir içi market <-> depo otomasyonu.
  - Caravan Master: şehirler arası depo <-> depo lojistiği.
- Oyuncu öğrenme sırası şu şekilde olmalıdır:
  1. Manuel ticaretle fiyat/şehir/mal mantığını öğrenir.
  2. Trading Post ile şehir içi otomasyon kurar.
  3. Caravan Master ile şehirler arası otomasyon kurar.
- Caravan Master sistemi mid-game otomasyon katmanı olarak tasarlanmalıdır; erken oyunun temel ticaret öğrenimini atlatan bir kestirme olmamalıdır.

## UI / Okunabilirlik Notları

- Oyuncuya otomasyon zinciri açıkça gösterilmelidir.
- Örnek okunabilir zincir:

```text
Ironmere Post buys Bread under 22g -> Master loads Bread from Ironmere -> Master unloads Bread at Stonebridge -> Stonebridge Post sells Bread over 31g -> Expected margin: +9g/unit
```

- Bu zincir görünürlüğü, Post ve Master sistemlerinin ayrı UI'lardan yönetilmesinin yaratacağı zihinsel yükü azaltmak için ana çözüm yönüdür.
- Debt uyarıları global finance/debt uyarısı olarak gösterilmeli; Post/Route UI'ını bozacak şekilde değil.
- Route ekranında beklenen kârlılık gösterilecekse, bu bilgi Trading Post buy/sell fiyat kurallarından türetilmelidir.

## Açık Sorular

**Post+Master koordinasyonu okunabilirliği**
Trading Post buy rule mal satın alıp depoya koyuyor. Caravan Master da depodaki malı başka depoya taşıyor. Bu iki sistem ayrı UI'dan yönetiliyor. Oyuncu bu zinciri zihinsel olarak kurabilmeli; zincir ve beklenen margin yeterince görünür mü?

## Gerilimler

**Otomasyon karmaşıklığı**
Post buy/sell kuralları + master route kuralları + Load davranış modları + canlı rota düzenleme + master özellik sistemi birlikte oldukça derin. Erken oyuncunun bunu kavraması zor olabilir. Çözüm yönü: UI'da otomasyon zinciri, rota durakları, mal miktarları, Load davranışı ve beklenen margin açık gösterilmeli.

**Master ve player yarışması**
Oyuncu bir kasabada ucuz malı bulmak isterken post buy rule'u o malı zaten almış olabilir. Ya da tam tersi; master bir malı taşırken oyuncu onu başka yere satmak isteyebilir. Bu çatışma kasıtlı mı, kaynak yönetimi olarak mı okunmalı, yoksa rahatsız edici mi?

## Tartışma Notları

- [2026-06-04] Uzayan Trading Post & Caravan Master dokümanı parçalandı. Ana dosya Trading Post temel rolü ve otomasyon zinciri görünürlüğü için bırakıldı; debt modeli `trading_post_debt.md`, rota sistemi `caravan_master_routes.md`, aday/archetype kararları `caravan_master_hiring.md` dosyasına taşındı.
- [2026-05-31] Caravan Master sistemi Patrician trade route yaklaşımından ilhamla netleştirildi. Master doğrudan markete girmeyecek; otomasyon rol ayrımı Trading Post ve Caravan Master arasında korunacak.
