# Gözlem ve Sağlık Metrikleri

## Karar verilmiş

### Metrikler
- **Para:** toplam para arzı, kaynak/dren dökümü (ithalat, komisyon, altyapı ücretleri, maaşlar), fiyat endeksi
- **Üretim:** toplam üretim değeri, yerli üretim / ithalat oranı
- **Nüfus:** nüfus, memnuniyet dağılımı, bar karşılama oranları, meslek bazında işsizlik, göç akışları
- **Şirketler:** sayı, doğum/iflas oranı, sektör bazında pazar yoğunlaşması, kâr marjları
- **Lojistik:** araç doluluğu, boş dönüş oranı, ortalama teslim süresi, tıkanıklık, bozulmadan kayıp
- **Dinamizm:** fiyat oynaklığı, pazar lideri değişim sayısı

### Alarmlar
- Para arzının sınırsız artması veya çökmesi
- Kalıcı tek şirket tekeli
- İthalata kalıcı bağımlılık
- Durağanlık (oynaklık ~0, lider değişmiyor)
- Ölüm sarmalı (nüfus sürekli düşüş)

### Araçlar (K29)
- **Debug viewer (Godot):** harita katmanları (arazi/kaynak, şehir/yoğunluk, şirket renkli tesisler, araçlar, tıkanıklık ısı haritası), tıklanabilir inceleme, zaman serisi grafikleri, hız kontrolü (duraklat, 1x–64x), seed seçimi. Sadece okur.
- **Headless toplu koşu:** seed listesi × süre × ayar dosyası; günlük metrik CSV'si + alarm logu; Python ile ayar karşılaştırması.

### Aşama 1 çıkış kriterleri
1. 20 seed × 10 oyun yılında hiçbir alarm tetiklenmez.
2. 2. yıl sonunda ithalat hane tüketiminin %20'sinin altında.
3. Her sektörde 10 yılda en az bir lider değişimi, bir iflas, bir yeni girişim.
4. Ortalama memnuniyet stabil bir banda oturur.
5. Hedef ölçekte 4x hızda tick < 16 ms.

## Tartışma Notları

- [2026-10-29] Gözlem modeli ve Aşama 1 çıkış kriterleri onaylandı (K29).
