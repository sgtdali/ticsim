# World Design

## Mevcut Durum (Karar verilmiş)

- 3 kasaba, hardcode: Ashford (kuzey-batı), Ironmere (doğu), Stonebridge (güney-orta).
- MVP 3 kasabayla tamamlanacak.
- İlk tam ekonomi hedefi en az 6 kasabadır.
- Uzun vadeli ideal şehir/kasaba ağı 8-10 kasabadır.
- Harita ve ekonomi mimarisi bu genişlemeye uygun korunmalıdır; 3 kasabalı MVP nihai dünya ölçeği değildir.
- Harita 2688×1536 piksel.
- Kasabalar arası mesafe sabit (Vector2 pozisyonlardan hesaplanıyor).
- Seyahat hızı: 200 harita birimi/gün.
- Tahmini günlük seyahat süreleri:
  - Ashford ↔ Ironmere: ~8 gün
  - Ashford ↔ Stonebridge: ~7 gün
  - Ironmere ↔ Stonebridge: ~7 gün
- Oyuncu haritada fiziksel olarak hareket ediyor (seyahat animasyonu var).
- RoadData sistemi mevcut ama şu an rotaları etkileyip etkilemediği net değil.

## Kasaba Özellikleri (Karar verilmiş)

| Kasaba |faksiyon | Başlangıç uzmanlığı | Slot yapısı |
|--------|------|----------------------|-------------|
| Ashford | Northern Kingdom | Wheat, wood, bread | 8 farm (3 dolu), 0 mine |
| Ironmere | Merchants Guild | Iron ore, iron bar, swords | 2 farm (1 dolu), 6 mine (3 dolu) |
| Stonebridge | Merchants Guild | Grapes, wine, must | 3 farm (2 dolu), 1 mine |

## Seyahat Riski (Karar verilmiş)

- Mevcut basit seyahat riski MVP'de olduğu gibi korunur: base route risk + cargo + faction rep etkisi, harita tooltip'inde risk yüzdesi ve saldırı sonrası kayıp popup'ı.
- Seyahat riskinin bir **karar katmanına** dönüştürülmesi MVP dışıdır. Bu kapsama girenler: route planlamasında risk/kâr trade-off'u, Caravan Master courage statının riske anlamlı etkisi, eskort veya önlem kararları.
- Bu derinleştirme silinmemiştir; post-MVP tasarım notu olarak korunur. Referans his Patrician III'teki "kargo alanı mı, silah mı" kararıdır.
- Post-MVP uygulanırken Patrician IV'ün geç oyunda korsan spam'iyle oyunu işletilemez hale getirme hatasından kaçınılmalıdır: saldırı frekansı düşük tutulmalı, risk taciz değil karar yaratmalıdır.

## Açık Sorular

**RoadData ne yapıyor?**
`scripts/systems/RoadData.gd` ve `scripts/tools/RoadDataExporter.gd` mevcut. Rotalar belirli güzergahları mı zorluyor, yoksa şu an sadece görsel mi? Seyahat süresi doğrudan `distance / 200` formülüyle hesaplanıyor — road sistemi bunu override ediyor mu?

**Kasaba büyümesi / şehir statüsü**
Nüfus ve prosperity büyüyebiliyor. Bir kasaba çok büyüdüğünde farklı bir şey olacak mı? Yeni slot açılması, yenifaksiyon ilişkileri, yeni ürünler gibi.

**Harita genişliği ve görünürlük**
Harita 2688×1536 oldukça büyük. 3 kasabayla bu alan çok boş kalıyor. Daha fazla kasaba eklenmezse haritanın boyutu küçülmeli mi, yoksa boşluk kasıtlı mı (ileride içerik eklemek için)?

## Tartışma Notları

- [2026-06-10] Benchmark analizi (Patrician III/IV, Port Royale 4) sonrası seyahat riski kararı alındı. Mevcut basit risk görünürlüğü MVP'de korunacak; riskin karar katmanına dönüştürülmesi (courage trade-off'u, eskort kararları) MVP dışı bırakıldı ancak silinmedi, post-MVP notu olarak saklandı. P4'ün korsan spam hatası anti-pattern olarak not edildi.
- [2026-06-04] Kasaba sayısı vizyonu netleştirildi. Patrician serilerindeki 20+ şehirli ağ referans alındı ama scope MVP için dar tutulacak: MVP 3 kasaba, ilk tam ekonomi hedefi en az 6 kasaba, uzun vadeli ideal 8-10 kasaba. 3 kasabalı MVP'de rota ezberini kırma yükü NPC trader, mevsim, prosperity ve stok dalgalanmasına kalacak; harita/ekonomi mimarisi ileride genişlemeye uygun korunacak.
