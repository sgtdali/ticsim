# Merchant's Road - Mekanik ve Sistem Iliskileri Rehberi

Bu belge, oyundaki canli sistemlerin birbirini nasil etkiledigini ve oyuncu ilerlemesinin mantigini aciklar. Kod yazarken, denge ayari yaparken veya yeni mekanik eklerken ana referans kaynagidir.

## 1. Rutbe ve Ilerleme Sistemi

Oyuncunun ana hedefi rutbe atlayarak **Patrician** seviyesine ulasmak ve oyunu kazanmaktir.

| Rutbe | Sartlar | Acilan Ozellikler |
| :--- | :--- | :--- |
| **Peddler** | Baslangic | Temel al-sat, basic Delivery kontratlar; Caravan Master: 0 |
| **Trader** | 500 gold | **Caravan Upgrades:** Horse Cart ve Small Caravan; Caravan Master: max 1 |
| **Merchant** | 1500 gold + 1 Growing city | **Trading Posts:** Sehirlerde depo ve otomatik ticaret kurallari; Caravan Master: max 2 |
| **Guild Master** | 4000 gold + 2 Trading Posts + 2 Growing + 1 Prosperous city | Kontrat reputation odullerine +%50 bonus; Caravan Master: max 4 |
| **Patrician** | 10000 gold + 3 Prosperous cities | **Win condition:** Victory summary gosterilir; oyuncu devam edebilir; Caravan Master: max 6 |

Not: Faksiyon itibar (reputation) gereksinimleri MVP kapsamında rank ilerlemesinden kaldırılmıştır. Trading Post, Merchant rutbesinde acildigi icin Merchant sartlari Trading Post isteyemez. Trading Post sayisi ilk kez Guild Master sartinda kullanilir.

## 2. Ekonomi, Uretim ve Fiyat Sistemi

Her sehir kendi stok, uretim, tuketim, nufus ve fiyat durumuna sahiptir. Fiyatlar sabit degildir; arz, talep, stok dolulugu ve aktif olaylara gore yeniden hesaplanir.

- **Stok ve fiyat:** Tuketilen mallarda fiyat, fiziksel kapasiteye degil sehrin kac gunluk ihtiyacinin stokta olduguna bakar. Denge noktasi 14 gunluk tuketimdir.
- **Patrician tarzi tuketim egrisi:** Stok 0 gunlukse fiyat `base x3.0`; 7 gunlukse `base x1.8`; 14 gunlukse `base x1.0`; 28 gunlukse `base x0.6`; 42 gunluk ve uzeriyse `base x0.35` olur. Aradaki degerler lineer interpolate edilir.
- **Tuketilmeyen mallar:** Gunluk tuketim 0 ise fiyat eski stok/kapasite mantigina doner. Bu, sehirde uretilen ama tuketilmeyen mallar icin kullanilir.
- **Market fiyati:** UI'da gorunen ana fiyat, sehrin stok/talep durumundan uretilen referans fiyattir.
- **Alim ve satis quote'u:** Oyuncu market fiyati uzerinden dogrudan sinirsiz al-sat yapmaz. Alimda ask spread, satista bid spread uygulanir.
- **Marginal toplu islem:** Birden fazla mal alinir veya satilirken her birim stok degisiminden sonra yeniden fiyatlanir. Bu, "10 birim al, stok 0 oldu, hemen daha pahaliya geri sat" arbitrajini engeller.
- **Alim fiyatlari:** Oyuncunun ilgili faction reputation degeri arttikca satin alma maliyeti azalir; bu indirim spread ile sinirlanir.
- **Satis fiyatlari:** Reputation ve sehir prosperity seviyesi satis gelirini artirir; ayni sehirde anlik al-sat kârina donusmemesi icin satis carpani alis carpani altinda tutulur.
- **Ortalama alis fiyati:** Oyuncunun her mal icin ortalama alis fiyati tutulur; market UI kâr/zarar firsatini gosterir.
- **Stock cap:** Sehirler her mal icin sinirli stok kapasitesine sahiptir. Kapasite doluysa uretim veya satis engellenebilir.

## 3. Uretim Zinciri, Sezonlar ve Nufus

Sehirler gunluk uretim ve tuketim tick'i ile yasar. Dunya oyuncu bir sey yapmasa da degismeye devam eder.

- **Doğal kaynaklar ve slot sistemi:** Wheat, grapes ve iron_ore doğal kaynaklardır. 
 Her şehirde coğrafyaya göre belirlenmiş `farm_slots` ve `mine_slots` kapasitesi vardır. 
 Oyuncu slot satın alarak doğal kaynak üretimini artırabilir. 
 Her slot günde 2 birim üretir. Slot maliyeti `base_cost × 2^mevcut_slot_sayısı` formülüyle artar.
 - Ashford: max 8 farm slot (başlangıç: 3 wheat slotu dolu)
 - Ironmere: max 6 mine slot, max 2 farm slot (başlangıç: 3 iron_ore + 1 wheat dolu)
 - Stonebridge: max 3 farm slot, max 1 mine slot (başlangıç: 2 grapes dolu)

- **İşleme ürünleri:** Flour, bread, iron_bar, tool, wine, must gibi ürünler 
 recipe input gerektiren işleme ürünleridir. Üretim kapasitesi slot'a bağlı değildir; 
 production_plan ile manuel tanımlanır ve upgrade ile artırılabilir.

- **Recipe inputs:** Bazi mallar baska mallari input olarak ister. Input yetersizse üretim verimi düşer.

- **Season multiplier:** Mevsimler bazı malların üretimini değiştirir.

- **Consumption rules:** Nüfus her gün belirli malları tüketir.

- **Nüfus değişimi:** Survival malı kritik tüketim karşılanamazsa nüfus %3 azalır. 
 Aksi halde nüfus prosperity level'a göre büyür (günlük gerçekçi oranlar):
 - Level 1 (Struggling): %0.03 büyüme
 - Level 2 (Growing): %0.06 büyüme
 - Level 3 (Prosperous): %0.10 büyüme

## 4. Olaylar

MVP'de event sistemi pasiftir. `EventManager` autoload olarak durur ama `process_day()` no-op calisir; fiyat, uretim ve tuketim carpani yaratmaz. Dinamizm stok, NPC trader ve mevsimsel uretim etkilerinden gelir.

Asagidaki olaylar tam surum referansi olarak korunur; MVP'de rastgele tetiklenmez ve event UI'i aktif ekonomi sinyali olarak kullanilmaz.

| Olay | Etki Alani | Fiyat | Uretim | Tuketim | Tasarim Amaci |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Festival** | Comfort kategorisi: wine, sword, grapes vb. | x1.6 | x1.0 | x2.0 | Konfor mallarina satis firsati |
| **Famine** | Survival kategorisi: wheat, bread vb. | x3.0 | x0.3 | x1.5 | Gida krizini ve acil kâr firsatini yaratir |
| **Demand Surge** | Sehir tarafindan tuketilen secili bir mal | x2.5 | x1.0 | x3.0 | Tek mala odakli kisa sureli talep patlamasi |
| **Bumper Crop** | Sehir tarafindan uretilen secili bir mal | x0.5 | x2.5 | x1.0 | Ucuz alim ve stok bollugu firsati |
| **Plague** | Tum mallar | x1.2 | x0.4 | x0.4 | Sehrin ekonomik ritmini yavaslatir |

## 5. Prosperity ve Yatirim

Prosperity iki kaynaktan değişir: tüketim memnuniyeti (otomatik) ve oyuncu gold yatırımı (manuel).

**Otomatik tüketim bazlı değişim (her gün, tüketim sonrası):**
Şehrin survival kategorisindeki her mal için günlük tüketim memnuniyeti (`tüketilen_miktar / talep_edilen_miktar`) hesaplanır:
- %80 ve üzeri tüketim memnuniyeti → +2 prosperity
- %40 - %80 arası tüketim memnuniyeti → -1 prosperity
- %40 altı tüketim memnuniyeti → -4 prosperity (nüfus düşüş riski)

Ayrıca, prosperity değeri 70 ve üzeri olan gelişmiş şehirlerde comfort/luxury kategorisindeki mallar yetersizse (tüketim memnuniyeti < %40) -1 prosperity cezası uygulanır. Günlük toplam otomatik prosperity değişimi clamp edilir (min -3.0, max +2.0).

**Manuel gold yatırımı:**
Debt varken yatırım yapılamaz. Yatırım maliyeti basamaklı band modeline tabidir:
- 0-29 prosperity aralığı → 25 gold = 1 prosperity puanı
- 30-64 prosperity aralığı → 50 gold = 1 prosperity puanı
- 65+ prosperity aralığı → 100 gold = 1 prosperity puanı

**Prosperity seviyeleri:**
- Struggling (< 30): Çarpan x1.0
- Growing (30-64): Üretim ve talep çarpanı x1.20. Satış bonusu bu farkın %30'u.
- Prosperous (>= 65): Üretim ve talep çarpanı x1.50. Satış bonusu bu farkın %30'u.

**Maksimum prosperity:** 100.

## 6. Trading Post ve Otomatik Ticaret

Trading Post, Merchant rutbesinde acilir ve oyuncunun sehirde fiziksel olarak bulunmadan stok yonetmesini saglar.

- **Kurulum:** 300 gold.
- **Rutbe gereksinimi:** Merchant.
- **Depo kapasitesi:** 50 birim.
- **Depot:** Oyuncu cargodan depoya mal birakabilir veya depodan cargo alabilir.
- **Buy rule:** Ortalama alım quote'u limit fiyatın altındaysa, depodaki miktar depot_limit'in altındaysa, markette stok varsa ve günlük limit dolmadıysa alır. Alım işlemi market sistemi üzerinden marginal pricing ile gerçekleşir.

- **Sell rule:** Ortalama satış quote'u limit fiyatın üstündeyse, depodaki miktar depot_limit'in üstündeyse, markette yer varsa ve günlük limit dolmadıysa satar.

- **Rule durumları:** Her rule her gün otomatik olarak bir status alır:
  - `active` → koşullar sağlanıyor, işlem yapılabilir
  - `waiting_price` → fiyat koşulu henüz sağlanmadı
  - `waiting_stock` → markette yeterli stok yok (buy)
  - `waiting_market` → markette satış için yer yok (sell)
  - `depot_full` → depot limiti doldu, alım durdu (buy)
  - `depot_empty` → depot limiti altına düştü, satış durdu (sell)

  Sadece `active` durumundaki rule'lar işlem yapar. UI'da her rule'un mevcut durumu gösterilir.
- **Gunluk maksimum:** Her kural kendi daily max degerine sahiptir.

## 7. Kontratlar

Kontratlar gold ve faction reputation kazanmanin ana yollarindan biridir.

- **Turler:** MVP'de yalnizca Delivery.
- **Tier:** MVP'de tek tier: Basic.
- **Urgent unlock:** Full scope icin saklidir; MVP kontrat uretimi urgent kontrat olusturmaz.
- **Deadline:** Kontrat kabul edilince deadline baslar. Sure gecerse kontrat fail olur.
- **Failure penalty:** Basarisiz kontrat ilgili faction reputation degerini dusurur.
- **Oduller:** Gold ve faction reputation.
- **Guild Master bonusu:** Kontrat reputation odulu +%50 artar.

## 8. Faction, Reputation ve NPC Iliskileri

Faction reputation progression kosulu degildir; ticaret kosullarini etkileyen spread bonusu olarak kalir.

- **Neutral (0-29):** Standart iliski seviyesi.
- **Friendly (30-59):** Ticaret spread bonusunu iyilestiren iliski seviyesi.
- **Allied (>= 60):** Ticaret spread bonusunu daha da iyilestiren iliski seviyesi.
- **Trade reputation:** Al-sat yapmak ilgili faction reputation degerini artirir.
- **Rival penalty:** Negatif iliskili rakip faction'lar, ticaretten kazanilan reputation nedeniyle az miktarda dusus alabilir.
- **NPC relation:** MVP'de yoktur. NPC'ler sehir/faction temsilcisi ve flavour roluyle kalir.
- **Travel tax UI:** Faction reputation'a bagli tax rate bilgisi gosterilebilir; ana para akisini etkilemeyen bilgi/altyapi seviyesindedir.

## 9. Seyahat, Risk ve Saldirilar

Haritada sehirler arasi yolculuk gun alir. Oyuncu vardiginda saldiri riski roll edilir.

- **Seyahat suresi:** Sehirler arasi mesafeye gore hesaplanir.
- **Bandit riski:** Base risk + cargo miktari kaynakli risk - hedef faction reputation korumasi.
- **Risk cap:** Saldiri sansi en fazla %50 olur.
- **Saldiri sonucu:** Oyuncu cargo tasiyorsa her mal grubunun yaklasik ucte birini kaybedebilir.
- **Risk UI:** Harita tooltipleri risk seviyesini ve yuzdesini gosterir.

## 10. NPC Tuccarlar ve Yasayan Dunya

NPC tuccarlar oyuncudan bagimsiz hareket eder, al-sat yapar ve sehir ekonomisini etkiler.

- **Aldric:** Aggressive. En iyi fiyat farkini kovalar, riski umursamaz.
- **Mira:** Careful. Risk toleransi dusuktur; tehlikeli rotalardan kacinir.
- **Torben:** Specialist. Production input kategorisine odaklanir.
- **Davranis:** Sehirdeyken once kârli mallari satar, sonra ucuz mallari alir, sonra yeni hedef secer.
- **Harita gorunurlugu:** NPC tuccarlar haritada label ve tooltip ile gorulur.

## 11. Caravan Upgrade

Caravan kapasitesi oyuncunun ticaret hacmini ve dolayli olarak riskini belirler.

| Upgrade | Kapasite | Maliyet | Sart |
| :--- | ---: | ---: | :--- |
| Donkey Cart | 20 | 0 | Baslangic |
| Horse Cart | 35 | 300 | Trader |
| Small Caravan | 50 | 800 | Trader |

## 12. Caravan Master ve Rota Sistemi

Oyuncu caravan master kiralayarak otomatik ticaret rotaları kurabilir. 
Master'lar Trading Post depoları arasında mal taşır.

**İşe alım:**
- Tek seferlik işe alım ücreti + günlük maaş (upkeep'e eklenir).
- İşe alımlar şehirlerdeki **Tavern** ekranından gerçekleştirilir.
- Her şehir tavernası kendi bağımsız aday havuzuna (şehir başına 0-2 aday) sahiptir ve adaylar her 30 günde bir yenilenir.
- Adayların nitelikleri, işe alım maliyeti (hire cost) ve günlük maaşları (daily wage) seçilen template/archetype'a ve oyuncunun mevcut rütbesine göre değişiklik gösterir.
- Sağ paneldeki "Hire Master" butonu artık doğrudan kiralama yapmaz; bunun yerine oyuncuyu şehir tavernalarına yönlendirir.
- Debt (borç) varken yeni işe alım yapılamaz.
- Kiralanan master sayısı rütbeye göre sınırlıdır.

**Master özellikleri (1-5 arası, seviye atladıkça artar):**
- **Hız:** Seyahat süresini kısaltır. Her puan %10 azaltır (max %40).
- **Kapasite:** Taşıyabileceği mal miktarı. Temel 15, her puan +5 birim.
- **Pazarlık:** Alımda indirim, satışta bonus. Her puan %0.5.
- **Cesaret:** Saldırı riskini azaltır. Her puan %3.

**Tecrübe sistemi:**
- Her durak tamamlandığında 25 XP kazanır
- Her seviyede XP eşiği: level × 100
- Max seviye: 5
- Seviye atladığında bir özellik puanı kazanır

**Rota sistemi:**
- Oyuncu durakları belirler (A→B→C→A veya A→B→C→D→B→A gibi)
- Her durak bir Trading Post'a bağlıdır — Post olmayan şehre durak eklenemez
- Her durakta "al" veya "sat" kuralları tanımlanır:
  - Hangi mal, fiyat limiti, max miktar
- Master şehre varınca önce sat kurallarını, sonra al kurallarını işler
- Al: Trading Post deposundan master envanterine
- Sat: Master envanterinden Trading Post deposuna

**Seyahat ve risk:**
- Seyahat süresi şehirler arası mesafeye ve master hızına göre hesaplanır
- Her seyahat günü saldırı riski kontrol edilir
- Cesaret özelliği saldırı şansını düşürür
- Saldırı olursa taşınan malların yaklaşık 1/3'ü kaybolur

**Upkeep:**
- Her master'ın günlük maaşı PlayerData upkeep'ine eklenir
- Debt durumunda master işe alınamaz ancak mevcut master'lar çalışmaya devam eder

## 13. Upkeep ve Debt

Oyuncu her gun caravan, Trading Post ve rutbe yasam standardi icin upkeep oder. Upkeep, gold ekonomisini sadece birikim degil hayatta kalma baskisi haline getirir.

| Kaynak | Gunluk gider |
| :--- | ---: |
| Donkey Cart | 2 gold |
| Horse Cart | 5 gold |
| Small Caravan | 10 gold |
| Her aktif Trading Post | 8 gold |
| Peddler rank | 0 gold |
| Trader rank | 3 gold |
| Merchant rank | 8 gold |
| Guild Master rank | 20 gold |
| Patrician rank | 0 gold |

Gold upkeep'i karsilamazsa eksik miktar **debt** olarak yazilir. Sonraki kontrat odulleri, satis gelirleri ve diger gold kazanclari once debt kapatir; debt bittikten sonra kalan miktar gold'a eklenir.

Debt varken:

- Rank up yapilamaz.
- Caravan upgrade yapilamaz.
- Yeni Trading Post acilamaz.
- Trading Post auto-buy calismaz.
- Gelirler once debt kapatir.

Debt sure cezasi:

- **14 gun debt:** Pozitif faction reputation kazanclari -%25 olur.
- **60 gun debt:** Oyuncu 60 gün boyunca borçta kalırsa oyun sonlandırılır (Game Over). Trading Post'ların askıya alınması veya otomatik ticaretin durdurulması cezaları kaldırılmıştır.

## 14. Gunluk Tick Sirasi

Gun ilerlemesi `EconomyManager.advance_day()` tarafindan merkezi olarak yonetilir. Sistemler sinyal baglanti sirasina guvenmez; gameplay sirasi aciktir.

1. Economy day artar.
2. Player day artar; upkeep/debt islenir.
3. Trading Post auto-trade calisir.
4. Sehir uretimi islenir.
5. Sehir tuketimi islenir.
6. Nufus degisimi islenir.
7. Market fiyatlari yeniden hesaplanir ve gunluk investment limiti resetlenir.
8. NPC trader'lar hareket/ticaret yapar.
8b. Caravan Master'lar hareket eder ve durak işlemlerini yapar.
9. Kontratlar expire/check edilir ve eksik sehir kontratlari yenilenir.
10. Event sistemi MVP'de no-op calisir.
11. Rank check yapilir.
12. WorldMap/UI refresh edilir.

## 15. Core Loop

1. **Al-sat ve kontrat yap** -> gold ve faction reputation kazan.
2. **Pazar firsatlarini oku** -> stok, fiyat, event, nufus trendi ve risk bilgilerini kullan.
3. **Gold yatir** -> sehir prosperity degerini artir.
4. **Rutbe atla** -> caravan upgrade, Trading Post ve urgent contract gibi yeni araclar ac.
5. **Trading Post kur** -> otomatik ticaretle pasif stok/gold akisi yarat.
6. **Yasayan dunyaya mudahale et** -> kriz yasayan sehirleri besle, firsat olan sehirlere mal gotur.
7. **Hedef:** 3 prosperous city ve yeterli gold ile **Patrician** rutbesine ulas.

## 16. Kayit ve Yukleme Sistemi

Oyun tek slotluk JSON kayit dosyasi kullanir (`user://saves/savegame.json`). Tum oyun durumu (gold/debt/envanter, sehir ekonomisi, rutbe, kontratlar, trading post'lar, caravan master'lar, NPC tuccarlar, seyahat/hiz durumu) bu dosyaya yazilir.

- **Otomatik kayit:** Her gun tick'inin sonunda (varissa varis gunu dahil) otomatik kayit yapilir. Oyuncunun ayrica bir sey yapmasina gerek yoktur.
- **Manuel kayit:** Ust bardaki **Save** butonuyla istedigi an elle kayit alabilir.
- **Devam etme:** Ana menudeki **Continue** butonu, kayitli bir oyun varsa gorunur ve son kayitli duruma (seyahat halindeyse seyahatin ortasina dahil) donulmesini saglar.
- **Game Over ve kayit:** Oyuncu 60 gun borc cezasina ugrayip Game Over olursa, kayit dosyasi silinir. Boylece "Continue" hicbir zaman kazanilmasi imkansiz bir borc durumuna geri donmez. Ana menuden "Start" (yeni oyun) ise PlayerData/RankManager/EconomyManager'i sifirlar; eski kayit dosyasi sadece bir sonraki otomatik/manuel kayitla ezilir.
- **Kaydedilmeyenler:** Sehir koordinatlari (harita anchor'larindan her yuklemede yeniden hesaplanir), caravan master aday havuzu (sahiplenilmemis teklifler, dogal olarak yeniden uretilir), ve tum CSV tabanli denge verileri (her zaman dosyadan yeniden yuklenir).
