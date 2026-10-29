# Nüfus

## Karar verilmiş

### Birim (K8)
Temel birim hane (2–5 kişi). Hane verisi: konut karosu, kişi sayısı, çalışanlar (meslek + işyeri), gelir, birikim, sahip olunan dayanıklı mallar (kalite, marka, kalan ömür), memnuniyet.

### İhtiyaç barları (K9, K10)
- Her ihtiyaç 0–100 bar; zamanla düşer.
- Tüketilen mal barı bir kerede doldurur; dayanıklı mal ömrü boyunca barı destekler (kalite = destek gücü), ömür bitince yenisi aranır.
- Hane her gün en düşük bara bakar, bütçesi yetiyorsa uygun malı alır (marka/kalite seçimi `goods.md`).
- Barların ortalaması = memnuniyet.
- **Aşama 1 ihtiyaçları:** Beslenme (ekmek), Konfor (mobilya), Ev yaşamı (ev aleti), Isınma (yakıt, mevsimsel), Ulaşım (yakıt).
- Isınma kışın hızlı düşer → **mevsim sistemi** var.
- Aşama 1'de araba zinciri yok; ulaşım doğrudan yakıtla dolar.

### Maaş oluşumu (K44–K46)

- **Haftalık değişim (K44):** `Δmaaş = λ × (Boş kadro − İşsiz) / Meslekteki toplam işgücü`, şehir × meslek bazında. Artış haftada en fazla %+3, düşüş en fazla %−1 (yapışkanlık).
- **Maaş primi (K45):** Şirket her tesiste meslek başına şehir maaşının üstüne %0–20 prim verebilir. İşsizler önce en yüksek primli boş kadroya yerleşir. Çalışanlar, mevcut primden en az 5 puan yüksek teklif varsa geçebilir; her ay çalışanların en fazla %5'i geçer, geçen çalışan en az 30 gün kalır. Prim AI taktik kararıdır (kapasite kullanımı düşük ve tesis kritikse artar).
- **Yaşam maliyeti tabanı (K46):** Temel sepet = hanenin temel barlarını (beslenme, ısınma, ulaşım) asgari düzeyde tutacak aylık mal miktarı (tanım dosyasında). `Taban = sepet × şehir ortalama perakende fiyatları / ortalama çalışan sayısı × meslek taban çarpanı` (İşçi 1,0 · Sürücü 1,1 · Teknisyen 1,3 · Mühendis 1,8). Mevsime göre değişir. Maaş tabanın altına inmez.
- **İşsizlik:** İşsiz hanenin geliri yok; birikimle yaşar, birikim bitince barlar düşer, göç başlar.
- **Döngü:** Genişleme → boş kadro → maaş ↑ → gelir ↑ → rezervasyon fiyatları ↑ → perakende fiyatları ↑ → yaşam maliyeti ve taban ↑. Göç ve meslek geçişi işgücü arzını artırarak frenler. Enflasyon sarmalı riski para arzı alarmıyla izlenir.

### Meslek ve maaş (K11, K12)
- Meslek grupları: İşçi, Teknisyen, Sürücü, Mühendis.
- Maaş her şehirde meslek bazında arz/talebe göre oluşur.
- Meslek geçişi: İşsiz veya maaşı şehir ortalamasının belirgin altında kalanların küçük bir yüzdesi her ay açığı olan mesleğe geçiş adayı olur. Geçiş süresi mesleğe göre değişir (İşçi→Sürücü kısa, →Teknisyen orta, →Mühendis uzun); geçişte gelir yok.

### Nüfus değişimi (K13)
- **Doğal büyüme:** Memnuniyet yüksekse hane bölünür, çok düşükse dağılır.
- **Göç:** Aylık çekim puanı (meslek maaşı, iş bulma ihtimali, memnuniyet, mesafe cezası); eşik geçilirse taşınır.
- **Konut kapasitesi:** Boş konut yoksa büyüme ve göç durur (şehir büyümesi `world_gen.md`).

## Açık Sorular

- İşsizlik desteği / kamu yardımı olsun mu? (memnuniyet ve kamu hizmetleri konusunda ele alınacak)
- Maaş parametreleri: λ, prim karar kuralları, temel sepet miktarları.

- Bar düşüş hızları, eşikler, geçiş ve göç yüzdeleri.

## Tartışma Notları

- [2026-10-29] Nüfus modeli kuruldu (K8–K13). K12 ve K13 kullanıcının isteğiyle Claude tarafından seçildi.
- [2026-10-29] Maaş oluşumu formül düzeyinde tasarlandı (K44–K46).
