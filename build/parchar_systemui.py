"""Agrega un filtro de rebote a la rueda de volumen del FiiO M9.

La rueda manda pasos extra 60-130 ms despues de cada clic (falla mecanica comun).
Este parche entra al inicio de VolumeControlActivityForM9.onKeyDown y descarta un paso
de volumen si llega muy pronto despues del anterior:
  - misma direccion:  persist.kaeru.dbnc_same (por defecto 140 ms)
  - direccion opuesta: persist.kaeru.dbnc_rev  (por defecto 300 ms)
Las teclas mantenidas (repeticion) no se filtran.

Uso: python3 parchar_systemui.py <VolumeControlActivityForM9.smali> [misma_ms] [reversa_ms]
"""
import re
import sys

C = 'Lcom/android/systemui/fiio/volume/VolumeControlActivityForM9;'
MARCA = ':dbnc_done'


def bloque(misma, reversa):
    return f'''    invoke-virtual {{p2}}, Landroid/view/KeyEvent;->getRepeatCount()I
    move-result v0
    if-nez v0, :dbnc_done
    const/4 v1, 0x1
    const/16 v0, 0x18
    if-eq p1, v0, :dbnc_check
    const/4 v1, -0x1
    const/16 v0, 0x19
    if-ne p1, v0, :dbnc_done
    :dbnc_check
    invoke-static {{}}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v2
    sget-wide v4, {C}->mLastStepTime:J
    sub-long v6, v2, v4
    sget v0, {C}->mLastDir:I
    if-eq v0, v1, :dbnc_same
    const-string v0, "persist.kaeru.dbnc_rev"
    const/16 v4, {hex(reversa)}
    goto :dbnc_prop
    :dbnc_same
    const-string v0, "persist.kaeru.dbnc_same"
    const/16 v4, {hex(misma)}
    :dbnc_prop
    invoke-static {{v0, v4}}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I
    move-result v0
    int-to-long v4, v0
    cmp-long v0, v6, v4
    if-ltz v0, :dbnc_reject
    sput-wide v2, {C}->mLastStepTime:J
    sput v1, {C}->mLastDir:I
    goto :dbnc_done
    :dbnc_reject
    const-string v0, "KaeruDbnc"
    const-string v1, "rebote descartado"
    invoke-static {{v0, v1}}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    const/4 v0, 0x1
    return v0
    :dbnc_done
'''.rstrip('\n').split('\n')


def parchar(texto, misma=140, reversa=300):
    if MARCA in texto:
        raise SystemExit('el archivo ya tiene el parche')
    s = texto.split('\n')
    # 1) campos estaticos nuevos, despues del primer .field
    i = next(k for k, l in enumerate(s) if l.startswith('.field '))
    s[i:i] = ['.field private static mLastStepTime:J', '', '.field private static mLastDir:I', '']
    # 2) metodo onKeyDown: necesita al menos 8 registros locales (v0-v7) + 3 parametros
    m = next(k for k, l in enumerate(s) if l.startswith('.method public onKeyDown(ILandroid/view/KeyEvent;)Z'))
    r = next(k for k in range(m, len(s)) if s[k].strip().startswith('.registers'))
    n = int(s[r].split()[1])
    s[r] = re.sub(r'\d+', str(max(n, 11)), s[r], count=1)
    pro = next(k for k in range(m, len(s)) if s[k].strip() == '.prologue')
    s[pro + 1:pro + 1] = bloque(misma, reversa)
    return '\n'.join(s)


if __name__ == '__main__':
    ruta = sys.argv[1]
    misma = int(sys.argv[2]) if len(sys.argv) > 2 else 140
    reversa = int(sys.argv[3]) if len(sys.argv) > 3 else 300
    with open(ruta) as f:
        nuevo = parchar(f.read(), misma, reversa)
    with open(ruta, 'w') as f:
        f.write(nuevo)
    print(f'   parche de rueda aplicado ({misma} ms misma direccion, {reversa} ms reversa)')
