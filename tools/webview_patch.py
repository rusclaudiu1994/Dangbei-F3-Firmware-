#!/usr/bin/env python3
"""transforma bromite SystemWebView (org.bromite.webview, 106.0.5249.163, arm64)
in pachetul com.android.webview, ca sa poata inlocui webview-ul de sistem pe android 6.
schimba numele pachetului in AndroidManifest.xml si in tabelul de resurse (aceeasi lungime, 19 caractere).
dupa rulare: semneaza cu jarsigner si extrage lib/arm64-v8a si lib/armeabi-v7a in
/system/app/webview/lib/arm64 si /system/app/webview/lib/arm.
utilizare: webview_patch.py arm64_SystemWebView.apk iesire_nesemnat.apk"""
import struct, sys, zipfile
src, dst = sys.argv[1], sys.argv[2]
old, new = 'org.bromite.webview', 'com.android.webview'
z = zipfile.ZipFile(src)
m = z.read('AndroidManifest.xml')
pat = struct.pack('<H', 19) + old.encode('utf-16-le') + b'\0\0'
assert m.count(pat) == 1
m = m.replace(pat, struct.pack('<H', 19) + new.encode('utf-16-le') + b'\0\0')
a = bytearray(z.read('resources.arsc'))
off = struct.unpack_from('<HHI', a, 0)[1]
while off < len(a):
    t, hs, sz = struct.unpack_from('<HHI', a, off)
    if t == 0x0200:
        n = new.encode('utf-16-le'); a[off + 12:off + 12 + 256] = n + b'\0' * (256 - len(n))
    off += sz
o = zipfile.ZipFile(dst, 'w')
for i in z.infolist():
    if i.filename.startswith('META-INF/') and i.filename.rsplit('.', 1)[-1] in ('SF', 'RSA', 'DSA', 'EC', 'MF'): continue
    d = m if i.filename == 'AndroidManifest.xml' else bytes(a) if i.filename == 'resources.arsc' else z.read(i.filename)
    zi = zipfile.ZipInfo(i.filename, i.date_time); zi.compress_type = i.compress_type; zi.external_attr = i.external_attr
    o.writestr(zi, d)
o.close(); print('ok', dst)
