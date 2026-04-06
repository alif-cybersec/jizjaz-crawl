#!/bin/bash

# ==============================================================================
# Script Name    : jizjaz-crawl.sh
# Description    : Security auditing tool for keyword crawling with context.
# Author         : Jizjaz Recon Team
# Usage          : ./jizjaz-crawl.sh <kata_kunci> <file_input.txt>
# ==============================================================================

# Definisikan Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Output File
OUTPUT_FILE="found_data.txt"

# Fungsi Banner ASCII
show_banner() {
    echo -e "${CYAN}"
    echo "#########################################################"
    echo "#                                                       #"
    echo "#   _____ _____ _____     _  _____ _____     _ _ _ _    #"
    echo "#  |     |     |__   |   | ||  _  |__   |   | | | | |   #"
    echo "#  |   --|  |  |  |  |   | ||     |  |  |   | | | | |   #"
    echo "#  |_____|_____|_____|___| ||__|__|_____|___|_______|   #"
    echo "#                    |_____|            |_____|         #"
    echo "#                                                       #"
    echo "#            JIZJAZ-CRAWL - Security Auditor            #"
    echo "#########################################################"
    echo -e "${NC}"
}

# Cek Argumen
if [ "$#" -lt 2 ]; then
    show_banner
    echo -e "${RED}[!] Error: Argumen kurang.${NC}"
    echo -e "${YELLOW}Usage: $0 <kata_kunci> <file_input_url.txt>${NC}"
    exit 1
fi

KEYWORD=$1
INPUT_FILE=$2

# Cek apakah file input ada
if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}[!] Error: File '$INPUT_FILE' tidak ditemukan!${NC}"
    exit 1
fi

show_banner

# Hitung total baris untuk progress bar sederhana
TOTAL_LINES=$(wc -l < "$INPUT_FILE")
CURRENT_COUNT=0

echo -e "${BLUE}[*] Target Keyword : ${YELLOW}$KEYWORD${NC}"
echo -e "${BLUE}[*] Input File     : ${YELLOW}$INPUT_FILE${NC}"
echo -e "${BLUE}[*] Output File    : ${YELLOW}$OUTPUT_FILE${NC}"
echo -e "${BLUE}[*] Memulai proses crawling...${NC}"
echo "---------------------------------------------------------"

# Loop membaca file input baris demi baris
while IFS= read -r URL || [ -n "$URL" ]; do
    # Lewati jika baris kosong
    [[ -z "$URL" ]] && continue
    
    ((CURRENT_COUNT++))
    
    # Indikator Progress
    echo -ne "${CYAN}[$CURRENT_COUNT/$TOTAL_LINES] Checking: ${NC}$URL\r"

    # Ambil konten URL menggunakan curl
    # -s: Silent mode, -L: Follow redirects, --max-time: Timeout 10 detik, -k: Ignore SSL errors
    CONTENT=$(curl -s -k -L --max-time 10 "$URL" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        # Jika curl gagal (misal: timeout atau koneksi error)
        # Clear line untuk pesan error agar tidak berantakan
        echo -e "\e[K${RED}[ERROR] URL: $URL | Reason: Connection Failed${NC}"
        continue
    fi

    # Ekstraksi semua kemunculan keyword dengan konteks 40 karakter (case-insensitive)
    # sort -u untuk menghindari duplikat konteks yang sama persis
    FINDINGS=$(echo "$CONTENT" | grep -oPi ".{0,40}$KEYWORD.{0,40}" | sort -u)
    
    if [[ -n "$FINDINGS" ]]; then
        # Bersihkan baris progress dan tampilkan URL yang ditemukan
        echo -e "\e[K${GREEN}[FOUND] URL: $URL${NC}"
        
        # Simpan URL ke file
        echo "[FOUND] URL: $URL" >> "$OUTPUT_FILE"

        # Loop setiap temuan konteks
        while read -r line; do
            [[ -z "$line" ]] && continue
            
            # Beri highlight pada keyword untuk terminal (Bold Yellow)
            # Menggunakan variabel warna agar konsisten
            HIGHLIGHTED=$(echo "$line" | sed -E "s!($KEYWORD)!\x1b[1;33m\1\x1b[0;32m!gI")
            
            # Tampilkan ke terminal dengan indentasi agar rapi
            echo -e "  ${GREEN}|-- Context: ...$HIGHLIGHTED...${NC}"
            
            # Simpan ke file (tanpa kode warna terminal)
            echo "  |-- Context: ...$line..." >> "$OUTPUT_FILE"
        done <<< "$FINDINGS"
        
        # Tambahkan separator di file output agar lebih terstruktur
        echo "---------------------------------------------------------" >> "$OUTPUT_FILE"
    fi

done < "$INPUT_FILE"

echo -e "\n---------------------------------------------------------"
echo -e "${GREEN}[V] Selesai! Hasil disimpan di: $OUTPUT_FILE${NC}"
