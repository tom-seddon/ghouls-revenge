#!/usr/bin/python3
import sys,os,os.path,argparse,json

##########################################################################
##########################################################################

g_charset=' -ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?'
assert len(g_charset)==40

##########################################################################
##########################################################################

def fatal(msg):
    sys.stderr.write('FATAL: %s\n'%msg)
    sys.exit(1)

##########################################################################
##########################################################################

g_verbose=False

def pv(msg):
    if g_verbose:
        sys.stdout.write(msg)
        sys.stdout.flush()

##########################################################################
##########################################################################

def open_file(path,mode):
    try: return open(path,mode)
    except FileNotFoundError as e: fatal('not found: %s'%path)
    except: raise

def load_file(path,mode):
    with open_file(path,mode) as f: return f.read()

def load_times_file(path):
    data=load_file(path,'rb')
    if len(data)!=768: fatal('not a Ghouls Party times file: %s'%path)
    return data

def save_file(path,mode,data):
    with open_file(path,mode) as f: f.write(data)
    
##########################################################################
##########################################################################

def get_name(data,i):
    def get3(d):
        x=data[i+d]|data[i+d+1]<<8
        c0=g_charset[x//40//40%40]
        c1=g_charset[x//40%40]
        c2=g_charset[x%40]
        return c0+c1+c2

    return get3(0)+get3(2)

##########################################################################
##########################################################################

def t_cmd(options):
    with open_file(options.metadata_path,'rt') as f: metadata_j=json.load(f)

    times_data=load_times_file(options.times_path)
    
    count_by_player={}

    mismatch=False
    for level_set_idx,level_set_j in enumerate(metadata_j['level_sets']):
        print('%c. %s'%(chr(ord('A')+level_set_idx),level_set_j['name']))
        for level_idx,level_j in enumerate(level_set_j['levels']):
            time_index=level_set_idx*4+level_idx
            time_data=times_data[time_index*12:time_index*12+12]

            name=get_name(time_data,8)

            count_by_player[name]=count_by_player.get(name,0)+1

            sys.stdout.write('  %d. %20s: %02x.%02x"  %s'%
                             (level_idx,
                              level_j['name'],
                              time_data[7], # seconds
                              time_data[6], # 100ths
                              name,
                              ))

            time_hash=time_data[0:6].hex()
            level_hash=level_j['hash'][0:12]
            if level_hash.lower()!=time_hash.lower():
                sys.stdout.write(' - hash mismatch! Time hash: %s; level hash: %s'%(time_hash,level_hash))
                mismatch=True

            sys.stdout.write('\n')

    if options.players:
        print('Best Times Per Player:')
        counts=[(k,v) for k,v in count_by_player.items()]
        counts.sort(key=lambda x:x[1],reverse=True)
        for player,count in counts: print('  %-6s: %d'%(player,count))

    if mismatch: sys.exit(1)

##########################################################################
##########################################################################

def m_cmd(options):
    input_data=load_times_file(options.input_path)
    output_data=list(load_times_file(options.output_path))

    for oindex in range(64):
        ooffset=oindex*12
        for iindex in range(64):
            ioffset=iindex*12
            if input_data[ioffset:ioffset+6]==od[ooffset:ooffset+6]:
                otime=od[6]|od[7]<<8
                itime=id[6]|id[7]<<8
                if itime<otime:
                    for i in range(6,12):
                        output_data[ooffset+i]=input_data[ioffset+i]

##########################################################################
##########################################################################

def dump_cmd(options):
    data=load_times_file(options.times_path)

    for i in range(16):
        for j in range(4):
            offset=(i*4+j)*12
            print('%c%d. %02x.%02x" %s (hash=%s)'%
                  (chr(ord('A')+i),
                   1+j,
                   data[offset+7],
                   data[offset+6],
                   get_name(data,offset+8),
                   data[offset:offset+6].hex()))
                                                   
##########################################################################
##########################################################################

def set_times_cmd(options):
    input_data=list(load_times_file(options.input_path))
    output_data=list(load_times_file(options.output_path))

    for i in range(64):
        offset=i*12
        output_data[offset+6:offset+12]=input_data[offset+6:offset+12]

    save_file(options.output_path,'wb',bytes(output_data))

##########################################################################
##########################################################################

def main(argv):
    parser=argparse.ArgumentParser()

    parser.add_argument('-v','--verbose',dest='g_verbose',action='store_true',help='be more verbose')
    parser.set_defaults(fun=None)

    subparsers=parser.add_subparsers()

    dump_parser=subparsers.add_parser('dump',help='''dump info, no metadata required''')
    dump_parser.set_defaults(fun=dump_cmd)
    dump_parser.add_argument('times_path',metavar='TIMES-FILE',help='''read times from %(metavar)s''')

    m_parser=subparsers.add_parser('merge',aliases=['m'],help='''merge score files''')
    m_parser.set_defaults(fun=m_cmd)
    m_parser.add_argument('input_path',metavar='INPUT-FILE',help='''file to merge scores from''')
    m_parser.add_argument('output_path',metavar='OUTPUT-FILE',help='''file to merge scores into (will be overwritten)''')

    set_times_parser=subparsers.add_parser('set-times',help='''set times, going purely by index, no questions asked''')
    set_times_parser.set_defaults(fun=set_times_cmd)
    set_times_parser.add_argument('input_path',metavar='SRC',help='''input file to read times from''')
    set_times_parser.add_argument('output_path',metavar='DEST',help='''output file to have times+names written to (hashes will be retained)''')

    t_parser=subparsers.add_parser('times',aliases=['t'],help='''print best times files''')
    t_parser.set_defaults(fun=t_cmd)
    t_parser.add_argument('-p','--players',action='store_true',help='''summarize players''')
    t_parser.add_argument('metadata_path',metavar='METADATA-FILE',help='''read levels metadata from %(metavar)s''')
    t_parser.add_argument('times_path',metavar='TIMES-FILE',help='''read times from %(metavar)s''')

    options=parser.parse_args(argv[1:])
    if options.fun is None:
        parser.print_help()
        sys.exit(1)

    global g_verbose
    g_verbose=options.g_verbose

    options.fun(options)

##########################################################################
##########################################################################

if __name__=='__main__': main(sys.argv)
