# Economy Design

## Temel Yaklaşım (Karar verilmiş)

- Fiyatlar sabit değil; arz-talep dinamiği var.
- Fiyat eğrisi tüketim bazlı: referans nokta 14 günlük tüketim stoku = base_price × 1.0.
- Fiyat eğrisi tek bir kategori ailesi kullanır: 0 günlük stok kıtlık tavanı, 14 günlük stok normal fiyat, 42+ günlük stok bolluk tabanı.
- Her malın bir günlük talep/tüketim zemini olacak; kapasite bazlı fiyatlama ana tasarım değil, en fazla teknik fallback olarak kalır.
- Kategoriye göre kıtlık tavanı ve bolluk tabanı değişir.
- Oyuncu doğrudan "market fiyatı" ile işlem yapmıyor; alımda +%8, satışta -%8 spread uygulanıyor.
- Toplu işlemler marginal — her birim kendi stok durumuna göre fiyatlanıyor. Anında arbitraj kapısı bu sayede kapalı.
- Faction rep alım maliyetini düşürüyor, satış gelirini artırıyor. Hem ödül hem progression bağlantısı.
- Prosperity satış quote'una küçük bonus veriyor; maksimum etki +%10.
- Satış çarpanı her zaman alım çarpanının en az %3 altında — aynı şehirde anında al-sat kâr edilemiyor.
- **Vergi ayrı bir mekanik olarak uygulanmıyor.** Spread zaten aynı şehirde al-sat'ı zararlı kılıyor; faction rep'in spread üzerindeki etkisi bu amacı karşılıyor. Kasıtlı tasarım seçimi.

## Fiyat Etki Felsefesi (Karar verilmiş)

- Ekonomi hibrit ama stok öncelikli olacak.
- Fiyatın ana gövdesi stok/günlük talep oranından gelir.
- Mevsim, NPC trader, üretim ve tüketim gibi sistemler fiyatı mümkünse doğrudan çarpanla değil, stok akışı veya günlük talep üzerinden etkiler.
- Doğrudan fiyat çarpanı son çaredir; kullanılırsa özel gerekçe ister.
- Faction reputation ve prosperity piyasa referans fiyatını değil, oyuncuya verilen alış/satış quote'unu etkiler.

## Mal Kategorileri ve Fiyat Eğrileri (Karar verilmiş)

MVP'de tüm kategoriler aynı stok günü referanslarını kullanır:

- 0 günlük stok = kıtlık tavanı
- 14 günlük stok = normal fiyat (`base_price x1.0`)
- 42+ günlük stok = bolluk tabanı

Kategori parametreleri:

| Kategori | 0 Gün Stok | 14 Gün Stok | 42+ Gün Stok | Tasarım Karakteri |
|----------|------------|-------------|--------------|-------------------|
| Survival | `x3.0` | `x1.0` | `x0.50` | Kıtlık sert, bolluk kontrollü. |
| Raw Material | `x2.2` | `x1.0` | `x0.45` | Ticaret fırsatı var ama üretim zinciri aşırı oynatılmıyor. |
| Processed | `x2.6` | `x1.0` | `x0.50` | Kıtlık primi yüksek; üretim zinciri beslemek ödüllendiriliyor. |
| Luxury / Comfort | `x1.8` | `x1.0` | `x0.45` | Stok eğrisi yumuşak; asıl değer farkı refah/nüfus talebinden geliyor. |

- Global `base_price x0.25` minimum floor tasarım kararı olarak kaldırıldı; kategori bazlı tabanlar yeterli.
- MVP'de kategori farkı min/max çarpanlardan gelir. Referans stok günü farklılaştırması ileride değerlendirilecek.

## Günlük Talep ve Tüketim (Karar verilmiş)

- Her malın bir günlük talep/tüketim zemini olacak.
- Nüfus tüketim hacminin ana belirleyicisidir; nüfus lineer ölçeklenir.
- Prosperity özellikle Luxury/Comfort mallarında kişi başı tüketim iştahını artırır.
- Survival tüketimi nüfus bazlı temel tüketimdir.
- Raw/Processed talebi üretim zinciri ihtiyacı + şehir bakım/soyut talebinden oluşur.
- Şehir bakım/soyut talebi mal bazlı demand tag'lerle dağıtılır.
- Item'lar birden fazla demand tag alabilir ve bu tag'ler ağırlıklı olabilir.
- MVP demand tag kaynakları basit tutulur:
  - `food` = nüfus
  - `comfort` / `luxury` = nüfus + prosperity
  - `construction` / `industry` / `military` = nüfus
- Üretim zinciri input ihtiyacı, ilgili malın günlük talebine ayrıca eklenir.

Örnek demand tag yapısı:

```text
wine:
  comfort: 0.6
  luxury: 0.4

tool:
  construction: 0.7
  industry: 0.3

sword:
  military: 0.7
  luxury: 0.3
```

## Fiyatı Dolaylı Etkileyen Sistemler (Karar verilmiş)

- Yerel üretim doğrudan fiyat indirimi vermez; üretim stok ekler, stok arttıkça fiyat doğal olarak düşer.
- Mevsim fiyatı doğrudan çarpmaz; üretim/tüketim üzerinden stok akışını değiştirir.
- NPC trader'lar fiyatı sadece gerçek stok işlemleriyle etkiler. NPC alımı stok azaltır, NPC satışı stok artırır.
- Marginal pricing herkes için geçerlidir: manuel oyuncu işlemleri, Trading Post, Caravan Master ve NPC trader işlemleri.

## Daily Tick ve Pazar Sırası (Karar verilmiş)

- Daily tick'te önce şehir simülasyonu, sonra tüm ticaret aktörleri çalışır.
- Ekonomik sıra:
  1. Player upkeep/debt
  2. Şehir üretim fazı
  3. Şehir tüketim fazı
  4. Nüfus/prosperity güncellemesi
  5. Market fiyatlarının güncellenmesi
  6. Trading Post auto-trade
  7. Caravan Master route işlemleri
  8. NPC trader işlemleri
  9. Kontrat/rank/gün sonu diğer sistemler
- Ticaret aktörü sırası MVP'de oyuncu otomasyonu öncelikli olacak: Trading Post → Caravan Master → NPC trader.
- Her ticaret işlemi stok değiştirir ve ilgili fiyat/quote aynı gün anlık yeniden hesaplanır.
- Günün üretim/tüketim hesabı gün başındaki nüfus ve prosperity ile yapılır.
- Tüketim sonucu değişen prosperity/nüfus değerleri talep ve quote hesaplarına ertesi gün etki eder.
- Şehir simülasyonunda üretim önce, tüketim sonra çalışır; bugün üretilen mal bugün tüketilebilir.

## Üretim, Stok ve İşlem Sınırları (Karar verilmiş)

- Recipe input eksikliği oransal üretimle çözülür. Input'un ne kadarı karşılanabiliyorsa output aynı oranda üretilir.
- Input eksikliği doğrudan fiyat çarpanı yaratmaz; output azalır, stok zamanla düşer, fiyat dolaylı yükselir.
- Stok kapasitesi doluyken üretim kapasiteye kadar stoğa eklenir, fazlası overflow/waste olarak kaybolur.
- Market stok kapasitesi doluyken satış sadece boş kapasite kadar yapılır; cap üstü satış yoktur.
- Market stoğu yetersizken alım sadece mevcut stok kadar yapılır; negatif stok yoktur.

## Demand Satisfaction ve Şehir Etkileri (Karar verilmiş)

- Tüketim fazında her mal için karşılanma oranı hesaplanır: `tüketilen_miktar / talep_edilen_miktar`.
- MVP satisfaction eşikleri:
  - `%80+` = iyi / normal
  - `%40-80` = zayıf
  - `%40 altı` = kötü / kritik
- Fiyat için stok-gün eğrisi kullanılır; şehir sağlığı için günlük demand satisfaction kullanılır.
- Survival satisfaction prosperity ve nüfus için ana şehir sağlığı göstergesidir:
  - `%80+` → prosperity `+2`
  - `%40-80` → prosperity `-1`
  - `%40 altı` → prosperity `-4`
- Survival kötü satisfaction (`%40 altı`) 3 gün birikirse nüfus `-%3` azalır.
- Nüfus düşüşü her 3 kötü günde bir tetiklenir; düşüşten sonra sayaç sıfırlanır.
- Kötü gün sayacı kademeli toparlanır: `%40 altı` sayaç `+1`, `%40-80` sayaç azaltır, `%80+` sayaç sıfırlar.
- Luxury/Comfort satisfaction düşük/orta prosperity şehirleri cezalandırmaz; yüksek prosperity şehirlerde refah koruma baskısı yaratır.
- Luxury/Comfort negatif baskısı sadece prosperity `70+` şehirlerde çalışır.
- Luxury/Comfort etkisi hafiftir:
  - `%80+` → prosperity artışına izin verir veya küçük `+1` destek sağlar.
  - `%40-80` → luxury kaynaklı artış yok.
  - `%40 altı` → sadece prosperity `70+` şehirlerde `-1` baskı.
- Processed/Industry eksikliği production_plan / işlenmiş üretimlere hafif verim cezası verir ve prosperity büyümesini sınırlar:
  - `%80+` → üretim cezası yok
  - `%40-80` → production_plan üretimi `-%5`
  - `%40 altı` → production_plan üretimi `-%10`
- Processed/Industry üretim cezası doğal kaynak üretimini etkilemez.
- Raw Material eksikliği input eksikliği dışında ek şehir etkisi yaratmaz; çifte ceza uygulanmaz.
- Günlük otomatik prosperity değişimi kategori etkilerinin toplamı olacak ve günlük clamp ile sınırlandırılacak. Clamp değerleri henüz karara bağlanmadı.

## Quote, Spread ve Oyuncu Avantajları (Karar verilmiş)

- Base spread MVP'de sabittir: alım quote'u market referans fiyatı `+%8`, satış quote'u `-%8`.
- Faction reputation sadece spread/quote etkisi yaratır; piyasa referans fiyatını değiştirmez.
- Prosperity tüm malların satış quote'una aynı küçük bonusu verir; maksimum +%10.
- Quote bonusları spread'i tamamen tersine çeviremez.
- Alış quote'u ile satış quote'u arasında her zaman en az %3 oyuncu aleyhine fark kalır.

## Üretim Sistemi (Karar verilmiş)

- Doğal kaynaklar (wheat, grapes, iron_ore): slot satın alarak üretim artırılıyor.
- İşleme ürünleri (flour, bread, iron_bar, tool, wine, must): production_plan ile tanımlı, upgrade ile artırılıyor.
- Recipe input eksikliği üretim verimini düşürüyor.
- Mevsimler bazı malların üretimini değiştiriyor (spring/summer/autumn/winter çarpanları mevcut).

## Stok Kapasitesi

- Her kasabada mal başına stok sınırı var.
- Kapasite doluysa üretim ve satış engellenebilir.
- Slot ve production upgrade alımı hem üretim hem stok cap'i artırıyor.

## Ekonomi Bilgisi Görünürlüğü (Karar verilmiş)

- Oyuncuya fiyat formülü, çarpan zinciri veya tam simülasyon hesabı gösterilmeyecek.
- Market UI fiyatı, stok miktarını ve toplam fiyat yönünü gösteren bir ikon alanı kullanacak.
- Satırdaki yön ikonu tüm ekonomi etkilerinin toplam sonucunu gösterir: fiyat base price'a göre anlamlı yüksekse `↑`, anlamlı düşükse `↓`, belirgin sapma yoksa nötr/`→`.
- MVP'de toplam yön ikonu için referans `base_price` olacak.
- Her ürün satırındaki yön ikonuna hover edilince fiyat etkileri tooltip'i açılacak.
- Tooltip sadece anlamlı eşiği geçen aktif fiyat etkilerini gösterir; etkisi olmayan veya çok küçük olan faktörler listelenmez.
- Görünürlük eşiği sabit yüzde eşiğidir: fiyatı en az %5 etkileyen faktör tooltip'e girer.
- Etki şiddeti oklarla gösterilir: %5 ve üzeri `↑`/`↓`, %15 ve üzeri `↑↑`/`↓↓`.
- Tooltip'teki oklar her zaman fiyat yönünü gösterir; üretim/stok yönünü değil.
- Tooltip satırları en güçlü etkiden en zayıfa doğru sıralanır.
- Örnek tooltip: `Stok düşük ↑↑`, `Kış ↑`, `NPC satışı ↓`.
- Amaç Patrician çizgisine yakın kalmak: oyuncu piyasayı okuyabilsin, ama ekonomiyi tablo/formül çözmeye indirgemesin.
- Mevsim etkisi varsa ayrı bir teknik hesap olarak değil, ilgili malın fiyat/üretim nedeni içinde görünür olacak.

## Açık Sorular

**NPC trader ekonomiye etkisi**
NPC'ler town_buy/town_sell üzerinden işlem yapıyor — yani marginal pricing etkisi var, stok değişiyor. Bu gerçek bir ekonomik baskı yaratıyor. Oyuncu buna karşı strateji kurabilmeli mi (mesela bir NPC'nin gittiği kasabayı önceliklendirmek)?

**Günlük prosperity clamp değeri**
Kategori etkileri toplanınca günlük otomatik prosperity değişiminin hangi min/max aralığa clamp edileceği henüz kararlaştırılmadı.

## Sonradan Değerlendirilecekler

**Yerel normal fiyat referansı**
MVP'de satırdaki toplam yön ikonu base_price'a göre çalışacak. İleride bunun yerine o malın o şehirdeki "normal yerel fiyatı" referans alınabilir. Bu, şehir karakteri ve yerel üretim/tüketim yapısını daha doğru yansıtır; ancak ayrıca normal yerel fiyat tanımı gerektirir.

**Kategoriye göre referans stok günü**
MVP'de tüm kategoriler 14 günlük normal stok ve 42+ günlük bolluk referansını kullanacak. İleride Luxury, Raw veya Processed kategorileri için farklı referans günleri değerlendirilebilir.

**Orta detay demand tag kaynakları**
MVP'de demand tag kaynakları basit tutulacak. İleride `construction` şehir büyümesi/yatırım dönemlerinden, `industry` üretim yoğunluğundan, `military` risk/faction durumundan ayrıca beslenebilir.

## Gerilimler

**3 kasaba ekonomisinin sınırları**
Sadece 3 kasabayla fiyat farkı az. Oyuncu hangi kasabadan alıp nereye satacağını hızlıca ezberleyebilir — dinamizm azalıyor. Şehir sayısı ilerleyen versiyonlarda artınca bu kendiliğinden çözülecek.

**Bolluk spiraline karşı mekanizma**
Oyuncu çok para kazanınca prosperity'ye yatırım yapıyor → satış bonusu artıyor → daha çok kazanıyor. Bu pozitif geri besleme döngüsünü kıran bir şey var mı? Debt+upkeep baskısı erken oyunda bunu dengeliyor ama geç oyunda?

## Event Sistemi — Ertelenmiş (Referans)

Event sistemi MVP kapsamından çıkarıldı. Temel ekonomi otururken gereksiz karmaşıklık katıyordu; piyasa dinamizmi stok değişimi + NPC hareketleri + mevsim çarpanlarıyla zaten sağlanıyor. İleride eklenecekse bu bölüm referans olarak kullanılabilir.

**Mevcut tasarım (koddan kaldırılacak):**

| Event | Etki Alanı | Fiyat | Üretim | Tüketim |
|-------|-----------|-------|--------|---------|
| Festival | Comfort: wine, sword, grapes vb. | ×1.6 | ×1.0 | ×2.0 |
| Famine | Survival: wheat, bread vb. | ×3.0 | ×0.3 | ×1.5 |
| Demand Surge | Şehrin tükettiği seçili bir mal | ×2.5 | ×1.0 | ×3.0 |
| Bumper Crop | Şehrin ürettiği seçili bir mal | ×0.5 | ×2.5 | ×1.0 |
| Plague | Tüm mallar | ×1.2 | ×0.4 | ×0.4 |

**Notlar (ileride tasarlanacaksa):**
- Patrician'da event'ler saf fiyat çarpanı değil, tüketim/üretim değiştirici olarak çalışıyor — bu yön daha sağlıklı.
- Event'in anlamlı olması için oyuncunun önceden haber alıp tepki verebilmesi lazım; rastgele tetiklenip sessizce bitmemeli.
- Event + stok etkisi çakışması çözülmeli (stok zaten 0'sa Famine x3.0 çarpanı anlamsız).

## Tartışma Notları

- [2026-06-03] Daily tick sırası ekonomi tasarımına göre yeniden kararlaştırıldı. Önce şehir üretim/tüketim simülasyonu, sonra güncel market üzerinde Trading Post, Caravan Master ve NPC trader işlemleri çalışacak. Ticaret aktörü sırası MVP'de oyuncu otomasyonu öncelikli olacak.
- [2026-06-03] Üretim ve stok sınırları netleştirildi. Recipe input eksikliği oransal üretim yapacak; stok cap doluyken üretim fazlası kaybolacak; alım/satım yalnızca mevcut stok ve boş kapasite kadar yapılacak.
- [2026-06-03] Demand satisfaction sistemi tasarlandı. Survival, Luxury/Comfort, Processed/Industry ve Raw Material eksikliklerinin şehir etkileri ayrıştırıldı. Survival şehir sağlığının ana göstergesi olacak; luxury yüksek prosperity korumasına, industry ise işlenmiş üretim verimine hafif etki edecek. Günlük prosperity clamp değeri açık soru olarak bırakıldı.
- [2026-06-03] Fiyat sistemi stok öncelikli hibrit model olarak netleştirildi. Fiyatın ana gövdesi stok/günlük talep oranından gelecek; üretim, mevsim ve NPC trader etkileri fiyatı doğrudan çarpmak yerine stok akışı veya talep üzerinden çalışacak.
- [2026-06-03] Kategori bazlı fiyat eğrileri belirlendi: Survival `x3.0/x1.0/x0.50`, Raw Material `x2.2/x1.0/x0.45`, Processed `x2.6/x1.0/x0.50`, Luxury/Comfort `x1.8/x1.0/x0.45`. Global `x0.25` fiyat tabanı kaldırıldı.
- [2026-06-03] Tüketim modeli netleştirildi. Her malın günlük talep zemini olacak; nüfus tüketimi lineer belirleyecek, prosperity Luxury/Comfort kişi başı tüketimini artıracak. Raw/Processed talebi üretim zinciri + demand tag bazlı şehir bakım talebinden oluşacak.
- [2026-06-03] Quote modeli sadeleştirildi. Base spread `+%8/-%8` kalacak; faction rep sadece quote etkisi yaratacak, prosperity tüm malların satış quote'una maksimum +%10 bonus verecek ve alış/satış arasında en az %3 oyuncu aleyhine fark korunacak.
- [2026-06-03] Market fiyat bilgi UI'ı detaylandırıldı. Ürün satırında toplam fiyat yönü ikonu olacak; referans MVP'de base_price. Hover tooltip sadece %5 üzeri aktif fiyat etkilerini gösterecek, %15 üzeri etkiler çift okla belirtilecek ve etkiler güç sırasına dizilecek. Yerel normal fiyat referansı ileride değerlendirilecek notu olarak eklendi.
- [2026-06-03] Ekonomi bilgisinin görünürlüğü kararlaştırıldı. Oyuncuya fiyat formülü veya tam çarpan zinciri gösterilmeyecek; market UI fiyat etkilerini kısa, okunabilir tooltip satırlarıyla açıklayacak. Mevsim etkisi de bu tooltip sistemiyle görünür olacak.
- [2026-06-02] Event sistemi MVP'den çıkarıldı. Temel dinamizm stok/NPC/mevsimden geliyor; event'ler bu aşamada gereksiz karmaşıklık. Koddan temizlenmesi için yapılacaklara eklendi. Tasarım referansı bu dosyada korunuyor.
- [2026-06-02] Vergi mekaniği tartışıldı. Ayrı bir tax rate uygulanmayacak. Spread zaten aynı şehirde al-sat'ı zararlı kılıyor; faction rep'in spread bonusu olarak yansıması yeterli. Kapatıldı.
