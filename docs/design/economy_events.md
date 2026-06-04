# Economy Event System Reference

Bu dosya MVP'den çıkarılan event sisteminin tasarım referansını tutar. Event sistemi şu an aktif tasarım kapsamı değildir; ileride geri gelirse buradaki notlar başlangıç noktası olarak kullanılabilir.

## Event Sistemi - Ertelenmiş (Referans)

Event sistemi MVP kapsamından çıkarıldı. Temel ekonomi otururken gereksiz karmaşıklık katıyordu; piyasa dinamizmi stok değişimi + NPC hareketleri + mevsim çarpanlarıyla zaten sağlanıyor.

**Mevcut tasarım (koddan kaldırılacak):**

| Event | Etki Alanı | Fiyat | Üretim | Tüketim |
|-------|------------|-------|--------|---------|
| Festival | Comfort: wine, sword, grapes vb. | x1.6 | x1.0 | x2.0 |
| Famine | Survival: wheat, bread vb. | x3.0 | x0.3 | x1.5 |
| Demand Surge | Şehrin tükettiği seçili bir mal | x2.5 | x1.0 | x3.0 |
| Bumper Crop | Şehrin ürettiği seçili bir mal | x0.5 | x2.5 | x1.0 |
| Plague | Tüm mallar | x1.2 | x0.4 | x0.4 |

## Notlar

- Patrician'da event'ler saf fiyat çarpanı değil, tüketim/üretim değiştirici olarak çalışıyor; bu yön daha sağlıklı.
- Event'in anlamlı olması için oyuncunun önceden haber alıp tepki verebilmesi lazım; rastgele tetiklenip sessizce bitmemeli.
- Event + stok etkisi çakışması çözülmeli. Stok zaten 0'sa Famine x3.0 çarpanı anlamsız hale gelir.

## Açık Sorular

- Event sistemi geri gelirse oyuncuya ön haber hangi kanaldan verilecek: şehir uyarısı, rumor, kontrat, harita işareti veya market tooltip?
- Event etkileri doğrudan fiyat çarpanı olarak mı kalacak, yoksa üretim/tüketim/stok akışı üzerinden mi tasarlanacak?
- Event etkisi stok-gün fiyat eğrisiyle çakışmadan nasıl uygulanacak?

## Tartışma Notları

- [2026-06-04] Ertelenmiş event referansı ana `economy.md` dosyasından ayrıldı. Event sistemi hâlâ MVP dışı; bu dosya yalnızca ileride geri dönmek için korunuyor.
- [2026-06-02] Event sistemi MVP'den çıkarıldı. Temel dinamizm stok/NPC/mevsimden geliyor; event'ler bu aşamada gereksiz karmaşıklık. Koddan temizlenmesi için yapılacaklara eklendi.
