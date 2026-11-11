"""Cambia los colores de Olauncher (fuente decodificada con apktool).
- Blancos del texto -> crema, con la misma transparencia.
- Acento del tema oscuro -> rojo del sello.
Uso: python3 colores_olauncher.py <carpeta-apktool> <crema-hex> <rojo-hex>"""
import os
import re
import sys

src, crema, rojo = sys.argv[1], sys.argv[2].lower(), sys.argv[3].lower()
BLANCOS = {'white': 'ff', 'whiteTrans50': '80', 'whiteTrans80': 'cc', 'whiteTrans90': 'e6'}

ruta = os.path.join(src, 'res/values/colors.xml')
s = open(ruta).read()
cambios = 0
for nombre in BLANCOS:
    patron = re.compile(r'(<color name="%s">#)([0-9a-fA-F]{2})?[0-9a-fA-F]{6}(</color>)' % nombre)
    def cambiar(m):
        alfa = m.group(2) or 'ff'
        return f'{m.group(1)}{alfa}{crema}{m.group(3)}'
    s, n = patron.subn(cambiar, s)
    cambios += n
open(ruta, 'w').write(s)

ruta = os.path.join(src, 'res/values-night/styles.xml')
s = open(ruta).read()
s, n = re.subn(r'(<item name="colorAccent">)[^<]*(</item>)', r'\g<1>#ff%s\g<2>' % rojo, s)
open(ruta, 'w').write(s)
cambios += n
if cambios < 2:
    raise SystemExit('no se encontraron los colores de Olauncher: cambio la version?')
print(f'   {cambios} colores cambiados')
