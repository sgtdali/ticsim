# Economy Design

## Temel Yaklaşım (Karar verilmiş)

- Fiyatlar sabit değil; arz-talep dinamiği var.
- Fiyat eğrisi tüketim bazlı: referans nokta 14 günlük tüketim stoku = base_price × 1.0.
- Stok 0'a düşünce base × 3.0, 14 günde base × 1.0, 42+ günde base × 0.35.
- Tüketim yoksa (doğal kaynak değil, tüketilmeyen üretim ürünü) kapasite bazlı fiyatlama devreye giriyor.
- Oyuncu doğrudan "market fiyatı" ile işlem yapmıyor; alımda +%8, satışta -%8 spread uygulanıyor.
- Toplu işlemler marginal — her birim kendi stok durumuna göre fiyatlanıyor. Anında arbitraj kapısı bu sayede kapalı.
- Faction rep alım maliyetini düşürüyor, satış gelirini artırıyor. Hem ödül hem progression bağlantısı.
- Prosperity da satışa bonus veriyor (%30 oranında etki).
- Satış çarpanı her zaman alım çarpanının en az %3 altında — aynı şehirde anında al-sat kâr edilemiyor.
- **Vergi ayrı bir mekanik olarak uygulanmıyor.** Spread zaten aynı şehirde al-sat'ı zararlı kılıyor; faction rep'in spread üzerindeki etkisi bu amacı karşılıyor. Kasıtlı tasarım seçimi.

## Üretim Sistemi (Karar verilmiş)

- Doğal kaynaklar (wheat, grapes, iron_ore): slot satın alarak üretim artırılıyor.
- İşleme ürünleri (flour, bread, iron_bar, tool, wine, must): production_plan ile tanımlı, upgrade ile artırılıyor.
- Recipe input eksikliği üretim verimini düşürüyor.
- Mevsimler bazı malların üretimini değiştiriyor (spring/summer/autumn/winter çarpanları mevcut).

## Stok Kapasitesi

- Her kasabada mal başına stok sınırı var.
- Kapasite doluysa üretim ve satış engellenebilir.
- Slot ve production upgrade alımı hem üretim hem stok cap'i artırıyor.

## Açık Sorular

**Mevsim görünürlüğü**
Mevsim çarpanları kodda var ve fiyatları etkiliyor. Ama oyuncu hangi mevsimde olduğunu ve hangi malı etkilediğini UI'dan görebiliyor mu? Şu an net değil. Bu bilgiyi oyuncuya sunmak lazım mı?

**Fiyat eğrisinin alt sınırı**
Herhangi bir mal base × 0.25'in altına düşemiyor (minimum floor). Bu kasıtlı bir tasarım seçimi mi, yoksa tutulacak mı? Çok düşük fiyatlar bazı malları değersiz yapıyor.

**NPC trader ekonomiye etkisi**
NPC'ler town_buy/town_sell üzerinden işlem yapıyor — yani marginal pricing etkisi var, stok değişiyor. Bu gerçek bir ekonomik baskı yaratıyor. Oyuncu buna karşı strateji kurabilmeli mi (mesela bir NPC'nin gittiği kasabayı önceliklendirmek)?

## Gerilimler

**3 kasaba ekonomisinin sınırları**
Sadece 3 kasabayla fiyat farkı az. Mira tipi careful trader'ın profitable olabileceği rotalar kısıtlı. Oyuncu hangi kasabadan alıp nereye satacağını hızlıca ezberleyebilir — dinamizm azalıyor. Bu daha fazla kasabayla mı çözülmeli, yoksa event/season varyasyonuyla mı?

**Bolluk spiraline karşı mekanizma**
Oyuncu çok para kazanınca prosperity'ye yatırım yapıyor → satış bonusu artıyor → daha çok kazanıyor. Bu pozitif geri besleme döngüsünü kıran bir şey var mı? Debt+upkeep baskısı erken oyunda bunu dengeliyor ama geç oyunda?

## Tartışma Notları

- [2026-06-02] Vergi mekaniği tartışıldı. Ayrı bir tax rate uygulanmayacak. Spread zaten aynı şehirde al-sat'ı zararlı kılıyor; faction rep'in spread bonusu olarak yansıması yeterli. Kapatıldı.
