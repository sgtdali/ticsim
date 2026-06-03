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

## Bolluk Spirali — Kabul Edilen Çözüm Yönleri

Bu bölüm nihai sayısal mekanik kararı değildir. Kabul edilenler, bolluk spirali problemini çözmek için tasarım yönü olarak kaydedilmiştir. Her maddenin Ironmere'ye entegrasyonu, hangi sistemleri etkileyeceği ve sayısal/mechanic kararları sonraki oturumlarda ayrıca alınacaktır.

### 1. Prosperity yükseldikçe ihtiyaç seviyesi artacak

Kabul edilen ana yön: Prosperity yalnızca satış bonusu veren pasif bir seviye olmayacak. Şehir refahı yükseldikçe şehrin ihtiyaç seviyesi de artacak.

Tasarım niyeti:

- Düşük prosperity şehirler temel ihtiyaçlarla idare edebilir.
- Growing seviyedeki şehirler daha düzenli food + basic processed/utility malları ister.
- Prosperous seviyedeki şehirler sadece temel gıda değil, comfort/luxury ve şehir işleyişini destekleyen malları da daha güçlü şekilde talep eder.
- Oyuncu zenginleştirdiği şehri sürekli beslemek zorunda kalır; prosperity kalıcı, risksiz satış bonusu terminaline dönüşmez.
- Bu yaklaşım Patrician çizgisindeki "şehir büyürse tüketim ve yönetim yükü de büyür" hissini Ironmere'ye taşır.

Sonradan alınacak mekanik kararlar:

- Prosperity aralıkları ihtiyaç seviyelerine nasıl bağlanacak? Örnek: `0-29`, `30-64`, `65+`.
- Her prosperity bandında hangi demand tag'ler aktifleşecek veya güçlenecek?
- Survival, comfort, luxury, construction, industry ve military tag'leri prosperity seviyesine göre nasıl ağırlık kazanacak?
- Prosperous şehirlerde lüks/comfort tüketimi ne kadar artacak?
- Bu ihtiyaç artışı doğrudan tüketim katsayısı mı olacak, yoksa stok güvenliği/günlük talep hedefi olarak mı çalışacak?
- Market UI ve city info UI bu artan ihtiyaç seviyesini oyuncuya nasıl gösterecek?

### 2. Eksik tedarik prosperity artışını durdurabilecek veya düşürebilecek

Kabul edilen yön: Tedarik eksikliği prosperity üzerinde etkili olacak. Ancak bu konu dokümanlarda zaten kısmen mevcut olduğu için ilgili bölümler birlikte tekrar değerlendirilecek.

Mevcut bağlantılı bölümler:

- Günlük talep ve tüketim bölümü: prosperity'nin özellikle Luxury/Comfort kişi başı tüketimi artıracağı kararı.
- Demand tag sistemi: food, comfort, luxury, construction, industry, military kaynakları.
- Rank/progression tarafı: rank koşullarında Growing/Prosperous city eşikleri.
- Economy bilgi görünürlüğü: oyuncuya formül değil, okunabilir neden/uyarı gösterme yaklaşımı.

Tasarım niyeti:

- Oyuncu bir şehri büyüttüyse, bu büyümenin korunması tedarik ağına bağlı olmalı.
- Eksik mallar prosperity'yi anında cezalandırmamalı; önce uyarı ve growth stop etkisi vermeli.
- Uzun süren veya kritik eksiklikler prosperity düşüşüne yol açabilmeli.
- Düşüş yavaş, geri çevrilebilir ve oyuncuya önceden bildirilen bir süreç olmalı.

Sonradan birlikte değerlendirilecek mekanik kararlar:

- Hangi malların eksikliği growth stop yaratır?
- Hangi malların eksikliği prosperity düşüşü yaratır?
- Eksiklik kaç gün sürerse uyarı, growth stop ve düşüş tetiklenecek?
- Prosperity düşüşü lineer mi, eşik bazlı mı, stok günü bazlı mı olacak?
- Tedarik eksikliği rank koşullarını bozabilecek mi? Örneğin şehir 65 altına düşerse Patrician koşulu kaybedilir mi?
- UI'da "şehir refahı düşme riski" nasıl gösterilecek?
- Bu sistem oyuncuyu haksız cezalandırmadan nasıl geri çevrilebilir tutulacak?

### 3. Prosperity yatırım maliyeti kademeli artacak

Kabul edilen yön: Prosperity yatırım maliyeti düz olmayacak. Refah yükseldikçe bir sonraki seviyeye çıkmak daha pahalı hale gelecek.

Tasarım niyeti:

- Erken seviyelerde şehir toparlamak ve büyütmek ulaşılabilir olacak.
- Orta seviyede yatırım hâlâ anlamlı ama daha bilinçli karar gerektirecek.
- Prosperous seviyeye ulaşmak ciddi sermaye, düzenli tedarik ve planlama isteyecek.
- Oyuncu sadece birikmiş parayı prosperity'ye basarak risksiz snowball yaratamayacak.
- Bu sistem para yakıcı gibi çalışacak ama çıplak vergi hissi vermeyecek.

Sonradan alınacak mekanik kararlar:

- Prosperity yatırım maliyeti hangi formülle artacak?
- Maliyet bandı prosperity seviyesine göre mi, şehir seviyesine göre mi, nüfusa göre mi belirlenecek?
- 0-30, 30-65 ve 65+ aralıkları kullanılacak mı?
- Yatırım doğrudan prosperity puanı mı verir, yoksa growth modifier / civic project etkisi mi verir?
- Tek seferlik yatırım mı, proje bazlı yatırım mı, günlük/haftalık bakım etkisi mi olacak?
- Rank ilerlemesi için gerekli prosperity değerlerine ulaşmak ne kadar zaman ve para istemeli?

### 4. Automation büyüdükçe fixed cost anlamlı hale gelecek

Kabul edilen yön: Trading Post, Caravan Master, depot expansion ve yüksek seviye master kullanımı geç oyunda anlamlı fixed cost yaratacak. Detaylar sonradan ayrıca tasarlanacak.

Mevcut bağlantılı bölümler:

- Trading Post mevcut upkeep kararı.
- Caravan Master aday sistemi: hire cost ve daily upkeep değerlerinin farklı olması.
- Master archetype yönleri: Apprentice, Runner, Hauler, Guarded Master, Broker, Veteran.
- Debt modeli: otomasyon debt sırasında da çalışır; sistem 60. günde game over'a gider.

Tasarım niyeti:

- Otomasyon oyuncuya rahatlık ve büyüme sağlamalı ama bedava para basma makinesine dönüşmemeli.
- İlk otomasyon ulaşılabilir olmalı; oyuncu sistemi denemekten korkmamalı.
- İleri otomasyon ağı büyüdükçe sabit giderler oyuncunun kâr hesabında görünür hale gelmeli.
- Daha iyi master daha yüksek verim sağlayacak ama daha yüksek wage/upkeep isteyecek.
- Büyük depot kapasitesi stratejik avantaj sağlayacak ama bakım maliyeti veya yatırım maliyetiyle dengelenecek.

Sonradan alınacak mekanik kararlar:

- Trading Post upkeep sabit mi kalacak, şehir/prosperity/post seviyesiyle artacak mı?
- Depot expansion sadece tek seferlik maliyet mi, ayrıca upkeep de yaratacak mı?
- Caravan Master wage hangi parametrelere göre belirlenecek? Rank, level, archetype, stat toplamı, capacity?
- Broker/Veteran gibi yüksek verimli master'lar ne kadar pahalı olmalı?
- Otomasyonun beklenen kârı UI'da upkeep sonrası net margin olarak gösterilecek mi?
- Automation fixed cost, debt modelini çok sertleştirmeden nasıl dengelenecek?
- Bu konu `trading_post.md` ile birlikte detaylandırılmalı.

### 5. NPC trader ekonomi dalgalanması yaratacak ve okunabilir olacak

Kabul edilen yön: NPC trader stokları ve fiyatları gerçek işlemlerle etkilemeye devam edecek; oyuncu bu etkinin en azından bir kısmını okuyabilmeli. Bu konu dokümanlarda zaten kısmen mevcut olduğu için ilgili bölümler birlikte tekrar değerlendirilecek.

Mevcut bağlantılı bölümler:

- Fiyatı dolaylı etkileyen sistemler: NPC trader gerçek stok işlemleriyle fiyatı etkiler.
- Açık soru: NPC trader ekonomiye etkisi ve oyuncunun buna strateji kurup kuramayacağı.
- Ekonomik fırsatların oyuncuya gösterilmesi açık sorusu.
- 3 kasaba ekonomisinin sınırları gerilimi: NPC hareketi rota ezberini kırabilir.

Tasarım niyeti:

- NPC sadece gizli stok azaltan/artıran arka plan sistemi olmamalı.
- Oyuncu sabit, ezberlenmiş rotalara güvenememeli; NPC hareketi piyasa fırsatlarını değiştirmeli.
- NPC etkisi tamamen şeffaf formül gibi gösterilmemeli; rumor, market hint, city info veya route activity gibi okunabilir ama sınırlı bilgi olarak sunulmalı.
- NPC hareketleri 3 kasabalı MVP ekonomisinde dinamizmi artıran temel araçlardan biri olabilir.

Sonradan birlikte değerlendirilecek mekanik kararlar:

- NPC rotaları oyuncuya önceden görünecek mi, yoksa sadece sonuçları mı görünecek?
- NPC activity market tooltip'e mi, city info'ya mı, event log'a mı, trade rumor sistemine mi girecek?
- NPC etkisi hangi eşikten sonra oyuncuya bilgi olarak gösterilecek?
- NPC trader oyuncunun kârlı rotalarını ne kadar bozmalı?
- NPC'ler belirli ekonomik kimliklere göre mi hareket edecek, yoksa fırsat bazlı mı karar verecek?
- NPC sisteminin factions veya NPC relation ile bağlantısı olacak mı?

## Bolluk Spirali — Sonraki Tasarım Yapılacakları

Bu yapılacaklar kod implementation görevi değildir. Her biri sonraki tasarım oturumlarında derinlemesine mekanik karara dönüştürülecek başlıklardır.

- [ ] **Prosperity ihtiyaç bandı tasarlanacak.** Her prosperity aralığında hangi mal sınıfları ve demand tag'lerin güçleneceği belirlenecek.
- [ ] **Tedarik eksikliği ve prosperity etkisi birlikte yeniden değerlendirilecek.** Mevcut daily demand, demand tag, prosperity growth/decline ve rank koşulu bölümleri beraber okunarak tek tutarlı model çıkarılacak.
- [ ] **Prosperity yatırım maliyeti formülü belirlenecek.** Düz maliyet yerine kademeli veya eğimli maliyet modeli seçilecek.
- [ ] **Automation fixed cost modeli detaylandırılacak.** Trading Post upkeep, Caravan Master wage, depot expansion ve high-tier master maliyetleri `trading_post.md` ile birlikte ele alınacak.
- [ ] **NPC trader okunabilirlik modeli detaylandırılacak.** NPC hareketlerinin oyuncuya ne kadar ve hangi UI katmanından gösterileceği ekonomi + UX dokümanlarıyla birlikte değerlendirilecek.
- [ ] **Bolluk spirali test senaryoları hazırlanacak.** Oyuncunun post/master ağı kurduğu, prosperity yatırımı yaptığı ve 3 şehirli MVP ekonomisinde snowball'a girip girmediği örnek senaryolarla kontrol edilecek.

## Açık Sorular

**NPC trader ekonomiye etkisi**
NPC'ler town_buy/town_sell üzerinden işlem yapıyor — yani marginal pricing etkisi var, stok değişiyor. Bu gerçek bir ekonomik baskı yaratıyor. Oyuncu buna karşı strateji kurabilmeli mi (mesela bir NPC'nin gittiği kasabayı önceliklendirmek)? NPC'ler sadece arka plan stok değiştirici olarak mı kalacak, yoksa oyuncunun takip edebileceği rakip/aktör gibi mi davranacak? Kabul edilen yön: NPC etkisi oyuncuya en azından sınırlı/okunabilir şekilde gösterilecek; detay mekanik sonra alınacak.

**Şehir ekonomik kimlikleri**
Her şehir için üretim karakteri, tüketim karakteri ve ticaret rolü netleşmeli mi? Örnek roller: maden şehri, tarım şehri, sanayi şehri, refah/luxury tüketim şehri. Bu karar fiyat farklarını, kontratları, NPC rotalarını ve Trading Post stratejisini doğrudan etkiler.

**Ekonomik fırsatların oyuncuya gösterilmesi**
Stok, mevsim, NPC hareketi ve prosperity değişimi fırsat üretecekse oyuncu bunları nasıl fark edecek? Market tooltip yeterli mi, yoksa trade hint, rumor, şehir uyarısı veya rota tavsiyesi gibi ek okuma katmanları gerekli mi?

**Stok kapasitesi dolunca davranış**
Town stock cap dolduğunda üretim, oyuncu satışı, NPC satışı ve Trading Post auto-sell nasıl davranacak? Tamamen engelleme mi, sert fiyat düşüşü mü, NPC'nin başka hedefe yönelmesi mi, yoksa sistem uyarısı mı kullanılacak?

**Geç oyun ekonomi baskısı ve para yakıcılar**
Oyuncu Trading Post, Caravan Master ve prosperity yatırımlarıyla çok para kazandığında ekonomiyi dengeleyen kalıcı maliyetler ne olacak? Caravan Master wage, Trading Post upkeep, depot expansion, diminishing return veya prestige/rank maliyeti gibi para yakıcılar hangi ölçüde kullanılacak? Kabul edilen yön: automation büyüdükçe fixed cost anlamlı olacak; detaylar `trading_post.md` ile birlikte sonradan tasarlanacak.

**Demand tag MVP kalibrasyonu**
Demand tag sistemi mevcut, fakat MVP için her malın sayısal tüketim zemini nasıl kalibre edilecek? Her item için `category`, `base_price`, `base_daily_demand_per_1000_pop` ve `demand_tags` yeterli mi, yoksa şehir bazlı özel tüketim katsayıları da gerekecek mi?

## Sonradan Değerlendirilecekler

**Yerel normal fiyat referansı**
MVP'de satırdaki toplam yön ikonu base_price'a göre çalışacak. İleride bunun yerine o malın o şehirdeki "normal yerel fiyatı" referans alınabilir. Bu, şehir karakteri ve yerel üretim/tüketim yapısını daha doğru yansıtır; ancak ayrıca normal yerel fiyat tanımı gerektirir.

**Kategoriye göre referans stok günü**
MVP'de tüm kategoriler 14 günlük normal stok ve 42+ günlük bolluk referansını kullanacak. İleride Luxury, Raw veya Processed kategorileri için farklı referans günleri değerlendirilebilir.

**Orta detay demand tag kaynakları**
MVP'de demand tag kaynakları basit tutulacak. İleride `construction` şehir büyümesi/yatırım dönemlerinden, `industry` üretim yoğunluğundan, `military` risk/faction durumundan ayrıca beslenebilir.

## Gerilimler

**3 kasaba ekonomisinin sınırları**
Sadece 3 kasabayla fiyat farkı az. Oyuncu hangi kasabadan alıp nereye satacağını hızlıca ezberleyebilir — dinamizm azalıyor. Şehir sayısı ilerleyen versiyonlarda artınca bu kendiliğinden çözülecek. 3 kasaba MVP'de kalacaksa NPC hareketleri, mevsim etkisi ve prosperity değişimi rota ezberini kıracak kadar görünür olmalı.

**Bolluk spiraline karşı mekanizma**
Oyuncu çok para kazanınca prosperity'ye yatırım yapıyor → satış bonusu artıyor → daha çok kazanıyor. Çözüm yönü kabul edildi: prosperity yükseldikçe ihtiyaç seviyesi artacak, eksik tedarik growth stop/düşüş etkisi yaratabilecek, prosperity yatırım maliyeti kademeli artacak, automation fixed cost anlamlı hale gelecek ve NPC trader ekonomi dalgalanması yaratacak. Detay mekanikler henüz kesinleşmedi; yukarıdaki yapılacaklar üzerinden ayrıca tasarlanacak.

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

- [2026-06-03] Bolluk spirali için kabul edilen çözüm yönleri kaydedildi. Prosperity yükseldikçe ihtiyaç seviyesi artacak; eksik tedarikin growth stop/düşüş etkisi mevcut doküman bölümleriyle birlikte tekrar değerlendirilecek; prosperity yatırım maliyeti kademeli artacak; automation büyüdükçe fixed cost anlamlı olacak ancak detaylar `trading_post.md` ile birlikte sonradan tasarlanacak; NPC trader ekonomi dalgalanması yaratacak ve okunabilir olacak, fakat mevcut NPC/fırsat görünürlüğü bölümleriyle birlikte yeniden değerlendirilecek. Bu maddeler kesin sayısal mekanik değil, sonraki tasarım yapılacakları olarak kaydedildi.
- [2026-06-03] Ekonomi geliştirme başlıkları karar verilmemiş konu olarak kaydedildi. Şehir ekonomik kimlikleri, fırsatların oyuncuya nasıl gösterileceği, stok kapasitesi dolunca davranış, geç oyun para yakıcıları ve demand tag MVP kalibrasyonu açık soru olarak eklendi. Mevcut NPC trader, 3 kasaba sınırı ve bolluk spirali notları detaylandırıldı.
- [2026-06-03] Fiyat sistemi stok öncelikli hibrit model olarak netleştirildi. Fiyatın ana gövdesi stok/günlük talep oranından gelecek; üretim, mevsim ve NPC trader etkileri fiyatı doğrudan çarpmak yerine stok akışı veya talep üzerinden çalışacak.
- [2026-06-03] Kategori bazlı fiyat eğrileri belirlendi: Survival `x3.0/x1.0/x0.50`, Raw Material `x2.2/x1.0/x0.45`, Processed `x2.6/x1.0/x0.50`, Luxury/Comfort `x1.8/x1.0/x0.45`. Global `x0.25` fiyat tabanı kaldırıldı.
- [2026-06-03] Tüketim modeli netleştirildi. Her malın günlük talep zemini olacak; nüfus tüketimi lineer belirleyecek, prosperity Luxury/Comfort kişi başı tüketimini artıracak. Raw/Processed talebi üretim zinciri + demand tag bazlı şehir bakım talebinden oluşacak.
- [2026-06-03] Quote modeli sadeleştirildi. Base spread `+%8/-%8` kalacak; faction rep sadece quote etkisi yaratacak, prosperity tüm malların satış quote'una maksimum +%10 bonus verecek ve alış/satış arasında en az %3 oyuncu aleyhine fark korunacak.
- [2026-06-03] Market fiyat bilgi UI'ı detaylandırıldı. Ürün satırında toplam fiyat yönü ikonu olacak; referans MVP'de base_price. Hover tooltip sadece %5 üzeri aktif fiyat etkilerini gösterecek, %15 üzeri etkiler çift okla belirtilecek ve etkiler güç sırasına dizilecek. Yerel normal fiyat referansı ileride değerlendirilecek notu olarak eklendi.
- [2026-06-03] Ekonomi bilgisinin görünürlüğü kararlaştırıldı. Oyuncuya fiyat formülü veya tam çarpan zinciri gösterilmeyecek; market UI fiyat etkilerini kısa, okunabilir tooltip satırlarıyla açıklayacak. Mevsim etkisi de bu tooltip sistemiyle görünür olacak.
- [2026-06-02] Event sistemi MVP'den çıkarıldı. Temel dinamizm stok/NPC/mevsimden geliyor; event'ler bu aşamada gereksiz karmaşıklık. Koddan temizlenmesi için yapılacaklara eklendi. Tasarım referansı bu dosyada korunuyor.
- [2026-06-02] Vergi mekaniği tartışıldı. Ayrı bir tax rate uygulanmayacak. Spread zaten aynı şehirde al-sat'ı zararlı kılıyor; faction rep'in spread bonusu olarak yansıması yeterli. Kapatıldı.
