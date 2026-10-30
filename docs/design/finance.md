# Finansman

Şirketlerin (oyuncu ve NPC) para bulma, borçlanma ve sahiplik mekanikleri. Ana referans: Capitalism / Capitalism Lab (Song of Syx'te şirket finansmanı yok).

## Karar verilmiş

### Araçlar (K56)
Banka kredisi, hisse/halka arz, rakip hisse alımı/devralma. Tahvil ve kredi notu sistemi yok; kredi faizi şirket riskine göre basit bir primle değişir.

### Bankacılık sistemi (K81 — K57'nin sadeleştirilmiş hali)
- Tek **toplu bankacılık sistemi**; ayrı banka şirketleri yok.
- **Mevduat:** hanelerin birikiminin bankadaki payı ulusal mevduat havuzunu oluşturur. `Mevduat faizi = politika faizi − sabit marj`.
- **Kredi:** havuzdan verilir. `Kredi faizi = politika faizi + sabit marj + risk primi`; risk primi borç/varlık oranı ve kâr geçmişinden. Teminat şirket varlıkları; kredi/varlık üst sınırı.
- **Kredi sıkışması:** toplam kredi / mevduat oranı eşiğe yaklaştıkça risk primi ve onay eşiği yükselir; eşik aşılınca yeni kredi verilmez.
- **Temerrüt:** borçlu iflas edince kayıp önce sistem rezervinden, rezerv yetmezse mevduattan düşer (haneler kayıp yaşar, harcama düşer).
- **Marj geliri:** rezerve gider; rezerv hedefin üstündeyse fazlası mevduat faizi olarak hanelere dağıtılır (para sistemde kalır).
- **Başlangıç (K26):** hanelerin başlangıç birikimi havuza girer.
- **Yatırım havuzu (K18) ile ilişki:** hane birikimi = mevduat + hisse yatırımı payı. Yeni girişimler kredi ve halka arzla finanse olur.
- Oyuncu banka kurabilirse sistem ayrı bankalara genişletilir (açık soru).

### Merkez bankası (K58)
- `Politika faizi = nötr faiz + φ × (enflasyon − hedef)`, aylık, ayda en fazla ±0,5 puan.
- Kredi ve mevduat faizleri politika faizine sabit marjla bağlıdır (K81).
- **Tam aracılık:** Krediler mevduattan karşılanır; para yaratılmaz. Para arzı sadece ithalat (çıkış) ve ileride ihracat (giriş) ile değişir.
- Kredi/mevduat eşiği ve rezerv hedefi tanım dosyasında sabit.

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
Borçla hızlı büyüme ↔ faiz riski; halka arz ↔ devralınma riski; kredi sıkışması; iflas dalgasında mevduat kaybı (müşteri harcaması düşer); ucuzlamış rakibi devralma fırsatı.

## Açık Sorular

- Oyuncunun başlangıç sermayesi ve CEO'su (Aşama 2).
- Oyuncu banka kurabilir mi?
- Parametreler: nötr faiz, φ, hedef enflasyon, banka marjı, kredi/mevduat eşiği, rezerv hedefi, risk primi formülü, kredi/varlık üst sınırı, hane yatırım payları, değer çarpanı.

## Gerilimler

- Yok (NPC bankacılık gerilimi K81 ile çözüldü).

## Tartışma Notları

- [2026-10-29] Capitalism'in finans modeli incelendi; kredi, NPC bankalar, kural tabanlı merkez bankası, hisse borsası ve bağlı şirket modeli kararlaştırıldı (K56–K60). K18'de park edilen satın alma/birleşme K60 ile çözüldü.
- [2026-10-30] K52 sözgeci: NPC bankalar tek toplu bankacılık sistemine indirildi (K81).
