"""Kamon de Kaeru: rana crema vista desde arriba dentro de un anillo, 侍蛙 y sello rojo.
Uso: render(fa, ring, ta) devuelve una imagen 480x800. Necesita Pillow y Noto Serif CJK (KAERU_FONT)."""
from PIL import Image, ImageDraw, ImageFont
import math
W,H=480,800; S=4
BG=(0,0,0); CREAM=(232,224,204); SEAL=(178,40,36); DIM=(150,140,118)
import os
FONT=os.environ.get('KAERU_FONT','/usr/share/fonts/opentype/noto/NotoSerifCJK-Bold.ttc')
def render(fa=1.0, ring=1.0, ta=1.0, wall=False):
    im=Image.new('RGB',(W*S,H*S),BG); d=ImageDraw.Draw(im)
    def k(v): return tuple(int(x*ta) for x in v)
    c=tuple(int(x*fa) for x in CREAM)
    rc=CREAM
    def P(x,y): return (x*S,y*S)
    def E(x,y,rx,ry,col): d.ellipse([x*S-rx*S,y*S-ry*S,x*S+rx*S,y*S+ry*S],fill=col)
    def L(pts,w,col):
        q=[P(*p) for p in pts]; d.line(q,fill=col,width=int(w*S),joint='curve')
        for p in pts: E(p[0],p[1],w/2,w/2,col)
    RX,RY=240,330; R=172
    if ring>0:
        d.arc([P(RX-R,RY-R),P(RX+R,RY+R)][0]+P(RX+R,RY+R),-90,-90+360*ring,fill=rc,width=int(4*S))
    ox,oy=240,318   # origen de la rana
    for sx in (-1,1):
        # pata trasera: cadera -> rodilla (costado) -> tobillo (atras, junto a cadera) -> pie hacia afuera
        hip=(ox+sx*34,oy+56); knee=(ox+sx*98,oy+38); ank=(ox+sx*64,oy+98); mid=(ox+sx*98,oy+110)
        L([hip,knee],19,c); L([knee,ank],13,c); L([ank,mid],8,c)
        for a in (-30,-5,20,45):
            ang=math.radians(a if sx>0 else 180-a)
            t=(mid[0]+math.cos(ang)*20, mid[1]+math.sin(ang)*20)
            L([mid,t],4.5,c); E(t[0],t[1],5,5,c)
        # pata delantera: hombro -> codo (afuera) -> mano (adelante/adentro)
        sh=(ox+sx*32,oy-2); el=(ox+sx*70,oy+16); wr=(ox+sx*84,oy-20)
        L([sh,el],12,c); L([el,wr],10,c)
        for a in (-115,-85,-55,-25):
            ang=math.radians(a if sx>0 else -180-a)
            t=(wr[0]+math.cos(ang)*15, wr[1]+math.sin(ang)*15)
            L([wr,t],4,c); E(t[0],t[1],4.5,4.5,c)
    # cuerpo (pera) + cabeza ancha
    E(ox,oy+40,46,56,c)
    E(ox,oy-40,52,36,c)
    E(ox,oy-4,40,30,c)
    # ojos salidos a los costados
    for sx in (-1,1):
        E(ox+sx*42,oy-60,16,15,c)
        E(ox+sx*46,oy-63,5.5,5.5,BG)
    if wall: return im.resize((W,H),Image.LANCZOS)
    # --- kanji vertical 侍 蛙 ---
    f=ImageFont.truetype(FONT,int(40*S),index=0)
    for i,ch in enumerate('侍蛙'):
        bb=d.textbbox((0,0),ch,font=f)
        d.text((240*S-(bb[2]-bb[0])/2-bb[0],(565+i*54)*S-bb[1]),ch,font=f,fill=k(DIM))
    # sello rojo con 蛙
    x0,y0,s=322,676,40
    d.rounded_rectangle([x0*S,y0*S,(x0+s)*S,(y0+s)*S],radius=int(4*S),fill=k(SEAL))
    f2=ImageFont.truetype(FONT,int(28*S),index=0); bb=d.textbbox((0,0),'蛙',font=f2)
    d.text(((x0+s/2)*S-(bb[2]-bb[0])/2-bb[0],(y0+s/2)*S-(bb[3]-bb[1])/2-bb[1]),'蛙',font=f2,fill=BG)
    return im.resize((W,H),Image.LANCZOS)
