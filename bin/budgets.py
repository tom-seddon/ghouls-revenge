#!/usr/bin/python
import os,os.path,sys,argparse,hashlib

##########################################################################
##########################################################################

class Symbols: pass

##########################################################################
##########################################################################

def load_symbol_file(path):
    symbols=Symbols()
    with open(path,'rt') as f:
        for line in f.readlines():
            parts=line.split('=',1)
            if len(parts)==2:
                key=parts[0].strip()
                value=parts[1].strip()
                if value.startswith('$'): value='0x%s'%value[1:]
                try: value=int(value,0)
                except: pass
                setattr(symbols,key,value)

    return symbols

##########################################################################
##########################################################################

def main2(options):
    any_bad=False

    gmc_symbols=load_symbol_file(os.path.join(options.build_folder,'GMC.symbols'))
    gedmc_symbols=load_symbol_file(os.path.join(options.build_folder,'GEDMC.symbols'))
    gpmc_symbols=load_symbol_file(os.path.join(options.build_folder,'GPMC.symbols'))
    
    def budget(name,begin,end):
        nonlocal any_bad

        with open(os.path.join(options.path,name),'rb') as f: data=f.read()

        hasher=hashlib.sha1()
        hasher.update(data)
        
        max_n=end-begin
        rem=max_n-len(data)
        print('%d/%d (%d free) %s %s'%(len(data),
                                       max_n,
                                       rem,
                                       name,
                                       hasher.hexdigest()))
        if rem<0: any_bad=True

    PAGE=0x1100

    # the -1024 is supposed to give room for BASIC stack plus the GBAS
    # vars.
    budget('$.GBAS',PAGE,gmc_symbols.gmc_org-1024)
    budget('$.GBASD',PAGE,gmc_symbols.gmc_org-1024)
    budget('$.GMC',gmc_symbols.gmc_org,gmc_symbols.levels_org)
    budget('$.GEDMC',gedmc_symbols.gedmc_org,gedmc_symbols.gedmc_org+gedmc_symbols.max_gedmc_pages*256)
    budget('$.GLEVELS',gmc_symbols.levels_org,gmc_symbols.himem)
    budget('$.GRUN',0x1900,gmc_symbols.gedmc_levels_org)
    budget('$.GPARTY0',0x8000,0xc000)
    budget('$.GPMC',gpmc_symbols.gmc_org,gpmc_symbols.gmc_top)

    if any_bad: sys.exit(1)

##########################################################################
##########################################################################

def main(argv):
    parser=argparse.ArgumentParser()
    parser.add_argument('path',metavar='PATH',help='''find ghouls-tng files in %(metavar)s''')
    parser.add_argument('build_folder',metavar='FOLDER',help='''find symbol file in %(metavar)s''')
    main2(parser.parse_args(argv))

##########################################################################
##########################################################################
    
if __name__=='__main__': main(sys.argv[1:])
