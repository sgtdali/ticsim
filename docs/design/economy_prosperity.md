# Economy Prosperity & Demand Satisfaction Design

Bu dosya şehir refahı, demand satisfaction, bolluk spirali, prosperity yatırımı, automation fixed cost ve NPC trader okunabilirliği kararlarını tutar.

## MVP Kapsamı

MVP'de temel demand satisfaction uygulanacak:

- Şehir günlük tüketim/talep hesabı.
- Survival satisfaction refahın ana belirleyicisi.
- Luxury/Comfort yüksek prosperity şehirlerde hafif baskı.
- Processed/Industry üretime hafif verim etkisi.
- Raw Material için çifte ceza yok.
- Günlük prosperity clamp.
- Basit prosperity yatırım bandları.
- Rank koşullarıyla uyumlu Growing / Prosperous eşikleri.
- NPC trader arka plan stok dalgalandırıcı olarak çalışacak.

MVP'de sade tutulacak:

- Prosperity ihtiyaç bandları sayısal olarak basit kalacak.
- Eksik tedarik growth stop/düşüş detayları minimal uygulanacak veya sonraya bırakılacak.
- Automation fixed cost modeli karar olarak korunacak; sayısal balance MVP'de basit tutulacak.
- NPC trader görünürlüğü market tooltip / şehir uyarısı gibi sınırlı izlerle kalacak.

MVP dışı:

- Tam civic project sistemi.
- Çok ayrıntılı prosperity ihtiyaç profilleri.
- Derin şehir bakım ekonomisi.
- Stratejik rakip NPC trader sistemi.
- Trade rumor / NPC rota tahmini.
- Kapsamlı snowball test ve late-game balance.
- Oyuncu sahipli üretim (bkz. bölüm 6 — post-MVP yönü).

Bu dosyadaki bolluk spirali ve geç oyun kararları tam vizyonu korur; MVP implementasyonu için önce bu kapsam esas alınmalıdır.

## Demand Satisfaction ve Şehir Etkileri (Karar verilmiş)

- Tüketim fazında her mal için karşılanma oranı hesaplanır: `tüketilen_miktar / talep_edilen_miktar`.
- MVP satisfaction eşikleri:
  - `%80+` = iyi / normal
  - `%40-80` = zayıf
  - `%40 altı` = kötü / kritik
- Fiyat için stok-gün eğrisi kullanılır; şehir sağlığı için günlük demand satisfaction kullanılır.
- Survival satisfaction prosperity ve nüfus için ana şehir sağlığı göstergesidir:
  - `%80+` -> prosperity `+2`
  - `%40-80` -> prosperity `-1`
  - `%40 altı` -> prosperity `-4`
- Survival kötü satisfaction (`%40 altı`) 3 gün birikirse nüfus `-%3` azalır.
- Nüfus düşüşü her 3 kötü günde bir tetiklenir; düşüşten sonra sayaç sıfırlanır.
- Kötü gün sayacı kademeli toparlanır: `%40 altı` sayaç `+1`, `%40-80` sayaç azaltır, `%80+` sayaç sıfırlar.
- Luxury/Comfort satisfaction düşük/orta prosperity şehirleri cezalandırmaz; yüksek prosperity şehirlerde refah koruma baskısı yaratır.
- Luxury/Comfort negatif baskısı sadece prosperity `70+` şehirlerde çalışır.
- Luxury/Comfort etkisi hafiftir:
  - `%80+` -> prosperity artışına izin verir veya küçük `+1` destek sağlar.
  - `%40-80` -> luxury kaynaklı artış yok.
  - `%40 altı` -> sadece prosperity `70+` şehirlerde `-1` baskı.
- Processed/Industry eksikliği production_plan / işlenmiş üretimlere hafif verim cezası verir ve prosperity büyümesini sınırlar:
  - `%80+` -> üretim cezası yok
  - `%40-80` -> production_plan üretimi `-%5`
  - `%40 altı` -> production_plan üretimi `-%10`
- Processed/Industry üretim cezası doğal kaynak üretimini etkilemez.
- Raw Material eksikliği input eksikliği dışında ek şehir etkisi yaratmaz; çifte ceza uygulanmaz.
- Günlük otomatik prosperity değişimi kategori etkilerinin toplamı olacak ve günlük clamp ile sınırlandırılacak.
- MVP günlük prosperity clamp değeri `-2 / +2` olarak kabul edildi:
  - Ham toplam `+2` üstündeyse uygulanacak günlük artış `+2` ile sınırlanır.
  - Ham toplam `-2` altındaysa uygulanacak günlük düşüş `-2` ile sınırlanır.
  - Bu değer, 120-180 günlük MVP victory hedefinde şehir gelişimini görünür tutarken ani snowball veya ani çöküş riskini azaltmak için seçildi.
  - Survival kötü satisfaction ve nüfus düşüşü sayaçları clamp dışında kendi kurallarıyla çalışır; clamp yalnızca günlük prosperity puanı değişimini sınırlar.

## Bolluk Spirali - Kabul Edilen Çözüm Yönleri

Bu bölüm nihai sayısal mekanik kararı değildir. Kabul edilenler, bolluk spirali problemini çözmek için tasarım yönü olarak kaydedilmiştir. Her maddenin Ironmere'ye entegrasyonu, hangi sistemleri etkileyeceği ve sayısal/mekanik kararları sonraki oturumlarda ayrıca alınacaktır.

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

- Günlük talep ve tüketim: prosperity'nin özellikle Luxury/Comfort kişi başı tüketimi artıracağı kararı.
- Demand tag sistemi: food, comfort, luxury, construction, industry, military kaynakları.
- Rank/progression tarafı: rank koşullarında Growing/Prosperous city eşikleri.
- Ekonomi bilgi görünürlüğü: oyuncuya formül değil, okunabilir neden/uyarı gösterme yaklaşımı.

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

Prosperity yatırım maliyeti basamaklı band modeliyle artacak. Düşük prosperity bandında yatırım ucuz, orta bandda belirgin pahalı, yüksek prosperity bandında ciddi pahalı olacak. Kesin band aralıkları ve sayısal çarpanlar balance aşamasında netleşecek.

Tasarım niyeti:

- Erken seviyelerde şehir toparlamak ve büyütmek ulaşılabilir olacak.
- Orta seviyede yatırım hâlâ anlamlı ama daha bilinçli karar gerektirecek.
- Prosperous seviyeye ulaşmak ciddi sermaye, düzenli tedarik ve planlama isteyecek.
- Oyuncu sadece birikmiş parayı prosperity'ye basarak risksiz snowball yaratamayacak.
- Bu sistem para yakıcı gibi çalışacak ama çıplak vergi hissi vermeyecek.

Sonradan alınacak mekanik kararlar:

- Prosperity yatırım bandları ve çarpanları hangi sayılarla kurulacak?
- Maliyet bandı prosperity seviyesine göre mi, şehir seviyesine göre mi, nüfusa göre mi belirlenecek?
- 0-30, 30-65 ve 65+ aralıkları kullanılacak mı?
- Yatırım doğrudan prosperity puanı mı verir, yoksa growth modifier / civic project etkisi mi verir?
- Tek seferlik yatırım mı, proje bazlı yatırım mı, günlük/haftalık bakım etkisi mi olacak?
- Rank ilerlemesi için gerekli prosperity değerlerine ulaşmak ne kadar zaman ve para istemeli?

### 4. Automation büyüdükçe fixed cost anlamlı hale gelecek

Kabul edilen yön: Trading Post, Caravan Master, depot expansion ve yüksek seviye master kullanımı geç oyunda anlamlı fixed cost yaratacak. Detaylar sonradan ayrıca tasarlanacak.

Geç oyun para yakıcıları dengeli dağıtılacak:

- Prosperity yatırımı büyük ama daha seyrek/stratejik para yakıcı olacak.
- Automation upkeep sürekli ama kontrollü işletme gideri yaratacak.
- Depot expansion kapasite avantajı verdiği için hem tek seferlik maliyet hem küçük günlük upkeep artışı taşıyacak.
- Prestige/rank maliyeti MVP'de para yakıcı olarak kullanılmayacak.
- Diminishing return doğrudan kârı kıran ayrı bir sistem olarak değil, prosperity yatırım eğrisi ve automation işletme maliyetiyle dolaylı kurulacak.

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

- Trading Post upgrade/depot expansion upkeep artışı sayısal olarak ne kadar olacak?
- Caravan Master archetype, level/stat ve capacity wage çarpanları hangi sayılarla kurulacak?
- Broker/Veteran gibi yüksek verimli master'ların hire cost ve wage değerleri ne kadar pahalı olmalı?
- Automation UI'da gross margin, upkeep ve net margin hangi panel/satır düzeniyle gösterilecek?
- Automation fixed cost, debt modelini çok sertleştirmeden nasıl dengelenecek?
- Bu konu [trading_post.md](trading_post.md), [trading_post_debt.md](trading_post_debt.md) ve [caravan_master_hiring.md](caravan_master_hiring.md) ile birlikte detaylandırılmalı.

### 5. NPC trader ekonomi dalgalanması yaratacak ve okunabilir olacak

Kabul edilen yön: NPC trader stokları ve fiyatları gerçek işlemlerle etkilemeye devam edecek; oyuncu bu etkinin en azından bir kısmını okuyabilmeli.

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
- NPC trader sisteminin faction rep ile bağlantısı olacak mı, yoksa tamamen ekonomik aktör olarak mı kalacak?

### 6. Post-MVP yönü: prosperity yatırımının oyuncu sahipli üretime evrilmesi

Kabul edilen post-MVP tasarım yönü (2026-06-10 benchmark analizi sonucu — MVP işi değildir, MVP'deki basit yatırım bandları olduğu gibi uygulanır):

- Patrician III'ün çekirdek başarısı oyuncunun üretime sahip olmasıdır: işletme kurmak, üretim-tüketim dengesini yönetmek, darboğaz çözmek "gerçekten hak edilmiş imparatorluk" hissini yaratır.
- Mevcut soyut "para -> prosperity puanı" yatırımı uzun vadede iki sorun taşır: bolluk spiralinin en çıplak hali olması ve duygusal getirisinin zayıf kalması.
- Post-MVP'de prosperity yatırımının en azından bir kısmı somut üretim yatırımına evrilmelidir: oyuncu şehre üretim binası kurar, girdisini tedarik eder, çıktısı şehri besler ve prosperity dolaylı büyür.
- Bu yön, bolluk spirali çözümlerinin (1) ihtiyaç bandı ve (3) kademeli yatırım maliyeti maddeleriyle doğal birleşir: üretim sahipliği hem para yakıcı hem tedarik sorumluluğu yaratır.
- Tasarım detayları (bina tipleri, slot sistemiyle ilişki, girdi zinciri, upkeep) tam sürüm tasarım oturumlarında ele alınacaktır.

## Bolluk Spirali - Sonraki Tasarım Yapılacakları

Bu yapılacaklar kod implementation görevi değildir. Her biri sonraki tasarım oturumlarında derinlemesine mekanik karara dönüştürülecek başlıklardır.

- [ ] **Prosperity ihtiyaç bandı tasarlanacak.** Her prosperity aralığında hangi mal sınıfları ve demand tag'lerin güçleneceği belirlenecek.
- [ ] **Tedarik eksikliği ve prosperity etkisi birlikte yeniden değerlendirilecek.** Mevcut daily demand, demand tag, prosperity growth/decline ve rank koşulu bölümleri beraber okunarak tek tutarlı model çıkarılacak.
- [ ] **Prosperity yatırım bandları ve sayıları belirlenecek.** Basamaklı band modeli seçildi; band aralıkları ve maliyet çarpanları balance edilecek.
- [ ] **Automation fixed cost sayıları detaylandırılacak.** Model seçildi; Trading Post upgrade upkeep'i, depot expansion upkeep'i, Caravan Master wage çarpanları ve high-tier master maliyetleri sayısallaştırılacak.
- [ ] **NPC trader okunabilirlik modeli detaylandırılacak.** NPC hareketlerinin oyuncuya ne kadar ve hangi UI katmanından gösterileceği ekonomi + UX dokümanlarıyla birlikte değerlendirilecek.
- [ ] **Bolluk spirali test senaryoları hazırlanacak.** Oyuncunun post/master ağı kurduğu, prosperity yatırımı yaptığı ve 3 şehirli MVP ekonomisinde snowball'a girip girmediği örnek senaryolarla kontrol edilecek.
- [ ] **Oyuncu sahipli üretim post-MVP tasarlanacak.** Prosperity yatırımının somut üretim yatırımına evrilme modeli (bina tipleri, slot ilişkisi, girdi zinciri, upkeep) tam sürüm kapsamında detaylandırılacak.

## Açık Sorular

**NPC trader ekonomiye etkisi**
NPC'ler town_buy/town_sell üzerinden işlem yapıyor; yani marginal pricing etkisi var, stok değişiyor. Oyuncu buna karşı strateji kurabilmeli mi? NPC'ler sadece arka plan stok değiştirici olarak mı kalacak, yoksa oyuncunun takip edebileceği rakip/aktör gibi mi davranacak? Kabul edilen yön: NPC etkisi oyuncuya en azından sınırlı/okunabilir şekilde gösterilecek; detay mekanik sonra alınacak.

## Gerilimler

**Bolluk spiraline karşı mekanizma**
Oyuncu çok para kazanınca prosperity'ye yatırım yapıyor -> satış bonusu artıyor -> daha çok kazanıyor. Çözüm yönü kabul edildi: prosperity yükseldikçe ihtiyaç seviyesi artacak, eksik tedarik growth stop/düşüş etkisi yaratabilecek, prosperity yatırım maliyeti kademeli artacak, automation fixed cost anlamlı hale gelecek ve NPC trader ekonomi dalgalanması yaratacak. Detay mekanikler henüz kesinleşmedi; yukarıdaki yapılacaklar üzerinden ayrıca tasarlanacak.

## Tartışma Notları

- [2026-06-10] Benchmark analizi (Patrician III/IV, Port Royale 4) sonrası post-MVP tasarım yönü eklendi: prosperity yatırımı uzun vadede oyuncu sahipli üretime evrilecek. Gerekçe: Patrician III'ün "hak edilmiş imparatorluk" hissi üretim sahipliğinden geliyor; soyut para->prosperity yatırımı hem bolluk spiralinin kökü hem duygusal olarak zayıf. MVP'deki basit yatırım bandları değişmedi.
- [2026-06-09] Günlük prosperity clamp değeri MVP için `-2 / +2` olarak kabul edildi. Amaç, 120-180 günlük victory hedefinde şehir gelişimini hissedilir tutmak; ancak demand satisfaction toplam etkilerinin ani snowball veya ani çöküş yaratmasını engellemek. Clamp yalnızca günlük prosperity puanı değişimini sınırlar; survival kötü satisfaction nüfus düşüşü sayaçları kendi kurallarıyla çalışmaya devam eder.
- [2026-06-04] Prosperity, demand satisfaction ve bolluk spirali kararları ana `economy.md` dosyasından ayrıldı. Günlük prosperity clamp, automation fixed cost, NPC okunabilirliği ve snowball testleri bu dosyada takip edilecek.
- [2026-06-04] Geç oyun para yakıcıları için model netleştirildi. Para yakıcılar prosperity investment, automation upkeep ve depot expansion arasında dengeli dağıtılacak; Trading Post upkeep şehir prosperity'sine göre otomatik artmayacak; depot expansion tek seferlik maliyet + küçük upkeep yaratacak; Caravan Master wage archetype + level/stat bazlı olacak; high-tier master'lar hem yüksek hire cost hem yüksek wage taşıyacak; prosperity yatırımı basamaklı band modeliyle pahalılaşacak; prestige/rank maliyeti MVP'de kullanılmayacak; automation UI gross + upkeep + net margin gösterecek.
- [2026-06-03] Demand satisfaction sistemi tasarlandı. Survival, Luxury/Comfort, Processed/Industry ve Raw Material eksikliklerinin şehir etkileri ayrıştırıldı. Survival şehir sağlığının ana göstergesi olacak; luxury yüksek prosperity korumasına, industry ise işlenmiş üretim verimine hafif etki edecek. Günlük prosperity clamp değeri açık soru olarak bırakıldı.
- [2026-06-03] Bolluk spirali için kabul edilen çözüm yönleri kaydedildi. Prosperity yükseldikçe ihtiyaç seviyesi artacak; eksik tedarikin growth stop/düşüş etkisi mevcut doküman bölümleriyle birlikte tekrar değerlendirilecek; prosperity yatırım maliyeti kademeli artacak; automation büyüdükçe fixed cost anlamlı olacak; NPC trader ekonomi dalgalanması yaratacak ve okunabilir olacak.
- [2026-06-03] Ekonomi geliştirme başlıkları karar verilmemiş konu olarak kaydedildi. Geç oyun para yakıcıları, mevcut NPC trader, 3 kasaba sınırı ve bolluk spirali notları detaylandırıldı.
