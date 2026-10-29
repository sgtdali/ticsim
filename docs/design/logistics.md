# Lojistik ve Yol Bulma

## Karar verilmiş

### Altyapı (K20, K21)
- Harita kamu ağıyla doğar: şehirlerarası karayolu, büyük şehirler arası ray omurgası, kıyı şehirlerinde limanlar, büyük şehirlerde havalimanları.
- Şirketler (NPC ve oyuncu) bağlantı yolu, istasyon, iskele, terminal ve özel hat kurar.
- Kamu altyapısı ücretli (otoyol, ray kullanımı, liman/havalimanı terminal ücreti); özel altyapı pahalı kurulur, kullanımı ücretsiz → kirala ya da inşa et kararı.

### Tıkanıklık (K22)
Her yol/hat kesiminin ve terminalin kapasitesi var; doluluk arttıkça hız düşer, terminallerde kuyruk oluşur. Sinyal/kavşak simülasyonu yok.

### Yol bulma
Grid inşa ve görselleştirme içindir. Altyapıdan ağ grafiği türetilir (kavşak/terminal = düğüm, kesim = kenar). A* grafikte çalışır, rotalar önbelleğe alınır, tıkanıklık kenar maliyetini periyodik günceller.

### Sevkiyat (K23)
- **Taşıma işi:** mal, adet, A → B, son tarih.
- **Planlayıcı:** İşi en uygun mod kombinasyonuna böler (örn. kamyon → tren → kamyon); her bacak alt iş olur. Aktarma terminallerinde depolama ve bozulma işler.
- **Araç:** Depoya/terminale bağlı; tip, kargo sınıfı, kapasite, hız, yakıt tüketimi, ömür/bakım; Sürücü gerektirir. Boştaki en yakın uygun araç bacağı alır.
- **Maliyet:** yakıt + sürücü maaşı + kamu ücretleri + bakım.

## Gerilimler

- Dinamik sevkiyat oyuncu için "kur ve unut" riski; oyuncu katmanında sabit hat ve öncelik kontrolleriyle dengelenecek (park).

## Tartışma Notları

- [2026-10-29] Lojistik modeli kuruldu (K20–K23). K23 kullanıcının isteğiyle Claude tarafından seçildi.
