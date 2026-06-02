# Factions & NPC Design

## Mevcut Durum (Karar verilmiş)

2 faksiyon, 3 kasaba, 3 NPC:

| Faksiyon | Kasaba | NPC |
|------|--------|-----|
| Northern Kingdom | Ashford | Aldric (Mayor) |
| Merchants Guild | Ironmere, Stonebridge | Mira (Ironmere), Torben (Stonebridge) |

**Thieves Brotherhood kaldırıldı.** Agent tarafından eklenmiş, tasarımda yeri yoktu — kasabası yok, NPC'si yok, etkileşim mekanizması hiç tanımlanmamış. Koddan da temizlenmesi gerekiyor (bkz. Yapılacaklar).

**Rep mekanik etkileri:**
- Alım maliyeti: her +1 rep → -%0.1 spread indirim (maks fayda rep 80'de platoya giriyor).
- Satış geliri: rep bonusu satış çarpanına ekleniyor.
- Rival penalty: bir faksiyon ile ticaret yaptığında, onun negatif ilişkili faksiyonun rep'i -%30 oranında düşüyor.
- Tax rate: rep'e bağlı hesaplanıyor (formül var) ama şu an gerçek al-sat fiyatını etkilemiyor — spread üzerinden zaten etkisi var, bunun üstüne ayrı bir vergi yok.
- **Rep artık rank koşulu değildir.** Rep yalnızca alım/satım spread bonusu olarak işlev görür. Rank sistemi gold + şehir prosperity koşullarına bağlıdır.

**NPC relation:**
- Kontrat tamamlandığında ilgili NPC ile relation artıyor.
- Şu an relation hiçbir sistem tarafından okunmuyor/kullanılmıyor.

## Açık Sorular

**NPC relation ne işe yarayacak?**
Değer birikiyor ama oyunda kullanılmıyor. Olası tasarımlar:
- Belirli NPC relation eşiğinde özel kontratlar açılıyor
- Yüksek relation ile o faksiyonda ekstra indirim
- Özel diyalog/event tetikleyici
- Bilgi: o faksiyonun bir sonraki olayını önceden haber veriyor

## Gerilimler

**Merchants Guild iki kasabada**
Ironmere ve Stonebridge ikisi de Merchants Guild faksiyonu. Bu iki kasabayla ticaret, tek faksiyonun reputasyonunu artırıyor. Northern Kingdom sadece Ashford'da. Rep artık rank kapısı olmadığı için bu asimetri daha az kritik — ancak rep bonusu optimizasyonu açısından Merchants Guild hâlâ çok daha kolay kazanılıyor.

## Tartışma Notları

- [2026-06-02] Thieves Brotherhood kaldırılmasına karar verildi. Agent tarafından eklenmiş, hiçbir tasarım temeli yok. Koddan temizlenmesi için yapılacaklara eklendi.
- [2026-06-02] Rep rank koşulu kaldırıldı. Rank sistemi artık gold + şehir prosperity bazlı çalışıyor. Rep yalnızca spread bonusu olarak kalıyor. Bkz. `progression.md`.
