# Trading Post Debt & Game Over Design

Bu dosya borç, upkeep ve game over kararlarını tutar.

## Debt ve Game Over Modeli (Karar verilmiş)

Eski karar olan `Debt 30 günde auto-trade durur, 60 günde en değerli post suspended olur` kaldırılmıştır.
Eski karar olan `60. günde upkeep durur, master'lar unpaid olur, route'lar pause olur` da kaldırılmıştır.

**Debt modeli - üç bölge:**

- **0-30 gün (Acı ama kurtarılabilir):** Bakiye negatif, tüm upkeep'ler düşmeye devam eder, otomasyon çalışır. Reputation penalty ve debt fee uygulanır. Oyuncu fark edip düzeltebilir.
- **30-60 gün (Kritik ama çıkış var):** Daha büyük reputation penalty uygulanır. Tüm upkeep'ler hâlâ düşer, Trading Post ve Caravan Master otomasyonu çalışmaya devam eder. Oyuncunun kurtulma şansı vardır.
- **60. gün (Game Over):** Sistem oyuncuya game over ekranı gösterir. Otomasyon sistemi ayrıca durdurulmaz; zaten oyun bitiyor.

## Temel Kararlar

- Oyuncunun tek bir bakiyesi vardır; bu bakiye negatife düşebilir.
- Bakiye negatife düştüğü an debt başlar ve gün sayacı işlemeye başlar.
- Debt trigger mekanizması genel debt süresine göre çalışır; master başına ayrı sayaç yoktur.
- Debt süresince tüm upkeep'ler (Trading Post + Caravan Master) işlemeye devam eder; otomasyon sistemi bozulmaz.
- Borç kapatılırsa gün sayacı sıfırlanır; oyun devam eder.
- Debt cezası mevcut Trading Post depolarını, route stop'larını, cargo'yu veya route validity yapısını otomatik bozmaz.
- Reputation penalty ve debt fee için numeric değerler balance aşamasında netleştirilecektir.

## Tasarım Gerekçesi

60. günde sistemi durdurmak ölüm sarmalı yaratıyordu. Otomasyon bozulunca zaten parası olmayan oyuncu manuel alım satım da yapamaz hale gelir ve dönüş yolu kalmaz. Game over ile direkt bitirmek hem daha temiz hem daha dürüst.

## Tartışma Notları

- [2026-06-04] Debt ve game over kararları ana `trading_post.md` dosyasından ayrıldı. Trading Post suspended davranışı, master unpaid/route pause yaklaşımı ve auto-trade durdurma kararlarının iptal edildiği bilgi korunuyor.
- [2026-06-02] Debt modeli ve game over kararı alındı. Eski "60. günde upkeep durur, master'lar unpaid olur, route'lar pause olur" kararı iptal edildi. Yeni model: 0-30 gün acı ama kurtarılabilir, 30-60 gün kritik ama çıkış var, 60. günde game over ekranı. Otomasyon ayrıca durdurulmaz; oyun bitiyor.
- [2026-06-02] Debt trigger mekanizması netleştirildi. Genel debt süresine göre çalışır; master başına ayrı sayaç yok. Bakiye negatife düşünce gün sayacı başlar.
