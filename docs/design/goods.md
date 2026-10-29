# Mallar ve Üretim Zincirleri

## Karar verilmiş

### Kademeler
- **Hammadde:** Haritadaki kaynak karosundan çıkar (tarla, maden, kuyu, orman).
- **Ara ürün:** Başka tesislerin girdisi.
- **Nihai ürün:** Haneler tüketir.

### Reçete
Her tesis tipinin reçetesi: girdiler, çıktılar, döngü süresi, meslek bazında işgücü (bkz. `population.md`), tesis maliyeti. İşgücü bulunamazsa tesis yavaşlar.

### Aşama 1 başlangıç seti
- **Gıda:** Buğday → Un → Ekmek
- **Yakıt:** Ham petrol → Yakıt (araçlar, ısınma ve ulaşım tüketir)
- **Dayanıklı:** Kereste → Mobilya; Demir cevheri + Kömür → Çelik → Ev aleti

### Kalite ve marka (K3, K4, K5)
- Her mal partisi `kalite` + `üretici şirket` taşır.
- `Çıktı kalitesi = a × (girdilerin ağırlıklı ort. kalitesi) + b × (şirketin ürün teknolojisi)`, `a + b = 1`, oran ürüne göre değişir (ekmekte girdi, ev aletinde teknoloji baskın).
- `Hammadde kalitesi = c × (karo zenginliği) + d × (çıkarım teknolojisi)`.
- Tesis seviyesi ve işgücü kaliteyi değil, kapasite ve hızı etkiler.
- Marka şirket × ürün kategorisi düzeyinde; reklam ve satış memnuniyetiyle büyür, zamanla söner.
- Hane seçimi: fiyat, kalite, marka, erişilebilirlik; ağırlıklar gelir seviyesine göre değişir.

### Kaynaklar (K6)
Kaynaklar tükenmez.

### Kargo sınıfları ve bozulma (K7)
- **Dökme:** buğday, kömür, demir cevheri
- **Sıvı:** ham petrol, yakıt
- **Genel (paletli):** un, kereste, çelik, mobilya, ev aleti
- **Soğuk zincir:** ekmek ve ileride taze gıdalar
- Araç ve depolar belirli sınıfları kabul eder; uyumsuz sınıf taşınamaz.
- Bozulma kaliteyi zamanla düşürür; uygun depoda yavaş, uygunsuz ama kabul eden depoda hızlı. Kalite eşiğin altına inince mal imha edilir.

## Açık Sorular

- Reçete sayısal değerleri ve `a/b/c/d` oranları.

## Gerilimler

- Tükenmeyen kaynaklar uzun vadeli durağanlık riski; Ar-Ge ile yeni ürünler (bkz. `research.md`) ve şirket devri ile dengelenmesi bekleniyor.

## Tartışma Notları

- [2026-10-29] Mal modeli kuruldu (K3–K7).
