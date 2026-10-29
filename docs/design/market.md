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

- **Girdi maliyeti (K37):** `w × stok ortalaması + (1 − w) × yerine koyma maliyeti`. Yerine koyma = en yakın borsanın son işlem fiyatı + tahmini taşıma. w kişilikten (temkinli düşük, agresif yüksek).
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

## Açık Sorular

- Komisyon ve depolama ücreti oranları.
- Fiyat parametreleri: α, e, u, w, k, m, adım büyüklükleri, hedef stok günleri (headless koşularla ayarlanacak).

## Gerilimler

- K15 nihai mal pazarına girişi pahalılaştırır; NPC girişim oranı izlenmeli.

## Tartışma Notları

- [2026-10-29] Piyasa modeli kuruldu (K14–K17). K17 kullanıcının isteğiyle Claude tarafından seçildi.
- [2026-10-29] Perakende fiyat oluşumu formül ve parametre düzeyinde tasarlandı (K33–K39). K33 kullanıcının isteğiyle Claude tarafından seçildi.
