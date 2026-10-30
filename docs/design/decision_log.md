# Karar Günlüğü

| # | Karar | Alternatifler | Gerekçe |
|---|-------|---------------|---------|
| K1 | Geliştirme sırası: önce dünya simülasyonu (oyuncusuz) | Dikey dilim; önce oyuncu döngüsü + soyut talep | Mikro sim ana ağırlık; dünya oyuncudan bağımsız çalışmalı |
| K2 | Simülasyon Godot + C#, headless | GDScript; Python prototip; GDExtension | Hızlı ve kod doğrudan oyuna taşınır |
| K3 | Ürünlerde kalite + marka | Homojen mal; sadece kalite | Mikro tüketici ve rakipler arasında rekabet yüzeyi |
| K4 | Kalite = girdi kalitesi + Ar-Ge | Tesis seviyesi, işgücü de etkilesin | Kalite ve verimlilik ayrı karar alanları kalır |
| K5 | Hammadde kalitesi = karo zenginliği + çıkarım teknolojisi | Sadece karo; sadece teknoloji | Haritaya değer katar, yer kapma rekabeti |
| K6 | Kaynaklar tükenmez | Madenler tükenir; hepsi tükenir/bozulur | Basitlik; rekabet yer seçiminde kalır |
| K7 | Bozulma + depolama/kargo sınıfı | Bozulma yok; sadece bozulma | Lojistiği araç/depo tipi seçimine dönüştürür |
| K8 | Temel birim hane | Birey; birey + hane | Dayanıklı mallar hane malı; ~3x daha az varlık |
| K9 | Harcama ihtiyaç barlarıyla | Öncelik sırası; bütçe payı | Song of Syx hissi, zengin mikro davranış |
| K10 | Haneler yakıtı ısınma + ulaşım için tüketir | Sadece araçlar; tek ihtiyaç | Yakıtı ekonominin omurgası yapar; mevsim sistemi doğar |
| K11 | Maaş şehir × meslek grubu piyasasında oluşur | Tek şehir maaşı; şirket belirler | Kullanıcı kararı; işgücü coğrafyası |
| K12 | Meslek talebe göre gecikmeli geçişle değişir | Sabit dağılım; eğitim tesisleri | Ek sistem olmadan dinamik işgücü (Claude seçti) |
| K13 | Doğal büyüme + şehirler arası göç | Sadece büyüme; + yeni yerleşimler | Tesislerin işgücü çekmesi; yeni yerleşim fazla kapsam (Claude seçti) |
| K14 | Perakende mağaza tesisleri üzerinden | Şehir pazarı; NPC perakendeciler | Kullanıcı kararı; mesafe ve kapsama rekabeti |
| K15 | Mağazada sadece kendi ürünü satılır | Başkasının malı da satılabilir | Kullanıcı kararı; dikey entegrasyon ana strateji |
| K16 | B2B ticaret spot borsada | Doğrudan sözleşme; ikisi birden | Tek mekanizma, okunur fiyat sinyali |
| K17 | Her şehirde fiziksel borsa | Ulusal sanal borsa; bölgesel borsalar | Coğrafi fiyat farkı/arbitraj, sabit lojistik düğümleri (Claude seçti) |
| K18 | Şirket döngüsü: iflas + yeni girişim | Sabit sayı; + satın alma/birleşme | Tükenmeyen kaynaklarda uzun vadeli canlılık (Claude seçti) |
| K19 | AI aynı kurallar, sınırlı bilgi | Tam bilgi; hileli AI | Tutarlılık; AI hataları fırsat yaratır (Claude seçti) |
| K20 | Kamu ağı + özel bağlantılar | NPC her şeyi kurar; kamu ağı büyür | NPC yol AI'ını basitleştirir |
| K21 | Kamu ağı 4 türü içerir (karayolu, ray omurgası, liman, havalimanı) **[→ K84]** | Sadece karayolu | NPC'ler ilk günden 4 türü kullanabilir |
| K22 | Yoğunluk bazlı tıkanıklık | Yok; tam fiziksel | Darboğaz görünür, sinyal simülasyonu gerekmez |
| K23 | Dinamik sevkiyat **[K83 ile oyuncu kontrolü eklendi]** | Sabit hat; ikisi birden | NPC basitliği; sabit hat oyuncu katmanına park (Claude seçti) |
| K24 | 1 karo = 250 m, ~2500² harita | 100 m/3000²; 500 m/2000²; ayarlanabilir | Küçük-orta ülke, makul detay |
| K25 | Şehir otomatik büyür | İnşaat sektörü; sabit kapasite | Basit ve canlı |
| K26 | Boş ekonomiyle başlar + ithalat güvenlik ağı | Hazır ekonomi; ayarlanabilir | Kullanıcı kararı; ekonominin kendi kendine kalkması testi |
| K27 | Deterministik simülasyon | Deterministik değil | Hata tekrarı ve seed karşılaştırmalı denge |
| K28 | Her yer tam detay | Mesafe/önem LOD | Tutarlılık; hedef ölçek izin veriyor |
| K29 | Debug viewer + headless toplu koşu | Sadece biri | Hem canlı his hem hızlı denge iterasyonu |
| K30 | Ar-Ge kilitleri: ürün, araç, verimlilik, tesis tipi | Daha dar kapsam | Uzun vadeli dinamizm motoru |
| K31 | Patent süresi sonra yayılım | Tamamen özel; lisans satışı | Liderlik geçici, lider değişimi doğal |
| K32 | Yayın hedefi Steam | itch.io | Kullanıcı kararı |
| K33 | Hane rezervasyon fiyatı kullanır; pahalıysa almaz | Her zaman en iyi skoru alır; rezervasyon + ayrı ikame sistemi | Gerçek talep esnekliği; ikame bar→çoklu mal eşleşmesiyle kendiliğinden (Claude seçti) |
| K34 | Referans fiyat hanenin kendi geçmiş alımlarından | Şehir ortalaması; sabit değer | Zamlar önce talebi düşürür, zamanla kabullenilir |
| K35 | Tüketim mallarında ev stoku | Sadece ihtiyaç kadar; + panik alımı | Fiyat şoklarına ve mevsime kendiliğinden tepki |
| K36 | Mesafe = yakıt + zaman maliyeti | Sabit yarıçap; mesafe cezası | Kullanıcı kararı; alışveriş bölgeleri ve trafik bağlantısı |
| K37 | Girdi maliyeti = stok ortalaması + yerine koyma maliyetinin kişiliğe göre karışımı **[→ K82]** | Sadece biri | Zamların zincirde farklı hızda yayılması |
| K38 | Sabit gider normal kapasiteye (%80) bölünür | Gerçek üretim; fiyata katılmaz | Ölüm sarmalını önler; atıl kapasite stratejik sinyal olur |
| K39 | Marj = konum + deneyerek öğrenme | Sabit kişilik marjı; sadece konum | Şehre özgü fiyatlar sınırlı bilgiyle keşfedilir |
| K40 | Borsa günlük toplu eşleşme | Sürekli eşleşme; haftalık | Deterministik, okunur tek günlük fiyat |
| K41 | Borsada 4 kalite sınıfı, ayrı defter ve fiyat | Kalite düzeltilmiş tek fiyat; kalite eşikli tek fiyat | Okunur fiyatlar ve kalite primi korunur |
| K42 | Satış emri = günün fiyatı × stok sapması, maliyet tabanı | Maliyet + öğrenilmiş marj; karışım | Borsada herkes ortak fiyatı görür |
| K43 | Alış emri = min(türetilmiş değer, günün fiyatı × aciliyet) | Sadece piyasa; sadece türetilmiş değer | Zararına üretimi sınırlar, kıtlıkta üretimi sürdürür |
| K44 | Maaş haftalık boş kadro / işsizlik oranına göre değişir; artış hızlı, düşüş yavaş | İşgücü borsası; doğrudan denge formülü | Okunur, yapışkan, ucuz |
| K45 | Şirketler şehir maaşı üstüne %0–20 prim verebilir | Orantılı dağılım; prim + işe gidiş süresi | İşgücü için rekabet, kritik tesis işçi bulabilir |
| K46 | Maaş tabanı yaşam maliyeti sepetine bağlı | Sabit asgari ücret; taban yok | Fiyatlarla tutarlı; çöküşü önler |
| K47 | Memnuniyet 8 kategori; faktör = karşılanan − beklenen **[→ K79]** | Bar ortalaması (K9) | Nedenleri açıklar, şirket etkilerini taşır |
| K48 | 4 kademe Maslow birleşimi; olumsuzlar tam yansır **[→ K79]** | Ağırlıklı toplam; en zayıf halka | Temel ihtiyaç önceliği, telafi edilemezlik |
| K49 | Beklenti = asimetrik alışkanlık + komşu kıyası **[→ K79]** | Gelire göre; sadece alışkanlık | Geçici mutluluk, kayıp acısı, eşitsizlik hissi |
| K50 | Kamu hizmetleri vergiyle finanse; dengeli şehir bütçesi **[→ K80]** | Şehir büyüklüğüne bağlı sabit; + belediye kararları | Şirket kârı şehre döner; dren kalemleri ekonomiye geri akar |
| K51 | Kirlilik ve gürültü memnuniyet + sağlığı etkiler **[K80: sağlık bağı kaldırıldı]** | Sadece memnuniyet; + tarım/arazi değeri | Şirketin şehre zararı sistemik maliyet olur |
| K52 | Prensip: dünya sistemi şirkete karar/fırsat/kriz doğurduğu kadar derinleştirilir | — | Oyun şehir simülasyonuna kaymasın |
| K53 | Oyuncu başta elle yönetir, büyüdükçe yönetici atar | Her şey elle; politika + müdahale; sadece yönetici | Kullanıcı kararı; mikrodan makroya geçiş |
| K54 | Kademe + yönetim puanı + yönetici (Song of Syx modeli); Ofis personeli 5. meslek | Kademe + slot; sadece yönetim puanı | Geçiş kendiliğinden zorunlu; ölçek verimsizliği tekele fren |
| K55 | Capitalism'den: yetki ayarları, seçerek devretme, sektör uzmanlığı, tesis deneyimi (1–5) | Sadece Song of Syx modeli | Erken oyunda kısmi devretme, doğru yönetici seçimi, mikro büyüme hissi, işçi kapma stratejisi |
| K56 | Finansman araçları: kredi, hisse/halka arz, hisse alımı/devralma | + tahvil ve kredi notu | Yeterli derinlik, daha az sistem |
| K57 | Kredi NPC bankalardan; mevduat = hane birikimi **[→ K81]** | Dışsal merkez bankası; yatırım havuzu = banka | Kullanıcı kararı; kredi sıkışması ve banka iflası krizleri |
| K58 | Kural tabanlı merkez bankası; tam aracılık, para yaratılmaz | Yok; + son çare kredisi | Enflasyon sarmalına fren, para arzı izlenebilir |
| K59 | Ulusal hisse borsası, günlük toplu eşleşme | Temel değer formülü; + spekülasyon | Dalgalanma ve devralma fırsatları, baloncuksuz |
| K60 | %50+ hisse = bağlı şirket; oyuncu kontrolü kaybederse oyun biter | Doğrudan birleşme; oyun bitmez | Yönetim puanı patlamaz; halka açılma risk kararı olur |
| K61 | Capitalism tarzı tesis: kabuk (4/6/9 slot) + birimler; deneyim birim bazında; otomatik şablon | Sabit tip + boyut; modüler hatlar | Kullanıcı kararı; tesis içi karar yüzeyi |
| K62 | Komşu birimler arası açık bağlantılar (≤3 giriş/çıkış) | Otomatik akış; otomatik + öncelik | Yerleşim bulmacası; şablon mikro yükü azaltır |
| K63 | İşgücü darboğazı: hız = en kıt meslek doluluk oranı | Ağırlıklı ortalama; darboğaz + ikame | Nadir meslek değerini net gösterir |
| K64 | Bakım bütçesi + yıpranma; düşük durumda hız düşer, arıza riski artar | Sabit bakım; + planlı duruş | Kısa vade kâr ↔ uzun vade risk kararı |
| K65 | İnşaat = para + süre + çelik/kereste | Para + süre; inşaat sektörü | Yatırım dalgaları ara mal talebi yaratır |
| K66 | Aşama 1'de araçlar sabit katalogdan (ithalat); üretim zinciri sonra | Sadece katalog; şimdiden yerli üretim | Kapsam kontrolü, ileride genişletilebilir |
| K67 | Taşıma pazarı: günlük ihale, öğrenilen marj, itibar, geç teslim cezası | Herkes kendi filosu; kamu taşıyıcısı | Lojistik ayrı iş modeli; küçük üreticiye giriş |
| K68 | Kamu ücreti = sabit tarife + %70 doluluk üstünde yoğunluk ek ücreti | Sabit tarife; kamu bütçesine göre | Trafik kendiliğinden dağılır; özel altyapı anlam kazanır |
| K69 | Tıkanıklık BPR fonksiyonu; terminal yanaşma kuyrukları | — | Standart, okunur, kapasiteye yaklaşınca sert artış |
| K70 | Stratejik adaylar risk düzeltilmiş getiri/yatırım (geri ödeme) ile kıyaslanır; kişilik ufku | Basit utility skoru; + stratejik hedef | Tüm eylem tipleri tek birimde (para) |
| K71 | Rakip şantiyeleri haritada görünür, kapasite kaba tahmin | Görünmez; tam görünür | Ilımlı yatırım döngüleri; oyuncu rakip hamlesine tepki verebilir |
| K72 | Arazi kamudan satın alınır veya kiralanır | Sadece satın alma; sadece kira | Nakit ↔ sabit gider finans kararı |
| K73 | Arazi değeri = merkez yakınlığı, altyapı erişimi, kirlilik, kaynak zenginliği, talep; kira faize bağlı | Daha az faktör | Yer seçimi anlamlı; kirlilik şirkete geri döner |
| K74 | Şehir büyümesi boş/atıl şirket arazisine primli teklif verir | Büyüme durur; kamulaştırma | Spekülasyon stratejisi; şirket arazisi korunur |
| K75 | Ar-Ge proje bazlı: laboratuvar birimleri, süre ve ekip eğrileri (Capitalism) | Sürekli akış + öncelik; sürekli seviye + proje kilitleri | Kullanıcı kararı; Ar-Ge taahhüt kararı olur |
| K76 | Seviye kazancı %70–130 sapmalı; kilit süresi ±%20 | Kesin; başarısızlık riski | Patent yarışında belirsizlik, cezasız |
| K77 | Göç bilgisi mesafeyle azalır; büyük şehirler her yerden görünür | Tam bilgi; sosyal ağ | Uzak bölgeye işçi çekmek stratejik maliyet |
| K78 | Dış göç ulusal işgücü açığına bağlı | Yok; sabit akış | Yavaş güvenlik vanası; kronik kıtlığı önler |
| K79 | Memnuniyet 4 şirket-etkili faktör (tüketim, iş ve gelir, kirlilik/gürültü, mağaza erişimi); temel ihtiyaç kuralı; beklenti sadece alışkanlık | K47–K49 tam model | K52 sözgeci: şirketin etkileyemediği faktörler çıktı |
| K80 | Kamu hizmetleri kaldırıldı; bütçe = işsizlik desteği + arazi teklifleri + kamu istihdamı; kirlilik–sağlık bağı yok | K50/K51 tam model; tek hizmet seviyesi | K52 sözgeci: oyuncu kararı yok; para döngüsü korunur |
| K81 | Tek toplu bankacılık sistemi (mevduat havuzu, sabit marj, risk primi, kredi sıkışması, rezerv) | K57 NPC bankalar | K52 sözgeci: aynı krizler, ayrı şirket türü yok |
| K82 | Girdi maliyeti = yerine koyma maliyeti | K37 kişilik karışımı | K52 sözgeci: oyuncuya görünmez iç detay |
| K83 | Oyuncu sevkiyat kontrolü çekirdekte: sabit hat, öncelik, filo kuralları, mod tercihi; NPC dinamik | Sadece dinamik (K23); sabit hat Aşama 2 | Lojistikte oyuncu karar yüzeyi |
| K84 | Aşama 1 taşıma modları: karayolu + demiryolu | Dört mod (K21) | Kapsam kontrolü |
