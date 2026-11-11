"""Genera assets/bootanimation.zip y assets/kamon.png a partir de kamon.py.
Uso: python3 assets/kamon/animacion.py   (necesita Pillow y Noto Serif CJK)."""
import os, sys, math, zipfile, tempfile
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kamon as K

AQUI = os.path.dirname(os.path.abspath(__file__))
SALIDA = os.path.normpath(os.path.join(AQUI, '..'))
suave = lambda t: 0.5 - 0.5 * math.cos(math.pi * max(0, min(1, t)))

with tempfile.TemporaryDirectory() as tmp:
    for parte in ('part0', 'part1'):
        os.makedirs(os.path.join(tmp, parte))
    n = 0
    def guardar(img, parte):
        global n
        img.save(os.path.join(tmp, parte, f'{n:05d}.jpg'), quality=92); n += 1
    for i in range(18): guardar(K.render(fa=0, ring=suave((i + 1) / 18), ta=0), 'part0')   # el anillo se dibuja
    for i in range(12): guardar(K.render(fa=suave((i + 1) / 12), ring=1, ta=0), 'part0')   # aparece la rana
    for i in range(12): guardar(K.render(fa=1, ring=1, ta=suave((i + 1) / 12)), 'part0')   # aparece el texto
    n = 0; guardar(K.render(1, 1, 1), 'part1')                                            # cuadro fijo en bucle
    with open(os.path.join(tmp, 'desc.txt'), 'w') as f:
        f.write('480 800 12\np 1 0 part0\np 0 0 part1\n')
    # bootanimation.zip debe ir SIN compresion (stored)
    with zipfile.ZipFile(os.path.join(SALIDA, 'bootanimation.zip'), 'w', zipfile.ZIP_STORED) as z:
        z.write(os.path.join(tmp, 'desc.txt'), 'desc.txt')
        for parte in ('part0', 'part1'):
            for f in sorted(os.listdir(os.path.join(tmp, parte))):
                z.write(os.path.join(tmp, parte, f), f'{parte}/{f}')
K.render(1, 1, 1).save(os.path.join(SALIDA, 'kamon.png'))
print('ok:', os.path.join(SALIDA, 'bootanimation.zip'))
