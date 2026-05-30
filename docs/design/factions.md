# Factions & NPC Design

## Mevcut Durum (Karar verilmiş)

3 faksiyon, 3 kasaba, 3 NPC:

| Faksiyon | Kasaba | NPC | İlişkiler |
|------|--------|-----|-----------|
| Northern Kingdom | Ashford | Aldric (Mayor) | Merchants Guild ile +20, Thieves ile -60 |
| Merchants Guild | Ironmere, Stonebridge | Mira (Ironmere), Torben (Stonebridge) | Northern ile +20, Thieves ile -30 |
| Thieves Brotherhood | — (kasabası yok) | — | Her ikiyle olumsuz |

**Rep mekanik etkileri:**
- Alım maliyeti: her +1 rep → -%0.1 spread indirim (maks fayda rep 80'de platoya giriyor).
- Satış geliri: rep bonusu satış çarpanına ekleniyor.
- Rival penalty: birfaksiyon ile ticaret yaptığında, onun negatif ilişkilifaksiyon rep'i -%30 oranında düşüyor.
- Tax rate: rep'e bağlı hesaplanıyor (formül var) ama şu an gerçek al-sat fiyatını etkilemiyor — spread üzerinden zaten etkisi var, bunun üstüne ayrı bir vergi yok.
- Progression: Friendly (≥30) Trader/Merchant/Guild Master için, Allied (≥60) Patrician için gerekli.

**NPC relation:**
- Kontrat tamamlandığında ilgili NPC ile relation artıyor.
- Şu an relation hiçbir sistem tarafından okunmuyor/kullanılmıyor.

## Açık Sorular

**Thieves Brotherhood ile nasıl etkileşilecek?**
Kasabası yok, NPCsi yok. Oyuncu bufaksiyon ile rep kazanabilir mi? Kazanmalı mı? Eğer Patrician için 3 Alliedfaksiyon gerekiyorsa ve Thieves Brotherhood 3.faksiyon ise, bufaksiyon ile etkileşim mekanizması şart. Olası yollar:
- Özel "kara borsa" eventi
- Belirli kontratlar (gizli teslimat tipi)
- Haritada bandit kampına yolculuk
- Tamamen farklıfaksiyon set (Thieves gereksini kaldırıp 4.faksiyon eklemek)

**NPC relation ne işe yarayacak?**
Değer birikiyor ama oyunda kullanılmıyor. Olası tasarımlar:
- Belirli NPC relation eşiğinde özel kontratlar açılıyor
- Yüksek relation ile ofaksiyon'da ekstra indirim
- Özel diyalog/event tetikleyici
- Bilgi: ofaksiyon'ın bir sonraki olayını önceden haber veriyor

**Tax rate aktif hale getirilecek mi?**
Altyapı hazır. Spread'den bağımsız bir vergi katmanı eklemek ayrı bir etki yaratır. Şu an spread üzerinden zaten etki var — bunun üstüne vergi eklenmesi çift sayım gibi hissettirmez mi?

## Gerilimler

**Merchants Guild iki kasabada**
Ironmere ve Stonebridge ikisi de Merchants Guildfaksiyon. Bu iki kasabayla ticaret, tekfaksiyon'ın reputasyonunu artırıyor. Northern Kingdom sadece Ashford'da. Yani erken oyundan itibaren Merchants Guild rep kazanmak çok kolay, Northern Kingdom rep kazanmak için sadece Ashford var. Bufaksiyon dengesi isteniyor mu?

**Rival penalty asimetrisi**
Thieves Brotherhood hem Northern Kingdom hem Merchants Guild'le olumsuz. Oyuncu Thieves rep'i artırmak isterse diğer ikifaksiyon zarar görüyor (%30 oranında). Patrician için 3 Alliedfaksiyon gerekiyorsa ve Thieves da içindeyse bu gerilim kasıtlı bir zorluk olabilir — ama çok ağır gelebilir.

## Tartışma Notları

*(Boş)*
