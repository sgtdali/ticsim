# Finansman

Şirketlerin (oyuncu ve NPC) para bulma, borçlanma ve sahiplik mekanikleri. Ana referans: Capitalism / Capitalism Lab (Song of Syx'te şirket finansmanı yok).

## Karar verilmiş

### Araçlar (K56)
Banka kredisi, hisse/halka arz, rakip hisse alımı/devralma. Tahvil ve kredi notu sistemi yok; kredi faizi şirket riskine göre basit bir primle değişir.

### NPC bankalar (K57)
- **Mevduat:** Haneler birikimlerini bankaya yatırır. Banka seçimi: mevduat faizi, güven (sermaye sağlamlığı), şehirde şube.
- **Kredi:** Mevduatın bir kısmı şirketlere kredi olarak verilir. `Faiz = baz oran + risk primi`; risk primi borç/varlık oranı ve kâr geçmişinden. Teminat şirket varlıkları.
- **Banka kârı:** kredi faizi − mevduat faizi − temerrüt kayıpları.
- **Sağlamlık:** Sermaye / mevduat oranı zorunlu eşiğin altına düşerse banka yeni kredi veremez. Temerrütler sermayeyi eritirse banka iflas eder, mevduat sahipleri (haneler) kayıp yaşar.
- **Başlangıç (K26):** Harita birkaç başlangıç bankasıyla doğar; hanelerin başlangıç birikimi mevduat olarak girer.
- **Yatırım havuzu (K18) ile ilişki:** Hane birikimi = banka mevduatı + hisse yatırımı payı. Yeni girişimler kredi ve halka arzla finanse olur.

### Merkez bankası (K58)
- `Politika faizi = nötr faiz + φ × (enflasyon − hedef)`, aylık, ayda en fazla ±0,5 puan.
- Kredi baz oranı = politika faizi + banka marjı; mevduat faizi = politika faizi − banka marjı. Banka marjları rekabetle, deneyerek öğrenmeyle (K39 mantığı) bulunur.
- **Tam aracılık:** Krediler mevduattan karşılanır; para yaratılmaz. Para arzı sadece ithalat (çıkış) ve ileride ihracat (giriş) ile değişir.
- Zorunlu sermaye oranı tanım dosyasında sabit.

### Hisse borsası (K59)
- Tek ulusal borsa, günlük toplu eşleşme (K40 mantığı).
- Yatırımcılar: haneler (birikimin gelir dilimine bağlı payı), şirketler (fazla nakit veya stratejik), birkaç NPC fon.
- Değer tahmini: `son 12 ay kâr × çarpan + net varlık`; çarpan sektör büyümesi ve faizle değişir (düşük faiz → yüksek çarpan); yatırımcıya özel sapma + küçük trend ağırlığı. Baloncuk/çöküş spekülasyonu yok.
- Halka arz: sadece Şirket kademesi (K54) ve üstü.
- Hisse ihracı: toplanan para hisse fiyatına bağlı; mevcut ortaklar sulanır.
- Temettü: isteğe bağlı; değer tahminine eklenir, hanelere gelir olarak döner.

### Devralma (K60)
- %50+ hisse → bağlı şirket. Ayrı tüzel kişi (kendi nakdi, borcu, hissedarları).
- Ana şirket yönetici ve yetki ayarlarıyla (K55) yönetir. Bağlı şirketin yönetim puanı kendi genel merkezinden; ana şirkete bağlı şirket başına küçük sabit maliyet.
- %100'e tamamlanınca tamamen birleştirilebilir; varlıklar ana şirketin yönetim puanına yüklenir.
- Oyuncunun şirketinde başka biri %50+ hisseye ulaşırsa oyun biter.

### Şirkete doğan kararlar ve krizler (K52)
Borçla hızlı büyüme ↔ faiz riski; halka arz ↔ devralınma riski; kredi sıkışması; banka iflası (müşteri harcaması düşer); ucuzlamış rakibi devralma fırsatı.

## Açık Sorular

- Oyuncunun başlangıç sermayesi ve CEO'su (Aşama 2).
- Oyuncu banka kurabilir mi?
- Parametreler: nötr faiz, φ, hedef enflasyon, zorunlu sermaye oranı, risk primi formülü, kredi/varlık üst sınırı, hane yatırım payları, değer çarpanı.

## Gerilimler

- NPC bankacılık sektörü kapsamı büyütüyor; K52 filtresine göre sadece şirkete kredi/kriz üreten kadar derin tutulmalı.

## Tartışma Notları

- [2026-10-29] Capitalism'in finans modeli incelendi; kredi, NPC bankalar, kural tabanlı merkez bankası, hisse borsası ve bağlı şirket modeli kararlaştırıldı (K56–K60). K18'de park edilen satın alma/birleşme K60 ile çözüldü.
