# MVP Scope Design

Bu dosya MVP kapsamını tanımlar. Amaç, mevcut geniş tasarım vizyonunu oynanabilir ve tamamlanabilir ilk sürüme indirmektir.

## MVP Hedefi (Karar verilmiş)

MVP hedefi **otomasyonlu ekonomi MVP'si** olacak.

MVP, tam Patrician ölçeği değil; 3 kasabalı dünyada ticaret ekonomisinin, rank ilerlemesinin ve temel otomasyonun çalıştığını kanıtlayan oynanabilir dikey kesittir.

## MVP'de Şart Olanlar

- 3 kasaba: Ashford, Ironmere, Stonebridge.
- Manuel al-sat ticareti.
- Stok bazlı fiyat sistemi.
- Günlük talep/tüketim zemini.
- Marginal pricing.
- Quote/spread sistemi.
- Faction rep'in basit spread bonusu olarak çalışması.
- Market stok kapasitesi ve cap davranışı.
- Mevsimsel üretim etkileri.
- Minimal Delivery kontratları.
- Tam rank ladder: Peddler -> Trader -> Merchant -> Guild Master -> Patrician.
- Rank koşullarının gold + şehir prosperity bazlı çalışması.
- Trading Post orta seviye otomasyon.
- Caravan Master orta seviye route otomasyon.
- Temel demand satisfaction.
- Basitleştirilmiş debt/game over.
- Victory summary ekranı.
- Okunabilir ama sade UI.

## MVP'de Sınırlı Tutulacaklar

### Trading Post

MVP'de Trading Post orta seviye olacak:

- Şehirde Trading Post açma.
- Depot capacity.
- Auto-buy / auto-sell kuralları.
- Fiyat limiti.
- Depot limit.
- Günlük rule status.
- Temel upkeep.
- Basit depot expansion veya en azından expansion altyapısı.
- Basit "neden işlem yapmadı?" bilgisi.

MVP'de ayrıca olacak:

- Gross/upkeep/net margin UI.

Sınırlı/opsiyonel:

- Gelişmiş automation chain görünürlüğü.
- Depot expansion'ın tam late-game balance'ı.
- Çok detaylı rule uyarıları.

### Caravan Master

MVP'de Caravan Master orta seviye route otomasyonu olacak:

- Load/Unload terminolojisi.
- Çok duraklı rota.
- Trading Post depoları arası taşıma.
- En az 2 durak şartı.
- Basit cargo uyumluluk uyarısı.
- Şehir bazlı 0-2 adaylı temel master hiring.
- Master'ın cargo/capacity taşıması.
- Route status okunabilirliği.

MVP dışı:

- Temporary Unload sistemi.
- Canlı rota düzenlemenin tüm gelişmiş edge-case'leri.
- Gelişmiş Load modları: Wait Until Full, Wait Until Amount, Take Exact Amount.
- Route mini-map'in tam gelişmiş interaktif versiyonu.
- Derin aday havuzu/archetype balance.
- Level-up özellik puanı sistemi.

### Prosperity ve Demand Satisfaction

MVP'de temel demand satisfaction olacak:

- Şehir günlük tüketim/talep hesabı.
- Survival satisfaction refahın ana belirleyicisi.
- Luxury/Comfort yüksek prosperity şehirlerde hafif baskı.
- Processed/Industry üretime hafif verim etkisi.
- Raw material için çifte ceza yok.
- Günlük prosperity clamp (`-2 / +2`, bkz. economy_prosperity.md).
- Basit prosperity yatırım bandları.
- Rank koşullarıyla uyumlu Growing / Prosperous eşikleri.

Sade tutulacak:

- Prosperity ihtiyaç bandları.
- Eksik tedarik growth stop/düşüş detayları.
- Bolluk spirali balance.
- UI uyarıları.

MVP dışı:

- Tam civic project sistemi.
- Çok ayrıntılı prosperity ihtiyaç profilleri.
- Derin şehir bakım ekonomisi.
- Kapsamlı snowball test/balance.
- Oyuncu sahipli üretim (post-MVP tasarım yönü olarak economy_prosperity.md'de korunuyor).

### NPC Trader

MVP'de NPC trader arka plan stok dalgalandırıcı olacak:

- Günlük tick'te gerçek stok işlemi yapar.
- NPC alımı stoğu azaltır, NPC satışı stoğu artırır.
- Fiyatlar stok değişimiyle dolaylı etkilenir.
- Oyuncu NPC'yi stratejik rakip olarak takip etmek zorunda kalmaz.

MVP dışı:

- Haritada takip edilebilir rakip trader.
- Önceden görünen NPC rotaları.
- Trade rumor sistemi.
- NPC'nin oyuncu rotalarını bilinçli bozması.
- Faction/NPC relation bağlantısı.

### Seyahat Riski

MVP'de mevcut basit seyahat riski korunur:

- Base route risk + cargo + faction rep etkisi.
- Harita tooltip'inde risk yüzdesi.
- Saldırı sonrası kayıp popup'ı.

MVP dışı:

- Riskin karar katmanına dönüştürülmesi: route planlamasında risk/kâr trade-off'u, courage statının riske anlamlı etkisi, eskort/önlem kararları. Bu derinleştirme silinmedi; post-MVP notu olarak `world.md` içinde korunuyor.

### Ekonomik Fırsat Gösterimi

MVP'de ekonomik fırsatlar market tooltip + basit şehir uyarılarıyla gösterilecek:

- Market satırında fiyat yönü ikonu.
- Hover tooltip'te aktif fiyat nedenleri.
- Sadece anlamlı etkiler gösterilir.
- Şehir panelinde basit uyarılar:
  - `Bread shortage`
  - `Wine surplus`
  - `Iron demand rising`
  - `Market storage full`

MVP dışı:

- Trade rumor sistemi.
- "Şuradan al, buraya sat" rota önerisi.
- NPC hareketlerine dayalı gelişmiş fırsat tahmini.
- Gelişmiş ekonomik rapor ekranı.

## Kontratlar

MVP'de kontrat sistemi minimal olacak:

- Sadece Delivery kontrat tipi.
- Tek kontrat tier'ı.
- A kasabasından B kasabasına belirli mal taşıma.
- Kontrat malı rastgele seçilmez; hedef şehirde gerçek açığı olan mallardan seçilir (kontratlar erken oyunda rota öğretmeni olsun diye).
- Basit deadline.
- Ödül: gold + faction rep.
- Her şehirde 1-2 available kontrat.
- Kontrat fail olursa oyuncu ödülden mahrum kalır ve küçük faction rep cezası alır.

MVP dışı:

- Procurement kontratları.
- Urgent kontratlar.
- Tier çeşitliliğinin tam balance'ı.
- Özel şehir yardım kontratları.
- Rival faction kontratları.
- Production chain / özel sipariş kontratları.

## Faction Rep

MVP'de faction rep basit spread bonusu olarak kalacak:

- Kontrat ve/veya ticaretle artar.
- Rank koşulu değildir.
- Alış/satış quote'unu hafif iyileştirir.
- NPC relation yok; tek ilişki metriği faction rep.

MVP dışı:

- Diplomasi.
- Faction eventleri.
- Faction-specific unlock.
- NPC kişisel relation.
- Rival faction penalty detayları.
- Tax rate.

## Şehir Kimlikleri ve Demand Kalibrasyonu

MVP'de mevcut 3 şehir kimliği yeterli olacak:

- Ashford: tarım / wheat / bread.
- Ironmere: maden / iron / metal ürünleri.
- Stonebridge: grapes / wine / must.

MVP'de item/demand tag kalibrasyonu basit item bazlı değerlerle yapılacak:

- `category`
- `base_price`
- `base_daily_demand_per_1000_pop`
- `demand_tags`

MVP dışı:

- Şehir bazlı özel tüketim katsayıları.
- Tam şehir demand profilleri.
- Refah/luxury tüketim şehri gibi açık şehir rolleri.
- Şehir rolüne göre ayrı tüketim sistemi.

## Event ve Mevsim

MVP'de event sistemi dışarıda kalacak; mevsimsel üretim etkileri ekonomi sisteminin parçası olarak korunacak.

MVP'de olsun:

- Spring / summer / autumn / winter üretim etkileri.
- Mevsimin stok ve fiyatı dolaylı etkilemesi.
- Market tooltip'te anlamlıysa mevsim etkisinin görünmesi.

MVP dışı:

- EventManager.
- Festival / famine / plague / demand surge / bumper crop eventleri.
- Event popup/UI.
- Event log.
- Event'e özel fiyat çarpanları.

## Debt, Game Over ve Victory

MVP'de basitleştirilmiş debt/game over olacak:

- Gold negatife düşebilir.
- Negatif gold süresi sayılır.
- Uyarı gösterilir.
- 60 gün negatif kalırsa game over screen tetiklenir.
- Otomasyon debt yüzünden durmaz.
- Borç kapatılırsa sayaç sıfırlanır.

MVP'de Patrician'a ulaşınca victory summary ekranı olacak:

- Kaçıncı gün.
- Final gold.
- Rank.
- Kaç Trading Post.
- Kaç Caravan Master.
- Şehir prosperity durumları.
- Victory summary sonrası oyuncu devam edebilir.

MVP dışı:

- Sinematik kutlama.
- Özel ending sahnesi.
- Narrative epilogue.
- Detaylı skor sistemi.
- Karmaşık debt ceza sistemi.
- Post suspend.
- Master unpaid.
- Route pause.

## UI Seviyesi

MVP'de UI okunabilir ama sade olacak.

MVP'de olsun:

- Market fiyat/stok görünürlüğü.
- Fiyat yönü ikonu.
- Tooltip'te anlamlı fiyat nedenleri.
- Basit şehir uyarıları.
- Trading Post rule status.
- Trading Post rule blok nedenleri sabit enum listesinden tek satır olarak: `Depo dolu`, `Fiyat limiti dışı`, `Market stoğu yok`, `Gold yetersiz / debt`, `İşlem yapıldı`.
- Caravan Master route status.
- Tek ekran Trade Route editor: durak sırası + Load/Unload kuralları aynı panelde, kayıtlı route düzenlenebilir.
- Automation margin paneli: Post ve Master başına gross/upkeep/net, 7 günlük pencere, pozitif/negatif renk kodu.
- Şehir panelinde günlük prosperity delta ve ana nedeni (tek satır).
- Rank için eksik kalan net hedef satırı (örn. `Merchant için eksik: 800g + Ironmere prosperity 24/30`).
- Prosperity bandına göre 3 kademeli şehir görseli (0-29 köy, 30-64 kasaba, 65+ şehir).
- Debt uyarısı.
- Game over ekranı.
- Victory summary ekranı.
- Temel rank/progression görünürlüğü.

MVP dışı:

- Tam ekonomik rapor ekranı.
- Gelişmiş dashboard.
- Trade rumor UI.
- Tam interaktif route mini-map polish.
- Sinematik/victory kutlama sahnesi.

## Açık MVP Kararları

- Açık MVP kapsam kararı kalmamıştır. Günlük prosperity clamp `-2 / +2` olarak kapatıldı (2026-06-09, detay `economy_prosperity.md`).

## Decision Log

- MVP hedefi otomasyonlu ekonomi MVP'si olarak belirlendi.
- MVP'de Caravan Master orta seviye route otomasyonu olacak; tam route edge-case sistemi sonraya kalacak.
- MVP'de Trading Post orta seviye olacak; gelişmiş dashboard ve tam margin simülasyonu sonraya kalacak.
- MVP'de temel demand satisfaction olacak; tam prosperity ihtiyaç profilleri sonraya kalacak.
- MVP'de NPC trader arka plan stok dalgalandırıcı olacak; stratejik rakip tüccar sonraya kalacak.
- MVP'de ekonomik fırsatlar market tooltip + basit şehir uyarılarıyla gösterilecek.
- MVP'de Patrician'a ulaşınca victory summary ekranı olacak ve oyuncu isterse devam edebilecek.
- MVP'de debt/game over basitleştirilecek: 60 gün negatif gold game over.
- MVP'de tam rank ladder korunacak.
- MVP'de kontratlar minimal, tek tier Delivery kontratlarına indirilecek; fail ödülden mahrum kalma + küçük faction rep cezası verecek.
- MVP'de faction rep basit spread bonusu olarak kalacak.
- MVP'de mevcut 3 şehir kimliği yeterli olacak.
- MVP'de demand tag kalibrasyonu item bazlı olacak; şehir özel katsayıları olmayacak.
- MVP'de event sistemi dışarıda kalacak; mevsim etkileri korunacak.
- MVP'de UI okunabilir ama sade olacak.
- MVP'de gross/upkeep/net margin UI olacak.
- MVP'de temel Caravan Master hiring şehir bazlı 0-2 aday modeliyle kurulacak.
- Günlük prosperity clamp `-2 / +2` olarak kapatıldı.
- Benchmark analizi (2026-06-10) sonrası MVP UI'a somut maddeler eklendi: blok nedeni sabit enum, tek ekran route editor, 7 günlük margin paneli, prosperity delta + neden satırı, rank eksik hedef satırı, 3 kademeli şehir görseli.
- Kontrat malı hedef şehirde gerçek açığı olan mallardan seçilecek.
- Seyahat riskinin karar katmanına dönüştürülmesi MVP dışı bırakıldı; post-MVP notu `world.md` içinde korunuyor.

## Tartışma Notları

- [2026-06-10] Patrician III/IV ve Port Royale 4 benchmark analizi yapıldı. Otomasyon UX'i MVP başarı çizgisi kabul edildi ve somut UI maddeleri MVP kapsamına işlendi (blok nedeni enum, tek ekran route editor, 7 günlük margin paneli, prosperity delta satırı, rank eksik hedef satırı, 3 kademeli şehir görseli). Kontrat malı gerçek açıktan seçilecek. Seyahat riski derinliği MVP dışı bırakıldı ama post-MVP notu olarak korundu. Oyuncu sahipli üretim post-MVP tasarım yönü olarak economy_prosperity.md'ye kaydedildi. Ayrıca günlük prosperity clamp kararının (`-2 / +2`) bu dosyaya senkronu yapıldı.
- [2026-06-04] MVP kapsamı ayrı doküman olarak oluşturuldu. Hedef otomasyonlu ekonomi MVP'si: manuel ticaret, 3 kasaba, stok bazlı ekonomi, minimal Delivery kontratları, tam rank ladder, orta seviye Trading Post, orta seviye Caravan Master, temel demand satisfaction, basit NPC stok dalgalanması, basitleştirilmiş debt/game over ve victory summary.
- [2026-06-04] Açık MVP kararlarının çoğu kapatıldı. Victory summary sonrası oyuncu devam edebilir; Delivery kontratları tek tier olacak; gross/upkeep/net margin UI MVP'de olacak; temel Caravan Master hiring şehir bazlı 0-2 aday modeliyle kurulacak; Delivery fail ödülden mahrum kalma + küçük faction rep cezası verecek. Günlük prosperity clamp sayısı MVP içinde sonradan netleştirilecek tek açık kapsam kararı olarak kaldı.
