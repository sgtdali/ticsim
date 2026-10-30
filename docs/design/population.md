# Nüfus

## Karar verilmiş

### Birim (K8)
Temel birim hane (2–5 kişi). Hane verisi: konut karosu, kişi sayısı, çalışanlar (meslek + işyeri), gelir, birikim, sahip olunan dayanıklı mallar (kalite, marka, kalan ömür), memnuniyet.

### İhtiyaç barları (K9, K10)
- Her ihtiyaç 0–100 bar; zamanla düşer.
- Tüketilen mal barı bir kerede doldurur; dayanıklı mal ömrü boyunca barı destekler (kalite = destek gücü), ömür bitince yenisi aranır.
- Hane her gün en düşük bara bakar, bütçesi yetiyorsa uygun malı alır (marka/kalite seçimi `goods.md`).
- Memnuniyet hesabı K79 ile tanımlandı (aşağıda); barlar Tüketim faktörünün girdisidir.
- **Aşama 1 ihtiyaçları:** Beslenme (ekmek), Konfor (mobilya), Ev yaşamı (ev aleti), Isınma (yakıt, mevsimsel), Ulaşım (yakıt).
- Isınma kışın hızlı düşer → **mevsim sistemi** var.
- Aşama 1'de araba zinciri yok; ulaşım doğrudan yakıtla dolar.

### Göç ve nüfus — formül düzeyi (K77, K78)

K13'ün içini doldurur. Şirkete etkisi (K52): göç işgücü krizlerini çözen ana mekanizma.

**Çekim puanı (aylık, hane bazında)**
`Çekim(şehir) = w₁ × Beklenen gelir oranı + w₂ × Memnuniyet farkı − Taşınma maliyeti − Aidiyet`
- Beklenen gelir oranı = `(hedef meslek maaşı × iş bulma olasılığı) / hedef yaşam maliyeti`, mevcut şehirle oranlanır. İş bulma olasılığı = boş kadro / (işsiz + boş kadro).
- Memnuniyet farkı = hedef şehir ortalaması − hanenin mevcut memnuniyeti.
- Taşınma maliyeti mesafe ve hane büyüklüğüyle artar; birikimden ödenir, yetmeyen taşınamaz.
- Aidiyet şehirde geçen süreyle artar (üst sınırlı); memnuniyete değil, sadece göç kararına girer.
- Eşik aşılınca taşınma ihtimali; ayda bir şehirden en fazla nüfusun %2'si göç eder. Hedefte boş konut yoksa taşınamaz.

**Bilgi (K77):** Hane bilgi yarıçapındaki şehirleri ve büyük şehirleri değerlendirir; uzak şehir verisi birkaç ay gecikmeli. Göç dalgaları komşu şehirlerden başlar; uzak bölgeye işçi çekmek prim (K45) gerektirir.

**Dış göç (K78)**
- Giriş: ulusal boş kadro oranı ve maaş/yaşam maliyeti eşiği geçerse sınır şehirlerine aylık hane gelir (en fazla ulusal nüfusun ~%0,2'si); meslek dağılımı açığı izler.
- Çıkış: ulusal işsizlik yüksek ve memnuniyet düşükse haneler ülkeyi terk eder.
- Gelen hane küçük birikim getirir, giden götürür → ithalattan sonra ikinci dış para akışı; para arzı metriğinde ayrı izlenir.

**Doğal büyüme**
- Hane bölünmesi: `p = taban × memnuniyet çarpanı` (yeterli birikim + boş konut şartıyla). Yeni çalışanın mesleği şehrin meslek açığına göre atanır.
- Dağılma: memnuniyet ~6 ay kritik eşik altında kalan hane önce göç dener; edemezse dağılır, birikimi şehirdeki hanelere dağıtılır.

### Maaş oluşumu (K44–K46)

- **Haftalık değişim (K44):** `Δmaaş = λ × (Boş kadro − İşsiz) / Meslekteki toplam işgücü`, şehir × meslek bazında. Artış haftada en fazla %+3, düşüş en fazla %−1 (yapışkanlık).
- **Maaş primi (K45):** Şirket her tesiste meslek başına şehir maaşının üstüne %0–20 prim verebilir. İşsizler önce en yüksek primli boş kadroya yerleşir. Çalışanlar, mevcut primden en az 5 puan yüksek teklif varsa geçebilir; her ay çalışanların en fazla %5'i geçer, geçen çalışan en az 30 gün kalır. Prim AI taktik kararıdır (kapasite kullanımı düşük ve tesis kritikse artar).
- **Yaşam maliyeti tabanı (K46):** Temel sepet = hanenin temel barlarını (beslenme, ısınma, ulaşım) asgari düzeyde tutacak aylık mal miktarı (tanım dosyasında). `Taban = sepet × şehir ortalama perakende fiyatları / ortalama çalışan sayısı × meslek taban çarpanı` (İşçi 1,0 · Sürücü 1,1 · Teknisyen 1,3 · Ofis personeli 1,3 · Mühendis 1,8). Mevsime göre değişir. Maaş tabanın altına inmez.
- **İşsizlik:** İşsiz hanenin geliri yok; birikimle yaşar, birikim bitince barlar düşer, göç başlar.
- **Döngü:** Genişleme → boş kadro → maaş ↑ → gelir ↑ → rezervasyon fiyatları ↑ → perakende fiyatları ↑ → yaşam maliyeti ve taban ↑. Göç ve meslek geçişi işgücü arzını artırarak frenler. Enflasyon sarmalı riski para arzı alarmıyla izlenir.

### Memnuniyet (K79 — K47–K49'un sadeleştirilmiş hali)

K52 sözgecinden geçirildi: sadece şirketlerin etkileyebildiği faktörler kalır.

- **Faktörler** (her biri `karşılanan − beklenen`):
  1. **Tüketim:** ihtiyaç barları — temel (beslenme, ısınma, ulaşım) ve üst (konfor, ev yaşamı). Şirketlerin fiyatı, kalitesi ve bulunabilirliği belirler.
  2. **İş ve gelir:** istihdam durumu + gelir / yaşam maliyeti sepeti (K46).
  3. **Kirlilik ve gürültü:** konut karosundaki seviye (aşağıda).
  4. **Mağaza erişimi:** temel ihtiyaçlar için etkin yol maliyeti (K36) + bulunabilirlik (aradığını bulamama oranı).
- **Temel ihtiyaç kuralı:** Temel barlar eşiğin altındaysa diğer faktörlerin olumlu katkısı `× temel karşılanma / eşik` ile kısılır; olumsuz katkılar her zaman tam yansır.
- **Beklenti:** sadece alışkanlık — hanenin kendi geçmiş seviyesinin asimetrik hareketli ortalaması (iyileşmeye hızlı, kötüleşmeye yavaş alışır).
- `Memnuniyet = Σ ağırlık × faktör puanı`.
- **Çıkarılanlar:** konut kalabalığı/kalitesi, birikim tamponu, fiyat algısı, iş güvencesi, kamu hizmetleri, yeşil alan, eşitsizlik, sosyal referans (komşu kıyası). Aidiyet sadece göç freni olarak kalır.

### Vergi ve kamu bütçesi (K80 — K50'nin sadeleştirilmiş hali)

- Gelir vergisi (maaştan) + kurumlar vergisi (kârdan); oranlar tanım dosyasında sabit. Şirket için bir gider kalemi.
- Şehir bütçesi gelirleri: vergiler + şehirdeki kamu altyapı ücretleri + borsa komisyonu + arazi satış/kira gelirleri (K72).
- Harcamalar, sırayla:
  1. İşsizlik desteği: işsiz hane başına maaş tabanının belli yüzdesi (çöküşü önler).
  2. Şehrin arazi alım teklifleri (K74).
  3. Kalan bütçe **kamu istihdamına**: şehrin meslek havuzundan çalışan alır, maaş olarak hanelere döner. Zengin şehirde kamu işgücü için şirketlerle rekabet eder.
- Kamu hizmetlerinin kalite etkisi yok; bütçe para döngüsünü ve işsizlik tamponunu sağlar. Dengeli bütçe, kamu borçlanmaz.
- Ekonomiden kalıcı para çıkaran kalemler: ithalat ve dış göç.

### Kirlilik ve gürültü (K51, K80 ile güncellendi)

- Kirlilik kaynağı: tesis tipine göre emisyon × kapasite kullanımı.
- Gürültü kaynağı: altyapı kenarı trafik hacmi × mod çarpanı (demiryolu > otoyol > şehir yolu) + tesisler.
- Mesafeyle azalan yayılım, karo bazında günlük ve chunk chunk güncellenir; rüzgâr/arazi etkisi yok.
- Etkiler: memnuniyetin Kirlilik faktörü + arazi değeri (K73). Sağlık bağı yok.
- Ar-Ge emisyon filtresi kirliliği azaltır.

### Meslek ve maaş (K11, K12)
- Meslek grupları: İşçi, Teknisyen, Sürücü, Mühendis, Ofis personeli (Genel Merkez; K54).
- Maaş her şehirde meslek bazında arz/talebe göre oluşur.
- Meslek geçişi: İşsiz veya maaşı şehir ortalamasının belirgin altında kalanların küçük bir yüzdesi her ay açığı olan mesleğe geçiş adayı olur. Geçiş süresi mesleğe göre değişir (İşçi→Sürücü kısa, →Teknisyen orta, →Mühendis uzun); geçişte gelir yok.

### Nüfus değişimi (K13)
- **Doğal büyüme:** Memnuniyet yüksekse hane bölünür, çok düşükse dağılır.
- **Göç:** Aylık çekim puanı (meslek maaşı, iş bulma ihtimali, memnuniyet, mesafe cezası); eşik geçilirse taşınır.
- **Konut kapasitesi:** Boş konut yoksa büyüme ve göç durur (şehir büyümesi `world_gen.md`).

## Açık Sorular

- Memnuniyet parametreleri: faktör ağırlıkları, temel ihtiyaç eşiği, alışkanlık hızları, vergi oranları, işsizlik desteği oranı, emisyon/gürültü katsayıları ve yayılım yarıçapları.
- Maaş parametreleri: λ, prim karar kuralları, temel sepet miktarları.

- Bar düşüş hızları, eşikler, geçiş ve göç yüzdeleri, w₁/w₂, bilgi yarıçapı, dış göç eşikleri, bölünme tabanı.

## Tartışma Notları

- [2026-10-29] Nüfus modeli kuruldu (K8–K13). K12 ve K13 kullanıcının isteğiyle Claude tarafından seçildi.
- [2026-10-29] Maaş oluşumu formül düzeyinde tasarlandı (K44–K46).
- [2026-10-29] Memnuniyet modeli kuruldu (K47–K51); K9'daki bar ortalaması kuralının yerini aldı. Vergi ve kamu bütçesi eklendi.
- [2026-10-29] Göç ve nüfus formül düzeyinde tasarlandı (K77, K78).
- [2026-10-30] K52 sözgeci: memnuniyet 4 şirket-etkili faktöre indirildi (K79); kamu hizmetleri kaldırıldı, bütçe işsizlik desteği + kamu istihdamına gidiyor (K80); kirlilik–sağlık bağı kaldırıldı.
