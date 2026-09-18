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

## B09 A/B slot notu

Bu araç B09 flash işleminden sonra, reset öncesi Android'in **A slotunu** etkinleştirir.
B09 `super` imajındaki dinamik Android bölümleri `system_a`/`vendor_a` olarak
eşlenir. Cihaz B slotunu etkin bırakırsa `system_b` sıfır uzunluklu görünür,
`init` kapanır ve cihaz beyaz LED ile yeniden başlama döngüsüne girer.

B09 daha önce flash edilmişse ve bu durum oluştuysa, firmware'i tekrar yazmadan
yalnızca A/B boot-control kaydını değiştirmek için aşağıdakini çalıştırın:

```sh
./set-active-slot-a-mac.sh
```

Araç açık bir onay ister, sadece `misc+0x800` konumundaki 32 baytlık
boot-control kaydını yazar ve doğrulama için yeni bir `misc` kopyası kaydeder.
