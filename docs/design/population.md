# Nüfus

## Karar verilmiş

### Birim (K8)
Temel birim hane (2–5 kişi). Hane verisi: konut karosu, kişi sayısı, çalışanlar (meslek + işyeri), gelir, birikim, sahip olunan dayanıklı mallar (kalite, marka, kalan ömür), memnuniyet.

### İhtiyaç barları (K9, K10)
- Her ihtiyaç 0–100 bar; zamanla düşer.
- Tüketilen mal barı bir kerede doldurur; dayanıklı mal ömrü boyunca barı destekler (kalite = destek gücü), ömür bitince yenisi aranır.
- Hane her gün en düşük bara bakar, bütçesi yetiyorsa uygun malı alır (marka/kalite seçimi `goods.md`).
- Memnuniyet hesabı K47–K51 ile tanımlandı (aşağıda); barlar Temel tüketim kategorisinin girdisidir.
- **Aşama 1 ihtiyaçları:** Beslenme (ekmek), Konfor (mobilya), Ev yaşamı (ev aleti), Isınma (yakıt, mevsimsel), Ulaşım (yakıt).
- Isınma kışın hızlı düşer → **mevsim sistemi** var.
- Aşama 1'de araba zinciri yok; ulaşım doğrudan yakıtla dolar.

### Maaş oluşumu (K44–K46)

- **Haftalık değişim (K44):** `Δmaaş = λ × (Boş kadro − İşsiz) / Meslekteki toplam işgücü`, şehir × meslek bazında. Artış haftada en fazla %+3, düşüş en fazla %−1 (yapışkanlık).
- **Maaş primi (K45):** Şirket her tesiste meslek başına şehir maaşının üstüne %0–20 prim verebilir. İşsizler önce en yüksek primli boş kadroya yerleşir. Çalışanlar, mevcut primden en az 5 puan yüksek teklif varsa geçebilir; her ay çalışanların en fazla %5'i geçer, geçen çalışan en az 30 gün kalır. Prim AI taktik kararıdır (kapasite kullanımı düşük ve tesis kritikse artar).
- **Yaşam maliyeti tabanı (K46):** Temel sepet = hanenin temel barlarını (beslenme, ısınma, ulaşım) asgari düzeyde tutacak aylık mal miktarı (tanım dosyasında). `Taban = sepet × şehir ortalama perakende fiyatları / ortalama çalışan sayısı × meslek taban çarpanı` (İşçi 1,0 · Sürücü 1,1 · Teknisyen 1,3 · Ofis personeli 1,3 · Mühendis 1,8). Mevsime göre değişir. Maaş tabanın altına inmez.
- **İşsizlik:** İşsiz hanenin geliri yok; birikimle yaşar, birikim bitince barlar düşer, göç başlar.
- **Döngü:** Genişleme → boş kadro → maaş ↑ → gelir ↑ → rezervasyon fiyatları ↑ → perakende fiyatları ↑ → yaşam maliyeti ve taban ↑. Göç ve meslek geçişi işgücü arzını artırarak frenler. Enflasyon sarmalı riski para arzı alarmıyla izlenir.

### Memnuniyet (K47–K51)

K9'daki "barların ortalaması = memnuniyet" kuralının yerini alır; barlar artık Temel tüketim kategorisinin girdisidir.

- **Faktör puanı (K47):** `Karşılanan − Beklenen`, her faktör için.
- **Kademeler (K48):**
  1. **Hayatta kalma:** Temel tüketim (beslenme, ısınma, ulaşım barları; ileride gıda çeşitliliği), Konut (kalabalık = kişi / konut kapasitesi, konut kalitesi = karo yoğunluğu ve tipi)
  2. **Güvence:** Ekonomik güvence (istihdam oranı, gelir / yaşam maliyeti sepeti, birikim tamponu = kaç aylık harcama, fiyat algısı = referans fiyatların 3 aylık artışı, iş güvencesi = son işten çıkarmalar ve işyeri kapasite kullanımı), Kamu hizmetleri (sağlık, eğitim, güvenlik, işsizlik desteği)
  3. **Konfor:** Yaşam standardı (dayanıklı mal kalitesi ve çeşidi), Erişim (temel ihtiyaçlar için etkin yol maliyeti, bulunabilirlik = aradığını bulamama oranı, işe gidiş süresi), Çevre (kirlilik, gürültü, yeşil alan)
  4. **Aidiyet:** Toplumsal (şehir işsizlik oranı, eşitsizlik, şehirde geçirilen süre)
  - Kademe n'nin **olumlu** katkısı `× min(1, Karşılanma(n−1) / eşik)` ile kısılır; **olumsuz** katkılar her zaman tam yansır.
- **Beklenti (K49):** `Beklenti = γ × Alışkanlık + (1 − γ) × Sosyal referans`. Alışkanlık = hanenin kendi geçmiş seviyesinin asimetrik hareketli ortalaması (iyileşmeye hızlı, kötüleşmeye yavaş alışır). Sosyal referans = aynı şehirde benzer ve bir üst gelir dilimindeki hanelerin ortalaması.
- **Kamu hizmetleri ve vergi (K50):**
  - Gelir vergisi (maaştan) + kurumlar vergisi (kârdan); oranlar tanım dosyasında sabit.
  - Şehir bütçesi gelirleri: vergiler + şehirdeki kamu altyapı ücretleri + borsa komisyonu.
  - Harcamalar: sağlık, eğitim, güvenlik (kamu çalışanı istihdam eder; maaş olarak hanelere döner) + işsizlik desteği (işsiz hane başına maaş tabanının belli yüzdesi, bütçe yettiğince). Dengeli bütçe, kamu borçlanmaz.
  - Hizmet kalitesi = kişi başı harcama (kirlilikle artan sağlık ihtiyacına göre düzeltilmiş), beklentiyle karşılaştırılır.
  - Eğitim meslek geçişini (K12) hızlandırır; sağlık doğal büyümeyi (K13) destekler.
  - Ekonomiden kalıcı para çıkaran tek kalem ithalat kalır.
- **Kirlilik ve gürültü (K51):**
  - Kirlilik kaynağı: tesis tipine göre emisyon × kapasite kullanımı.
  - Gürültü kaynağı: altyapı kenarı trafik hacmi × mod çarpanı (havalimanı > demiryolu > otoyol > şehir yolu) + tesisler.
  - Mesafeyle azalan yayılım, karo bazında günlük ve chunk chunk güncellenir; rüzgâr/arazi etkisi yok.
  - Konfor kademesinde olumsuz etki (kısılmaz) + kirlilik kişi başı sağlık ihtiyacını artırır.
  - Ar-Ge tesis verimliliği kilitleri emisyon azaltabilir.

### Meslek ve maaş (K11, K12)
- Meslek grupları: İşçi, Teknisyen, Sürücü, Mühendis, Ofis personeli (Genel Merkez; K54).
- Maaş her şehirde meslek bazında arz/talebe göre oluşur.
- Meslek geçişi: İşsiz veya maaşı şehir ortalamasının belirgin altında kalanların küçük bir yüzdesi her ay açığı olan mesleğe geçiş adayı olur. Geçiş süresi mesleğe göre değişir (İşçi→Sürücü kısa, →Teknisyen orta, →Mühendis uzun); geçişte gelir yok.

### Nüfus değişimi (K13)
- **Doğal büyüme:** Memnuniyet yüksekse hane bölünür, çok düşükse dağılır.
- **Göç:** Aylık çekim puanı (meslek maaşı, iş bulma ihtimali, memnuniyet, mesafe cezası); eşik geçilirse taşınır.
- **Konut kapasitesi:** Boş konut yoksa büyüme ve göç durur (şehir büyümesi `world_gen.md`).

## Açık Sorular

- Memnuniyet parametreleri: kademe eşikleri, kategori ağırlıkları, γ, alışkanlık hızları, vergi oranları, bütçe payları, emisyon/gürültü katsayıları ve yayılım yarıçapları.
- Maaş parametreleri: λ, prim karar kuralları, temel sepet miktarları.

- Bar düşüş hızları, eşikler, geçiş ve göç yüzdeleri.

## Tartışma Notları

- [2026-10-29] Nüfus modeli kuruldu (K8–K13). K12 ve K13 kullanıcının isteğiyle Claude tarafından seçildi.
- [2026-10-29] Maaş oluşumu formül düzeyinde tasarlandı (K44–K46).
- [2026-10-29] Memnuniyet modeli kuruldu (K47–K51); K9'daki bar ortalaması kuralının yerini aldı. Vergi ve kamu bütçesi eklendi.
