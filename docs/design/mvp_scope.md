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
- Günlük prosperity clamp.
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
- Caravan Master route status.
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

- Günlük prosperity clamp sayısı ne olacak? Temel demand satisfaction MVP'de olduğu için bu sayı MVP implementasyonu sırasında ayrıca netleştirilecek.

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

## Tartışma Notları

- [2026-06-04] MVP kapsamı ayrı doküman olarak oluşturuldu. Hedef otomasyonlu ekonomi MVP'si: manuel ticaret, 3 kasaba, stok bazlı ekonomi, minimal Delivery kontratları, tam rank ladder, orta seviye Trading Post, orta seviye Caravan Master, temel demand satisfaction, basit NPC stok dalgalanması, basitleştirilmiş debt/game over ve victory summary.
- [2026-06-04] Açık MVP kararlarının çoğu kapatıldı. Victory summary sonrası oyuncu devam edebilir; Delivery kontratları tek tier olacak; gross/upkeep/net margin UI MVP'de olacak; temel Caravan Master hiring şehir bazlı 0-2 aday modeliyle kurulacak; Delivery fail ödülden mahrum kalma + küçük faction rep cezası verecek. Günlük prosperity clamp sayısı MVP içinde sonradan netleştirilecek tek açık kapsam kararı olarak kaldı.
