# Üretim

Tesislerin yapısı, işleyişi, bakımı ve inşaatı. Mal tanımları, reçeteler ve kalite formülü `goods.md`'de; maliyet ve fiyat `market.md`'de; deneyim ve yöneticiler `company_management.md`'de.

## Karar verilmiş

### Tesis yapısı (K61) — Capitalism tarzı birimler
- **Kabuk:** tesis tipi + boyut. Küçük 4, orta 6, büyük 9 birim slotu (3×3 ızgara). Boyut kuruluş maliyetini, sabit gideri ve kapladığı karo sayısını (1–3) belirler.
- **Üretim tesisi birimleri:**
  - **Satın alma:** bir girdiyi bir kaynaktan çeker (şehir borsası, K43; ya da şirketin kendi başka tesisi)
  - **Üretim:** bir reçete çalıştırır
  - **Depo:** stok kapasitesi; kargo sınıfı ve bozulma (K7) burada işler
  - **Satış:** çıktıyı borsaya (K42) veya şirketin kendi mağaza/tesisine gönderir
- **Kaynak tesisleri** (tarla, maden, kuyu, orman): **Çıkarım** birimi, üzerinde durduğu karonun kaynağına bağlı.
- **Mağazalar:** Satın alma (kendi tesisinden), Raf (bir kategori; fiyat K37–K39), Reklam.
- **Deneyim:** birim bazında (K55'in güncellemesi). Her birim ayrı seviye kazanır; ürün/reçete değişince sadece o birim düşer.
- **Otomatik kurulum:** reçeteden tek tıkla standart düzen şablonu; oyuncu elle değiştirebilir.

### Bağlantılar (K62)
- Sadece ızgarada komşu birimler arasında (8 yön); birim başına en fazla 3 giriş, 3 çıkış.
- Birden fazla çıkışta oyuncunun belirlediği oranla bölme (varsayılan eşit).
- Akış birim kapasitesiyle sınırlı; dolu depo besleyeni yavaşlatır.
- NPC'ler sadece şablon düzenleri kullanır, yerleşimi optimize etmez.

### İşgücü (K63)
- Her birim meslek bazında çalışan ister (örn. çelik üretimi: 40 İşçi + 8 Teknisyen + 2 Mühendis).
- **Darboğaz:** `Hız = min(her meslek için mevcut / gereken)`.

### Bakım ve arıza (K64)
- Birim durumu 0–100. Günlük düşüş `yıpranma hızı × kapasite kullanımı`; bakım harcaması geri yükseltir.
- Bakım = birim başına bütçe + gereken Teknisyen (işgücü darboğazına tabi).
- Durum %70 altında hız kademeli düşer (durum %30'da hız ~%60).
- Günlük arıza olasılığı `p₀ × (1 − durum/100)²`; arızada birim 2–7 gün durur, onarım maliyeti çıkar. Seed'li RNG (K27).
- Bakımdan tasarruf kısa vadede kâr, uzun vadede arıza; nakit sıkıntısındaki şirketler bakımı kısar.

### İnşaat (K65)
- Kabuk boyutu, birim tipi ve altyapı için tanım dosyasında çelik ve kereste miktarı (ileride çimento).
- Şantiye alış emri gibi malzemeyi borsadan alır (K43 mantığı) ve lojistikle taşır; malzeme yoksa bekler.
- Malzeme tamamlanınca boyuta göre birkaç hafta; önce kabuk, sonra birimler.
- İnşaat süresince geçici İşçi çalıştırır.
- Yatırım dalgaları çelik/kereste talebini artırır; yarım şantiyeler iflasta satılık varlık olur.

### Hız ve kapasite özeti
`Etkin hız = Baz hız × Tesis/birim deneyim bonusu (K55) × İşgücü darboğazı (K63) × Durum çarpanı (K64) × Yönetim puanı açığı cezası (K54) × Yönetici bonusu (K55)`

## Açık Sorular

- Kabuk ve birim maliyetleri, slot sayıları, birim kapasiteleri, yıpranma hızları, p₀, malzeme miktarları, inşaat süreleri.
- A/b/c/d kalite oranları (`goods.md`).

## Tartışma Notları

- [2026-10-29] Üretim modeli kuruldu (K61–K65). Capitalism'in kabuk + birim + bağlantı modeli benimsendi; deneyim birim bazına taşındı.
