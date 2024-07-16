#!/bin/bash

# Pobranie i rozpakowanie źródeł OpenSCAP
wget https://github.com/OpenSCAP/openscap/releases/download/1.3.10/openscap-1.3.10.tar.gz
tar -xvzf openscap-1.3.10.tar.gz
cd openscap-1.3.10

# Instalacja wymaganych pakietów
sudo apt install -y bzip2 build-essential cmake git libbz2-dev libcurl4-openssl-dev libgcrypt20-dev libglib2.0-dev libgnutls28-dev libpcap-dev libssh-dev libxml2-dev libxml2-utils libxmlsec1-dev libxslt1-dev xsltproc

# Budowanie i instalacja OpenSCAP
mkdir build
cd build/
cmake ..
make
make install
ldconfig

# Powrót do katalogu domowego i klonowanie repozytorium ComplianceAsCode
cd ~
git clone https://github.com/ComplianceAsCode/content.git
cd content/build
cmake ..

# Wyłączenie wszystkich opcji poza Ubuntu 22.04

# Ścieżka do pliku CMakeCache.txt
input_file="CMakeCache.txt"

# Sprawdzenie, czy plik CMakeCache.txt istnieje
if [[ ! -f "$input_file" ]]; then
    echo "Plik CMakeCache.txt nie został znaleziony. Upewnij się, że komenda cmake przebiegła pomyślnie."
    exit 1
fi

# Tymczasowy plik wyjściowy
temp_file=$(mktemp)

# Inicjalizacja zmiennej linii
line_number=0

# Przetwarzanie pliku linia po linii
while IFS= read -r line; do
    ((line_number++))
    if ((line_number >= 193 && line_number <= 296)) && [[ "$line" != "SSG_PRODUCT_UBUNTU2204:BOOL=ON" ]]; then
        # Zamień :BOOL=ON na :BOOL=OFF w odpowiednich liniach
        echo "${line/:BOOL=ON/:BOOL=OFF}" >> "$temp_file"
    else
        # Kopiuj linie bez zmian
        echo "$line" >> "$temp_file"
    fi
done < "$input_file"

# Zamień oryginalny plik tymczasowym
mv "$temp_file" "$input_file"

# Skompilowanie projektu
make

# Informacja o zakończeniu
echo "Proces zakończony pomyślnie."
