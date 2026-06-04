# Contracts Design

## MVP Kapsamı

MVP'de kontrat sistemi minimal olacak:

- Sadece Delivery kontrat tipi.
- Tek kontrat tier'ı.
- A kasabasından B kasabasına belirli mal taşıma.
- Basit deadline.
- Ödül: gold + faction rep.
- Her şehirde 1-2 available kontrat.
- Fail davranışı: oyuncu ödülden mahrum kalır ve küçük faction rep cezası alır.

MVP'de sade/opsiyonel:

- Fail cezasının kesin sayısı balance aşamasında belirlenebilir.
- Fail olunca küçük rep cezası veya sadece ödülden mahrum kalma kullanılabilir.

MVP dışı:

- Procurement kontratları.
- Urgent kontratlar.
- Tier çeşitliliğinin tam balance'ı.
- Özel şehir yardım kontratları.
- Rival faction kontratları.
- Production chain / özel sipariş kontratları.

Aşağıdaki mevcut durum tam sistem notlarını içerir; MVP implementasyonu için bu kapsam önceliklidir.

## Mevcut Durum (Karar verilmiş)

- 2 tip: Delivery (A kasabasından B'ye taşı) ve Procurement (B'ye getir, nereden bulursan bul).
- 3 tier: Basic, Standard, Urgent.
- Urgent sadece Guild Master+ için açık.
- Her kasabada her zaman 2 adet available kontrat bulunuyor.
- Kontrat kabul edildikten sonra deadline başlıyor (available haldeyken süre işlemiyor).
- Deadline geçerse kontrat fail →faksiyon rep cezası (-1.0).
- Ödüller: gold, faction rep.
- Guild Master bonusu: kontrat rep ödülü ×1.5.

**Tier farkları:**

| Tier | Min deadline | Gold çarpanı | Rep çarpanı |
|------|-------------|-------------|-------------|
| Basic | 10 gün | ×1.0 | ×1.0 |
| Standard | 8 gün | ×1.35 | ×1.5 |
| Urgent | 6 gün | ×1.8 | ×2.0 |

Gold ödülü: `(base_price × qty × 1.35 + 12) × mesafe_bonusu × tier_çarpanı`
- Aynı kasabada teslimat: mesafe bonusu ×1.0
- Farklı kasabada: ×1.25

## Açık Sorular

**Kontrat çeşitliliği**
Şu an yalnızca delivery ve procurement var. Başka kontrat tipleri planlanıyor mu?
- Örnek: "Bufaksiyon'a karşı çalış" (rival'a mal satma, ceza öde)
- Örnek: "Kasabayı bes" (X günde Y birim survival malı ulaştır)
- Örnek: "Özel sipariş" (işleme ürünü, recipe mantığıyla bağlantılı)

**Kontrat miktarları dengeli mi?**
Quantity, caravan kapasitesinin %45'ini geçemiyor. Bu erken oyunda mantıklı ama Small Caravan (50 birim) olan oyuncu için urgent kontrat maksimum ~22 birim. Tier farkı bu boyutta anlamlı mı?

**Procurement kontratın zorluk algısı**
Procurement kontratta oyuncu hedef kasabaya gidip malı bulmak zorunda — bu aslında delivery'den daha fazla seyahat gerektirebilir. Ödül farkı bu ek yükü karşılıyor mu?

## Gerilimler

**Failure penalty hafif kalabilir**
-1.0 faction rep cezası oldukça düşük. Özellikle geç oyunda faction rep yüksekken bu ceza neredeyse fark edilmiyor. Kontrat fail etmek riski yok gibi hissettiriyor — ödülden mahrum kalmak zaten yeterli bir ceza mı?

**faksiyon rep = hem trade bonusu hem progression koşulu**
Kontrat yapmakfaksiyon rep kazandırıyor. Bu rep hem ticaret avantajına hem rank atlamaya yarıyor. Çok verimli bir döngü — kontrat sistemi progression'ın ana motoru haline geliyor. Bu tasarım hedefi mi, yoksa al-satın da eşit ağırlıkta olması mı isteniyor?

## Tartışma Notları

- [2026-06-04] NPC relation kaldırma kararıyla kontrat ödüllerinden NPC relation çıkarıldı. Kontratların ilişki etkisi faction rep üzerinden kalacak.
- [2026-06-04] MVP kontrat kapsamı netleşti. MVP'de yalnızca tek tier Delivery kontratları olacak; Procurement/Urgent ve tier balance MVP dışı kalacak. Kontrat fail davranışı ödülden mahrum kalma + küçük faction rep cezası olacak.
