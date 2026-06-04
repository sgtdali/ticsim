# MVP Balance Design

Bu dosya MVP seviyesindeki ekonomik balans hedeflerini, pacing aralıklarını ve ilk test değerlerini toplar.

MVP balansının amacı tam ölçekli, kusursuz ekonomi simülasyonu kurmak değildir. Amaç, 3 kasabalı dikey kesitte manuel ticaret, rank ilerlemesi, şehir prosperity'si, Trading Post otomasyonu ve Caravan Master route otomasyonunun birlikte çalıştığını kanıtlayan oynanabilir bir ekonomi temposu yakalamaktır.

---

## MVP Balance Rolü

MVP'de balans şu sorulara cevap vermelidir:

- Oyuncu oyunun temel ticaret mantığını kaç gün içinde öğrenir?
- İlk rank geçişleri ne kadar hızlı olmalıdır?
- Manuel ticaret, kontrat ve otomasyon birbirini ezmeden nasıl birlikte değer üretir?
- Trading Post ve Caravan Master yatırımları kaç günde geri dönmelidir?
- Şehir prosperity'si rank koşulu olarak anlamlı ama sıkıcı olmayan bir hızda nasıl büyür?
- 3 kasabalı ekonomide rota ezberi oluşmadan yeterli dinamizm nasıl korunur?
- Patrician victory ne erken ne de gereksiz uzun olacak şekilde hangi sürede hedeflenir?

---

## Kesinleşen Ana Karar

### MVP Victory Süresi

MVP için Patrician victory hedef süresi:

```text
120-180 oyun günü
```

Bu süre şu nedenle kabul edilmiştir:

- 80-120 gün bandı, otomasyon ekonomisinin kendini göstermesi için kısa kalabilir.
- 180+ gün bandı, yalnızca 3 kasabalı MVP'de tekrar hissini artırabilir.
- 120-180 gün, oyuncunun manuel ticaretten otomasyona geçmesini, en az birkaç ekonomik döngü görmesini ve mevsim etkilerini hissetmesini sağlar.
- Bu süre, MVP'nin "tam oyun" değil ama anlamlı bir ekonomi dikey kesiti olduğu fikriyle uyumludur.

Hedef akış:

```text
Manuel ticaret öğrenilir
-> küçük sermaye yapılır
-> rank açılır
-> Trading Post kurulur
-> Caravan Master ile şehirler arası otomasyon başlar
-> şehir prosperity büyütülür
-> Patrician victory alınır
```

---

## Hedef Pacing Aralığı

Aşağıdaki değerler ilk MVP balans hedefidir. Bunlar kesin final sayılar değil, implementasyon ve playtest sırasında kontrol edilecek başlangıç aralıklarıdır.

| Aşama | Hedef Süre | Tasarım Amacı |
|------|------------|---------------|
| Peddler -> Trader | 10-20 gün | Oyuncu market, stok, fiyat yönü ve basit rota mantığını öğrenir. |
| Trader -> Merchant | 25-45 gün | Oyuncu daha bilinçli rota seçer, kontratları kullanır, ilk otomasyon hedefini görür. |
| Merchant -> Guild Master | 60-90 gün | Trading Post kurulmuş olur; oyuncu şehir prosperity ve post ekonomisini yönetir. |
| Guild Master -> Patrician | 100-160 gün | Post + Master zinciri anlamlı hale gelir; 3 şehir prosperous hedefi tamamlanır. |
| Toplam Victory | 120-180 gün | MVP ekonomisi tamamlanmış hissi verir. |

Not: Aşamalar üst üste binen hedeflerdir. Örneğin Guild Master'a 80. gün civarında ulaşan oyuncunun Patrician'a 140. gün civarında ulaşması kabul edilebilir.

---

## Günlük Net Kâr Hedefleri

Rank gold eşikleri ancak oyuncunun günlük ortalama net kazancı ile anlamlı hale gelir. Bu nedenle her oyun aşaması için hedef net kâr bandı belirlenmelidir.

| Aşama | Oyuncu Durumu | Hedef Günlük Net Kâr |
|------|---------------|----------------------|
| Erken oyun | Manuel ticaret | 20-40g/gün |
| Trader | Manuel ticaret + küçük kontrat | 35-70g/gün |
| Merchant | 1 Trading Post + manuel destek | 60-120g/gün |
| Guild Master | Post + Master zinciri | 120-250g/gün |
| Patrician öncesi | 2-3 şehir otomasyon ağı | 200-400g/gün |

Bu hedefler şunları korumalıdır:

- Erken oyun tamamen yavaş ve cezalandırıcı olmamalıdır.
- Kontratlar manuel ticareti tamamen ezmemelidir.
- Trading Post tek başına oyunu bitiren para makinesi olmamalıdır.
- Caravan Master otomasyonu doğru kurulduğunda oyunun ana mid-game gelir motoruna dönüşmelidir.
- Upkeep değerleri oyuncunun net kâr hesabında görünür olmalıdır.

---

## Rank Balance Bağlantısı

Mevcut rank eşikleri:

| Rank | Gold | Şehir Koşulu | Diğer |
|------|------|--------------|-------|
| Trader | 500 | - | - |
| Merchant | 1.500 | 1 Growing city | - |
| Guild Master | 4.000 | 2 Growing + 1 Prosperous | 2 Post |
| Patrician | 10.000 | 3 Prosperous city | - |

Growing city = prosperity >= 30  
Prosperous city = prosperity >= 65

Bu eşikler MVP'de kullanılabilir görünüyor, ancak aşağıdaki tempo hedefleriyle test edilmelidir:

- Trader, oyuncu daha otomasyon açmadan ulaşılabilir olmalı.
- Merchant, oyuncuya Trading Post kurma hedefini makul sürede vermeli.
- Guild Master, oyuncudan sadece gold değil şehir geliştirme ve en az 2 Post yatırımı istemeli.
- Patrician, oyuncunun 3 kasabayı da prosperous seviyeye taşıdığı final hedef olmalı.

### Kontrol Edilecek Risk

Rank koşulları aynı anda sağlanmak zorunda olduğu için oyuncu şu durumda takılabilir:

```text
Gold yeterli ama prosperity eksik.
Prosperity yeterli ama gold eksik.
Debt olduğu için rank geçilemiyor.
```

Bu durum tasarımsal olarak kabul edilebilir; ancak UI oyuncuya "sonraki rank için eksik kalan net hedefi" açık göstermelidir.

---

## Manuel Ticaret Kâr Hedefi

Manuel ticaret MVP'nin öğrenme zemini olduğu için erken oyunda güçlü kalmalıdır.

Hedef brüt kâr bandı:

| Rota Kalitesi | Brüt Kâr Potansiyeli | Tasarım Yorumu |
|--------------|----------------------|----------------|
| İyi rota | %20-%45 | Oyuncu fiyat/stok farkını doğru okuduğunda ödüllendirilir. |
| Ortalama rota | %10-%25 | Güvenli ama çok hızlı büyütmeyen gelir. |
| Kötü rota | Zarar veya çok düşük kâr | Oyuncuya piyasa okumayı öğretir. |

Base spread alışta +%8, satışta -%8 olduğu için aynı şehirde anlık al-sat kârı kapalı kalmalıdır. Kâr şehirler arası stok/fiyat farkından gelmelidir.

### Manuel Ticaretin Rolü

Manuel ticaret:

- Pazar mantığını öğretir.
- Oyuncuya ilk sermayeyi kazandırır.
- Kontratlar için taşıma davranışını doğal hale getirir.
- Trading Post ve Caravan Master kurulmadan önce ana gelir motorudur.
- Otomasyon açıldıktan sonra bile fırsat kovalamak için anlamlı kalabilir.

---

## Kontrat Balance Hedefi

MVP'de kontratlar minimal tutulacaktır:

- Sadece Delivery kontrat tipi.
- Tek kontrat tier'ı.
- Ödül: gold + faction rep.
- Fail: ödülden mahrum kalma + küçük faction rep cezası.

Kontratların ana rolü:

```text
Erken oyunda güvenli gelir
+ oyuncuya rota öğretme
+ faction rep kazanımı
```

Kontratlar manuel ticareti ezmemelidir. Bu nedenle ödül hedefi:

```text
Kontrat ödülü = aynı taşıma kapasitesiyle yapılabilecek normal ticaret kârının yaklaşık 1.2x - 1.5x'i
```

Bunun nedeni:

- Kontrat belirli malı ve hedefi verdiği için oyuncuya daha güvenli bir karar sunar.
- Deadline riski ve taşıma yükü vardır.
- Ancak ödül çok yüksek olursa oyuncu market fırsatı aramak yerine sadece kontrat takip eder.

Başlangıç önerisi:

| Rank / Aşama | Kontrat Miktarı | Ortalama Ödül |
|-------------|-----------------|---------------|
| Peddler | 8-15 birim | 35-75g |
| Trader | 12-22 birim | 60-120g |
| Merchant+ | 18-35 birim | 100-220g |

### Kontrat Riskleri

- Ödül çok yüksek olursa manuel ticaret değersizleşir.
- Ödül çok düşük olursa kontrat yalnızca rep kazanma aracı olur.
- Fail cezası çok düşük kalırsa kontrat kabul etmek risksiz görünür.
- Fail cezası çok sert olursa oyuncu kontrat almaktan kaçınır.

MVP için fail cezası küçük tutulabilir; asıl ceza ödülden mahrum kalmak olmalıdır.

---

## Trading Post Balance Hedefi

Mevcut Trading Post temel değerleri:

| Kalem | Değer |
|------|-------|
| Açılış rank'ı | Merchant |
| Açılış maliyeti | 300g |
| Depo kapasitesi | 50 birim |
| Temel upkeep | 8g/gün |

Trading Post'un rolü şehir içi market <-> depo otomasyonudur. Tek başına şehirler arası ticaret yapmaz; Caravan Master ile birlikte otomasyon zincirine dönüşür.

### Net Kâr Hedefi

| Kurulum Kalitesi | Hedef Net Sonuç |
|------------------|-----------------|
| Kötü ayar | -5 / -15g gün |
| Ortalama ayar | +5 / +20g gün |
| İyi ayar | +20 / +50g gün |
| Çok iyi zincir | +50g/gün üzeri |

Bu hedefler şu tasarım niyetini korur:

- Oyuncu fiyat limitlerini kötü ayarlarsa zarar edebilir.
- Ortalama ayar küçük ama düzenli kâr sağlar.
- İyi ayar oyuncunun marketi doğru okuduğunu gösterir.
- Büyük para tek başına Post'tan değil, Post + Master + doğru şehir ağı zincirinden gelir.

### Trading Post Geri Dönüş Hedefi

300g açılış maliyeti için:

| Net Kâr | Geri Dönüş Süresi |
|--------|-------------------|
| 10g/gün | 30 gün |
| 20g/gün | 15 gün |
| 30g/gün | 10 gün |

MVP için sağlıklı hedef:

```text
İlk Trading Post yatırımını 15-30 gün arasında geri döndürmelidir.
```

Daha hızlı geri dönüş Trading Post'u zorunlu ve aşırı güçlü yapabilir. Daha yavaş geri dönüş ise oyuncunun otomasyona geçme isteğini azaltabilir.

---

## Caravan Master Balance Hedefi

Caravan Master şehirler arası depo <-> depo lojistiğidir. Doğrudan marketten alım-satım yapmaz. Bu nedenle gerçek değeri Trading Post kurallarıyla birlikte ortaya çıkar.

### Temel Tasarım Hissi

```text
İyi master pahalıdır ama doğru route'a bağlanırsa yatırımını çıkarır.
Kötü route'a bağlanırsa zarar ettirebilir.
Ucuz master erken otomasyon denemesi için uygundur.
Pahalı master late-game optimizasyon aracıdır.
```

Başlangıç önerisi:

| Master Tipi | Hire Cost | Upkeep | Geri Dönüş Hedefi | Rol |
|------------|-----------|--------|-------------------|-----|
| Apprentice | 120-180g | 3-4g/gün | 15-25 gün | İlk otomasyon denemesi. |
| Runner | 220-300g | 5-6g/gün | 20-35 gün | Hızlı, düşük kapasite. |
| Hauler | 350-500g | 7-9g/gün | 25-45 gün | Yüksek kapasite, yavaş. |
| Broker / Veteran | 700g+ | 12g+/gün | Late-game | Verimli ama ciddi işletme yükü. |

Bu değerler mevcut örnek yönlerle uyumludur:

```text
Runner örneği: 260g hire, 5g/day upkeep
Hauler örneği: 420g hire, 7g/day upkeep
```

### Caravan Master Riskleri

- Master çok ucuz olursa manuel ticaret çok erken devreden çıkar.
- Master çok pahalı olursa oyuncu otomasyon sistemini MVP süresinde deneyemeyebilir.
- Upkeep çok düşük olursa route her koşulda pozitif kâr üretir.
- Upkeep çok yüksek olursa oyuncu master kullanmayı cezalandırılmış gibi hisseder.
- Aday şansı çok düşük olursa oyuncu sistemden sinir olur.

MVP'de şehir bazlı 0-2 aday modeli korunmalıdır, ancak oyuncunun çok uzun süre hiç aday bulamaması engellenmelidir.

---

## Automation Zinciri Balance Hedefi

MVP'de asıl mid-game gelir şu zincirden gelmelidir:

```text
Ironmere Post ucuz Bread alır
-> Master Bread'i Ironmere deposundan yükler
-> Stonebridge deposuna indirir
-> Stonebridge Post fiyat uygunsa satar
-> Gross margin - upkeep = net margin
```

Automation UI gross, upkeep ve net margin'i birlikte göstermelidir.

### Zincir Kârlılık Hedefi

| Zincir Durumu | Hedef Sonuç |
|--------------|-------------|
| Eksik/kötü zincir | Zarar veya işlem bekleme |
| Basit doğru zincir | +20 / +60g gün |
| İyi optimize zincir | +60 / +150g gün |
| Geç oyun güçlü ağ | +200g/gün üzeri |

Otomasyon oyuncuya bedava para değil, yönetilebilir işletme sistemi gibi hissettirmelidir.

---

## Prosperity Balance Hedefi

Prosperity MVP'de iki nedenle kritiktir:

1. Rank koşullarına doğrudan bağlıdır.
2. Şehir ekonomisinin sağlıklı işleyip işlemediğini gösterir.

Mevcut eşikler:

```text
Growing city = prosperity >= 30
Prosperous city = prosperity >= 65
```

Mevcut demand satisfaction etkileri:

```text
Survival satisfaction %80+  -> prosperity +2
Survival satisfaction %40-80 -> prosperity -1
Survival satisfaction %40 altı -> prosperity -4
```

Ayrıca survival kötü satisfaction 3 gün birikirse nüfus -%3 azalır.

### Günlük Prosperity Clamp Önerisi

Bu konu hâlâ açık MVP kararıdır. Balance başlangıç önerisi:

```text
Günlük prosperity clamp: -3 / +2
```

Gerekçe:

- +2 mevcut iyi survival etkisiyle uyumludur.
- -3 oyuncuya şehir bozuluyor hissi verir ama -4 kadar sert değildir.
- 30'dan 65'e çıkmak teorik olarak en iyi durumda yaklaşık 18 gün sürer; yatırım maliyeti, tedarik eksikleri ve üç şehir hedefi bunu pratikte uzatır.
- MVP'de prosperity fazla yavaş olursa 3 kasabalı oyun gereksiz uzar.

Daha güvenli ama yavaş alternatif:

```text
Günlük prosperity clamp: -2 / +1
```

Bu alternatif daha kontrollüdür ama şehir geliştirme temposunu fazla yavaşlatabilir.

İlk öneri:

```text
MVP başlangıç testi için -3 / +2 kullanılmalı.
```

Bu değer, henüz kesin karar değildir; playtest ile kontrol edilmelidir.

---

## Prosperity Yatırım Balance Hedefi

Prosperity yatırımı MVP'de basit tutulacak, ancak bolluk spiralini kırmak için düz ve ucuz olmamalıdır.

Tasarım yönü:

- Düşük prosperity seviyelerinde yatırım ucuz olmalı.
- Orta seviyede yatırım bilinçli karar istemeli.
- Prosperous seviyeye yaklaşırken yatırım ciddi sermaye istemeli.
- Oyuncu sadece para basarak risksiz şekilde üç şehri prosperous yapamamalı.

Başlangıç band önerisi:

| Prosperity Bandı | Yatırım Hissi | Tasarım Rolü |
|------------------|---------------|--------------|
| 0-29 | Ucuz/toparlanabilir | Şehri Growing seviyeye taşımak ulaşılabilir. |
| 30-64 | Orta maliyetli | Merchant/Guild Master hedefi için planlama ister. |
| 65+ | Pahalı | Patrician hedefi için ciddi para yakıcı. |

Sayısal yatırım maliyetleri henüz kesinleşmemiştir. Bu dosya yalnızca pacing hedefini belirler.

---

## Debt Balance Hedefi

Mevcut MVP debt kararı:

- Gold negatife düşebilir.
- Negatif gold süresi sayılır.
- 60 gün negatif kalırsa game over tetiklenir.
- Otomasyon debt yüzünden durmaz.
- Borç kapatılırsa sayaç sıfırlanır.

MVP balans hedefi:

```text
Debt oyuncuya baskı kurmalı ama otomasyon sistemini bozarak ölüm sarmalı yaratmamalıdır.
```

### Debt Baskı Seviyesi

- 0-30 gün: oyuncu sorunu fark eder ve toparlanabilir.
- 30-60 gün: kritik dönem; oyuncu aktif karar almak zorunda kalır.
- 60. gün: game over.

Debt fee ve reputation penalty MVP'de opsiyonel/sade tutulabilir. Eğer eklenirse küçük başlamalıdır.

---

## 3 Kasabalı MVP Ekonomi Riski

MVP'de yalnızca 3 kasaba olduğu için rota ezberi riski yüksektir.

Bu risk şu sistemlerle azaltılmalıdır:

- Stok bazlı fiyat değişimi.
- Günlük tüketim.
- Mevsimsel üretim etkileri.
- NPC trader'ın arka plan stok dalgalandırması.
- Demand satisfaction ve prosperity değişimleri.
- Market tooltip ve şehir uyarılarının oyuncuya değişen fırsatları göstermesi.

Ancak MVP'de oyuncuya doğrudan "şuradan al, buraya sat" rota tavsiyesi verilmemelidir. Oyuncu fırsatı UI sinyallerinden kendisi okumalıdır.

---

## İlk Playtest Kontrol Senaryoları

MVP balansı test edilirken en az şu senaryolar ölçülmelidir:

### Senaryo 1 — Manuel Ticaret

Oyuncu yalnızca manuel ticaretle oynar.

Kontrol soruları:

- Trader'a 10-20 gün içinde ulaşabiliyor mu?
- Merchant'a ulaşmak çok sıkıcı oluyor mu?
- İyi rota ile kötü rota arasındaki fark hissediliyor mu?

### Senaryo 2 — Kontrat Ağırlıklı Erken Oyun

Oyuncu mümkün olduğunca kontrat yapar.

Kontrol soruları:

- Kontratlar manuel ticareti tamamen eziyor mu?
- Faction rep kazanımı spread bonusunu fazla hızlı büyütüyor mu?
- Fail cezası anlamlı mı?

### Senaryo 3 — İlk Trading Post

Oyuncu Merchant olur olmaz ilk Trading Post'u kurar.

Kontrol soruları:

- 300g yatırım 15-30 gün içinde geri dönüyor mu?
- Upkeep UI'da yeterince hissediliyor mu?
- Kötü fiyat limitleri zarar ettirebiliyor mu?

### Senaryo 4 — İlk Caravan Master

Oyuncu bir master işe alıp basit iki şehirli route kurar.

Kontrol soruları:

- Master yatırımı 20-45 gün bandında geri dönebiliyor mu?
- Route yanlış kurulursa zarar veya bekleme durumu oluşuyor mu?
- Master, manuel ticareti çok erken gereksiz hale getiriyor mu?

### Senaryo 5 — Full MVP Victory

Oyuncu hedefe uygun şekilde manuel ticaret + kontrat + Post + Master + prosperity yönetimi yapar.

Kontrol soruları:

- Patrician victory 120-180 gün bandında geliyor mu?
- 3 Prosperous city hedefi anlamlı çaba istiyor mu?
- Son 30 gün grind gibi hissettiriyor mu?
- Automation ağı oyuncuya net yönetim hissi veriyor mu?

---

## Açık Balance Soruları

- Günlük prosperity clamp kesin olarak `-3 / +2` mi olacak, yoksa daha yavaş `-2 / +1` mi seçilecek?
- Rank gold eşikleri mevcut haliyle 120-180 gün victory hedefini destekliyor mu?
- Kontrat ödülü manuel ticaret kârının 1.2x-1.5x'i olarak mı kalacak?
- Trading Post 300g açılış maliyeti ve 8g/gün upkeep ile doğru geri dönüş süresini veriyor mu?
- Caravan Master hire/upkeep değerleri archetype bazında hangi kesin sayılara bağlanacak?
- Prosperity yatırım maliyetleri 0-29 / 30-64 / 65+ bandlarında hangi sayılarla kurulacak?
- NPC trader stok dalgalandırması 3 kasabalı ekonomide rota ezberini kırmaya yetiyor mu?

---

## Tartışma Notları

- [2026-06-04] MVP balans için ayrı dosya açıldı. Patrician victory hedef süresi 120-180 oyun günü olarak kabul edildi. Manuel ticaret, kontrat, Trading Post, Caravan Master, automation zinciri, prosperity, debt ve playtest senaryoları için başlangıç balans hedefleri kaydedildi. Sayısal öneriler playtest başlangıç değeri olarak tutuldu; yalnızca 120-180 gün victory hedefi kesinleşmiş karar olarak işlendi.
