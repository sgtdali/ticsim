# Şirket AI

## Karar verilmiş

### Karar katmanları
- **Stratejik (aylık) — [yerini K70/K71 aldı, aşağıda]:** Her yatırım adayı (sektör × şehir × tesis) puanlanır: beklenen marj × talep potansiyeli − işgücü maliyeti − lojistik mesafesi − rekabet. Kişilik ağırlıkları puanı büker; en yüksek puan bütçe yetiyorsa uygulanır.
- **Taktik (haftalık) — kural tabanlı:**
  - Mağaza fiyatı = maliyet + hedef marj; stok birikirse düşer, raf boşalırsa artar, rakip fiyatına doğru çekilir.
  - Borsa: girdi stoğu hedefin altındaysa alış, çıktı fazlaysa satış emri.
  - İşgücü: kapasite kullanımına göre işe alma/çıkarma.
- **Operasyonel (tick):** Lojistik sisteminin dinamik sevkiyatı (bkz. `logistics.md`).
- **Ar-Ge ve reklam:** Kişiliğe bağlı bütçe yüzdesi.

### Stratejik kararlar — formül düzeyi (K70, K71)

Yukarıdaki "utility skorlama" maddesinin yerini alır.

**Aday eylemler:** yeni tesis; mevcut tesise birim ekleme; mağaza açma; filo genişletme veya taşıma pazarına girme (K67); özel altyapı; Ar-Ge projesi; küçültme/satma/kapatma; rakibi devralma (K60).

**Değerlendirme (K70)**
- Her aday: tahmini `Ek aylık kâr`, `Yatırım` (para + yönetim puanı maliyeti, K54), `Risk` (0–1).
- `Skor = Ek aylık kâr × (1 − Risk) / Yatırım`; tersi risk düzeltilmiş geri ödeme süresi.
- Geri ödeme süresi kişiliğin yatırım ufkunun (örn. temkinli 24 ay, agresif 60 ay) altındaki adaylar arasından en yüksek skor seçilir. Bütçe = nakit + kullanılabilir kredi.
- Kapatma/satma: `Ek kâr = −(mevcut zarar)`, yatırım = 0 veya satış geliri.
- Finansman ayrı skorlanmaz: en iyi aday bütçeyi aşarsa kişiliğe göre kredi veya hisse ihracı değerlendirilir; faiz maliyeti getiriden düşülür.

**Ek kâr tahmini**
- **Arz açığı** (mal × şehir) = ithalat satış miktarı + ortalama karşılanmamış alış emirleri − rakip şantiyelerin tahmini kapasitesi × dikkat katsayısı − kendi planlanan kapasite.
- **Rakip yatırımları (K71):** şantiyeler haritada görünür; kapasite tesis boyutundan kaba tahmin edilir; dikkat katsayısı kişilikten (agresif düşük, temkinli yüksek).
- **Fiyat etkisi:** `Beklenen fiyat = günün fiyatı × (1 − ε × eklenen kapasite / pazar hacmi)`.
- `Ek kâr = min(açık, kapasite × 0,8) × (beklenen fiyat − tahmini birim maliyet) − sabit giderler`.
- Nihai mallar/mağazalar: şehrin açık istatistikleri (nüfus, medyan gelir) üzerinden kategori talebi tahmini + o şehirdeki ithalat satışları; rakip mağaza fiyatları sadece mağazası olan şehirde görülür.

**Risk:** fiyat oynaklığı (borsa geçmişi), rakip sayısı, yeni sektör (deneyimsizlik), merkezden uzaklık; kişiliğin risk iştahıyla ölçeklenir.

**Yer seçimi (şehir içi karo):** kaynak tesislerinde karo zenginliği (K5); üretim tesislerinde borsaya ve girdi kaynaklarına mesafe, işgücü erişimi (işe gidiş süresi), şehir büyüme yönü (K25).

**Ritim:** ayda bir değerlendirme, en fazla 1–2 yeni yatırım (yönetim puanı ve bütçe izin verdiğince). Krizde (negatif nakit, zarar eden birim) ara değerlendirme; küçültme/kapatma adayları öne çıkar.

**Yeni girişimler (K18)** aynı skorlayıcıyı kullanır: havuzdaki parayla en yüksek skorlu adayı finanse edecek yeni şirket doğar.

**Beklenen davranış:** ithalat satan mal yatırım çeker → birkaç şirket girerse kapasite fazlası ve fiyat düşüşü → zayıflar küçülür/batar → varlıklar ucuza el değiştirir. Ilımlı, görünür yatırım döngüsü.

### Ölçek kuralları
NPC şirketler de kademe, yönetim puanı ve yönetici kurallarına tabidir (bkz. `company_management.md`).

### Kişilik
Risk iştahı, kalite/fiyat odağı, genişleme hızı.

### Bilgi ve kurallar (K19)
AI oyuncuyla aynı kurallara tabi, sınırlı bilgiyle çalışır. Görür: kendi verileri, tüm şehir borsa fiyat ve hacimleri, kendi mağazalarının kapsama alanındaki rakip fiyatları. Görmez: rakip maliyet ve stokları.

### Yaşam döngüsü (K18)
- **İflas:** Nakit belirli süre negatif kalırsa şirket batar; tesis ve araçlar indirimli satılık listesine düşer, stoklar borsaya boşaltılır.
- **Yeni girişim:** Aylık sektör kârlılığı kontrolü; marj yüksek ve rekabet azsa o sektör/bölgede yeni şirket doğar.
- **Başlangıç sermayesi:** Hane birikimlerinden; banka kredisi ve halka arz üzerinden (bkz. `finance.md`, K81, K58, K59).
- **Devralma:** Şirketler birbirinin hissesini alıp bağlı şirket yapabilir (K60).

## Açık Sorular

- İflas süresi, girişim eşikleri, yatırım ufukları, ε, dikkat katsayıları, risk formülü ağırlıkları.

## Tartışma Notları

- [2026-10-29] Şirket AI modeli kuruldu (K18, K19). Her ikisi kullanıcının isteğiyle Claude tarafından seçildi; satın alma/birleşme ileriye park edildi (sonradan K60 ile çözüldü).
- [2026-10-29] Stratejik kararlar formül düzeyinde tasarlandı (K70, K71); arazi fiyatının olmadığı fark edildi, açık soru olarak eklendi.
