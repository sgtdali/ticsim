# Caravan Master Hiring & Tavern Design

## Temel Karar

Caravan Master işe alma sistemi global ve tek tuşluk bir aksiyon olmayacaktır. Caravan Master adayları şehir bazlı olarak Tavern / Inn üzerinden bulunur ve işe alınır.

Bu kararın amacı, Caravan Master otomasyonunun çok kolay erişilebilir olmasını engellemek ve oyuncuya Patrician tarzı “kaptan/master arama” hissi vermektir.

## İşe Alma Yeri

- Caravan Master adayları world map üzerindeki `Trade Routes` panelinden doğrudan işe alınmaz.
- Trade Routes paneli yalnızca mevcut master/route yönetimi için kullanılır.
- Yeni master işe alma yeri şehirlerdeki Tavern / Inn panelidir.
- Oyuncu bir şehre girdiğinde TownUI üzerinden Tavern panelini açabilir.
- Tavern paneli MarketUI gibi ayrı bir panel/screen olarak açılır; TownUI içinden erişilir.
- Tavern, TownUI içinde ayrı bir buton/entry point olarak bulunmalıdır.

Örnek akış:

```text
World Map → City → TownUI → Tavern → Caravan Master Candidates
```

## Şehir Bazlı Aday Havuzu

- Aday havuzu global değildir; şehir bazlıdır.
- Her şehir kendi Tavern aday havuzuna sahiptir.
- Her şehirde her zaman Caravan Master adayı bulunmaz.
- Bazı şehirlerde hiç aday çıkmayabilir.
- Oyuncu iyi master bulmak için şehirleri gezmek zorunda kalabilir.
- Bu durum erken/mid-game’de oyuncunun manuel ticarete devam etmesini ve dünyayı gezmesini teşvik eder.
- Eski genel "aynı anda 3 aday" fikri, şehir bazlı Tavern kararıyla daraltılmıştır: dünya genelinde birden fazla aday bulunabilir, ancak tek bir global işe alma havuzu yoktur.

Örnek:

```text
Ironmere Tavern
- No Caravan Master available

Stonebridge Tavern
- Garrick the Hauler
  Hire: 420g
  Upkeep: 7g/day
  Capacity: 4
  Speed: 2
  Courage: 3

Kingsport Tavern
- Rowan the Runner
  Hire: 260g
  Upkeep: 5g/day
  Speed: 4
  Capacity: 2
```

## Aday Çıkma Mantığı

- Her şehirde aday çıkması garanti değildir.
- Aday sayısı şehir başına düşük tutulmalıdır.
- Önerilen yön: şehir başına aynı anda 0-2 Caravan Master adayı.
- Adaylar periyodik olarak yenilenir.
- Mevcut genel refresh kararı 30 gün olarak korunabilir; ancak artık şehir bazlı aday havuzlarına uygulanmalıdır.
- Adaylar yenilenirken her şehir kendi aday durumunu yeniden roll eder.
- Eski tek sabit aday yaklaşımı (120g hire + 4g/gün) geçerli değildir; adayların stat dağılımı, hire cost ve daily upkeep değerleri farklı olacaktır.

## Aday Kalitesi

Aday kalitesi oyuncu rank’ına göre değişmelidir.

- Düşük ranklarda düşük statli ve ucuz adaylar daha sık çıkar.
- Rank yükseldikçe daha iyi stat kombinasyonlarına sahip adayların çıkma ihtimali artar.
- Daha iyi adaylar daha yüksek hire cost ve daha yüksek daily upkeep ister.
- Oyuncu iyi adayı gördüğünde parası yetmeyebilir; bu bilinçli bir karar gerilimi oluşturur.
- Aday sistemi oyuncuya gerçek tercih sunmalıdır: ucuz ama zayıf apprentice almak, hızlı ama riskli runner almak, pahalı ama güvenli guarded master almak veya bekleyip daha iyi aday aramak.

Örnek yön:

```text
Trader / erken Merchant:
- Apprentice
- Runner
- düşük statli Hauler

Merchant / Guild Master:
- Hauler
- Broker
- Guarded Master

Late-game:
- Veteran
- yüksek toplam statli pahalı adaylar
```

## Master Archetype Yönleri

Bu archetype'lar kesin numeric balance değildir; sadece tasarım yönünü tarif eder. Sayısal değerler mechanics/balance aşamasında netleştirilebilir.

- **Apprentice:** Ucuz, düşük stat, erken otomasyon için uygun.
- **Runner:** Hızlı, düşük kapasite ve düşük cesaret.
- **Hauler:** Yüksek kapasite, düşük hız.
- **Guarded Master:** Yüksek cesaret, yüksek upkeep.
- **Broker:** Yüksek pazarlık, orta kapasite.
- **Veteran:** Pahalı, yüksek toplam stat, late-game için uygun.

## Tasarım Amacı

Bu sistem şu karar baskılarını üretmelidir:

- Oyuncu master aramak için şehir gezmeli mi?
- Karşısına çıkan zayıf ama ucuz adayı hemen işe almalı mı?
- Daha iyi bir aday beklemeli mi?
- İyi aday çıktıysa parasını buna mı ayırmalı?
- Otomasyona erken mi geçmeli, yoksa bir süre daha manuel ticaret mi yapmalı?

Caravan Master, güçlü bir otomasyon aracı olduğu için işe alma süreci basit, garanti ve tek tıklık olmamalıdır.

## Trade Routes Panel ile İlişki

Trade Routes panelinde boş master yoksa oyuncuya doğrudan işe alma butonu vermek yerine yönlendirme yapılmalıdır.

Örnek UI mesajı:

```text
No idle Caravan Master available.
Find a Caravan Master in city taverns.
```

Trade Routes paneli:

- route listesi,
- aktif/idle master durumu,
- route oluşturma ve düzenleme,
- mini map,
- route uyarıları

için kullanılır.

Tavern paneli:

- şehirdeki adayları gösterme,
- aday statlarını karşılaştırma,
- hire cost ve upkeep bilgisini gösterme,
- uygun adayı işe alma

için kullanılır.

## UI Notları

Tavern panelinde aday kartları net okunmalıdır:

- ad,
- archetype,
- hire cost,
- daily upkeep,
- Speed,
- Capacity,
- Bargain,
- Courage,
- kısa karakter/rol açıklaması,
- Hire butonu.

Aday yoksa panel boş kalmamalı; oyuncuya net mesaj vermelidir:

```text
No Caravan Master is available in this tavern.
Check another city or return later.
```

## Gerilimler

**Aşırı şans bağımlılığı**
Adayların her zaman çıkmaması iyi bir oyun gerilimi üretir; ancak oyuncu çok uzun süre hiç aday bulamazsa sistem sinir bozucu olabilir. Bu nedenle şehir sayısı, refresh süresi ve aday çıkma olasılığı balance aşamasında dikkatli ayarlanmalıdır.

**Tavern panelinin kapsamı**
Tavern ileride sadece Caravan Master için değil, NPC söylentileri, özel kontratlar veya bilgi satın alma gibi sistemler için de kullanılabilir. Ancak ilk karar kapsamında Tavern’in ana işlevlerinden biri Caravan Master adaylarını şehir bazlı göstermek olacaktır.

## Tartışma Notları

- [2026-06-04] Ana `trading_post.md` dosyasındaki Caravan Master aday sistemi ve archetype yönleri bu dosyaya taşındı. Şehir bazlı Tavern kararı korunarak eski global 3 aday fikri, şehir başına 0-2 aday ve dünya genelinde değişken aday havuzu şeklinde yorumlandı.

- [2026-06-02] Caravan Master işe alma sistemi şehir bazlı Tavern / Inn sistemi olarak netleştirildi. Adaylar global Trade Routes panelinden tek tıkla işe alınmayacak. Her şehirde aday çıkması garanti olmayacak; aday kalitesi oyuncu rank'ına göre değişecek. Tavern, TownUI üzerinden MarketUI gibi ayrı bir panel olarak açılacak.
