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
| K21 | Kamu ağı 4 türü içerir (karayolu, ray omurgası, liman, havalimanı) | Sadece karayolu | NPC'ler ilk günden 4 türü kullanabilir |
| K22 | Yoğunluk bazlı tıkanıklık | Yok; tam fiziksel | Darboğaz görünür, sinyal simülasyonu gerekmez |
| K23 | Dinamik sevkiyat | Sabit hat; ikisi birden | NPC basitliği; sabit hat oyuncu katmanına park (Claude seçti) |
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
| K37 | Girdi maliyeti = stok ortalaması + yerine koyma maliyetinin kişiliğe göre karışımı | Sadece biri | Zamların zincirde farklı hızda yayılması |
| K38 | Sabit gider normal kapasiteye (%80) bölünür | Gerçek üretim; fiyata katılmaz | Ölüm sarmalını önler; atıl kapasite stratejik sinyal olur |
| K39 | Marj = konum + deneyerek öğrenme | Sabit kişilik marjı; sadece konum | Şehre özgü fiyatlar sınırlı bilgiyle keşfedilir |
| K40 | Borsa günlük toplu eşleşme | Sürekli eşleşme; haftalık | Deterministik, okunur tek günlük fiyat |
| K41 | Borsada 4 kalite sınıfı, ayrı defter ve fiyat | Kalite düzeltilmiş tek fiyat; kalite eşikli tek fiyat | Okunur fiyatlar ve kalite primi korunur |
| K42 | Satış emri = günün fiyatı × stok sapması, maliyet tabanı | Maliyet + öğrenilmiş marj; karışım | Borsada herkes ortak fiyatı görür |
| K43 | Alış emri = min(türetilmiş değer, günün fiyatı × aciliyet) | Sadece piyasa; sadece türetilmiş değer | Zararına üretimi sınırlar, kıtlıkta üretimi sürdürür |
| K44 | Maaş haftalık boş kadro / işsizlik oranına göre değişir; artış hızlı, düşüş yavaş | İşgücü borsası; doğrudan denge formülü | Okunur, yapışkan, ucuz |
| K45 | Şirketler şehir maaşı üstüne %0–20 prim verebilir | Orantılı dağılım; prim + işe gidiş süresi | İşgücü için rekabet, kritik tesis işçi bulabilir |
| K46 | Maaş tabanı yaşam maliyeti sepetine bağlı | Sabit asgari ücret; taban yok | Fiyatlarla tutarlı; çöküşü önler |
