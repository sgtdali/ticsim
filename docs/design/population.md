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

### Meslek ve maaş (K11, K12)
- Meslek grupları: İşçi, Teknisyen, Sürücü, Mühendis.
- Maaş her şehirde meslek bazında arz/talebe göre oluşur.
- Meslek geçişi: İşsiz veya maaşı şehir ortalamasının belirgin altında kalanların küçük bir yüzdesi her ay açığı olan mesleğe geçiş adayı olur. Geçiş süresi mesleğe göre değişir (İşçi→Sürücü kısa, →Teknisyen orta, →Mühendis uzun); geçişte gelir yok.

### Nüfus değişimi (K13)
- **Doğal büyüme:** Memnuniyet yüksekse hane bölünür, çok düşükse dağılır.
- **Göç:** Aylık çekim puanı (meslek maaşı, iş bulma ihtimali, memnuniyet, mesafe cezası); eşik geçilirse taşınır.
- **Konut kapasitesi:** Boş konut yoksa büyüme ve göç durur (şehir büyümesi `world_gen.md`).

## Açık Sorular

- Bar düşüş hızları, eşikler, geçiş ve göç yüzdeleri.

## Tartışma Notları

- [2026-10-29] Nüfus modeli kuruldu (K8–K13). K12 ve K13 kullanıcının isteğiyle Claude tarafından seçildi.
