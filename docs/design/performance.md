# Performans ve Veri Yapısı

## Karar verilmiş

### Veri yapısı
- Data-oriented C#: varlıklar `struct` dizileri + ID; tick içinde bellek tahsisi yok.
- Sistemler veri üzerinden bağlı saf fonksiyonlar gibi.
- Bağımsız işler worker thread'lerde; ortak kaynaklara (borsa, ağ grafiği) yazanlar sıralı.
- Periyodik işler tek tick'e yığılmaz, tick'lere yayılır.

### Determinizm (K27)
- Sistem başına seed'li RNG; global `Random` yok.
- Paralel tamponlar sabit sırayla birleştirilir.
- Para tam sayı (kuruş, `long`).
- Kaydet/yükle tam durum anlık görüntüsü; birebir devam.

### Detay (K28)
Her yer tam detay; LOD ileride optimizasyon seçeneği.

### Tick ritmi
- 1 tick = 1 oyun saati.
- Her tick: araç hareketi, terminal kuyrukları, üretim döngüleri.
- Günlük (yayılmış): hane barları ve alışveriş, mağaza satışları, bozulma, borsa eşleşmesi.
- Haftalık: şirket taktik kararları, maaş güncellemesi.
- Aylık: stratejik kararlar, göç, meslek geçişi, girişim/iflas.
- Tıkanıklık maliyetleri ve rota önbelleği birkaç saatte bir.

### Bütçe
4x hızda tick < 16 ms. Her sistemin tick süresi ölçülüp loglanır.

## Tartışma Notları

- [2026-10-29] Performans modeli kuruldu (K27, K28).
