# dangbei f3 (dbf3) – firmware, analiză și modificări

documentația modificărilor făcute pe proiectorul dangbei f3 (model `DBF3`, placă mstar 938 „mangosteen”, android 6.0, arm64), cu firmware-ul european. totul s-a făcut prin adb root (firmware-ul european e `userdebug`), fără reflash.

firmware-urile complete sunt în release-ul [`v1`](../../releases/tag/v1):

| fișier | versiune | build | tip |
|---|---|---|---|
| `DangbeiF34GUpgrade.bin` | 2.1.4.1 (`F3_EN`) | 22.06.2021, `TVOS.20210622.193057` | `userdebug` – are root prin adb, google play, play services |
| `DangbeiF34GUpgrade.CN.bin` | 3.1.2.3 (`F3464`) | 03.01.2023 | `user` – fără root, fără google, boot semnat |

ambele sunt android 6.0, cu același webview (2015) și același nivel de securitate (martie 2017). diferențele chinezești sunt doar aplicațiile dangbei (launcher lerad, huawei cast, screensaver, ota, sogou). detalii în [`docs/analiza-firmware.md`](docs/analiza-firmware.md).

## ce s-a modificat pe proiector

| # | modificare | script |
|---|---|---|
| 1 | adb peste wifi (`192.168.1.92:5555`) + `platform-tools` pe tableta windows | `pas1`–`pas2` |
| 2 | backup complet al partițiilor (mboot, boot, recovery, tee, tvconfig, tvdatabase, tvcustomer, tvservice, mpool) | `pas3`, `pas4`, `pas26` |
| 3 | certificatele lets encrypt isrg root x1 / x2 în `/system/etc/security/cacerts` | `pas4` |
| 4 | dezinstalat aptoide, hik-connect, wps (wps forțat prin ștergere, `pm uninstall` se bloca) | `pas7`–`pas10` |
| 5 | pornire fără „optimizare 1 din 3”: `dalvik.vm.dex2oat-flags=--no-watch-dog` (limita de 120 s omora compilarea play services) | `pas10` |
| 6 | ora automată: `auto_time=1`, `ntp_server=ro.pool.ntp.org`, fus `Europe/Bucharest` | `pas12` |
| 7 | webview 2015 → bromite 106.0.5249.163 instalat ca `com.android.webview` în `/system/app/webview` | `pas18`, `pas19` |
| 8 | smarttube (youtube fără reclame) și home assistant (varianta minimal) | `pas20`, `pas22` |
| 9 | siglă de pornire și animație proprii (poza pe card + linie de încărcare) | `pas24`, `pas27` |
| 10 | serviciul `touchpadd`: mouse virtual real (touchpad ca la laptop) + proxy pentru camera din home assistant | `pas31`–`pas35` |
| 11 | integrare home assistant „android debug bridge”, tab „proiector” cu telecomandă și touchpad | – |

scripturile `.bat` sunt în [`scripts/`](scripts), fiecare scrie un jurnal `proiector_logN.txt`. au nevoie de `platform-tools` (adb) în același folder. pentru revenire: `proiector_anulare_webview2.bat`, `proiector_anulare_poze.bat`.

## lucruri aflate pe parcurs

- **adb acceptă un singur client.** dacă home assistant e conectat, scripturile de pe tabletă nu se pot conecta (și invers). înainte de un script: dezactivezi integrarea în home assistant; la final scriptul face `adb kill-server`.
- **play services pe android 6:** google a oprit suportul în iulie 2026; versiunea 26.26 instalată merge, dar nu mai primește actualizări.
- **sigla de pornire nu se ia din fișier la fiecare pornire.** mboot copiază `/tvconfig/boot0.jpg` și `boot0.mp3` într-o „db table” din partiția `MPOOL` și pune `db_table=1` în mediul lui. ca să ia o siglă nouă: schimbi `boot0.jpg`, apoi pui `db_table=0` (ambele copii de mediu, la `0x1e0000` și `0x1f0000`, cu crc32 recalculat) – vezi [`tools/mpool_dbtable.py`](tools/mpool_dbtable.py).
- **webview-ul pe android 6** e citit doar din pachetul `com.android.webview` (`config_webViewPackageName` din framework-res). un overlay în `/vendor/overlay` a fost acceptat de idmap, dar ignorat la rulare; soluția care merge: bromite redenumit (manifest + numele pachetului din `resources.arsc`) pus direct în `/system/app/webview`, cu bibliotecile extrase în `lib/arm64` și `lib/arm` – vezi [`tools/webview_patch.py`](tools/webview_patch.py).
- **aplicația home assistant** (2026.11) crapă în webview 106 (sigtrap în `Chrome_InProcRendererThread`) la încărcarea interfeței – nerezolvat.
- **transferul de jpeg** prin fișierele claude e recomprimat pe drum; jpeg-urile se trimit ca text base64 și se decodează cu `certutil` pe windows.

## touchpadd

serviciu nativ (c, static aarch64, ~70 kb) în `/system/bin/touchpadd`, pornit la boot din `/system/bin/install-recovery.sh` (rulează ca root). sursa în [`src/touchpadd`](src/touchpadd), se construiește cu `src/touchpadd/build.sh` (zig: `pip install ziglang`).

- creează un mouse virtual prin `/dev/uinput` (rel x/y, rotiță, buton stânga/dreapta/mijloc); android îl tratează ca pe un mouse usb real.
- server http pe portul `8099`:
  - `/` – pagina de touchpad (un deget = mișcare, atingere = click, 2 degete = scroll, atingere cu 2 = click dreapta, butoane stânga/dreapta dedesubt, comutator pornit/oprit)
  - `/e?q=m,dx,dy;c,l;c,r;b,l,1;b,l,0;w,n` – evenimente
  - `/on`, `/off`, `/state` – mouse pornit/oprit; starea e fișierul `/data/local/tmp/touchpadd.off` (rămâne după repornire)
  - `/camera` – pagină cu imaginea live a camerei lui levi; `/cam.mjpg` – proxy mjpeg către `http://192.168.1.155:8123/api/camera_proxy_stream/camera.camera_levi`, cu tokenul din `/data/touchpadd/token` (doar root, `600`)

## aplicații (apk fără cod)

- [`apk/camera-levi`](apk/camera-levi) – iconița „camera levi”: `android.app.AliasActivity` care deschide `http://127.0.0.1:8099/camera` în brave.
- [`apk/webview-overlay`](apk/webview-overlay) – overlay pentru `config_webViewPackageName` (încercat, ignorat de sistem; păstrat ca referință).

## home assistant

- integrarea „android debug bridge” pe `192.168.1.92:5555`, entitate `media_player.proiector`.
- [`homeassistant/card_telecomanda_proiector.yaml`](homeassistant/card_telecomanda_proiector.yaml) – telecomanda (săgeți, ok, home, volum, aplicații). pagina de touchpad e pusă cu un card `iframe` spre `http://192.168.1.92:8099/` (merge doar din rețeaua locală sau prin vpn).

## ce nu e în repo

backup-urile partițiilor, tokenul home assistant, jurnalele și pozele personale de pornire nu sunt urcate (repo public). binarele mari (webview ~300 mb) se refac cu `tools/webview_patch.py` din `arm64_SystemWebView.apk` 106.0.5249.163 de pe github-ul bromite.
