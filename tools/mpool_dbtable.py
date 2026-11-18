#!/usr/bin/env python3
"""seteaza db_table=0 in ambele copii ale mediului mboot din partitia MPOOL (dangbei f3 / mstar 938).
la urmatoarea pornire mboot recitește sigla (/tvconfig/boot0.jpg), muzica si setarile si isi reface copia.
copiile mediului: 0x1e0000 si 0x1f0000, 64 KiB fiecare, crc32 pe primii 4 octeti.
utilizare: mpool_dbtable.py MPOOL.img MPOOL_patched.img"""
import sys, zlib
d = bytearray(open(sys.argv[1], 'rb').read())
for off in (0x1e0000, 0x1f0000):
    blk = d[off:off + 0x10000]
    crc = int.from_bytes(blk[:4], 'little')
    assert zlib.crc32(bytes(blk[4:])) & 0xffffffff == crc, 'crc invalid la %x' % off
    i = blk.find(b'\0db_table=1\0'); assert i > 0, 'db_table=1 negasit la %x' % off
    blk[i + 10] = ord('0')
    blk[:4] = (zlib.crc32(bytes(blk[4:])) & 0xffffffff).to_bytes(4, 'little')
    d[off:off + 0x10000] = blk
open(sys.argv[2], 'wb').write(d); print('ok')
