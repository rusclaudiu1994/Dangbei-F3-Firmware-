#!/usr/bin/env python3
"""extrage partitiile dintr-un fisier MstarUpgrade (ex. DangbeiF34GUpgrade.bin).
foloseste scriptul text de la inceputul fisierului (filepartload / mmc unlzo).
partitiile comprimate lzo sunt despachetate cu `lzop -dc` (apt install lzop).
utilizare: mstar_extract.py DangbeiF34GUpgrade.bin iesire/"""
import os, re, subprocess, sys
src, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)
script = open(src, 'rb').read(16384).split(b'%')[0].decode('latin1')
part = None; chunks = {}
for line in script.splitlines():
    m = re.match(r'# File Partition: (\S+)', line)
    if m: part = m.group(1); continue
    m = re.match(r'filepartload \S+ \$\(UpgradeImage\) (0x[0-9a-fA-F]+) (0x[0-9a-fA-F]+)', line)
    if m and part: chunks.setdefault(part, []).append((int(m.group(1), 16), int(m.group(2), 16)))
    if part and 'unlzo' in line: chunks.setdefault(part + '#lzo', [True])
with open(src, 'rb') as f:
    for p, lst in chunks.items():
        if p.endswith('#lzo'): continue
        lzo = (p + '#lzo') in chunks
        dst = os.path.join(out, p + '.img')
        with open(dst, 'wb') as o:
            for off, sz in lst:
                f.seek(off); data = f.read(sz)
                if lzo: data = subprocess.run(['lzop', '-dc'], input=data, capture_output=True, check=True).stdout
                o.write(data)
        print(p, os.path.getsize(dst))
