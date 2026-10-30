# Lojistik ve Yol Bulma

## Karar verilmiş

### Altyapı (K20, K21)
- Harita kamu ağıyla doğar: şehirlerarası karayolu ve büyük şehirler arası ray omurgası.
- **Aşama 1 (K84):** sadece karayolu ve demiryolu. Denizyolu ve havayolu (liman, havalimanı, gemi, uçak) sonraki aşamaya park edildi.
- Şirketler (NPC ve oyuncu) bağlantı yolu, istasyon, terminal ve özel hat kurar.
- Kamu altyapısı ücretli (otoyol, ray kullanımı, kamu istasyonu ücreti); özel altyapı pahalı kurulur, kullanımı ücretsiz → kirala ya da inşa et kararı.

### Tıkanıklık (K22)
Her yol/hat kesiminin ve terminalin kapasitesi var; doluluk arttıkça hız düşer, terminallerde kuyruk oluşur. Sinyal/kavşak simülasyonu yok.

### Yol bulma
Grid inşa ve görselleştirme içindir. Altyapıdan ağ grafiği türetilir (kavşak/terminal = düğüm, kesim = kenar). A* grafikte çalışır, rotalar önbelleğe alınır, tıkanıklık kenar maliyetini periyodik günceller.

### Sevkiyat (K23)
- **Taşıma işi:** mal, adet, A → B, son tarih.
- **Planlayıcı:** İşi en uygun mod kombinasyonuna böler (örn. kamyon → tren → kamyon); her bacak alt iş olur. Aktarma terminallerinde depolama ve bozulma işler.
- **Araç:** Depoya/terminale bağlı; tip, kargo sınıfı, kapasite, hız, yakıt tüketimi, ömür/bakım; Sürücü gerektirir. Boştaki en yakın uygun araç bacağı alır.
- **Maliyet:** yakıt + sürücü maaşı + kamu ücretleri + bakım.

### Sevkiyat kontrolü (K83)
Dinamik sevkiyat varsayılan kalır; NPC'ler sadece onu kullanır. Oyuncu (ve devredilen yöneticiler, K55) ek olarak:
- **Sabit hat:** araçları bir hatta atar — duraklar, her durakta yükle/boşalt kuralı (tam yük bekle / ne varsa al / boşalt), sefer sıklığı. Hattaki araçlar dinamik havuza dönmez; düzenli, yüksek hacimli akışlarda boş dönüş ve bekleme kontrol altında.
- **Öncelik:** taşıma işlerine kritik / normal / düşük önceliği; kritik işler araç atamasında ve terminal kuyruğunda önce gelir. Stoğu kritik seviyeye düşen girdiler için kritik önerilir.
- **Filo kuralları:** depo/filo bazında hangi işleri alacağı (mal, kargo sınıfı, mesafe aralığı) ve dinamik havuza ne kadar araç bırakılacağı.
- **Mod tercihi:** iş bazında planlayıcıya mod zorlama (örn. "sadece demiryolu").

### Araç kaynağı (K66)
- Aşama 1'de araçlar sabit fiyatlı bir **katalogdan** alınır (ithalat; para ekonomiden çıkar). Ar-Ge (K30) kataloğa yeni modeller ekler.
- Her mod için katalogda birkaç model: tip, kargo sınıfları, kapasite, hız, dolu/boş yakıt tüketimi, ağırlık sınıfı, ömür, fiyat.
- Araç üretim zinciri (çelik + motor → kamyon vb.) ileride eklenince yerli üreticiler ithalatın yerine geçer; ithalat tavan fiyat olarak kalır (K26).

### Taşıma pazarı (K67)
- Şirket bir taşıma işini kendi filosuna vermek yerine **taşıma pazarına** koyabilir.
- Lojistik şirketleri (NPC veya oyuncu) teklif verir; pazar günlük toplu ihaleyle çalışır (K40 mantığı). Kazanan, `fiyat + itibar cezası` en düşük olan teklif.
- Teklif fiyatı = tahmini bacak maliyeti × (1 + öğrenilen marj; K39 mantığı).
- **İtibar:** zamanında teslim oranından; geç teslimde sözleşmedeki ceza ödenir ve itibar düşer.
- Filosu olmayan şirket de üretebilir; lojistik tek başına bir iş modeli olur.

### Kamu ücretleri (K68)
- Yol/ray kenarı: `mesafe × araç ağırlık sınıfı × mod tarifesi × (1 + κ × max(0, doluluk − 0,7))`.
- Terminal: `sabit yanaşma ücreti + yükleme/boşaltma birim ücreti`, doluyken aynı ek ücret çarpanıyla.
- Planlayıcı rota seçiminde süreyle birlikte ücreti tartar; tıkanık güzergahlar pahalanınca trafik dağılır.
- Gelir bulunduğu şehrin bütçesine gider (K50).

### Tıkanıklık ve terminaller (K69)
- **BPR fonksiyonu:** `Geçiş süresi = serbest süre × (1 + 0,15 × (hacim / kapasite)⁴)`.
- Hacim = araçlar + alışveriş ve işe gidiş yolculuklarının toplu yükü (K36).
- Kenar kapasitesi yol tipine göre (şehir yolu < karayolu < otoyol); ray için hat başına tren sayısı.
- Terminallerin yanaşma yeri sayısı (yükleme rampası, peron) ve yükleme hızı var; doluysa araç kuyrukta bekler.
- Aktarmada mal terminal deposunda bekler; depolama ücreti ve bozulma işler (K7).
- Özel terminal sahibi kendi kuyruğunu kontrol eder.

### Bacak maliyeti
`Yakıt (dolu/boş tüketim × mesafe) + sürücü maaşı × süre + kamu ücretleri + bakım/yıpranma + amortisman`

## Açık Sorular

- Katalog modelleri ve değerleri, tarifeler, κ, yanaşma yeri sayıları, yol kapasiteleri.

## Gerilimler

- Sabit hatlar ve dinamik havuz aynı terminalleri paylaşır; kuyrukta öncelik ve hat çakışma kuralları netleştirilmeli.

## Tartışma Notları

- [2026-10-29] Lojistik modeli kuruldu (K20–K23). K23 kullanıcının isteğiyle Claude tarafından seçildi.
- [2026-10-29] Lojistik maliyeti modeli kuruldu (K66–K69): katalog araçlar, taşıma pazarı, yoğunluk ek ücretli kamu tarifesi, BPR tıkanıklık ve terminal kuyrukları.
- [2026-10-30] K52 sözgeci: sabit hat, öncelik, filo kuralları ve mod tercihi oyuncu kontrolü olarak çekirdeğe alındı (K83); Aşama 1 karayolu + demiryoluna indirildi (K84).
