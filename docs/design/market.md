# Piyasa ve Fiyat Oluşumu

## Karar verilmiş

Kalite + marka nedeniyle tek şehir fiyatı yok; satıcılar fiyatı kendileri koyar.

### B2C — Mağazalar (K14, K15)
- Şirket satmak istediği şehirde mağaza kurar (ticari şehir karosu).
- Kapsama yarıçapı; hane erişebildiği mağazalar arasından fiyat, kalite, marka ve mesafeye göre seçer.
- Sınırlı raf; her raf bir ürün kategorisi. Yakıt istasyonu ayrı mağaza tipi olabilir.
- Mağaza işgücü ister (İşçi), stoku lojistikle beslenir.
- **Sadece şirketin kendi ürettiği mal satılır.** Nihai mal üreticisi aynı zamanda perakendecidir; sadece perakende yapan şirket modeli yok.

### Perakende fiyat oluşumu — alıcı tarafı (K33–K36)

Her hane, erişebildiği her ürün için:

- `R = Referans × Gelir çarpanı × Aciliyet × Kalite çarpanı × (1 + Marka primi)` (bütçeyle sınırlı)
- `Net fayda = R − Etkin fiyat`
- Net faydası en yüksek ürünü alır; net fayda negatifse almaz ve bekler.

| Parametre | Tanım |
|---|---|
| Referans fiyat (K34) | Hanenin kendi alımlarının hareketli ortalaması: `Ref = Ref × (1 − α) + Ödenen × α`. α ürüne özel uyum hızı (sık alınan malda hızlı, dayanıklıda yavaş). Hiç alınmamışsa şehir ortalama satış fiyatıyla başlar. Mağazada görülen fiyatlar da referansı zayıf şekilde etkiler. |
| Gelir çarpanı | `(hane geliri / şehir medyan geliri)^e`; e ürüne özel gelir esnekliği |
| Aciliyet | `1 + u × (1 − bar/100)²`; u zorunlu mallarda (beslenme, ısınma) yüksek |
| Kalite çarpanı | Ürün kalitesi / hanenin beklediği kalite (beklenti gelire bağlı) |
| Marka primi | Marka değeri × hanenin marka duyarlılığı (gelire bağlı) |
| Bütçe | Bu ayın gelir payı + birikimden çekme limiti |

- **Rezervasyon fiyatı (K33):** Fiyat R'yi aşarsa hane almaz; bar düştükçe aciliyet ve R yükselir. İkame ayrı sistem değil: bir barı birden fazla mal doldurduğunda skor seçimiyle kendiliğinden oluşur.
- **Ev stoku (K35):** Sadece tüketim mallarında. Ürüne özel hedef stok günü (ekmek ~2, yakıt ~30). `Alım = hedef stok − mevcut`; fiyat referansın altındaysa hedef büyür, üstündeyse küçülür. Kış yaklaştıkça yakıt hedefi artar. Ev stoku bozulur.
- **Mesafe = gerçek maliyet (K36):** Yol süresi şehir yol ağı + tıkanıklıkla hesaplanır. `Yol maliyeti = yakıt (ev stokundan) + zaman × hanenin saatlik gelir değeri`. `Etkin fiyat = raf fiyatı + yol maliyeti / alınan adet`. Yakın ticari karolar alışveriş bölgesi sayılır; tek yolculukta bölgedeki tüm mağazalar gezilir. Alışveriş yolculukları araç olarak simüle edilmez, bölge bazında toplu yük olarak yol ağına eklenir.

### Perakende fiyat oluşumu — satıcı tarafı (K37–K39)

`Fiyat = Birim maliyet × (1 + Öğrenilmiş marj) × Stok çarpanı × Bozulma çarpanı`, değişim sınırı ve taban/tavanla kırpılır.

- **Girdi maliyeti (K82 — K37'nin sadeleştirilmiş hali):** yerine koyma maliyeti = en yakın borsanın son işlem fiyatı + tahmini taşıma.
- **Birim maliyet (K38):** `Girdi + değişken giderler + sabit giderler / (kapasite × 0,8)`. Düşük kullanım fiyata yansımaz; "atıl kapasite zararı" olarak kayda geçer ve stratejik katmana küçültme/satış/kapatma sinyali gönderir.
- **Marj (K39):** `Baz marj = kişilik marjı + k × (kendi kalite − rakip ort. kalite) + m × marka farkı`. Her şehir × ürün için haftalık deneme: marj küçük adımla oynatılır, kâr arttıysa aynı yönde devam, azaldıysa geri dönüp adım küçülür; küçük rastgele denemeler; kişiliğe bağlı alt-üst sınır.
- **Stok çarpanı:** Raf stoku hedefin çok üstündeyse geçici indirim, boşalmak üzereyse geçici artış; öğrenilen marjı bozmaz.
- **Bozulma çarpanı:** Kalitesi eşiğe yaklaşan bozulabilir mallarda kademeli indirim.
- **Değişim sınırı:** Haftalık en fazla %5–15 (kişiliğe bağlı).
- **Taban/tavan:** Normalde birim maliyetin altına satılmaz (nakit krizinde kırılabilir); fiilî tavan ithalat fiyatı.

### B2B — Şehir borsaları (K16, K17)
- Her şehirde fiziksel spot borsa.
- Satıcı malı borsa deposuna fiziksel olarak teslim eder, sonra satış emri verir (adet, kalite, min. fiyat).
- Alıcı alış emri verir (adet, min. kalite, max. fiyat). Kalite eşiğini karşılayan en ucuz satış emri önce eşleşir. Alıcı malı borsadan kendi taşır.
- Borsa deposu tüm kargo sınıflarını uygun tutar; günlük depolama ücreti alır.
- İşlem başına komisyon (para dreni).
- Şehirler arası fiyat farkı > taşıma maliyeti ise arbitraj kendiliğinden oluşur.

### Borsa fiyat oluşumu (K40–K43)

- **Günlük toplu eşleşme (K40):** Günde bir kez tüm emirler toplanır. Her olası fiyatta satışa hazır ve almaya hazır miktar hesaplanır; en çok işlemin gerçekleştiği fiyat **günün fiyatı** olur ve tüm işlemler bu fiyattan yapılır. Talep arzdan fazlaysa yüksek teklif önce alır (fazla arzda düşük satış önce satar). Eşitlikte önce eski emir, sonra şirket ID'si. Emir ömrü ~7 gün. Her gün mal × sınıf başına günün fiyatı ve hacmi kaydedilir.
- **Kalite sınıfları (K41):** C (0–39), B (40–59), A (60–79), Premium (80–100). Her sınıfın ayrı emir defteri ve günlük fiyatı var. Parti gerçek kalitesini korur (K4 formülünde kullanılır); sınıf sadece fiyatlama içindir. Alış emri tek bir sınıfa verilir.
- **Satış emri (K42):** `max(Taban, Günün fiyatı × (1 + s))`. `s = −σ × (stok günü − hedef stok günü) / hedef stok günü`, %−10 ile %+5 arası. Taban = birim maliyet (K38); nakit krizinde kırılabilir. Günün fiyatı yoksa `birim maliyet × (1 + kişilik marjı)`. σ kişilikten.
- **Alış emri (K43):** `min(Türetilmiş değer, Günün fiyatı × (1 + a))`.
  - Türetilmiş değer = `(çıktı satış fiyatı − diğer maliyetler) × (1 − min. marj)`, girdi birimi başına; çok girdili reçetelerde maliyet payına göre bölünür.
  - `a = β × (hedef stok günü − mevcut stok günü) / hedef stok günü`, 0 ile %+20 arası.
  - Kritik stokta min. marj geçici olarak sıfıra iner.
  - Miktar = `hedef stok − (depo + yolda + açık emirler)`.
  - Borsa seçimi: `günün fiyatı + fabrikaya taşıma` en düşük şehir.
  - Sınıf seçimi: kişiliğin kalite odağına göre hedef çıktı kalitesine ulaştıran en ucuz sınıf.
- **Fiyat zinciri:** Talep zincirin sonundan başına (hane → perakende → türetilmiş değer → girdi teklifleri), maliyet başından sonuna akar; her kademede borsada buluşur.

## Açık Sorular

- Komisyon ve depolama ücreti oranları.
- Fiyat parametreleri: α, e, u, k, m, σ, β, adım büyüklükleri, hedef stok günleri (headless koşularla ayarlanacak).

## Gerilimler

- K15 nihai mal pazarına girişi pahalılaştırır; NPC girişim oranı izlenmeli.

## Tartışma Notları

- [2026-10-29] Piyasa modeli kuruldu (K14–K17). K17 kullanıcının isteğiyle Claude tarafından seçildi.
- [2026-10-29] Perakende fiyat oluşumu formül ve parametre düzeyinde tasarlandı (K33–K39). K33 kullanıcının isteğiyle Claude tarafından seçildi.
- [2026-10-29] Borsa fiyat oluşumu formül düzeyinde tasarlandı (K40–K43).
- [2026-10-30] K52 sözgeci: girdi maliyeti tek kurala indirildi (K82).
