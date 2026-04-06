# JIZJAZ-CRAWL 🕷️
**Contextual Sensitive Data Scraper for Security Auditing**

JIZJAZ-CRAWL adalah tool untuk melakukan scraping data sensitif (seperti password, token, atau API keys) dari daftar URL (hasil Katana/Waybackurls). Tool ini memberikan konteks 30 karakter di sekitar kata kunci yang ditemukan untuk mempermudah analisis.

## ✨ Fitur
- **Deep Scrape:** Mencari semua kemunculan keyword dalam satu file (Global Search).
- **Contextual Preview:** Mengambil 30 karakter sebelum dan sesudah keyword.
- **Auto-Save:** Hasil temuan otomatis tersimpan ke `found_data.txt`.
- **Clean UI:** Dilengkapi dengan ASCII banner dan progress tracker.

## 🚀 Cara Pakai
```bash
chmod +x jizjaz-crawl.sh
./jizjaz-crawl.sh "keyword" list_url.txt

Developed by alif-cybersec
