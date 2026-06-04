# Economy Design

Bu dosya ekonomi tasarımının giriş kapısıdır. Ayrıntılı kararlar artık konu dosyalarına ayrılmıştır; yeni ekonomi tartışmalarında önce ilgili alt dosya okunmalıdır.

## Dosya Haritası

| Dosya | Kapsam |
|-------|--------|
| [economy_market.md](economy_market.md) | Fiyat omurgası, kategori eğrileri, günlük talep, üretim/stok sınırları, quote/spread, market bilgi görünürlüğü |
| [economy_prosperity.md](economy_prosperity.md) | Demand satisfaction, şehir refahı etkileri, bolluk spirali, prosperity yatırımı, automation fixed cost ve NPC okunabilirliği |
| [economy_events.md](economy_events.md) | MVP'den çıkarılan event sistemi ve ileride geri gelirse kullanılacak referans |

## Temel Karar Özeti

- Ekonomi stok öncelikli hibrit modeldir; fiyatın ana gövdesi stok/günlük talep oranından gelir.
- Üretim, tüketim, mevsim ve NPC trader etkileri mümkün oldukça doğrudan fiyat çarpanı yerine stok akışı veya günlük talep üzerinden çalışır.
- Oyuncu market referans fiyatıyla değil, alışta +%8 ve satışta -%8 spread uygulanmış quote ile işlem yapar.
- Faction reputation ve prosperity market referans fiyatını değil, oyuncuya verilen quote'u etkiler.
- Toplu işlemler marginal pricing kullanır; her birim güncel stok durumuna göre fiyatlanır.
- Daily tick'te önce şehir üretim/tüketim simülasyonu, sonra Trading Post, Caravan Master ve NPC trader işlemleri çalışır.
- Şehir sağlığı için günlük demand satisfaction izlenir; survival eksikliği en sert şehir etkisini üretir.
- Prosperity yükseldikçe şehir ihtiyaç seviyesi de artacak; refah risksiz pasif satış bonusuna dönüşmeyecek.
- Event sistemi MVP kapsamından çıkarılmıştır; temel dinamizm stok, NPC hareketi ve mevsimden gelir.

## Açık Sorular

Açık ekonomi soruları artık konu dosyalarına dağılmıştır:

- Şehir ekonomik kimlikleri, stok kapasitesi davranışı, demand tag MVP kalibrasyonu ve yerel fiyat referansları: [economy_market.md](economy_market.md)
- Günlük prosperity clamp, prosperity ihtiyaç bandı, geç oyun para yakıcıları, automation fixed cost ve NPC trader okunabilirliği: [economy_prosperity.md](economy_prosperity.md)
- Event sistemi ileride geri gelirse ön haber, stok çakışması ve üretim/tüketim etkileri: [economy_events.md](economy_events.md)

## Tartışma Notları

- [2026-06-04] Uzayan ekonomi dokümanı üç parçaya ayrıldı. Ana dosya giriş kapısı olarak bırakıldı; fiyat/pazar kararları `economy_market.md`, prosperity ve bolluk spirali kararları `economy_prosperity.md`, ertelenmiş event referansı `economy_events.md` dosyasına taşındı. Bilgi kaybı olmaması için açık soru, gerilim ve tartışma notları ilgili konu dosyalarına dağıtıldı.
