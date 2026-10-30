# Harita Üretimi

## Karar verilmiş

### Ölçek (K24)
1 karo = 250 m, ~2500 × 2500 karo (~600 km). Şehir 10–30 karo, fabrika 1–3 karo. Harita chunk'lara bölünür (örn. 64×64).

### Üretim hattı
1. Yükseklik (noise): deniz, kıyı, ova, tepe, dağ
2. İklim: sıcaklık + nem → biyom; mevsim etkisi enleme göre
3. Nehirler: tarım verimini artırır, köprü maliyeti yaratır
4. Kaynaklar: petrol, cevher, kömür yatakları zenginlik değeriyle; tarım/orman verimi biyomdan
5. Şehirler: kıyı/nehir/ova tercihi, minimum mesafe, boyut hiyerarşisi
6. Kamu ağı: karayolu (minimum yayılan ağaç + ek bağlantılar), ray omurgası (Aşama 1; limanlar ve havalimanları sonraki aşama, K84)

### Şehir büyümesi (K25)
- Karo tipleri: konut, ticari, şehir yolu.
- Konut doluluğu eşiği geçince şehir kenar karolarına kendiliğinden yayılır; verimli arazi, nehir ve tesisler büyümeyi keser.
- Karolar yoğunlaşabilir (düşük → orta → yüksek).

### Arazi (K72–K74)

- **Edinme (K72):** Başlangıçta tüm arazi kamuya aittir. Şirket karoyu kamudan **satın alır** (bir kerelik; varlık olur, kredi teminatı, satılabilir) veya **kiralar** (aylık, şehir bütçesine; süresiz, kira her ay değere göre güncellenir). Şirketler arası arazi satışı serbest (iflas varlıkları dahil, K18).
- **Değer (K73):** `Değer = Taban × (1 + a × Merkez yakınlığı) × (1 + b × Altyapı erişimi) × (1 − c × Kirlilik/gürültü) × (1 + d × Kaynak zenginliği) × Talep çarpanı`
  - Taban: arazi tipine göre (ova > tepe > dağ; nehir kenarı primli)
  - Merkez yakınlığı şehir büyüklüğüyle ölçeklenir
  - Altyapı erişimi: en yakın otoyol ve ray istasyonu mesafesi; yeni altyapı çevresini değerlendirir
  - Kirlilik/gürültü: K51 karo alanları; kirleten komşu araziyi ucuzlatır
  - Kaynak zenginliği: K5
  - Talep çarpanı: şehir büyüme hızı + son arazi işlemleri
  - Aylık güncellenir. `Kira = değer × (politika faizi + kira primi) / 12` (K58).
- **Şehir büyümesi (K74):** Büyüme şirket arazisine dayanırsa şehir, **boş veya atıl** arazi için `değer × (1 + %20–50)` teklif eder (şehir bütçesinden; yetmezse bekler). Çalışan tesise teklif yok. Ret → büyüme o yönde durur. Kenar arazisi spekülasyonu mümkün ama atıl arazi verim üretmez.
- Arazi maliyeti K70 değerlendirmesinde yatırıma (satın alma) veya sabit gidere (kira) eklenir.

### Başlangıç (K26)
- Boş ekonomi: şehirler, haneler, kaynaklar, kamu ağı; şirket yok.
- **İthalat güvenlik ağı:** Her şehirde pahalı ithal mal noktası (sınır şehirlerinde daha ucuz); tavan fiyat görevi görür, ödemeler ekonomiden para çıkarır.
- Hanelerin başlangıç birikimi yatırım havuzunu besler, ilk şirketler buradan doğar.

## Açık Sorular

- Başlangıç şehir sayısı/boyutları, ithalat fiyat çarpanı, başlangıç birikimi.
- Arazi parametreleri: taban değerler, a/b/c/d, kira primi, şehir teklif primi.

## Tartışma Notları

- [2026-10-29] Harita modeli kuruldu (K24–K26). İthalat güvenlik ağı boş ekonomi riskine çözüm olarak onaylandı.
- [2026-10-29] Arazi sahipliği, değeri ve şehir büyümesiyle ilişkisi kararlaştırıldı (K72–K74).
