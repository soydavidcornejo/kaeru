"""Reemplaza un PNG por uno negro del mismo tamano (sin dependencias).
Uso: python3 fondo_negro.py <archivo.png>"""
import struct
import sys
import zlib


def tamano(ruta):
    with open(ruta, 'rb') as f:
        cab = f.read(24)
    if cab[:8] != b'\x89PNG\r\n\x1a\n':
        raise SystemExit(f'{ruta} no es PNG')
    return struct.unpack('>II', cab[16:24])


def png_negro(ancho, alto):
    def trozo(tipo, datos):
        return struct.pack('>I', len(datos)) + tipo + datos + struct.pack('>I', zlib.crc32(tipo + datos) & 0xffffffff)
    fila = b'\x00' + b'\x00\x00\x00' * ancho
    return (b'\x89PNG\r\n\x1a\n'
            + trozo(b'IHDR', struct.pack('>IIBBBBB', ancho, alto, 8, 2, 0, 0, 0))
            + trozo(b'IDAT', zlib.compress(fila * alto, 9))
            + trozo(b'IEND', b''))


if __name__ == '__main__':
    ruta = sys.argv[1]
    a, h = tamano(ruta)
    with open(ruta, 'wb') as f:
        f.write(png_negro(a, h))
