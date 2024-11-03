#!/usr/bin/python3
import sys,os,argparse,collections,hashlib,subprocess

##########################################################################
##########################################################################

g_verbose=False

def pv(msg):
    if g_verbose:
        sys.stdout.write(msg)
        sys.stdout.flush()

##########################################################################
##########################################################################

def fatal(msg):
    sys.stderr.write('FATAL: %s\n'%msg)
    sys.exit(1)

##########################################################################
##########################################################################

def load_file(path):
    with open(path,'rb') as f: return f.read()

##########################################################################
##########################################################################

def get_zx02_data(data,options):
    if options.zx02_path is None or options.zx02_cache_path is None:
        fatal('must specify --zx02 and --zx02-cache-path')

    if not os.path.isdir(options.zx02_cache_path):
        os.makedirs(options.zx02_cache_path)

    hash=hashlib.sha256(data).hexdigest()

    output_path=os.path.join(options.zx02_cache_path,'%s.zx02'%hash)
    if not os.path.isfile(output_path):
        input_path=os.path.join(options.zx02_cache_path,'%s.dat'%hash)
        with open(input_path,'wb') as f: f.write(data)

        argv=[options.zx02_path,input_path,output_path]
        subprocess.run(argv,check=True)

    return load_file(output_path)

##########################################################################
##########################################################################

LevelAddr=collections.namedtuple('LevelOffset','bank addr')
LevelSet=collections.namedtuple('LevelSet','name levels addrs hashes')

def main2(options):
    global g_verbose;g_verbose=options.verbose

    if options.rom_prefix_path is not None:
        with open(options.rom_prefix_path,'rb') as f: rom_prefix=f.read()
    else:
        rom_prefix=None
        if (options.rom_output_stem is not None or
            options.s65_output_path is not None):
            fatal('--rom-prefix must be provided when using --rom-output-stem or --s65-output')

    if len(options.input_paths)>16: fatal('max number of level sets is 16')

    level_sets=[]
    for input_path in options.input_paths:
        data=load_file(input_path)
        if len(data)<4 or data[0:4]!=b'\x60\xd7\x73\x0e':
            fatal('not a Ghouls level set: %s'%input_path)

        pv('%s: '%input_path)

        if data[4+2*575+20]&4:
            offset=0x900+201+161
            name=data[offset:offset+31].decode('ascii').rstrip()
        else: name='GHOULS'

        pv('%s\n'%name)

        levels=[]
        addrs=[]
        hashes=[]
        for i in range(4):
            offset=4+i*575
            level=data[offset:offset+575]
            levels.append(level)
            addrs.append(None)

            h=hashlib.sha256()
            h.update(bytes([level[18],     # player start X
                            level[10],     # player start Y
                            level[20]&2])) # standard goal flag
            h.update(level[55:575])        # level data

            hashes.append(h)

        level_sets.append(LevelSet(name=name,
                                   levels=levels,
                                   addrs=addrs,
                                   hashes=hashes))

    # uncompressed_size=0
    # compressed_size=0
    # for level_set in level_sets:
    #     for level in level_set.levels:
    #         uncompressed_size+=len(level)
    #         compressed_size+=len(get_zx02_data(level,options))
    # pv('%d/%d compressed'%(compressed_size,uncompressed_size))

    rom=None
    if rom_prefix is not None:
        rom=rom_prefix
        for level_set in level_sets:
            for i,level in enumerate(level_set.levels):
                addr=0x8000+len(rom)
                # Level name is uncompressed
                rom+=level[0:17]

                # Rest of data is compressed
                rom+=get_zx02_data(level[17:],options)

                if len(rom)>16384:
                    # Didn't expect it initially, but the compressed
                    # level data is super tiny. So I dodged a bit of
                    # work...
                    fatal('level data would take up >1 bank - TODO')

                level_set.addrs[i]=LevelAddr(bank=0,addr=addr)

    if options.s65_output_path is not None:
        with open(options.s65_output_path,'wt') as f:
            f.write('num_level_sets: .byte %d\n'%(len(level_sets)))

            f.write('level_set_names: .word %s\n'%(','.join(['level_set_%d_name'%i for i in range(len(level_sets))])))
            
            for i,level_set in enumerate(level_sets):
                f.write('level_set_%d_name: .text "%s",13\n'%(i,level_set.name))

            all_addrs=[]
            for level_set in level_sets: all_addrs+=level_set.addrs

            f.write('; Table indexes are level_set*4+level\n')
            # f.write('level_banks: .byte %s\n'%(','.join(['$%02x'%addr.bank for addr in all_addrs])))
            f.write('level_addrs_lo: .byte %s\n'%(','.join(['$%02x'%(addr.addr&0xff) for addr in all_addrs])))
            f.write('level_addrs_hi: .byte %s\n'%(','.join(['$%02x'%(addr.addr>>8) for addr in all_addrs])))

    if options.rom_output_stem is not None:
        with open('%s0'%options.rom_output_stem,'wb') as f: f.write(rom)

    # 0123456789012345678901234567890123456789
    # -ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

    if options.scores_output_path is not None:
        scores_data=b''
        for i in range(64):
            if i//4>=len(level_sets): digest=6*b'\x00'
            else: digest=level_sets[i//4].hashes[i%4].digest()[:6]

            scores_data+=digest
            scores_data+=b'\x99\x99' # time
            w=1*40*40+1*40+1
            scores_data+=bytes([w&0xff,w>>8,w&0xff,w>>8])

        with open(options.scores_output_path,'wb') as f:
            f.write(scores_data)

##########################################################################
##########################################################################

def main(argv):
    parser=argparse.ArgumentParser()

    parser.add_argument('-v','--verbose',action='store_true',help='be more verbose')
    parser.add_argument('--s65-output',dest='s65_output_path',metavar='FILE',help='''write metadata code to %(metavar)s''')
    parser.add_argument('--rom-output-stem',metavar='STEM',help='''write ROM data to %(metavar)s0, %(metavar)s1, etc.''')
    parser.add_argument('--rom-prefix',dest='rom_prefix_path',metavar='FILE',help='''read ROM prefix from %(metavar)s''')
    parser.add_argument('--zx02-cache-path',dest='zx02_cache_path',default=None,metavar='FOLDER',help='''use %(metavar)s as cache path for .zx02 files''')
    parser.add_argument('--zx02',dest='zx02_path',metavar='FILE',default=None,help='''use %(metavar)s as zx02 executable''')
    parser.add_argument('--scores-output',dest='scores_output_path',metavar='FILE',help='''output initial scores file to %(metavar)s''')
    parser.add_argument('input_paths',nargs='+',metavar='FILE',help='''read Ghouls level set(s) from %(metavar)s''')

    main2(parser.parse_args(argv[1:]))

##########################################################################
##########################################################################

if __name__=='__main__': main(sys.argv)
