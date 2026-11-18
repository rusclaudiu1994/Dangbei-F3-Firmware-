#!/usr/bin/env python3
"""face sigla de pornire (boot0.jpg) si bootanimation.zip dintr-o poza:
poza pe un card cu colturi rotunjite, fundal inchis spre rosu, linie de incarcare jos.
utilizare: bootanim_make.py poza.jpg iesire/"""
import os, sys, zipfile
from PIL import Image, ImageDraw, ImageFilter
src, out = sys.argv[1], sys.argv[2]; os.makedirs(out, exist_ok=True)
W, H = 1920, 1080
photo = Image.open(src).convert('RGB')
bg = Image.new('RGB', (W, H)); d = ImageDraw.Draw(bg)
for y in range(H):
    t = y / (H - 1); d.line([(0, y), (W, y)], fill=(int(14 + 26 * t), int(14 - 8 * t), int(22 - 12 * t)))
ch = 880; sc = (ch - 40) / photo.size[1]; pw, ph = int(photo.size[0] * sc), int(photo.size[1] * sc); cw = pw + 40
cx, cy = (W - cw) // 2, 60
sh = Image.new('L', (W, H), 0); ImageDraw.Draw(sh).rounded_rectangle([cx + 6, cy + 14, cx + cw + 6, cy + ch + 14], radius=40, fill=150)
bg = Image.composite(Image.new('RGB', (W, H)), bg, sh.filter(ImageFilter.GaussianBlur(22)))
mask = Image.new('L', (cw, ch), 0); ImageDraw.Draw(mask).rounded_rectangle([0, 0, cw - 1, ch - 1], radius=40, fill=255)
card = Image.new('RGB', (cw, ch), (255, 255, 255)); card.paste(photo.resize((pw, ph), Image.LANCZOS), (20, 20))
bg.paste(card, (cx, cy), mask)
bg.save(os.path.join(out, 'boot0.jpg'), 'JPEG', quality=88, subsampling=2, progressive=False)
bw, bh, bx, by = 560, 8, (W - 560) // 2, 995
def frame(f, hl=None):
    im = bg.copy(); g = ImageDraw.Draw(im)
    g.rounded_rectangle([bx, by, bx + bw, by + bh], radius=4, fill=(70, 62, 66))
    if f > 0: g.rounded_rectangle([bx, by, bx + max(bh, int(bw * f)), by + bh], radius=4, fill=(225, 6, 0))
    if hl is not None:
        x0 = bx + int((bw + 120) * hl) - 120; a, b = max(bx, x0), min(bx + bw, x0 + 120)
        if b > a: g.rounded_rectangle([a, by, b, by + bh], radius=4, fill=(255, 120, 110))
    return im
z = zipfile.ZipFile(os.path.join(out, 'bootanimation.zip'), 'w', zipfile.ZIP_STORED)
z.writestr('desc.txt', '1920 1080 12\np 1 0 part0\np 0 0 part1\n')
import io
for i in range(48):
    t = (i + 1) / 48; b = io.BytesIO(); frame(1 - (1 - t) ** 2).save(b, 'JPEG', quality=85); z.writestr('part0/%03d.jpg' % i, b.getvalue())
for i in range(24):
    b = io.BytesIO(); frame(1.0, i / 23).save(b, 'JPEG', quality=85); z.writestr('part1/%03d.jpg' % i, b.getvalue())
z.close(); print('ok')
