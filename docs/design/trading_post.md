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
- Her durakta Load veya Unload kuralı olabilir; hangi mal, işlem tipi ve miktar sınırı görünür olmalıdır.
- Caravan Master kuralında fiyat limiti bulunmaz. Fiyat limitleri Trading Post buy/sell kurallarına aittir.
- Master özellikleri korunur: Hız, Kapasite, Pazarlık, Cesaret.
- XP ve rank cap sistemi korunur.

**Master ve route ataması:**
- Bir Caravan Master aynı anda yalnızca bir aktif route yönetebilir.
- Bir route oluşturmak için boşta bir Caravan Master seçmek zorunludur.
- Mastersız route veya taslak route sistemi bulunmaz.
- Bir master başka route'a atanmak istenirse önce mevcut route iptal edilir, sonra aynı master ile yeni route kurulur.
- Route iptal davranışı aynen geçerlidir: master bulunduğu yerde idle olur ve cargo üzerinde kalır.
- Yeni route oluşturulurken master'ın mevcut cargo'su için cargo uyumluluğu tekrar kontrol edilir.
- Boşta master yeni route'a bulunduğu şehirden başlar.
- Yeni route'un ilk durağı master'ın bulunduğu şehir olmak zorunda değildir.
- Eğer ilk durak farklı şehirdeyse master önce route'un ilk durağına seyahat eder; sonra route kuralları işlemeye başlar.

**Trade route yapısı:**
- Caravan Master rotaları çok duraklı olabilir.
- Oyuncu rota duraklarını world map üzerinden kendisi seçer.
- Rota otomatik olarak standart döngüye zorlanmaz; durak sırası tamamen oyuncu kararına bağlıdır.
- Aynı şehir rota içinde birden fazla kez yer alabilir.
- Rota ister basit döngü olabilir: `Ironmere Post → Stonebridge Post → Kingsport Post → Ironmere Post`.
- Rota ister geri dönüşlü/tekrar duraklı olabilir: `Ironmere Post → Stonebridge Post → Kingsport Post → Stonebridge Post → Ironmere Post`.
- Sistem oyuncuya lojistik hattın şeklini kurma özgürlüğü vermelidir; UI durak sırasını açıkça göstermelidir.

**Trade Routes Panel UI:**
- Caravan Master / Trade Route yönetimi TownUI içinden değil, world map üzerinden açılan ayrı bir `Trade Routes` panelinden yapılır.
- TownUI / Post tab yalnızca ilgili şehrin Trading Post kuralları için kullanılır.
- Trade Routes panelinin ana görünümü route odaklıdır; master route'un atanmış çalışanı gibi görünür.
- Ana listede route adı, bağlı master, status, cargo özeti ve gerekirse uyarılar gösterilmelidir.
- Panelde ana haritanın küçültülmüş interaktif bir versiyonu bulunmalıdır.
- Mini map üzerinde şehirler, yollar, aktif route çizgileri ve Caravan Master konumları görünmelidir.
- Yeni route oluştururken oyuncu şehirleri mini map üzerinden sırayla tıklayarak route stop'ları oluşturur.
- Mini map üzerinde tüm aktif route'lar çizilir; seçili route diğerlerinden daha belirgin şekilde vurgulanır.
- Seçili route'un stop sırası, yönü ve mevcut master konumu mini map üzerinde açıkça okunmalıdır.

**Rota çalışma davranışı:**
- Caravan Master rotaları sonsuz döngü şeklinde çalışır.
- Son duraktan sonra master tekrar ilk durağa döner ve rota devam eder.
- Tek seferlik rota modu bulunmaz; tek seferlik taşıma kullanıcı tarafından manuel yapılır.
- Rota kullanıcı iptal edene kadar çalışmaya devam eder.
- Rota iptal edildiğinde master bulunduğu yerde idle olur.
- İptal sırasında master üzerindeki cargo korunur; otomatik boşaltma veya home post'a dönüş yapılmaz.
- Master rota üzerindeyken rota canlı düzenlenebilir.
- Canlı düzenleme master'ı ışınlamaz ve mevcut seyahati bozmaz.
- Rota değişiklikleri master'ın bir sonraki şehre varmasıyla uygulanır; tüm eski rota turunun bitmesi beklenmez.
- Kod tarafında canlı rota düzenleme dikkatli ele alınmalıdır; rota listesi değişirken current_stop/current_leg gibi runtime state'ler bozulmamalıdır.

**Canlı rota düzenleme ve cargo uyumu:**
- Canlı düzenleme yapıldığında master üzerindeki mevcut cargo yeni rota ile karşılaştırılır.
- Eğer master üzerindeki bir mal için yeni rotada uygun Unload kuralı yoksa sistem kritik uyarı gösterir.
- Bu durumda rota doğrudan aktifleşmez; oyuncu açıkça `Proceed Anyway` demeden yeni rota uygulanmaz.
- Sistem cargo'ya otomatik dokunmaz; cargo master üzerinde kalır.
- Oyuncu bu durumdan çıkmak için rotaya ilgili mal için bir Unload kuralı ekleyebilir.
- Uyarı ekranı oyuncuya çözüm olarak ilgili mal için geçici boşaltma durağı/kuralı ekleme seçeneği sunmalıdır.

**Temporary Unload Stop / Rule:**
- Uyumsuz cargo durumunda oyuncu geçici boşaltma durağı veya geçici Unload kuralı ekleyebilir.
- Geçici unload, sadece master üzerinde kalan mevcut cargo'yu temizlemek için kullanılır.
- İlgili cargo tamamen boşalınca geçici Unload kuralı otomatik kaldırılır.
- Eğer geçici unload için rota içine yeni bir durak eklendiyse, cargo tamamen boşalınca bu geçici durak da otomatik kaldırılır.
- Eğer geçici Unload mevcut bir durak üzerine eklendiyse, sadece geçici kural kaldırılır; durak rotada kalır.
- Hedef depoda yeterli yer yoksa partial unload yapılır; cargo tamamen boşalmadıysa geçici unload görevi silinmez ve sonraki uygun uğramada tekrar denenir.
- Temporary Unload Stop / Rule oyuncu tarafından manuel silinebilir.
- Geçici unload manuel silinirse sistem cargo uyumluluğunu tekrar kontrol eder ve gerekirse kritik uyarıyı yeniden gösterir.
- Temporary Unload hedefi için sistem en yakın uygun Trading Post'u önerir; oyuncu öneriyi kabul edebilir veya başka post seçebilir.
- Uygun Trading Post seçimi önceliklidir: sistem önce cargo'yu tam boşaltabilecek post arar, yoksa partial unload yapabilecek post önerir.
- Temporary Unload önerisi depo alanı rezerve etmez.
- Öneri yapıldığı andaki depo boşluğu yalnızca bilgilendirme niteliğindedir; master hedefe vardığında gerçek depo boşluğu tekrar kontrol edilir.
- Master hedefe vardığında yer varsa unload yapılır, kısmi yer varsa partial unload yapılır, hiç yer yoksa cargo master üzerinde kalır.
- Yer olmadığı için unload yapılamazsa Temporary Unload görevi silinmez; rota döngüsünde sonraki uygun uğramada tekrar denenir.
- Normal route stop ve temporary cleanup stop UI'da ayırt edilebilir olmalıdır.

**Durak kural yapısı:**
- Bir durakta birden fazla işlem kuralı olabilir.
- İşlem adları Buy/Sell değil, Load/Unload olacaktır.
- Load: Master'ın ilgili Trading Post deposundan mal almasıdır.
- Unload: Master'ın taşıdığı malı ilgili Trading Post deposuna bırakmasıdır.
- Buy/Sell ifadeleri Caravan Master UI'ında kullanılmamalıdır; bunlar Trading Post'un market işlemleriyle karışır.
- Unload tarafında bekleme/koşul modu bulunmaz; hedef depoya kapasite izin verdiği ölçüde mal bırakılır.
- Aynı durakta aynı mal için hem Load hem Unload kuralı tanımlanamaz. Gerekirse oyuncu aynı şehri rota içinde ikinci kez ekleyebilir.

**Load davranış modları:**
- Load Available: Depoda ne varsa, kapasite ve max miktar sınırına kadar yükler; beklemez.
- Wait Until Full: Belirlenen max miktara ulaşmadan hareket etmez.
- Wait Until Amount: Kullanıcının belirlediği minimum miktara ulaşınca yükler; max miktarı aşmaz.
- Take Exact Amount: Belirlenen adedi yükler; o adet yoksa bekler, daha fazlasını almaz.
- Load davranış modu sadece Load kuralları için geçerlidir; Unload kurallarında kullanılmaz.
- Varsayılan Load modu: Load Available. Bu mod rota kilitlenme riskini azaltır.

**Durak çalışma sırası ve kapasite davranışı:**
- Master bir durağa geldiğinde önce Unload kuralları, sonra Load kuralları çalışır.
- Oyuncu UI'da farklı sırada görse veya eklese bile çalışma sırası sistem tarafından önce Unload, sonra Load olarak uygulanır.
- Unload sırasında hedef depoda yeterli boş alan yoksa mümkün olan kadar mal bırakılır; kalan mal master üzerinde kalır ve rota devam eder.
- Birden fazla Load kuralı varsa ve master kapasitesi hepsine yetmiyorsa, Load kuralları listedeki sıraya göre çalışır.
- Load kurallarında ayrıca priority alanı kullanılmaz; oyuncu önceliği kural sırasını değiştirerek belirler.

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
- Her durakta hangi maldan ne kadar yükleneceği/boşaltılacağı ve Load davranış modu net görünmelidir.
- Caravan Master UI'ında fiyat limiti rota kuralı olarak girilmez.
- Route ekranında beklenen kârlılık gösterilecekse, bu bilgi Trading Post buy/sell fiyat kurallarından türetilmelidir.
- Cargo uyumsuzluğu uyarısı kritik seviyede gösterilmeli ve oyuncu `Proceed Anyway` demeden rota aktifleşmemelidir.
- Temporary Unload Stop / Rule normal rota duraklarından görsel olarak ayrılmalıdır.
- Temporary Unload önerilerinde mevcut boş alan gösterilebilir; ancak oyuncuya bu alanın rezerve edilmediği açıkça belirtilmelidir.
- Route oluşturma akışında önce boşta Caravan Master seçimi, sonra rota durakları ve kuralları gelmelidir.
- Trade Routes panelinde mini map ile route listesi birbirini desteklemelidir: listede seçilen route mini map üzerinde vurgulanmalı, mini mapten seçilen route listede aktif hale gelmelidir.
- Oyuncuya otomasyon zinciri açıkça gösterilmelidir.
- Örnek okunabilir zincir:
  - “Ironmere Post buys Bread under 22g → Master loads Bread from Ironmere → Master unloads Bread at Stonebridge → Stonebridge Post sells Bread over 31g → Expected margin: +9g/unit”
- Bu zincir görünürlüğü, Post ve Master sistemlerinin ayrı UI'lardan yönetilmesinin yaratacağı zihinsel yükü azaltmak için ana çözüm yönüdür.

## Açık Sorular

**Post+Master koordinasyonu okunabilirliği**
Trading Post buy rule mal satın alıp depoya koyuyor. Caravan Master da depodaki malı başka depoya taşıyor. Bu iki sistem ayrı UI'dan yönetiliyor. Oyuncu bu zinciri zihinsel olarak kurabilmeli; zincir ve beklenen margin yeterince görünür mü?

**Suspend sonrası yeniden açış**
Debt 60 günde post suspended olunca oyuncu onu tekrar açmak için 300 gold daha ödemek zorunda mı? Evet — bu recover yolunu kasıtlı olarak zorlaştırıyor.

## Gerilimler

**Otomasyon karmaşıklığı**
Post buy/sell kuralları + master route kuralları + Load davranış modları + canlı rota düzenleme + master özellik sistemi birlikte oldukça derin. Erken oyuncunun bunu kavraması zor olabilir. Çözüm yönü: UI'da otomasyon zinciri, rota durakları, mal miktarları, Load davranışı ve beklenen margin açık gösterilmeli.

**Master ve player yarışması**
Oyuncu bir kasabada ucuz malı bulmak isterken post buy rule'u o malı zaten almış olabilir. Ya da tam tersi — master bir malı taşırken oyuncu onu başka yere satmak isteyebilir. Bu çatışma kasıtlı mı (kaynak yönetimi), rahatsız edici mi?

**Canlı rota düzenleme teknik riski**
Master rota üzerindeyken rota düzenlenebildiği için mevcut seyahat, current leg, current stop index ve cargo state dikkatli korunmalıdır. Değişiklikler master'ı ışınlatmamalı, mevcut travel leg'i bozmamalı ve rota state'inde tutarsızlık üretmemelidir.

**Temporary Unload karmaşıklığı**
Geçici unload durakları oyuncuya güçlü bir kurtarma yolu sağlar; ancak normal rota duraklarıyla karışırsa kafa karıştırabilir. UI'da temporary stop/rule açık işaretlenmeli ve cargo tamamen boşalınca otomatik kaldırıldığı anlaşılmalıdır.

**Temporary Unload rezervasyon yapmama riski**
Temporary Unload hedefi önerildiğinde depo alanı rezerve edilmez. Başka route veya Trading Post işlemleri master hedefe varmadan alanı doldurabilir. Bu durumda unload başarısız olabilir veya partial gerçekleşebilir. Sistem bunu kabul eder; temporary unload görevi cargo tamamen boşalana kadar silinmez.

**Route başlangıç ve reposition riski**
Yeni route'un ilk durağı master'ın bulunduğu şehir olmak zorunda değildir. Bu nedenle master önce ilk durağa boş veya mevcut cargo ile reposition seyahati yapabilir. UI bu başlangıç seyahatini açık göstermelidir; aksi halde oyuncu route'un neden hemen işlem yapmadığını anlamayabilir.

**Mini map kalabalığı**
Trade Routes panelinde tüm aktif route'lar mini map üzerinde çizilecektir. Route sayısı arttıkça harita kalabalıklaşabilir. Seçili route vurgusu güçlü olmalı; gerekirse ileride filtre/layer seçenekleri değerlendirilebilir.

## Tartışma Notları

- [2026-06-02] Trade Routes UI kararları alındı. Caravan Master / Trade Route yönetimi world map üzerinden açılan ayrı bir panelden yapılacak; TownUI/Post tab şehir içi Trading Post kuralları için kalacak. Panel ana görünümü route odaklı olacak. Panel içinde şehirleri, yolları, aktif route çizgilerini ve master konumlarını gösteren interaktif mini map bulunacak. Yeni route şehirleri mini map üzerinden tıklanarak oluşturulacak. Mini mapte tüm route'lar çizilecek, seçili route güçlü şekilde vurgulanacak.
- [2026-06-02] Master-route atama kuralları netleştirildi. Bir Caravan Master aynı anda yalnızca bir aktif route yönetebilir. Route oluşturmak için boşta master seçmek zorunludur; mastersız veya taslak route sistemi olmayacak. Master başka route'a atanacaksa önce mevcut route iptal edilir, sonra yeni route kurulur. Boşta master yeni route'a bulunduğu şehirden başlar; ilk durak farklıysa master önce ilk durağa reposition seyahati yapar.
- [2026-06-02] Temporary Unload hedef seçimi ve rezervasyon davranışı netleştirildi. Sistem en yakın uygun Trading Post'u önerir; önce cargo'yu tam boşaltabilecek post aranır, yoksa partial unload yapabilecek post önerilir. Temporary Unload önerisi depo alanı rezerve etmez; master hedefe vardığında gerçek boşluk tekrar kontrol edilir. Yer yoksa cargo master üzerinde kalır ve Temporary Unload görevi silinmeden sonraki döngüde tekrar denenir. Temporary Unload Stop/Rule oyuncu tarafından manuel silinebilir; silinirse cargo uyumluluğu yeniden kontrol edilir.
- [2026-06-02] Canlı rota düzenlemesinde cargo uyumu kararı alındı. Master üzerindeki cargo yeni rotada Unload karşılığı bulamazsa sistem kritik uyarı verir ve oyuncu `Proceed Anyway` demeden rota aktifleşmez. Oyuncu uyumsuz cargo'yu çözmek için ilgili mal için geçici Unload durağı/kuralı ekleyebilir. Geçici unload mevcut cargo tamamen boşalınca otomatik kaldırılır; sırf bu iş için eklenen geçici durak da cargo boşalınca silinir.
- [2026-06-02] Caravan Master rota çalışma davranışı netleştirildi. Rotalar tek seferlik değil, kullanıcı iptal edene kadar sonsuz döngü şeklinde çalışacak. İptal edildiğinde master bulunduğu yerde idle olur ve cargo üzerinde kalır. Rota canlı düzenlenebilir; ancak değişiklikler master'ı ışınlamaz, mevcut seyahati bozmaz ve master bir sonraki şehre vardığında uygulanır. Bu karar teknik risk taşıdığı için implementation aşamasında runtime route state dikkatli korunmalıdır.
- [2026-06-02] Caravan Master durak yürütme kuralları netleştirildi. Unload sırasında hedef depoda yeterli alan yoksa mümkün olan kadar boşaltılır ve kalan cargo master üzerinde taşınmaya devam eder. Bir durakta çalışma sırası sistem tarafından önce Unload, sonra Load olarak uygulanır. Birden fazla Load kuralında kapasite yetmezse yükleme listedeki sıraya göre yapılır; ayrı priority alanı kullanılmaz. Aynı durakta aynı mal için hem Load hem Unload tanımlanamaz.
- [2026-06-02] Caravan Master durak kural sistemi netleştirildi. Bir durakta birden fazla kural olabilir. İşlem adları Buy/Sell değil Load/Unload olacak. Caravan Master kuralında fiyat limiti olmayacak; fiyat limitleri Trading Post buy/sell kurallarına ait kalacak. Load için kullanıcı davranış modu seçebilecek: Load Available, Wait Until Full, Wait Until Amount, Take Exact Amount. Bu bekleme/koşul sistemi yalnızca Load tarafında olacak; Unload tarafında kullanılmayacak.
- [2026-06-02] Caravan Master trade route yapısı çok duraklı olarak netleştirildi. Oyuncu şehirleri world map üzerinden kendisi seçecek; rota standart döngüye zorlanmayacak. Aynı şehir rota içinde tekrar edebilecek. Örnek akışlar: Ironmere → Stonebridge → Kingsport → Ironmere veya Ironmere → Stonebridge → Kingsport → Stonebridge → Ironmere.
- [2026-05-31] Caravan Master sistemi Patrician trade route yaklaşımından ilhamla netleştirildi. Master doğrudan markete girmeyecek; Trading Post şehir içi otomasyon, Caravan Master şehirler arası depot-to-depot lojistik olarak konumlandı. Tek sabit aday yerine 3 adaylı, 30 günde yenilenen aday havuzu kararı alındı.
