# Ar-Ge

## Karar verilmiş

### Yapı
- **Seviyeler (sürekli):** Şirketin her ürün ve çıkarım türü için 0–100 teknoloji seviyesi; azalan getiri. Kaliteye etki `goods.md`'de.
- **Kilit ağacı (K30):** Yeni ürünler, yeni araç modelleri, tesis verimliliği, yeni tesis tipleri.
- Yeni ürünler dünyaya araştırmayla girer; icat edilince hanelerde yeni ihtiyaç veya mevcut bara daha güçlü dolum doğar → uzun vadeli dinamizm motoru.

### Yayılım (K31)
- Kilitler patentli: ilk bulan belirli süre (örn. 5 oyun yılı) tek kullanır; süre dolunca diğerleri çok daha ucuza araştırır.
- Seviyeler her zaman şirkete özel, ama yetişme bonusu var: sektör liderinin altındaki şirket daha ucuz ilerler.

### Kaynak
- Ar-Ge tesisi: Mühendis çalıştıran ayrı tesis tipi; kurulduğu şehir mühendis maaşı ve bulunabilirliğini etkiler.
- Mühendis-ay + para tüketir; AI bütçeyi kişiliğine göre ayırır.

### Proje bazlı araştırma (K75) — Capitalism referansı
- **Ar-Ge tesisi** (K61 kabuğu) içinde 1–9 **laboratuvar birimi**; her laboratuvar Mühendis ister (K63 darboğazı).
- Bir tesis aynı anda bir proje yürütür: hedef (ürün/çıkarım seviyesi ya da kilit) + süre.
- `Seviye kazancı = f(süre) × g(laboratuvar) × deneyim × yetişme bonusu × (1 − mevcut seviye / 120)`
  - `f(süre)`: 6 ay → 1, 1 yıl → 3, 2 yıl → 7, 5 yıl → 20 seviye (uzun proje birim zamanda daha verimli)
  - `g(laboratuvar)`: 1 → %100, 2 → %170, 5 → %350, 9 → %480
  - Yetişme bonusu: lider seviyesinin altındaysa ek çarpan (K31)
- Kazanç proje bitince toplu gelir; erken iptalde harcama kaybolur.
- **Kilit projeleri:** ön koşul (örn. ilgili seviye ≥ 40) + sabit süre/maliyet; bitince kilit açılır, patent başlar (K31).
- Bu bölüm yukarıdaki "Kaynak: mühendis-ay + para" maddesinin işleyişini tanımlar.

### Belirsizlik (K76)
- Seviye kazancı tahminin %70–130'u (seed'li RNG, K27).
- Kilit projeleri kesin, süre ±%20.

### Aşama 1 kilit ağacı
- **Yeni ürünler:** Makarna (un → makarna; ikinci gıda, ikame ve gıda çeşitliliği); Buzdolabı (çelik → buzdolabı; sahibi hanede ev stoku gıdası yavaş bozulur); Kombi (çelik → kombi; ısınma için daha az yakıt)
- **Araç modelleri:** büyük kamyon, soğutmalı kamyon, hızlı yük treni, soğutmalı vagon
- **Tesis verimliliği:** Otomasyon I–II (İşçi −%20 / −%35, Teknisyen ihtiyacı artar); Emisyon filtresi (kirlilik −%40); Kestirimci bakım (yıpranma −%30); Yakıt verimliliği (araç yakıtı −%15)
- **Yeni tesis tipleri:** soğuk hava deposu, otomatik depo, rafineri II

### AI
Ar-Ge projeleri K70 skorlayıcısında aday olur. Ek kâr = beklenen kalite artışının fiyat primi × satış hacmi, veya verimlilik kilidinin maliyet tasarrufu; yeni ürünlerde talep şehir istatistiklerinden tahmin edilir.

## Açık Sorular

- Proje maliyetleri, kilit ön koşulları ve süreleri, patent süresi, yetişme bonusu çarpanı.

## Tartışma Notları

- [2026-10-29] Ar-Ge modeli kuruldu (K30, K31).
- [2026-10-29] Ar-Ge proje bazlı modele (Capitalism) geçti; sapmalı sonuç ve Aşama 1 kilit ağacı belirlendi (K75, K76).
