# Merchant's Road - Mekanik ve Sistem Iliskileri Rehberi

Bu belge, oyundaki canli sistemlerin birbirini nasil etkiledigini ve oyuncu ilerlemesinin mantigini aciklar. Kod yazarken, denge ayari yaparken veya yeni mekanik eklerken ana referans kaynagidir.

## 1. Rutbe ve Ilerleme Sistemi

Oyuncunun ana hedefi rutbe atlayarak **Patrician** seviyesine ulasmak ve oyunu kazanmaktir.

| Rutbe | Sartlar | Acilan Ozellikler |
| :--- | :--- | :--- |
| **Peddler** | Baslangic | Temel al-sat, basic/standard kontratlar |
| **Trader** | 500 gold + 1 Friendly faction | **Caravan Upgrades:** Horse Cart ve Small Caravan |
| **Merchant** | 1500 gold + 2 Friendly factions | **Trading Posts:** Sehirlerde depo ve otomatik ticaret kurallari |
| **Guild Master** | 4000 gold + 3 Friendly factions + 2 Trading Posts + 1 Growing city | **Urgent Contracts:** Yuksek odullu kontratlar; kontrat reputation odullerine +%50 bonus |
| **Patrician** | 10000 gold + 3 Allied factions + 3 Prosperous cities | **Win condition:** Oyun biter |

Not: Trading Post, Merchant rutbesinde acildigi icin Merchant sartlari Trading Post isteyemez. Trading Post sayisi ilk kez Guild Master sartinda kullanilir.

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

- **Production plan:** Her sehir belirli mallari uretir.
- **Recipe inputs:** Bazi mallar baska mallari input olarak ister. Input yetersizse uretim verimi duser.
- **Season multiplier:** Mevsimler bazi mallarin uretimini degistirir. Ornek: wheat yaz/kis farkli uretir, grapes yazin daha guclu, wood kisin daha iyi olabilir.
- **Consumption rules:** Nufus her gun belirli mallari tuketir.
- **Nufus degisimi:** Survival kategorisindeki kritik tuketim karsilanamazsa nufus azalir. Yeterli temel gida varsa nufus artabilir.
- **Population trend:** Haritada sehirlerin nufus trendi yukari/asagi/stabil olarak gosterilir.

## 4. Olaylar

Olaylar sehirlerin arz-talep dengesini gecici olarak bozar ve kâr firsatlari yaratir. Olaylar rastgele tetiklenir, sureleri vardir ve sehir bazlidir.

| Olay | Etki Alani | Fiyat | Uretim | Tuketim | Tasarim Amaci |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Festival** | Comfort kategorisi: wine, sword, grapes vb. | x1.6 | x1.0 | x2.0 | Konfor mallarina satis firsati |
| **Famine** | Survival kategorisi: wheat, bread vb. | x3.0 | x0.3 | x1.5 | Gida krizini ve acil kâr firsatini yaratir |
| **Demand Surge** | Sehir tarafindan tuketilen secili bir mal | x2.5 | x1.0 | x3.0 | Tek mala odakli kisa sureli talep patlamasi |
| **Bumper Crop** | Sehir tarafindan uretilen secili bir mal | x0.5 | x2.5 | x1.0 | Ucuz alim ve stok bollugu firsati |
| **Plague** | Tum mallar | x1.2 | x0.4 | x0.4 | Sehrin ekonomik ritmini yavaslatir |

## 5. Prosperity ve Yatirim

Oyuncu sehirlere gold yatirarak prosperity artirir. Prosperity hem progression hem de ekonomi icin ana yatirim eksenidir.

- **Yatirim orani:** 25 gold = 1 prosperity puani.
- **Gunluk limit:** Sehir basina gunde en fazla 50 prosperity puani kazanilabilir.
- **Maksimum prosperity:** 100.
- **Struggling (< 30):** Carpani x1.0.
- **Growing (30-64):** Uretim ve talep carpani x1.20. Satis bonusu, bu farkin %30'u kadar uygulanir.
- **Prosperous (>= 65):** Uretim ve talep carpani x1.50. Satis bonusu, bu farkin %30'u kadar uygulanir.

## 6. Trading Post ve Otomatik Ticaret

Trading Post, Merchant rutbesinde acilir ve oyuncunun sehirde fiziksel olarak bulunmadan stok yonetmesini saglar.

- **Kurulum:** 300 gold.
- **Rutbe gereksinimi:** Merchant.
- **Depo kapasitesi:** 50 birim.
- **Depot:** Oyuncu cargodan depoya mal birakabilir veya depodan cargo alabilir.
- **Buy rule:** Ortalama alim quote'u limitin altindaysa, depodaki miktar hedefin altindaysa ve gunluk limit dolmadiysa alir.
- **Sell rule:** Ortalama satis quote'u limitin ustundeyse, depodaki miktar hedefin ustundeyse ve markette yer varsa satar.
- **Gunluk maksimum:** Her kural kendi daily max degerine sahiptir.

## 7. Kontratlar

Kontratlar gold, faction reputation ve NPC relation kazanmanin ana yoludur.

- **Turler:** Delivery ve procurement.
- **Tier:** Basic, standard, urgent.
- **Urgent unlock:** Guild Master rutbesi.
- **Deadline:** Kontrat kabul edilince deadline baslar. Sure gecerse kontrat fail olur.
- **Failure penalty:** Basarisiz kontrat ilgili faction reputation degerini dusurur.
- **Oduller:** Gold, faction reputation ve issuer NPC relation.
- **Guild Master bonusu:** Kontrat reputation odulu +%50 artar.

## 8. Faction, Reputation ve NPC Iliskileri

Faction reputation hem progression hem de ticaret kosullarini etkiler.

- **Neutral (0-29):** Standart iliski seviyesi.
- **Friendly (30-59):** Trader, Merchant ve Guild Master progression sartlarinda kullanilir.
- **Allied (>= 60):** Patrician progression sartinda kullanilir.
- **Trade reputation:** Al-sat yapmak ilgili faction reputation degerini artirir.
- **Rival penalty:** Negatif iliskili rakip faction'lar, ticaretten kazanilan reputation nedeniyle az miktarda dusus alabilir.
- **NPC relation:** Kontrat veren NPC ile iliski kontrat tamamlandikca artar.
- **Travel tax UI:** Faction reputation'a bagli tax rate bilgisi gosterilir; su an ana para akisini etkilemeyen bilgi/altyapi seviyesindedir.

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

## 12. Upkeep ve Debt

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
- **30 gun debt:** Mevcut Trading Postlar otomatik ticareti tamamen durdurur.
- **60 gun debt:** Depo degeri en yuksek aktif Trading Post suspended olur. Suspended post aktif post sayilmaz ve tekrar acilmasi gerekir.

## 13. Gunluk Tick Sirasi

Gun ilerlemesi `EconomyManager.advance_day()` tarafindan merkezi olarak yonetilir. Sistemler sinyal baglanti sirasina guvenmez; gameplay sirasi aciktir.

1. Economy day artar.
2. Player day artar; upkeep/debt islenir.
3. Trading Post auto-trade calisir.
4. Sehir uretimi islenir.
5. Sehir tuketimi islenir.
6. Nufus degisimi islenir.
7. Market fiyatlari yeniden hesaplanir ve gunluk investment limiti resetlenir.
8. NPC trader'lar hareket/ticaret yapar.
9. Kontratlar expire/check edilir ve eksik sehir kontratlari yenilenir.
10. Event'ler expire/spawn edilir.
11. Rank check yapilir.
12. WorldMap/UI refresh edilir.

## 14. Core Loop

1. **Al-sat ve kontrat yap** -> gold, faction reputation ve NPC relation kazan.
2. **Pazar firsatlarini oku** -> stok, fiyat, event, nufus trendi ve risk bilgilerini kullan.
3. **Gold yatir** -> sehir prosperity degerini artir.
4. **Rutbe atla** -> caravan upgrade, Trading Post ve urgent contract gibi yeni araclar ac.
5. **Trading Post kur** -> otomatik ticaretle pasif stok/gold akisi yarat.
6. **Yasayan dunyaya mudahale et** -> kriz yasayan sehirleri besle, firsat olan sehirlere mal gotur.
7. **Hedef:** 3 allied faction ve 3 prosperous city ile **Patrician** rutbesine ulas.
