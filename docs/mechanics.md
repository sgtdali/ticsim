# Merchant's Road — Mekanik ve Sistem İlişkileri Rehberi

Bu belge, oyundaki sistemlerin birbirini nasıl etkilediğini ve oyuncu ilerlemesinin (progression) mantığını açıklar. Kod yazarken veya denge ayarı yaparken ana referans kaynağıdır.

## 1. Rütbe (Rank) ve İlerleme Sistemi
Oyuncunun ana hedefi rütbe atlayarak **Patrician** seviyesine ulaşmaktır.

| Rütbe | Şartlar (Requirements) | Açılan Özellikler (Unlocks) |
| :--- | :--- | :--- |
| **Peddler** | Başlangıç | Temel Al-Sat, Basic/Standard Kontratlar |
| **Trader** | 500 Gold + 1 Friendly Faction | **Caravan Upgrades:** Horse Cart ve Small Caravan |
| **Merchant** | 1500 Gold + 2 Friendly Factions + 1 Trading Post | **Trading Posts:** Şehirlerde depo ve oto-kural açma |
| **Guild Master**| 4000 Gold + 3 Friendly Factions + 2 Trading Posts + 1 Growing City | **Urgent Contracts:** Yüksek ödüllü görevler<br>**Bonus:** Kontratlardan +%50 fazla Rep |
| **Patrician** | 10000 Gold + 3 Allied Factions + 3 Prosperous Cities | **WIN CONDITION:** Oyun biter. |

---

## 2. Ekonomi ve Olay (Event) Etkileri
Olaylar, şehirlerin arz-talep dengesini geçici olarak bozar ve kâr fırsatları yaratır.

| Olay Tipi | Etkilenen Mallar | Fiyat Etkisi | Stok Etkisi | Diğer |
| :--- | :--- | :--- | :--- | :--- |
| **Famine (Kıtlık)** | Wheat, Meat | **Artar (↑↑)** | Kritik Seviye (↓↓) | Prosperity düşebilir. |
| **Demand Surge** | Lüks Mallar (Iron, Tools) | **Artar (↑)** | Azalır (↓) | Kısa süreli yüksek kâr. |
| **Festival** | Beer, Wheat | **Artar (↑)** | Hızlı Tüketim (↓) | Prosperity +1 bonus. |
| **Bumper Crop** | Wheat, Beer | **Düşer (↓↓)** | Taşma (↑↑) | Alım için en iyi zaman. |
| **Plague (Salgın)** | Hepsi | Sabit / Belirsiz | Üretim durur (↓↓) | Şehir nüfusu azalır. |

---

## 3. Refah (Prosperity) ve Yatırım
Şehirlere altın yatırarak onları geliştirmek, uzun vadeli ekonomik avantajlar sağlar.

*   **Yatırım Oranı:** 25 Gold = 1 Prosperity Puanı.
*   **Günlük Limit:** Şehir başına max 50 Prosperity puanı yatırım yapılabilir.
*   **Seviyeler:**
    *   **Struggling (< 30):** Standart üretim.
    *   **Growing (30 - 64):** Üretim hızı +%10, Fiyatlarda ufak iyileşme.
    *   **Prosperous (>= 65):** Üretim hızı +%25, Alım fiyatlarında indirim, Satış fiyatlarında bonus.

---

## 4. Trading Post ve Otomatik Ticaret
Trading Postlar, oyuncunun fiziksel olarak orada bulunmasına gerek kalmadan pasif gelir ve stok yönetimi sağlar.

*   **Kurulum:** 300 Gold (Merchant rütbesi gerekir).
*   **Depo Kapasitesi:** 50 Birim (Şehir marketinden bağımsız).
*   **Otomatik Kurallar:**
    *   **Buy Rule:** Fiyat X'in altındaysa ve depo Y'den azsa al.
    *   **Sell Rule:** Fiyat X'in üstündeyse ve depo Y'den fazlaysa sat.
*   **Limit:** Her kural için günlük maksimum işlem miktarı belirlenebilir.

---

## 5. Faksiyonlar ve İtibar (Reputation)
Kontratlar aracılığıyla faksiyonlarla olan ilişkiler geliştirilir.

*   **Neutral (0-29):** Standart kontratlar.
*   **Friendly (30-59):** Daha iyi kontrat ödülleri, **Trader/Merchant/Guild Master rütbe şartı.**
*   **Allied (>= 60):** En yüksek ödül çarpanları, **Patrician rütbe şartı.**

---

## Sistemler Arası Döngü (The Core Loop)
1. **Ticaret/Kontrat Yap** → Gold ve Rep Kazan.
2. **Gold Yatır** → Prosperity Artır → Rütbe Atla.
3. **Yeni Rütbe** → Daha iyi Karavan/Trading Post Aç.
4. **Trading Post Kur** → Otomatik ticaretle daha hızlı Gold biriktir.
5. **Hedef:** Tüm şehirleri geliştirip **Patrician** rütbesine ulaş.
