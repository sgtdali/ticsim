# UI Panel Mimarisi

Bu belge, oyunun sağ panel yapısını ve her tab'ın içeriğini tanımlar.

## Sağ Panel — Tab Yapısı

Sağ panel üç tab'dan oluşur: Operasyonlar, Oyuncu, Kontratlar.

---

## Tab 1 — Operasyonlar

### Caravan Masters
- Her master için tek satır: İsim | Konum veya rota durumu | Seviye
- Satıra tıklayınca expand olur: rota durakları, taşınan envanter, XP progress bar
- Hire Master butonu: cap dolmamışsa aktif, dolmuşsa disabled

### Trading Posts
- Her post için tek satır: Şehir adı | Depot doluluk (ör. 23/50) | Aktif rule sayısı
- Satıra tıklayınca expand olur: rule listesi, her rule'un status ikonu (active / waiting_price / waiting_stock / waiting_market / depot_full / depot_empty)
- Establish Post butonu: oyuncu o şehirdeyken ve şartlar sağlanmışsa aktif

---

## Tab 2 — Oyuncu

### Caravan
- Mevcut upgrade adı ve kapasite (ör. "Horse Cart — 35")
- Cargo doluluk (ör. 12/35)
- Envanter listesi: her item için isim | miktar | ortalama alış fiyatı
- Upgrade butonu: şartlar sağlanmışsa aktif

### İlerleme
- Mevcut rank adı
- Sonraki rank için gereksinimler ve mevcut değerleri
- Her şehir için prosperity progress bar (isim | bar | seviye etiketi)

---

## Tab 3 — Kontratlar

- Sadece oyuncunun kabul ettiği aktif kontratlar listelenir
- Her kontrat: başlık | durum | progress (ör. 3/10 wheat) | kalan gün | ödül (gold)
- Liste boşsa "Aktif kontrat yok." mesajı gösterilir
- Tamamlanan, başarısız olan veya henüz kabul edilmemiş kontratlar bu panelde görünmez
