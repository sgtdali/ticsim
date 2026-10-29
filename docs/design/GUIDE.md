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

### 1.1. Karar Kontrolü Yapmadan Soru Sorma

Tasarım tartışmasında kullanıcıya soru sormadan önce ilgili design dosyasındaki mevcut kararlar mutlaka kontrol edilmelidir.

- "Karar verilmiş", "Temel Rol", "Karar" veya benzeri bölümlerde cevaplanmış bir konu tekrar açık soru gibi sorulmaz.
- Eğer konu daha önce karara bağlandıysa, önce mevcut karar hatırlatılır ve tartışma o kararın devamındaki açık noktadan sürdürülür.
- Eğer kullanıcı daha önce verilmiş bir kararı yeniden tartışmak istiyorsa, bu açıkça "mevcut kararı revize ediyoruz" şeklinde ele alınır.
- 1 soru / 1 cevap şeklinde ilerlenirken sorular yalnızca ilgili dosyadaki gerçek açık sorulardan, henüz karara bağlanmamış alt detaylardan veya yeni ortaya çıkan çatışmalardan seçilir.
- Bir sorunun cevaplanmış olup olmadığından emin olunamıyorsa, önce dosyadaki mevcut karar kısa şekilde belirtilir; sonra sadece eksik kalan nokta sorulur.

Amaç, önceki oturumlarda verilmiş kararları yok sayan veya kullanıcıya aynı kararı tekrar aldıran konuşma akışlarını engellemektir.

### 2. Tartışma Sırasında

- Kullanıcı bir fikir önerirse: avantajları, dezavantajları ve mevcut sistemlerle çatışmaları söyle.
- Tek cevap vermek yerine alternatifler sun: "A seçeneği şunu sağlar, B seçeneği şunu."
- Oyunun geneline etkisini değerlendir: "Bu karar lojistik sistemini de etkiler, çünkü..."
- Eğer bir karar açık bir sorunu çözüyorsa bunu teyit et.
- Eğer bir karar yeni bir sorun yaratıyorsa hemen söyle.
- Kullanıcı kararsızsa iki-üç seçenek sun ve hangisini önerdiğini belirt, nedenini açıkla.
- Hiçbir zaman "ne istiyorsanız yapın" deme — analizini her zaman sun.

### 3. Kararlar Netleşince

Kullanıcı bir konuda net karar verdiğinde veya tartışma doğal olarak kapandığında, ajanın ilgili dosyayı güncellemesi gerekir. Güncelleme şablonu:

**Karar verildiyse:**
- Dosyanın "Karar verilmiş" bölümüne ekle veya mevcut satırı düzelt.
- Kararı `decision_log.md`'ye yeni K numarasıyla ekle (karar, alternatifler, gerekçe).
- Eğer bu karar bir açık soruyu yanıtladıysa, o soruyu dosyadan ve `_index.md`'den kaldır.

**Fikir veya olasılık tartışıldıysa ama karar verilmediyse:**
- Açık soru olarak koru veya yenisini ekle.

**Gerilim veya çelişki keşfedildiyse:**
- İlgili dosyanın "Gerilimler" bölümüne ekle.
- `_index.md`'deki "Çelişkiler / Gerilimler" bölümünü de güncelle.

**Tartışma özeti:**
- Dosyanın "Tartışma Notları" bölümüne tarihi ve kısa özeti ekle.
- Örnek format: `[2026-10-29] Borsa komisyonu %2'den %1'e düşürüldü. Gerekçe: küçük şirketlerin girişini zorluyordu.`

### 4. Güncellemeler Hakkında

- Güncellemeyi tartışma bitmeden yapma — konuşma akarken dosyayı düzenleme.
- Her küçük soru/cevap sonrası dosya güncellemek zorunlu değildir.
- 3-4 net karar birikince toplu güncelleme yapılabilir.
- Toplu güncellemede her karar kendi ilgili design dosyasına yazılmalıdır.
- Birden fazla konu tartışıldıysa her konu kendi dosyasında güncellenir.
- Açık soru kapanırsa hem konu dosyasından hem `_index.md` dosyasından kaldırılır.
- Yeni açık soru veya çelişki doğarsa hem konu dosyasına hem `_index.md` dosyasına eklenir.
- Kullanıcı açıkça kaydetmeyi isterse ilgili dosya beklemeden güncellenir.
- `_index.md` her zaman güncel kalsın: yanıtlanan sorular silinsin, yeni sorular eklensin.

---

## Design Dosyaları Referansı

| Dosya | Ne zaman okunur |
|-------|-----------------|
| `_index.md` | Her tasarım oturumu başında — açık sorular, çelişkiler, park edilenler |
| `vision.md` | Tür, kapsam, varsayımlar, hedef dışı, aşamalar |
| `decision_log.md` | Bir kararın gerekçesini veya alternatiflerini kontrol ederken |
| `goods.md` | Mallar, reçeteler, kalite, marka, kargo sınıfı, bozulma |
| `population.md` | Hane, ihtiyaç barları, memnuniyet, vergi/kamu, kirlilik, meslek, maaş, büyüme, göç, mevsim |
| `production.md` | Tesis yapısı, birimler, bağlantılar, işgücü, bakım, inşaat |
| `market.md` | Mağazalar, şehir borsaları, fiyat oluşumu |
| `company_management.md` | Şirket kademeleri, yönetim puanı, yöneticiler, kontrol modeli |
| `finance.md` | Kredi, bankalar, merkez bankası, hisse borsası, devralma |
| `company_ai.md` | NPC şirket kararları, kişilik, iflas, girişim |
| `logistics.md` | Altyapı, tıkanıklık, yol bulma, sevkiyat, araçlar |
| `world_gen.md` | Harita ölçeği, prosedürel üretim, şehir büyümesi, başlangıç ekonomisi |
| `performance.md` | Veri yapısı, determinizm, tick ritmi, performans bütçesi |
| `observation.md` | Metrikler, alarmlar, debug viewer, headless koşu, Aşama 1 çıkış kriterleri |
| `research.md` | Ar-Ge seviyeleri, kilitler, patent |

---

## Tasarım Modunda Yapılmayanlar

- Kod yazmak veya değiştirmek (`docs/design/` dışında).
- `docs/mechanics.md` veya `docs/architecture.md` güncellemek (bu belgeler kodla senkronize olmalı, tasarım tartışmasıyla değil).
- Henüz tartışılmamış konuları "karar verildi" olarak işaretlemek.
- Kullanıcının açık bir kararı olmaksızın belirsiz fikirleri kesin karar gibi kaydetmek.
