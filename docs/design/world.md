# World Design

## Mevcut Durum (Karar verilmiş)

- 3 kasaba, hardcode: Ashford (kuzey-batı), Ironmere (doğu), Stonebridge (güney-orta).
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

## Açık Sorular

**Daha fazla kasaba planlanıyor mu?**
Şu an 3 kasaba ekonomik çeşitliliği sınırlandırıyor: oyuncu rotayı hızlı ezberliyor, NPC trader'ların stratejisi kısıtlı. 4-5 kasabaya çıkmak oyun dinamiğini önemli ölçüde değiştirir. Bu bir yol haritası hedefi mi?

**RoadData ne yapıyor?**
`scripts/systems/RoadData.gd` ve `scripts/tools/RoadDataExporter.gd` mevcut. Rotalar belirli güzergahları mı zorluyor, yoksa şu an sadece görsel mi? Seyahat süresi doğrudan `distance / 200` formülüyle hesaplanıyor — road sistemi bunu override ediyor mu?

**Kasaba büyümesi / şehir statüsü**
Nüfus ve prosperity büyüyebiliyor. Bir kasaba çok büyüdüğünde farklı bir şey olacak mı? Yeni slot açılması, yenifaksiyon ilişkileri, yeni ürünler gibi.

**Harita genişliği ve görünürlük**
Harita 2688×1536 oldukça büyük. 3 kasabayla bu alan çok boş kalıyor. Daha fazla kasaba eklenmezse haritanın boyutu küçülmeli mi, yoksa boşluk kasıtlı mı (ileride içerik eklemek için)?

## Tartışma Notları

*(Boş)*
