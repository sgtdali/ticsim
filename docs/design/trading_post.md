# Trading Post & Caravan Master Design

## Trading Post (Karar verilmiş)

- Açılış: Merchant rank, 300 gold.
- Depo kapasitesi: 50 birim.
- Upkeep: 8 gold/gün.
- Debt 30 günde auto-trade durur. 60 günde en değerli post suspended olur.

**Otomasyon mantığı:**
Buy rule: fiyat limitin altındaysa + depot_limit dolmadıysa + markette stok varsa → alır.
Sell rule: fiyat limitin üstündeyse + depot_limit aşıldıysa + markette yer varsa → satar.

Her rule her gün bir status alır (active, waiting_price, waiting_stock, waiting_market, depot_full, depot_empty). Sadece active olanlar işlem yapar.

## Caravan Master (Karar verilmiş)

- Her master bir rota üzerinde çalışıyor, Trading Post depoları arasında mal taşıyor.
- Rota: en az 2 durak, her durakta bir Trading Post şart.
- Her durakta "al" veya "sat" kuralı: hangi mal, fiyat limiti, max miktar.
- Master: depot'tan alıp başka depot'a satıyor — market'a doğrudan müdahil değil.

**Master özellikleri (1-5 arası, seviye atladıkça):
- Hız: -%10/puan (max -%40 seyahat süresi)
- Kapasite: 15 + 5/puan
- Pazarlık: +%0.5/puan alım indirimi & satış bonusu
- Cesaret: -%3/puan saldırı riski

XP: durak başına 25, seviye başına level×100 threshold. Max seviye 5.

**Rank cap:** 0 / 1 / 2 / 4 / 6 (Peddler→Patrician).

**Tek sabit aday:** Şu an hire aksiyon 120g+4g/gün sabit bir master üretiyor.

## Açık Sorular

**Caravan Master aday sistemi?**
Şu an tek tip master var (120g hire, 4g/gün). Farklı özellik dağılımlı adaylar olmalı mı?
- Örnek: Hız odaklı (ucuz ama zayıf savunma), Cesur (pahalı ama az kayıp), Uzman (sadece belirli mallar).
- Adaylar belirli aralıklarla "yenileniyor" mu (refresh mantığı)?

**Master envanteri ve market ilişkisi**
Master depot'tan alıp depot'a satıyor. Hiçbir zaman doğrudan market'a girmesi planlanıyor mu? Şu an tam otomatik bir döngü oluşturmak için: market → depot (post buy rule), depot → master envanter (master al), master → başka depot (master sat), depot → market (post sell rule). Bu zincir uzun ama kasıtlı mı?

**Post+Master koordinasyonu**
Trading Post buy rule mal satın alıp depoya koyuyor. Caravan Master da depodaki malı başka depoya taşıyor. Bu iki sistem ayrı UI'dan yönetiliyor. Oyuncu bu zinciri zihinsel olarak kurabilmeli — yeterince görünür mü?

**Suspend sonrası yeniden açış**
Debt 60 günde post suspended olunca oyuncu onu tekrar açmak için 300 gold daha ödemek zorunda mı? Evet — bu recover yolunu kasıtlı olarak zorlaştırıyor.

## Gerilimler

**Otomasyon karmaşıklığı**
Post buy/sell kuralları + master rota kuralları + master özellik sistemi birlikte oldukça derin. Erken oyuncunun bunu kavraması zor olabilir. Öğrenme eğrisi kontrolü nasıl yapılacak?

**Master ve player yarışması**
Oyuncu bir kasabada ucuz malı bulmak isterken post buy rule'u o malı zaten almış olabilir. Ya da tam tersi — master bir malı taşırken oyuncu onu başka yere satmak isteyebilir. Bu çatışma kasıtlı mı (kaynak yönetimi), rahatsız edici mi?

## Tartışma Notları

*(Boş)*
