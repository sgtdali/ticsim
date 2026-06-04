# Caravan Master Routes Design

Bu dosya Caravan Master temel rolünü, route atama kurallarını, rota yaşam döngüsünü, durak kural sistemini, temporary unload davranışını ve Trade Routes panel UI kararlarını tutar.

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

## Master ve Route Ataması

- Bir Caravan Master aynı anda yalnızca bir aktif route yönetebilir.
- Bir route oluşturmak için boşta bir Caravan Master seçmek zorunludur.
- Mastersız route veya taslak route sistemi bulunmaz.
- Bir master başka route'a atanmak istenirse önce mevcut route iptal edilir, sonra aynı master ile yeni route kurulur.
- Route iptal davranışı aynen geçerlidir: master bulunduğu yerde idle olur ve cargo üzerinde kalır.
- Yeni route atanırken master üzerinde cargo varsa cargo uyumluluğu kontrol edilir.
- Eğer yeni rotada uygun Unload kuralı yoksa sistem kritik uyarı gösterir; oyuncu `Proceed Anyway` demeden route aktifleşmez.
- Temporary Unload seçeneği sunulur.
- Cargo uyumluluk kontrolü canlı rota düzenlemesiyle aynı mekanizmayı kullanır ve yeni route atama anını da kapsar.
- Boşta master yeni route'a bulunduğu şehirden başlar.
- Yeni route'un ilk durağı master'ın bulunduğu şehir olmak zorunda değildir.
- Eğer ilk durak farklı şehirdeyse master önce route'un ilk durağına seyahat eder; sonra route kuralları işlemeye başlar.
- Reposition seyahati sırasında master üzerindeki cargo olduğu gibi taşınır; yolda Load/Unload kuralı çalışmaz.
- Cargo uyumsuzluğu kontrolü route atama anında yapıldığı için reposition sırasında ayrıca müdahale gerekmez.

## Trade Route Yapısı

- Caravan Master rotaları çok duraklı olabilir.
- Oyuncu rota duraklarını world map üzerinden kendisi seçer.
- Rota otomatik olarak standart döngüye zorlanmaz; durak sırası tamamen oyuncu kararına bağlıdır.
- Aynı şehir rota içinde birden fazla kez yer alabilir.
- Rota basit döngü olabilir: `Ironmere Post -> Stonebridge Post -> Kingsport Post -> Ironmere Post`.
- Rota geri dönüşlü/tekrar duraklı olabilir: `Ironmere Post -> Stonebridge Post -> Kingsport Post -> Stonebridge Post -> Ironmere Post`.
- Sistem oyuncuya lojistik hattın şeklini kurma özgürlüğü vermelidir; UI durak sırasını açıkça göstermelidir.

## Trade Routes Panel UI

- Caravan Master / Trade Route yönetimi TownUI içinden değil, world map üzerinden açılan ayrı bir `Trade Routes` panelinden yapılır.
- TownUI / Post tab yalnızca ilgili şehrin Trading Post kuralları için kullanılır.
- Trade Routes panelinin ana görünümü route odaklıdır; master route'un atanmış çalışanı gibi görünür.
- Ana listede route adı, bağlı master, status, cargo özeti ve gerekirse uyarılar gösterilmelidir.
- Panelde ana haritanın küçültülmüş interaktif bir versiyonu bulunmalıdır.
- Mini map üzerinde şehirler, yollar, aktif route çizgileri ve Caravan Master konumları görünmelidir.
- Yeni route oluştururken oyuncu şehirleri mini map üzerinden sırayla tıklayarak route stop'ları oluşturur.
- Mini map üzerinde tüm aktif route'lar çizilir; seçili route diğerlerinden daha belirgin şekilde vurgulanır.
- Route çizgileri route kimliğine göre otomatik farklı renk alır; renkler taşıdığı mala göre belirlenmez.
- Seçili route çizgisi kalınlaşır, diğer route'lar soluklaşır.
- Seçili route'un durak sırası mini map üzerinde küçük sıra numaralarıyla gösterilir.
- Ok, animasyonlu çizgi veya hareket efekti şimdilik kullanılmaz; seçili route için kalınlık, soluklaştırma ve durak numaraları yeterlidir.
- Seçili route'un stop sırası, yönü ve mevcut master konumu mini map üzerinde açıkça okunmalıdır.

## Rota Çalışma Davranışı

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

## Canlı Rota Düzenleme ve Cargo Uyumu

- Canlı düzenleme yapıldığında master üzerindeki mevcut cargo yeni rota ile karşılaştırılır.
- Eğer master üzerindeki bir mal için yeni rotada uygun Unload kuralı yoksa sistem kritik uyarı gösterir.
- Bu durumda rota doğrudan aktifleşmez; oyuncu açıkça `Proceed Anyway` demeden yeni rota uygulanmaz.
- Sistem cargo'ya otomatik dokunmaz; cargo master üzerinde kalır.
- Oyuncu bu durumdan çıkmak için rotaya ilgili mal için bir Unload kuralı ekleyebilir.
- Uyarı ekranı oyuncuya çözüm olarak ilgili mal için geçici boşaltma durağı/kuralı ekleme seçeneği sunmalıdır.
- Bu cargo uyumluluk kontrolü yeni route atama anında da çalışır; yalnızca canlı düzenlemeyle sınırlı değildir.

## Temporary Unload Stop / Rule

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

## Durak Kural Yapısı

- Bir durakta birden fazla işlem kuralı olabilir.
- İşlem adları Buy/Sell değil, Load/Unload olacaktır.
- Load: Master'ın ilgili Trading Post deposundan mal almasıdır.
- Unload: Master'ın taşıdığı malı ilgili Trading Post deposuna bırakmasıdır.
- Buy/Sell ifadeleri Caravan Master UI'ında kullanılmamalıdır; bunlar Trading Post'un market işlemleriyle karışır.
- Unload tarafında bekleme/koşul modu bulunmaz; hedef depoya kapasite izin verdiği ölçüde mal bırakılır.
- Aynı durakta aynı mal için hem Load hem Unload kuralı tanımlanamaz. Gerekirse oyuncu aynı şehri rota içinde ikinci kez ekleyebilir.

## Load Davranış Modları

- Load Available: Depoda ne varsa, kapasite ve max miktar sınırına kadar yükler; beklemez.
- Wait Until Full: Belirlenen max miktara ulaşmadan hareket etmez.
- Wait Until Amount: Kullanıcının belirlediği minimum miktara ulaşınca yükler; max miktarı aşmaz.
- Take Exact Amount: Belirlenen adedi yükler; o adet yoksa bekler, daha fazlasını almaz.
- Load davranış modu sadece Load kuralları için geçerlidir; Unload kurallarında kullanılmaz.
- Varsayılan Load modu: Load Available. Bu mod rota kilitlenme riskini azaltır.

## Durak Çalışma Sırası ve Kapasite Davranışı

- Master bir durağa geldiğinde önce Unload kuralları, sonra Load kuralları çalışır.
- Oyuncu UI'da farklı sırada görse veya eklese bile çalışma sırası sistem tarafından önce Unload, sonra Load olarak uygulanır.
- Unload sırasında hedef depoda yeterli boş alan yoksa mümkün olan kadar mal bırakılır; kalan mal master üzerinde kalır ve rota devam eder.
- Birden fazla Load kuralı varsa ve master kapasitesi hepsine yetmiyorsa, Load kuralları listedeki sıraya göre çalışır.
- Load kurallarında ayrıca priority alanı kullanılmaz; oyuncu önceliği kural sırasını değiştirerek belirler.

## Master Özellikleri

Master özellikleri 1-5 arasındadır ve seviye atladıkça gelişir:

- Hız: -%10/puan, maksimum -%40 seyahat süresi.
- Kapasite: 15 + 5/puan.
- Pazarlık: +%0.5/puan alım indirimi ve satış bonusu.
- Cesaret: -%3/puan saldırı riski.

XP: durak başına 25, seviye başına `level x 100` threshold. Max seviye 5.

Rank cap: 0 / 1 / 2 / 4 / 6 (Peddler -> Patrician).

## UI / Okunabilirlik Notları

- Rota sistemi şehir/durak bazlı ve mal bazlı okunmalıdır.
- Her durakta hangi maldan ne kadar yükleneceği/boşaltılacağı ve Load davranış modu net görünmelidir.
- Caravan Master UI'ında fiyat limiti rota kuralı olarak girilmez.
- Cargo uyumsuzluğu uyarısı kritik seviyede gösterilmeli ve oyuncu `Proceed Anyway` demeden rota aktifleşmemelidir.
- Temporary Unload Stop / Rule normal rota duraklarından görsel olarak ayrılmalıdır.
- Temporary Unload önerilerinde mevcut boş alan gösterilebilir; ancak oyuncuya bu alanın rezerve edilmediği açıkça belirtilmelidir.
- Route oluşturma akışında önce boşta Caravan Master seçimi, sonra rota durakları ve kuralları gelmelidir.
- Trade Routes panelinde mini map ile route listesi birbirini desteklemelidir: listede seçilen route mini map üzerinde vurgulanmalı, mini mapten seçilen route listede aktif hale gelmelidir.
- Route çizgileri otomatik farklı renkler kullanmalı; mal bazlı renk kullanılmamalıdır.
- Seçili route kalın çizilmeli, diğer route'lar soluklaştırılmalıdır.
- Seçili route'un durak sırası küçük sıra numaralarıyla gösterilmelidir.

## Gerilimler

**Canlı rota düzenleme teknik riski**
Master rota üzerindeyken rota düzenlenebildiği için mevcut seyahat, current leg, current stop index ve cargo state dikkatli korunmalıdır. Değişiklikler master'ı ışınlatmamalı, mevcut travel leg'i bozmamalı ve rota state'inde tutarsızlık üretmemelidir.

**Temporary Unload karmaşıklığı**
Geçici unload durakları oyuncuya güçlü bir kurtarma yolu sağlar; ancak normal rota duraklarıyla karışırsa kafa karıştırabilir. UI'da temporary stop/rule açık işaretlenmeli ve cargo tamamen boşalınca otomatik kaldırıldığı anlaşılmalıdır.

**Temporary Unload rezervasyon yapmama riski**
Temporary Unload hedefi önerildiğinde depo alanı rezerve edilmez. Başka route veya Trading Post işlemleri master hedefe varmadan alanı doldurabilir. Bu durumda unload başarısız olabilir veya partial gerçekleşebilir. Sistem bunu kabul eder; temporary unload görevi cargo tamamen boşalana kadar silinmez.

**Route başlangıç ve reposition riski**
Yeni route'un ilk durağı master'ın bulunduğu şehir olmak zorunda değildir. Bu nedenle master önce ilk durağa boş veya mevcut cargo ile reposition seyahati yapabilir. UI bu başlangıç seyahatini açık göstermelidir; aksi halde oyuncu route'un neden hemen işlem yapmadığını anlamayabilir.

**Mini map kalabalığı**
Trade Routes panelinde tüm aktif route'lar mini map üzerinde çizilecektir. Route sayısı arttıkça harita kalabalıklaşabilir. Route bazlı renkler, seçili route kalınlığı ve diğer route'ların soluklaştırılması okunabilirliği artırmalıdır. Gerekirse ileride filtre/layer seçenekleri değerlendirilebilir.

## Tartışma Notları

- [2026-06-04] Caravan Master rota, live edit, temporary unload, durak kuralı ve Trade Routes panel kararları ana `trading_post.md` dosyasından ayrıldı.
- [2026-06-02] Reposition seyahati sırasında cargo davranışı netleştirildi. Yeni route atanırken master üzerinde cargo varsa cargo uyumluluk kontrolü çalışır; uygun Unload yoksa kritik uyarı ve Temporary Unload seçeneği sunulur.
- [2026-06-02] Trade Routes mini map route gösterimi netleşti. Route çizgileri route kimliğine göre otomatik farklı renk alacak; mal bazlı renk kullanılmayacak. Seçili route kalın çizilecek, diğer route'lar soluklaşacak.
- [2026-06-02] Trade Routes UI kararları alındı. Caravan Master / Trade Route yönetimi world map üzerinden açılan ayrı bir panelden yapılacak; TownUI/Post tab şehir içi Trading Post kuralları için kalacak.
- [2026-06-02] Master-route atama kuralları netleşti. Bir Caravan Master aynı anda yalnızca bir aktif route yönetebilir. Route oluşturmak için boşta master seçmek zorunludur; mastersız veya taslak route sistemi olmayacak.
- [2026-06-02] Temporary Unload hedef seçimi ve rezervasyon davranışı netleşti. Sistem en yakın uygun Trading Post'u önerir; depo alanı rezerve etmez.
- [2026-06-02] Canlı rota düzenlemesinde cargo uyumu kararı alındı. Uyumsuz cargo varsa kritik uyarı, `Proceed Anyway` olmadan rota aktifleşmez, Temporary Unload sunulur.
- [2026-06-02] Caravan Master rota çalışma davranışı netleşti. Sonsuz döngü, iptal edilince idle, canlı düzenleme mevcut seyahati bozmaz.
- [2026-06-02] Caravan Master durak yürütme kuralları netleşti. Önce Unload sonra Load, partial unload kabul edilir, kapasite yetmezse listedeki sıraya göre yükleme.
- [2026-06-02] Caravan Master durak kural sistemi netleşti. Load/Unload isimleri, fiyat limiti yok, Load için 4 davranış modu.
