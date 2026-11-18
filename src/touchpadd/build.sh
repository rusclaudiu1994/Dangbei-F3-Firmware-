#!/bin/sh
# construieste touchpadd static pentru proiector (aarch64) cu zig (pip install ziglang)
set -e
cd "$(dirname "$0")"
python3 - <<'PY'
for src,name,out in (('page.html','PAGE','page.h'),('campage.html','CAMPAGE','campage.h')):
    h=open(src,'rb').read()
    open(out,'w').write('static const char %s[] = {%s,0};\n'%(name,','.join(str(b) for b in h)))
PY
python3 -m ziglang cc -target aarch64-linux-musl -static -Os -s -o touchpadd touchpadd.c
echo ok: touchpadd
