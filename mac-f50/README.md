# macOS B09 aracı

Apple Silicon ve Intel Mac için native `spd_dump` akışı. F50/MU300 pilsiz ve tamamen kapalıyken çalışır; `--kickto 2` B09 Windows aracındaki akışın karşılığıdır.

```sh
cd mac-f50
./install-mac.sh
./read-gpt-mac.sh
./backup-mac.sh
```

B09 ROM `.bin` dosyalarını repo kökündeki `zte-f50-b09/` klasörüne koyduktan sonra tam flash için:

```sh
./flash-b09-mac.sh ../zte-f50-b09
```

Flash komutu açıkça `FLASH` yazılmasını ister. Cihaz pilsiz/kapalı olmalı; araç bağlantıyı beklerken USB’yi takın. `vendor/` içindeki FDL ve UMS9620 exploit dosyaları sürüm varlıklarıdır. macOS’ta Homebrew ve `libusb` gerekir; Intel Mac’te installer yerel olarak derler.
