import struct,sys
BS=4096
inp,out=sys.argv[1],sys.argv[2]
sz=__import__('os').path.getsize(inp)
total=sz//BS
f=open(inp,'rb')
o=open(out,'wb')
# reservar header
o.write(b'\x00'*28)
chunks=0
run_type=None
run_blocks=0
run_data=[]
def flush():
    global chunks,run_type,run_blocks,run_data
    if run_type is None or run_blocks==0:
        return
    if run_type=='raw':
        o.write(struct.pack('<HHII',0xCAC1,0,run_blocks,12+run_blocks*BS))
        for d in run_data:
            o.write(d)
    else:
        o.write(struct.pack('<HHII',0xCAC3,0,run_blocks,12))
    chunks+=1
    run_type=None;run_blocks=0;run_data=[]
zero=b'\x00'*BS
for i in range(total):
    b=f.read(BS)
    if len(b)<BS:
        b=b+b'\x00'*(BS-len(b))
    t='dc' if b==zero else 'raw'
    if run_type is not None and t!=run_type:
        flush()
    run_type=t;run_blocks+=1
    if t=='raw':
        run_data.append(b)
flush()
o.seek(0)
o.write(struct.pack('<IHHHHIIII',0xED26FF3A,1,0,28,12,BS,total,chunks,0))
o.close();f.close()
print('blocks',total,'chunks',chunks)
