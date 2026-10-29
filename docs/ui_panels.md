# UI Panel Mimarisi

> **Durum (2026-10-29):** Eski ortaçağ prototipinin panelleri (Caravan Masters, Trading Posts, Rank, Kontratlar) geçersizdir. Aşama 1'de oyuncu yok; tek UI **debug viewer**'dır. Oyuncu UI'ı Aşama 2'de tasarlanacak.
>
> Kaynak tasarım: `docs/design/observation.md`. Viewer sim durumunu sadece okur (bkz. `docs/architecture.md`).

## Ekran Düzeni

- **Orta:** Harita görünümü (zoom/pan)
- **Üst çubuk:** Tarih, mevsim, hız kontrolü, seed
- **Sol panel:** Harita katmanları
- **Sağ panel:** İnceleme (seçili varlık)
- **Alt panel:** Metrik grafikleri ve alarm logu

---

## Üst Çubuk

- Oyun tarihi ve mevsim
- Hız: duraklat, 1x, 4x, 16x, 64x; tek tick ilerlet
- Aktif seed ve yeni seed ile dünya oluştur
- Tick süresi göstergesi (ms) — bütçe aşılınca kırmızı

---

## Sol Panel — Harita Katmanları

Aç/kapa listesi:
- Arazi / biyom
- Kaynaklar (tip + zenginlik)
- Şehirler ve yoğunluk
- Tesisler ve mağazalar (şirket rengiyle)
- Altyapı (kamu / özel ayrı renk; mod bazında filtre)
- Araçlar (hareket halinde; mod bazında filtre)
- Tıkanıklık ısı haritası

---

## Sağ Panel — İnceleme

Haritada tıklanan varlığın tüm verisi gösterilir. Tipler:

- **Şehir:** nüfus, konut doluluk, meslek bazında maaş ve işsizlik, ortalama bar seviyeleri, mağaza listesi
- **Borsa:** mal bazında son fiyat/hacim, açık emir defteri, depo stokları
- **Hane:** kişi sayısı, çalışanlar (meslek, işyeri), gelir, birikim, ihtiyaç barları, dayanıklı mallar, memnuniyet
- **Tesis:** tip, sahip, reçete durumu, girdi/çıktı stokları (kalite ile), kapasite kullanımı, işgücü
- **Mağaza:** sahip, raflar (kategori, stok, fiyat), son satışlar, kapsama alanı (haritada vurgulanır)
- **Araç:** tip, yük (kalite, yaş), aktif bacak ve rota (haritada çizilir), bağlı depo
- **Şirket:** nakit, kişilik, varlık listesi, teknoloji seviyeleri, patentler, marka değerleri, son stratejik karar ve skoru

---

## Alt Panel — Metrikler

- Metrik seçici: `observation.md`'deki 6 aile (para, üretim, nüfus, şirketler, lojistik, dinamizm)
- Zaman serisi grafiği; birden fazla seri üst üste
- Kapsam filtresi: tüm ülke / seçili şehir / seçili şirket / seçili mal
- **Alarm logu:** tetiklenen alarmlar, tarih ve ilgili varlık; tıklayınca o varlığa gider

---

## Uygulama Notları

- Paneller `.tscn` sahneleri olarak kurulur (AGENTS.md UI Workflow).
- Harita, araç ve katman çizimi performans için kodla, chunk bazında yapılır.
- Viewer sim'e hiçbir şey yazmaz; hız ve seed kontrolleri sim'in çalıştırıcısına komut gönderir.
