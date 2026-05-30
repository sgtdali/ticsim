# Design Mode — Agent Kılavuzu

Bu dosya, tasarım modu aktifken ajanın nasıl davranması gerektiğini tanımlar.

---

## Tasarım Modunun Amacı

Tasarım modu, oyunun kodlamadan bağımsız kararlarını tartışmak, kayıt altına almak ve düzenlemek içindir. Bu modda:

- Kod yazılmaz, dosya değiştirilmez (design dosyaları hariç).
- Kullanıcı fikirlerini, sorularını ve kararlarını ajanla konuşarak netleştirir.
- Ajan dinler, analiz eder, seçenekler sunar, gerilimler ve riskler konusunda uyarır.
- Tartışma sonunda ajan ilgili design dosyasını günceller.

---

## Tasarım Modu Davranış Kuralları

### 1. Konuya Girmeden Önce

Bir tasarım konusu açıldığında, ilk adım olarak ilgili `docs/design/*.md` dosyasını oku.

- Mevcut kararları özetle: "Şu an şöyle bir kararımız var..."
- Açık soruları özetle: "Bu konuda şu soru hâlâ yanıtsız..."
- Gerilim veya çelişki varsa işaret et: "Bu fikirle şu mevcut kararın arasında şöyle bir çatışma var..."

Bunu kısa tut — kullanıcı zaten bağlamı biliyor. Amaç tartışmaya girmeden önce aynı sayfada olmak.

### 2. Tartışma Sırasında

- Kullanıcı bir fikir önerirse: avantajları, dezavantajları ve mevcut sistemlerle çatışmaları söyle.
- Tek cevap vermek yerine alternatifler sun: "A seçeneği şunu sağlar, B seçeneği şunu."
- Oyunun geneline etkisini değerlendir: "Bu karar kontrat sistemini de etkiler, çünkü..."
- Eğer bir karar açık bir sorunu çözüyorsa bunu teyit et.
- Eğer bir karar yeni bir sorun yaratıyorsa hemen söyle.
- Kullanıcı kararsızsa iki-üç seçenek sun ve hangisini önerdiğini belirt, nedenini açıkla.
- Hiçbir zaman "ne istiyorsanız yapın" deme — analizini her zaman sun.

### 3. Kararlar Netleşince

Kullanıcı bir konuda net karar verdiğinde veya tartışma doğal olarak kapandığında, ajanın ilgili dosyayı güncellemesi gerekir. Güncelleme şablonu:

**Karar verildiyse:**
- Dosyanın "Karar verilmiş" bölümüne ekle veya mevcut satırı düzelt.
- Eğer bu karar bir açık soruyu yanıtladıysa, o soruyu dosyadan ve `_index.md`'den kaldır.

**Fikir veya olasılık tartışıldıysa ama karar verilmediyse:**
- Açık soru olarak koru veya yenisini ekle.

**Gerilim veya çelişki keşfedildiyse:**
- İlgili dosyanın "Gerilimler" bölümüne ekle.
- `_index.md`'deki "Çelişkiler" bölümünü de güncelle.

**Tartışma özeti:**
- Dosyanın "Tartışma Notları" bölümüne tarihi ve kısa özeti ekle.
- Örnek format: `[2026-05-31] Famine eventi fiyat çarpanı x3.0'dan x2.5'e düşürüldü. Gerekçe: x3.0 oyuncuyu kasabada kilitlemeye zorluyor.`

### 4. Güncellemeler Hakkında

- Güncellemeyi tartışma bitmeden yapma — konuşma akarken dosyayı düzenleme.
- Karar netleşince "kaydediyorum" de ve güncelle.
- Birden fazla konu tartışıldıysa her biri için ayrı güncelleme yap.
- `_index.md` her zaman güncel kalsın: yanıtlanan sorular silinsin, yeni sorular eklensin.

---

## Design Dosyaları Referansı

| Dosya | Ne zaman okunur |
|-------|-----------------|
| `_index.md` | Her tasarım oturumu başında — açık sorulara ve çelişkilere bak |
| `economy.md` | Fiyat, üretim, tüketim, piyasa dengesi, mevsimler |
| `progression.md` | Rank gereksinimleri, unlock kapıları, oyun ritmi |
| `factions.md` | Faksiyon sistemi, NPC ilişkileri, reputasyon mekaniği |
| `world.md` | Kasabalar, harita, seyahat, dünya büyümesi |
| `contracts.md` | Kontrat tipleri, tier dengesi, ödül tasarımı |
| `trading_post.md` | Trading Post otomasyonu, Caravan Master sistemi |
| `ux.md` | Oyuncu akışı, bilgi sunumu, UI kararları |

---

## Tasarım Modunda Yapılmayanlar

- Kod yazmak veya değiştirmek (`docs/design/` dışında).
- `docs/mechanics.md` veya `docs/architecture.md` güncellemek (bu belgeler kodla senkronize olmalı, tasarım tartışmasıyla değil).
- Henüz tartışılmamış konuları "karar verildi" olarak işaretlemek.
- Kullanıcının açık bir kararı olmaksızın belirsiz fikirleri kesin karar gibi kaydetmek.
