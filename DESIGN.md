# DESIGN.md — BEKALIMA (Aplikasi Pemesanan Catering Online)

> Dokumen acuan arah desain visual, hierarki antarmuka, dan tipografi untuk BEKALIMA.
> Mengikuti standar **antislop** (C-1 s/d C-5, R-01 s/d R-38): berkarakter, beralasan kuat, ramah pengguna, dan bebas dari generic AI slop.

---

## 1. Identitas & Karakter Produk (Product Soul)
- **Nama Produk:** BEKALIMA
- **Jenis Aplikasi:** Aplikasi mobile pemesanan katering online (Mobile-First Flutter).
- **Personality & Mood:** Hangat, menggugah selera (appetizing), terpercaya, bersahabat, dan higienis.
- **Karakter Visual:** Modern Indonesian culinary feel — bukan aplikasi fintech steril atau template SaaS developer serba ungu/biru.

---

## 2. Antislop Dials
| Dial | Nilai | Alasan / Penerapan |
|---|---|---|
| **ENERGY** | **2 (Balanced)** | Ramah dan hangat untuk katering keluarga & korporat; jelas terbaca tanpa visual berisik. |
| **RHYTHM** | **2 (Balanced)** | Ritme visual bervariasi antara banner promo kurasi, kartu menu vertikal/horizontal, dan ringkasan pesanan bertahap. |
| **MOTION** | **1 (Calm)** | Transisi native Flutter yang responsif (haptic/touch feedback, page transition halus); tanpa animasi looping tanpa henti atau floating orbs. |

---

## 3. Palet Warna (Brand Palette)
Berdasarkan Keputusan Klien PRD Bab 5, diintegrasikan ke sistem token terstruktur (R-29: 2-3 warna inti + aksen fungsional):

### Warna Inti (Core)
- **Primary / Brand Action:** `Crisp Carrot` (`#F86015`)
  - *Alasan:* Menjadi titik fokus tombol aksi utama (CTA), tombol pesan/checkout, dan status aktif. Membangkitkan nafsu makan dan energi hangat.
- **Secondary / Trust & Quality:** `Forest Green` (`#19532B`)
  - *Alasan:* Mewakili kesegaran bahan, sertifikasi halal/higienis, dan status sukses pesanan. Memberikan bobot keterpercayaan tinggi.
- **Neutral Background Canvas:** `Cream Tint` (`#FAF7F0`) & `Pure Cream` (`#F3E8CC`)
  - *Alasan:* Latar belakang hangat pengganti putih silau (#FFFFFF murni), membuat foto makanan terlihat lebih kaya dan natural.
- **Dark Neutral (Ink/Text):** `Espresso Charcoal` (`#231B15` & `#4A3E38`)
  - *Alasan:* Kontras teks tinggi (rasio > 7:1) di atas Cream, jauh lebih hangat dan nyaman dibanding hitam pekat #000000.

### Warna Aksen Fungsional (Functional Accents)
- **Sunshine (`#FFCA26`):** Digunakan khusus untuk bintang rating, badge menu favorit/rekomendasi katering.
- **Tomato Burst (`#D42518`):** Digunakan khusus untuk badge diskon terbatas, batas waktu pembayaran, dan tombol pembatalan pesanan.
- **Kiwi (`#9ABC04`):** Digunakan untuk badge menu sehat / vegetarian / snack ringan.

---

## 4. Tipografi (Typography Hierarchy)
- **Font Family:** `Plus Jakarta Sans` / `Outfit` (Fallback: `system-ui, sans-serif`)
  - *Alasan:* Font humanist sans dengan geometri hangat yang modern, sangat cocok untuk industri kuliner Indonesia kontemporer dan memiliki keterbacaan tinggi di layar mobile kecil.
- **Skala Tipografi:**
  - `Display / Title (24sp, SemiBold)`: Nama menu utama, total pembayaran, judul beranda.
  - `Heading (18sp, SemiBold)`: Sub-bagian (Kategori, Detail Pesanan, Alamat).
  - `Body (14sp, Regular/Medium)`: Deskripsi menu, rincian lauk pauk, instruksi pengiriman.
  - `Caption (12sp, Medium)`: Rating, waktu pemesanan (lead time), status badge.

---

## 5. Bentuk Komponen & Spacing (Component Language)
- **Border Radius (R-11):**
  - Radius Terkendali: `12dp` untuk Card menu dan Container; `24dp` untuk Button CTA utama; `8dp` untuk Input Field dan Badge status.
  - *Aturan Anti-slop:* Menghindari semua komponen dibuat kapsul/pill seragam yang menghilangkan hierarki.
- **Elevasi & Shadow (R-12):**
  - Elevasi datar (flat surface) dengan garis tepi lembut `1px solid rgba(35, 27, 21, 0.08)`.
  - Hanya Floating Cart Bar dan Bottom Sheet yang menggunakan elevasi bayangan terarah (`blur 12, y: 4, opacity 0.06`).
- **Ikonografi (R-04):**
  - Hanya menggunakan ikon yang relevan dengan katering dan e-commerce kuliner (misal: sendok garpu, kotak bekal, kalender acara, pin alamat, bintang rating, keranjang belanja). Dilarang memasukkan ikon AI generic (sparkles/magic wand/lightning).

---

## 6. Copywriting & Bahasa (Anti-AI Voice)
- Menggunakan Bahasa Indonesia yang alami, bersahabat, dan jelas.
- Tombol aksi spesifik: "Pesan Menu Ini", "Tambah ke Keranjang", "Pilih Pembayaran", "Konfirmasi Pesanan" (bukan generic "Get Started" atau "Explore").
- Tanpa klaim palsu atau buzzword: Hindari "Katering Revolusioner Berbasis AI Tercanggih" atau "Didukung oleh 10,000+ Klien". Tampilkan fakta: menu lengkap, porsi jelas, opsi pengiriman terpercaya.

---

## 7. Status Pesanan & Feedback (R-27)
Sesuai alur PRD Bab 6 & 7:
1. `Menunggu Pembayaran` (Warna aksen Tomato Burst / Amber dengan countdown waktu)
2. `Diproses` (Warna Forest Green muda / Cooking icon)
3. `Dikirim` (Warna Crisp Carrot / Delivery icon)
4. `Selesai` (Warna Forest Green solid / Checkmark)
5. `Dibatalkan` (Warna abu netral bergaris merah)
Setiap empty state memberikan instruksi solusi yang jelas (misal: *"Keranjang Anda masih kosong. Cari menu lezat untuk acara Anda sekarang."*).