# analiza firmware-ului dangbei f3

## format

`DangbeiF34GUpgrade.bin` e un fișier mstar „usb upgrade”: primii ~16 kb sunt un script text pentru mboot (`mmc create`, `filepartload`, `mmc unlzo`, `setenv`), apoi imaginile partițiilor. `system` și `cache` sunt comprimate lzo în bucăți (`mmc unlzo` / `unlzo.cont`). `boot` și `recovery` sunt criptate și semnate (`store_secure_info`, `authenticate`) – nu se pot citi sau modifica direct. extragere: [`tools/mstar_extract.py`](../tools/mstar_extract.py).

## partiții (emmc `mstar_mci.0`)

| partiție | mărime | rol |
|---|---|---|
| MBOOT | 3 mb | bootloader mstar (mboot) |
| MPOOL | 2 mb | mediul mboot (2 copii, 64 kb, la `0x1e0000` / `0x1f0000`) + „db table” cu sigla și sunetul de pornire |
| misc, recovery, boot, tee, RTPM, dtb, frc | – | standard / mstar |
| system | 2,2 gb (ext4) | android |
| cache | 1 gb | |
| tvservice | 160 mb | servicii tv mstar |
| tvconfig | 12 mb | `boot.ini`, `boot0.jpg`, `boot0.mp3`, baza de date tv |
| tvdatabase, tvcustomer | 8 / 16 mb | calibrări și setări |
| userdata | ~54 gb | date |

## european vs chinezesc

| | european 2.1.4.1 | chinezesc 3.1.2.3 |
|---|---|---|
| data build | 22.06.2021 | 03.01.2023 |
| android | 6.0 (api 23), patch 2017-03 | 6.0 (api 23), patch 2017-03 |
| tip build | `userdebug` (adb root) | `user` |
| webview | aosp „developer build” 2015 | același |
| google | gsf, play store 20.3, gms tv 20.12, katniss, youtube tv | lipsă |
| launcher | dangbei launcher 3.3.1 (engleză) | lerad launcher |
| extra | – | huawei cast, screensaver, asistent, ota, sogou |

concluzie: firmware-ul chinezesc nu aduce compatibilitate mai bună cu aplicațiile (tot android 6) și pierde root-ul; s-a rămas pe cel european, îmbunătățit.

## pornire

- `install-recovery.sh` rulează ca root la fiecare pornire (serviciul `flash_recovery`) – folosit pentru pornirea `touchpadd`.
- selinux: dezactivat (`androidboot.selinux=permissive`).
- `ro.adb.secure=1`, `service.adb.tcp.port=5555` (adb pe rețea pornit implicit).
