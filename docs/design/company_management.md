# Şirket Yönetimi ve Ölçek

Oyuncunun ve NPC şirketlerin büyüdükçe nasıl yönetildiğini tanımlar. K19 gereği tüm kurallar NPC'ler için de geçerlidir.

## Karar verilmiş

### Prensip (K52)
Bir dünya sistemi, şirkete bir karar, fırsat veya kriz doğurduğu kadar derinleştirilir.

### Kontrol (K53)
Oyuncu başta her şeyi elle yönetir (fiyat, borsa emri, prim, stok hedefi). Şirket büyüdükçe yöneticiler atar; geç oyunda bölgeler ve direktörlerle politika düzeyinde çalışır, sadece krizlere iner.

### Mikrodan makroya geçiş (K54) — Song of Syx modeli

Referans: Song of Syx'te yerleşim unvanları nüfusla açılır; Administration binası katiplerle yönetim puanı üretir; puanlar bölgelere dağıtılır ve aşırı harcama tüm politikalara ceza verir; soylular slot sınırlı görevlere atanıp zamanla artan bonus verir.

**Şirket kademeleri (çalışan sayısına göre)**

| Kademe | Eşik | Açılanlar | Yönetici slotu |
|---|---|---|---|
| Atölye | 0 | Temel tesisler, karayolu | 0 |
| Firma | 50 | Genel Merkez | 2 |
| Şirket | 300 | Ar-Ge tesisi, demiryolu terminali | 4 |
| Holding | 1.500 | Liman ve havalimanı terminali, bölge müdürü rolü | 7 |
| Konglomera | 6.000 | Yönetim verimi +%100 | 12 |

**Yönetim puanı**
- Üretim: CEO taban puanı (Atölye'yi tek başına yönetmeye yeter) + Genel Merkez'deki Ofis personeli × kademe verim çarpanı.
- Tüketim: tesis 2, mağaza 1, depo/terminal 1, her 20 araç 1 puan; merkeze uzaklıkla artan çarpan; yeni şehre ilk giriş ek maliyeti.
- Açık: açık oranında tüm tesislerin kapasitesi ve mağazaların satış verimi düşer.

**Yöneticiler**
- Bireysel karakterler (çalışanların bireysel simüle edilmemesi kuralının istisnası; sayıları azdır).
- Roller: Üretim direktörü (+tesis verimi), Lojistik direktörü (−lojistik maliyeti), Satış direktörü (+marka büyümesi), Bölge müdürü (bir şehrin puan maliyetini yarıya indirir, oradaki taktik kararları devralır).
- Beceri zamanla artar; maaş yüksek; kişilik (risk, marj, kalite odağı) taşır.
- Bölge müdürü, NPC taktik AI katmanının (K39, K42–K45) kişilikli bir örneğidir. Oyuncu politika sınırları koyar (örn. marj aralığı, stok hedefi) ve her an elle müdahale edebilir.

**Merkez ve bölgeler:** Genel Merkez şehri ayrıntılı ekranla, diğer şehirler bölge ekranıyla yönetilir.

**Sonuçlar**
- Ölçek büyüdükçe yönetim maliyeti verimi düşürür → tekelleşmeye doğal fren.
- Genel Merkez yeri Ofis personeli işgücüne bağlı bir karardır.

### Capitalism'den eklenenler (K55)

Referans: Capitalism 2 / Capitalism Lab'de COO sadece açıkça devredilen tesisleri yönetir; etkinliği verilen serbestliğe (ürün değiştirme, rakipten alım, fiyat agresifliği) bağlıdır; yöneticinin tesis tipine özel uzmanlığı birimlere aktarılır; tesis birimleri 1–9 seviye kazanır.

**Yetki ayarları** (her devretmede ayrı)
- Fiyat: kapalı / normal / agresif + marj alt-üst sınırı
- Tedarik: kullanılabilir kalite sınıfları ve şehir borsaları
- Üretim: reçete/ürün değiştirme izni
- İşgücü: prim üst sınırı, işten çıkarma izni
- Bütçe: bakım ve küçük genişletme harcama limiti

**Seçerek devretme**
- Devredilebilir birimler: tek tesis/mağaza, bütün şehir (bölge müdürü) veya fonksiyon (örn. tüm mağazaların fiyatlaması → Satış direktörü).
- Her yöneticinin beceriyle artan bir **yönetim kapsamı** (yönetebileceği birim sayısı) vardır.
- Devredilen birimlerin yönetim puanı maliyeti yöneticinin becerisine göre düşer; K54'teki "bölge müdürü yarıya indirir" kuralı bunun özel halidir.

**Sektör uzmanlığı**
- Alanlar: Tarım, Hammadde (maden, kuyu, orman), İmalat, Perakende, Lojistik, Ar-Ge, Pazarlama.
- `Bonus = uzmanlık × katsayı`, sadece eşleşen birim türlerinde.
- Oyuncu CEO'su da uzmanlık taşıyabilir (başlangıçta seçilir; Aşama 2).

**Tesis deneyimi**
- Tesis 1–5 seviye kazanır; seviye kapasite ve hızı artırır (örn. seviye 5'te +%60). Kaliteyi etkilemez (K4).
- Deneyim kapasite kullanımıyla birikir; reçete/ürün değişince düşer.
- Çalışanlar prim için başka şirkete geçtiğinde (K45) tesis deneyim kaybeder → rakipten işçi kapmak stratejik silah.
- Deneyim tesis bazında toplu tutulur; çalışanlar bireysel simüle edilmez.

## Açık Sorular

- Finansman: kredi, borç, yatırımcı; oyuncunun başlangıç sermayesi.
- Yönetici işe alma: aday havuzu, maaş, kişilik seçimi.
- Kademe eşikleri, puan değerleri, yönetici bonus oranları, beceri artış hızı, uzmanlık katsayıları, yönetim kapsamı, tesis deneyimi eşikleri ve bonusları.
- Oyuncunun karar yüzeylerinin geri kalanı ve kriz uyarıları (Aşama 2).

## Tartışma Notları

- [2026-10-29] Oyuncunun şirket yönetimi odağı yeniden teyit edildi; dünya sistemleri için K52 filtre prensibi konuldu. Kontrol modeli ve Song of Syx tarzı mikro→makro geçiş kararlaştırıldı (K53, K54). Ofis personeli beşinci meslek grubu olarak eklendi.
- [2026-10-29] Capitalism'in yönetim modeli incelendi; yetki ayarları, seçerek devretme, sektör uzmanlığı ve tesis deneyimi eklendi (K55).
