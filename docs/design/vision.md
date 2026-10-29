# Vizyon ve Kapsam

## Karar verilmiş

- **Tür:** Şirket üretim ve lojistik tycoon oyunu.
- **Dönem:** Modern endüstriyel.
- **Harita:** Ülke büyüklüğünde, prosedürel, grid/tile arazi.
- **Detay hedefi:** Song of Syx seviyesinde mikro simülasyon.
- **Ağırlık:** Mikro simülasyon birinci; üretim zinciri, lojistik ve şirket rekabeti onun üzerinde farklı ağırlıklarla çalışır.
- **Tek tek simüle edilenler:** Haneler (nüfus/tüketiciler), araçlar/sevkiyatlar, rakip şirketler. Çalışanlar tek tek simüle edilmez (sadece meslek grubu ve işyeri).
- **Altyapı:** Oyuncu/şirketler inşa eder; harita kamu ağıyla doğar (bkz. `logistics.md`).
- **Taşıma türleri:** Karayolu, demiryolu, denizyolu, havayolu.
- **Teknoloji:** Ar-Ge ile açılır; tarihsel dönem ilerlemesi yok.
- **Hedef yapısı:** Açık sandbox, bitiş yok.
- **Görsel:** 2D top-down.
- **Teknoloji yığını:** Godot 4 + C#, simülasyon headless çalışır (K2).
- **Geliştirme sırası:** Önce dünya simülasyonu, oyuncusuz (K1). Oyuncu katmanı Aşama 2.

## Hedef dışı

- Çalışanların bireysel simülasyonu (beceri, moral)
- Senaryo / zafer koşulları
- Tarihsel dönem ilerlemesi

## Varsayımlar

- Tek oyunculu, PC.
- Ölçek: orta seviye PC'de akıcı; ~25–35 bin hane (~100 bin kişi), birkaç bin araç.
- Simülasyon UI'dan ayrı, data-oriented katmanda.
- Kaydet/yükle zorunlu.

## Aşamalar

- **Aşama 1 — Dünya simülasyonu:** Oyuncusuz, kendi kendine yaşayan ekonomi. Çıkış kriterleri `observation.md`'de.
- **Aşama 2 — Oyuncu katmanı:** Tasarlanmadı.

## Gerilimler

- Kapsam solo geliştirici için çok büyük. A yaklaşımı uzun süre oynanabilir çıktı vermez; terk riskine karşı her aşama sonunda izlenebilir çıktı (debug viewer) üretilecek.

## Tartışma Notları

- [2026-10-29] Oyunun yönü ortaçağ ticaret siminden ülke haritalı üretim/lojistik tycoon'a çevrildi. Dikey dilim (B) önerildi, kullanıcı önce dünya simülasyonunu (A) seçti.
