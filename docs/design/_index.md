# Tasarım İndeksi

> **Yön değişikliği (2026-10-29):** ticsim artık ortaçağ ticaret simi değil. Modern endüstriyel dönemde, prosedürel ülke haritasında geçen, Song of Syx detayında bir şirket üretim/lojistik tycoon oyunu. Eski tasarım dosyaları silindi (git geçmişinde duruyor).

## Dosyalar

| Dosya | Konu |
|-------|------|
| `vision.md` | Vizyon, kapsam, varsayımlar, hedef dışı, geliştirme sırası |
| `decision_log.md` | K1–K31 tüm kararlar, alternatifler, gerekçeler |
| `goods.md` | Mallar, üretim zincirleri, kalite, marka, kargo sınıfı, bozulma |
| `population.md` | Hane, ihtiyaç barları, memnuniyet, vergi ve kamu bütçesi, kirlilik, meslek, maaş, büyüme, göç |
| `production.md` | Tesis kabuğu ve birimleri, bağlantılar, işgücü darboğazı, bakım/arıza, inşaat |
| `market.md` | Mağaza (B2C), şehir borsaları (B2B), fiyat oluşumu |
| `company_management.md` | Şirket kademeleri, yönetim puanı, yöneticiler, kontrol modeli (oyuncu + NPC) |
| `finance.md` | Banka kredisi, bankacılık sistemi, merkez bankası, hisse borsası, devralma |
| `company_ai.md` | NPC şirket karar katmanları, kişilik, iflas, girişim |
| `logistics.md` | Kamu/özel altyapı, tıkanıklık, yol bulma, dinamik sevkiyat |
| `world_gen.md` | Harita ölçeği, prosedürel üretim, şehir büyümesi, arazi, başlangıç ekonomisi |
| `performance.md` | Veri yapısı, determinizm, tick ritmi, performans bütçesi |
| `observation.md` | Sağlık metrikleri, alarmlar, debug viewer, headless koşu, Aşama 1 çıkış kriterleri |
| `research.md` | Ar-Ge projeleri, seviyeler, Aşama 1 kilit ağacı, patent ve yayılım |

## Açık Sorular


- Üretim zinciri, lojistik ve şirket rekabetinin kendi aralarındaki ağırlık sırası ne? (Mikro simülasyon birinci ağırlık — karar verildi.)
- Oyuncu katmanı (Aşama 2) tasarımı: oyuncu dünyaya nasıl girer, karar yüzeyleri, kriz uyarıları. Kontrol modeli ve ölçek mekanikleri karara bağlandı (`company_management.md`).
- Oyuncunun başlangıç sermayesi ve CEO'su; oyuncu banka kurabilir mi? (Finansman modeli `finance.md`'de karara bağlandı.)
- Başlangıç mal setindeki sayısal değerler (reçeteler, süreler, işgücü) — headless koşularla belirlenecek.

## Çelişkiler / Gerilimler

- Maaş tabanı (K46) fiyatlara bağlı olduğu için fiyat–maaş enflasyon sarmalı mümkün; para arzı alarmıyla izlenecek.

- Sabit hatlar (K83) ve dinamik havuz aynı terminalleri paylaşır; kuyruk kuralları netleştirilmeli.
- Sadece kendi ürününü satma (K15) nihai mal pazarına girişi pahalılaştırır; NPC girişim oranı izlenmeli.
- Boş ekonomi (K26) ile başlamak ekonominin hiç kalkmama riskini taşır; ithalat güvenlik ağı ile çözülmesi bekleniyor, `observation.md` kriter 2 ile doğrulanacak.
- Her yer tam detay (K28) ölçek büyürse performans riski.

## İleriye Park Edilenler

- Denizyolu ve havayolu: liman, havalimanı, gemi, uçak (K84)
- Reklam mekaniği (marka büyümesi; K3) — sonra konuşulacak
- Yeni yerleşimlerin doğması
- Eğitim tesisleri (meslek geçişini hızlandırır)
- B2B uzun vadeli tedarik sözleşmeleri
- Teknoloji lisans satışı
- Araba üretim zinciri (ulaşım ihtiyacını dayanıklı mal + yakıta böler)
- İhracat
- Simülasyon LOD
