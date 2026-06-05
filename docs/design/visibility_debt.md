# Visibility Debt

Bu dosya, oyunda mekanik olarak var olan ama oyuncuya UI'da yeterince görünmeyen veya nedeni anlaşılmayan sistemleri takip eder.

Amaç formülleri oyuncuya açmak değildir. Amaç, oyuncunun karar alması için gereken sonuç, uyarı, durum ve neden bilgisinin yeterince okunabilir olup olmadığını görmek ve MVP önceliği vermektir.

## Durum Etiketleri

- **Var:** Oyuncu bu bilgiyi yeterince görüyor.
- **Kısmi:** Bilgi bir yerde var ama zayıf, dağınık, geç fark ediliyor veya nedeni açık değil.
- **Eksik:** Sistem çalışıyor ama oyuncu anlamlı şekilde göremiyor.
- **Pasif:** MVP'de sistem bilinçli olarak kapalı veya kapsam dışı.

## Öncelik Etiketleri

- **P0:** MVP oynanabilirliği veya oyuncu karar kalitesi için kritik.
- **P1:** MVP'de güçlü şekilde faydalı; kafa karışıklığını azaltır.
- **P2:** MVP sonrası polish veya tam sürüm görünürlüğü.

## MVP Görünürlük Borçları

| Sistem / Bilgi | Oyunda var mı? | Oyuncu şu an görüyor mu? | Durum | Öncelik | MVP UI yönü |
|---|---|---|---|---|---|
| Mevsim ve mevsimsel üretim etkisi | Evet. `season_modifiers.csv` ve `TownSimulation.get_season()` ekonomiyi etkiliyor. | Kısmen. Production report içinde sezona dair iz var; global/top bar sinyali net değil. | Kısmi | P1 | Top bar veya market tooltip'te kısa sezon etiketi. Anlamlıysa ürün tooltip'inde sezon etkisi satırı. |
| Market fiyat nedeni | Evet. Stok, tüketim ihtiyacı, prosperity, spread ve mevsim fiyatı etkiliyor. | Kısmen. Market fiyat/stok görünüyor; nedenlerin tamamı her zaman okunmayabilir. | Kısmi | P0 | Ürün satırında fiyat yönü ikonu ve hover'da yalnızca anlamlı etkiler: stok düşük/yüksek, sezon, prosperity, spread. |
| Market full / şehir stok kapasitesi | Evet. Üretim waste oluyor; satış ve kontrat teslimi boş kapasiteye bağlı. | Kısmen. İşlem yapılamayınca neden her yerde açık olmayabilir. | Kısmi | P0 | Satış/teslim butonu disabled ise kısa neden: `Market full`, `Storage full`, `No town capacity`. |
| Ortalama alış fiyatı ve kar/zarar fırsatı | Evet. `purchase_prices` tutuluyor. | Kısmen. Cargo/market alanlarında görünüyor ama rota bazlı fırsat okuması sınırlı. | Kısmi | P1 | Market satırında oyuncu envanteri varsa ortalama alış ve tahmini kar/zarar net gösterilsin. |
| Demand satisfaction / tüketim memnuniyeti | Evet. Tüketim, prosperity ve population etkileniyor. | Zayıf. Şehir raporu bazı sonuçları gösteriyor; oyuncu "neden prosperity düştü?" sorusunu zor okuyabilir. | Eksik | P0 | Info veya şehir uyarılarında `Bread shortage`, `Survival needs unmet`, `Prosperity at risk` gibi kısa uyarılar. |
| Günlük prosperity değişimi | Evet. Tüketim sonrası otomatik prosperity değişiyor. | Kısmen veya eksik. Günlük delta ve nedeni net değil. | Eksik | P0 | Şehir Info panelinde son gün prosperity delta: `+2 food supplied`, `-3 bread shortage`. |
| Prosperity düşme / nüfus düşüş riski | Evet. Survival eksikliği population düşüşüne yol açıyor. | Kısmen. Population trend rengi/okları var; neden net değil. | Kısmi | P1 | Şehir uyarısı: `Population decline risk: bread shortage`. |
| Rank progress gereksinimleri | Evet. RankManager current/required hesaplıyor. | Evet. Sağ panelde current/required gösteriliyor. | Var | P0 | Mevcut görünürlük korunur; eksik hedef en okunur satır olmalı. |
| Debt miktarı ve debt gün sayısı | Evet. `debt` ve `debt_days` tutuluyor. | Kısmen. Finans panelinde görünür olabilir; kritik eşikler netleşmeli. | Kısmi | P0 | Global finance/debt uyarısı: `Debt day 14: rep gains reduced`, `Debt day 60: game over`. |
| 14 gün debt rep cezası | Evet. Pozitif faction rep kazanımı düşüyor. | Eksik. Oyuncu ödülün neden azaldığını anlamayabilir. | Eksik | P1 | Kontrat/rep kazanımı yanında küçük uyarı: `Debt penalty active`. |
| Günlük upkeep kırılımı | Evet. Caravan, rank, Trading Post ve master wage finance summary'de var. | Kısmen. Finans paneli gösteriyor; automation kararına bağlanan net etki zayıf. | Kısmi | P1 | Finans panelinde net günlük akış ve kaynak kırılımı korunur; automation UI ile bağlanır. |
| Automation gross/upkeep/net margin | Kısmen. Upkeep var, automation işlemleri çalışıyor. | Eksik. Oyuncu gross kar ile net karı ayıramaz. | Eksik | P0 | Trading Post / route satırında `Gross`, `Upkeep`, `Net` birlikte. |
| Trading Post rule status | Evet. `active`, `waiting_price`, `waiting_stock`, `waiting_market`, `depot_full`, `depot_empty`. | Evet/kısmi. Status var; bazı atlanma nedenleri status'a yansımayabilir. | Kısmi | P0 | Her rule status'u yanında tek cümle neden. Debt veya market full gibi özel bloklar açık yazılmalı. |
| Trading Post auto-buy debt davranışı | Evet. Debt varken buy işlemi atlanabiliyor. | Eksik. Rule active görünürken işlem yapmama riski var. | Eksik | P0 | Rule status veya global post uyarısı: `Debt: auto-buy skipped`. |
| Trading Post depot doluluğu | Evet. Depot capacity ve item miktarları var. | Kısmen. Post tab/sağ panelde iz var. | Kısmi | P1 | Post listesinde `23/50` gibi doluluk ve item bazlı limitler net kalmalı. |
| Caravan Master route status | Evet. Master route, cargo ve konum var. | Kısmen. Sağ panel/Trade Routes panelinde bazı bilgiler var. | Kısmi | P1 | Route listesinde master, current stop, next stop, cargo, status, uyarı. |
| Caravan Master cargo uyumluluğu | Tasarımda var; kod senkron borcu açık. | Eksik. Uyumsuz cargo için kritik uyarı henüz garanti değil. | Eksik | P1 | Route atarken `No unload rule for X` uyarısı; oyuncu onaylamadan route aktifleşmemeli. |
| Caravan Master reposition seyahati | Tasarımda var; tam kapsam borcu açık. | Eksik veya zayıf. İlk durağa neden boş gittiği anlaşılmayabilir. | Eksik | P2 | Route status: `Repositioning to Ashford`. |
| Caravan Master wage / route net etkisi | Evet. Master daily wage upkeep'e ekleniyor. | Kısmen. Finans kırılımında var; route kararında net değil. | Kısmi | P1 | Master/route satırında günlük wage ve beklenen net margin. |
| Caravan Master adayları | Tasarımda şehir bazlı 0-2 aday var; uygulama borcu açık. | Eksik. Global hire aksiyonu eski model olabilir. | Eksik | P0 | TownUI içinden Tavern paneli; aday varsa stat/cost/wage, yoksa açık boş durum mesajı. |
| Kontrat deadline yaklaşması | Evet. Deadline kabulden sonra işler. | Kısmen. Kalan gün görünüyor; yaklaşınca vurgu/uyarı net değil. | Kısmi | P1 | Aktif kontratta son 2-3 gün renk/ikon uyarısı. |
| Kontrat tamamlanamama nedeni | Evet. Hedef town, deadline, cargo, target stock cap koşulları var. | Eksik/kısmi. Complete butonu disabled olduğunda neden açık olmayabilir. | Eksik | P0 | Disabled buton tooltip'i: `Need 3 bread`, `Travel to Ironmere`, `Market full`, `Deadline passed`. |
| Faction reputation spread etkisi | Evet. Rep alış/satış quote'unu iyileştiriyor. | Kısmen. Reputation değeri Info'da var; fiyat üzerindeki etkisi net olmayabilir. | Kısmi | P1 | Market tooltip'te kısa satır: `Guild reputation improves quote`. Formül gösterilmez. |
| Travel tax | Kod/UI altyapısı var ama ana para akışını etkilemiyor. | Görünürse yanlış beklenti yaratabilir. | Kısmi | P1 | Eğer etkisizse `informational` olarak işaretlenmeli veya MVP UI'dan çıkarılmalı. |
| Seyahat riski | Evet. Base route risk + cargo + faction rep etkisi var. | Evet. Harita tooltip'i risk yüzdesi gösteriyor. | Var | P0 | Mevcut risk yüzdesi korunur; cargo artınca risk artışı sezdirilebilir. |
| Saldırı sonucu cargo kaybı | Evet. AttackPopup kaybı gösteriyor. | Evet. Saldırıdan sonra popup var. | Var | P0 | Mevcut görünürlük yeterli. |
| NPC trader konumu ve cargo | Evet. TraderManager hareket eder ve ticaret yapar. | Kısmen. Label/tooltip var; piyasaya etkisi sınırlı okunuyor. | Kısmi | P2 | MVP'de label yeterli olabilir. Tam sürümde market tooltip/city activity: `NPC bought wheat recently`. |
| NPC trader fiyat/stok etkisi | Evet. NPC town_buy/town_sell gerçek stok değiştiriyor. | Eksik. Oyuncu ani stok/fiyat değişiminin NPC kaynaklı olduğunu anlamayabilir. | Eksik | P2 | Tam sürüm: şehir activity log, rumor veya market tooltip satırı. |
| Event sistemi | Kod shell'i var, MVP'de no-op. | Görünür olmamalı. | Pasif | P2 | MVP'de event panel aktif ekonomi sinyali gibi davranmamalı; tam sürümde geri alınırsa ayrı görünürlük tasarlanır. |
| Victory summary | Evet. Patrician olunca modal gösteriliyor. | Evet. Gün, gold, debt, post/master sayısı ve şehir prosperity özetleniyor. | Var | P0 | Mevcut akış korunur; Continue ile oyun sürer. |
| Game over yaklaşma uyarısı | Evet. 60 gün debt game over. | Kısmen. Game over ekranı var; ön uyarı net olmayabilir. | Kısmi | P0 | Debt panelinde 60 gün sayacı ve kritik renk eşiği. |

## Kod Taramasıyla Bulunan Ana Sayfa / Panel Eksikleri

Bu bölüm, notlardan değil mevcut scene ve script yapısından çıkarılan daha büyük UI yüzeyi eksiklerini takip eder.

Mevcut ana UI yüzeyleri:

- `WorldMap.tscn`: TopBar, sağ panel `Operations / Player / Contracts`, event panel, town buttons.
- `TownScene.gd`: şehir içinde iki ana giriş var: `Market Hall` ve `Town Hall`.
- `TownUI.tscn`: Market, Info, Contracts, Invest, Upgrade, NPC ve runtime eklenen Post tab.
- `TradeRoutePanel.tscn`: dünya haritası üstünde route panel iskeleti, mini map, şehir markerları ve settings alanı.
- `FinancePanelController.gd`: runtime finance summary popup.

Kod taramasında bulunan eksik veya iskelet halinde kalan ana yüzeyler:

| Eksik panel / sayfa | Koddan bulgu | Etkilenen sistem | Durum | Öncelik | MVP UI yönü |
|---|---|---|---|---|---|
| **Tavern / Caravan Master Hiring sayfası** | `SidePanelController._on_hire_master_pressed()` sağ panelde tek butonla rastgele unlocked/affordable master kiralıyor. TownUI'da `Tavern` tab/panel yok. | CaravanMasterManager hiring, master templates, rank cap, wage. | Eksik | P0 | TownUI içinde şehir bazlı Tavern entry point; 0-2 aday kartı, stat/cost/wage, aday yok mesajı. Sağ paneldeki global hire butonu kaldırılmalı veya Tavern'e yönlendirmeli. |
| **Gerçek Trade Route editor sayfası** | `TradeRoutePanel.gd` şehir markerları ve yolları çiziyor ama master seçimi, stop listesi, rule formu, save/start/stop akışı yok. `CaravanMasterManager.set_route()` ve `start_route()` public API olarak var. | Caravan Master routes, Trading Post depoları, route rules. | Eksik | P0 | TradeRoutePanel içinde master seçimi, stop sırası, Load/Unload kural formu, route save/start/stop ve validation uyarıları. |
| **Route listesi / route dashboard** | Sağ panel master detail yalnızca expand olunca route stoplarını ve cargo'yu metin olarak gösteriyor; TradeRoutePanel ana route listesi yok. | Aktif master route'ları, route status, cargo, wage. | Eksik | P1 | TradeRoutePanel sol/sağ kolonunda route listesi: master, active/idle/traveling, current/next stop, cargo, uyarılar. |
| **Automation profit dashboard** | Trading Post rule UI var; route ve post işlemleri çalışıyor. Gross/upkeep/net hesaplarını birleştiren ana ekran yok. FinancePanel sadece genel upkeep ve günlük bucket gösteriyor. | Trading Post, Caravan Master wage, automation ROI. | Eksik | P0 | Operations tab veya ayrı Automation panelinde Post ve Route bazlı Gross / Upkeep / Net. |
| **City report / demand health sayfası** | MarketTab içinde `GoodsProjection` var; `CityInfoPlaceholder` yalnızca placeholder metin yazıyor. InfoTab genel town report gösteriyor ama demand/prosperity nedeni için ayrı okunur sayfa yok. | TownSimulation report, consumption, production, prosperity delta. | Eksik/Kısmi | P0 | Market Hall `City Info` tabı gerçek şehir sağlık raporuna dönüşmeli: shortages, surplus, production blocked, prosperity delta, population risk. |
| **Kasabalar arası market karşılaştırma / trade atlas** | WorldMap tooltip pahalı/ucuz malları kasaba bazında veriyor; oyuncu genel karşılaştırma için kasabaları tek tek okumak zorunda. Ayrı karşılaştırma paneli yok. | MarketSystem prices, route travel days, risk. | Eksik | P1 | MVP'de basit Trade Atlas: town x item fiyat karşılaştırması, stok, risk ve travel days. Rota tavsiyesi vermeden oyuncunun okumasına izin verir. |
| **Contract board / contract details sayfası** | TownUI ContractsTab available + active kontratları listeliyor; sağ panel yalnızca aktif kontratlar. Ayrı contract detail modalı yok. | ContractManager, deadline, rewards, completion conditions. | Kısmi | P1 | Contract card expand/detail: kaynak, hedef, required item, held qty, deadline, reward, fail penalty, disabled completion nedeni. |
| **Rank / victory hedef sayfası** | Sağ panel Player tab rank requirements gösteriyor. Ayrı progression screen yok. | RankManager, prosperity goals, post requirements. | Kısmi | P1 | Player tab yeterli olabilir; ama hedef rehberi olarak Patrician path özetini ve eksik en önemli hedefi vurgulamalı. |
| **Debt warning / finance state sayfası** | FinancePanel var; debt günleri ve upkeep kırılımı görünüyor. Kritik eşik davranışları için ayrı uyarı bandı yok. | PlayerData debt, rep penalty, game over. | Kısmi | P0 | TopBar/FinancePanel içinde debt state banner: safe/warning/critical, 14/60 gün eşikleri. |
| **Event log paneli MVP'de pasifken görünür UI** | `EventPanel` sahnede var, `EventManager` MVP no-op. EventLogController boş panel gösterebilir. | EventManager, MVP scope. | Kısmi | P1 | MVP'de event panel gizlenmeli, sezon/şehir uyarıları paneline dönüştürülmeli veya boş event alanı oyuncuya gösterilmemeli. |
| **Trading Post management ana sayfası** | TownUI Post tab şehir bazlı depo/rule yönetiyor; sağ panel established post özetini gösteriyor. Tüm postları birlikte düzenleyen ana panel yok. | TradingPostManager posts, depot, rules. | Kısmi | P1 | Operations tab özet kalabilir; tam yönetim için her post satırından ilgili Town/Post UI'a deep link veya ayrı Post Network paneli. |
| **System help / onboarding paneli** | Kodda tutorial/help overlay görünmüyor. Derin sistemler organik keşfe bırakılmış. | Market, prosperity, post, master, debt. | Eksik | P2 | MVP sonrası kısa contextual help; MVP'de en azından disabled nedenleri ve empty state metinleri güçlü olmalı. |

## Kod Taraması Sonucu İlk Büyük UI Adayları

Bu adaylar, mevcut sistemlerin ana kullanım akışını doğrudan etkilediği için mikro tooltip işlerinden önce veya onlarla birlikte ele alınmalıdır:

- [ ] **Tavern / Caravan Master Hiring sayfası.** Şehir bazlı aday kararı kodda henüz gerçek UI yüzeyi bulmuyor.
- [ ] **Gerçek Trade Route editor.** `TradeRoutePanel` harita iskeleti olmaktan çıkıp route kurma ekranı olmalı.
- [ ] **City report / demand health sayfası.** `CityInfoPlaceholder` gerçek ekonomi sağlık ekranına dönmeli.
- [ ] **Automation profit dashboard.** Post ve Master otomasyonunun net karı ana karar yüzeyi olarak görünmeli.
- [ ] **Debt warning banner.** Finance popup dışında global kritik uyarı katmanı olmalı.
- [ ] **Event panelinin MVP karşılığı.** Event sistemi pasifken boş event paneli yerine şehir uyarıları/sezon bilgisi veya gizleme kararı verilmeli.

## MVP İçin İlk Uygulama Adayları

Bu maddeler görünürlük borcunun en yüksek etkili kısmıdır:

- [ ] **Automation gross/upkeep/net margin UI.** Trading Post ve Caravan Master kararlarında net karı görünür yapar.
- [ ] **Kontrat tamamlanamama nedeni.** Disabled Complete butonu oyuncuya nedenini söylemeli.
- [ ] **Demand satisfaction / prosperity delta uyarısı.** Şehir refahı neden değişiyor sorusunu çözer.
- [ ] **Debt eşik uyarıları.** 14 gün rep cezası ve 60 gün game over sayacı açık görünmeli.
- [ ] **Trading Post debt/market/depot blok nedeni.** Rule active görünüp işlem yapmama hissini engeller.
- [ ] **Mevsim bilgisi.** Ekonomi değişimini oyuncuya formül vermeden bağlar.
- [ ] **Caravan Master şehir bazlı Tavern adayları.** Bu zaten MVP senkron borcudur; görünürlük tarafında aday yokluğu da açık mesaj ister.

## MVP Sonrası / Tam Sürüm Görünürlükleri

- NPC trader activity'nin şehir/market tooltip veya rumor sistemiyle okunabilir hale gelmesi.
- Route mini-map polish, filtre/layer ve yoğun route okunabilirliği.
- Temporary Unload ve reposition davranışlarının daha detaylı UI açıklaması.
- Tam ekonomik rapor ekranı veya şehirler arası fiyat karşılaştırma ekranı.
- Event sistemi geri gelirse event ön haberleri, şehir uyarıları ve market etkileri.

## Tartışma Notları

- [2026-06-05] Kod taramasıyla mikro görünürlük borçlarının dışında ana UI yüzeyi eksikleri de ayrıldı. Tavern/Hiring sayfası, gerçek Trade Route editor, route dashboard, automation profit dashboard, city report/demand health sayfası, trade atlas, debt warning banner ve MVP event paneli karşılığı ilk büyük eksikler olarak kaydedildi.
- [2026-06-05] Oyunda çalışan ama oyuncuya zayıf görünen sistemler için ayrı görünürlük borcu listesi oluşturuldu. Liste MVP karar kalitesi için gereken sonuç/neden/uyarı bilgisini takip eder; formül şeffaflığı hedeflemez.
