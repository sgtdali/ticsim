# Şirket AI

## Karar verilmiş

### Karar katmanları
- **Stratejik (aylık) — utility skorlama:** Her yatırım adayı (sektör × şehir × tesis) puanlanır: beklenen marj × talep potansiyeli − işgücü maliyeti − lojistik mesafesi − rekabet. Kişilik ağırlıkları puanı büker; en yüksek puan bütçe yetiyorsa uygulanır.
- **Taktik (haftalık) — kural tabanlı:**
  - Mağaza fiyatı = maliyet + hedef marj; stok birikirse düşer, raf boşalırsa artar, rakip fiyatına doğru çekilir.
  - Borsa: girdi stoğu hedefin altındaysa alış, çıktı fazlaysa satış emri.
  - İşgücü: kapasite kullanımına göre işe alma/çıkarma.
- **Operasyonel (tick):** Lojistik sisteminin dinamik sevkiyatı (bkz. `logistics.md`).
- **Ar-Ge ve reklam:** Kişiliğe bağlı bütçe yüzdesi.

### Ölçek kuralları
NPC şirketler de kademe, yönetim puanı ve yönetici kurallarına tabidir (bkz. `company_management.md`).

### Kişilik
Risk iştahı, kalite/fiyat odağı, genişleme hızı.

### Bilgi ve kurallar (K19)
AI oyuncuyla aynı kurallara tabi, sınırlı bilgiyle çalışır. Görür: kendi verileri, tüm şehir borsa fiyat ve hacimleri, kendi mağazalarının kapsama alanındaki rakip fiyatları. Görmez: rakip maliyet ve stokları.

### Yaşam döngüsü (K18)
- **İflas:** Nakit belirli süre negatif kalırsa şirket batar; tesis ve araçlar indirimli satılık listesine düşer, stoklar borsaya boşaltılır.
- **Yeni girişim:** Aylık sektör kârlılığı kontrolü; marj yüksek ve rekabet azsa o sektör/bölgede yeni şirket doğar.
- **Başlangıç sermayesi:** Hane birikimlerinden beslenen yatırım havuzu (varsayım; para dengesi `observation.md`'de izlenir).

## Açık Sorular

- İflas süresi, girişim eşikleri, utility ağırlıkları.

## Tartışma Notları

- [2026-10-29] Şirket AI modeli kuruldu (K18, K19). Her ikisi kullanıcının isteğiyle Claude tarafından seçildi; satın alma/birleşme ileriye park edildi.
