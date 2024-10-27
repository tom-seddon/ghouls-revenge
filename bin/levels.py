#!/usr/bin/python3
import sys,os,os.path,argparse,html,collections,textwrap

##########################################################################
##########################################################################

def fatal(msg):sys.stderr.write('FATAL: %s\n'%msg);sys.exit(1)

def fatal_if(flag,msg):
    if flag:fatal(msg)
    else:sys.stderr.write('WARNING: %s\n'%msg)

##########################################################################
##########################################################################

# def pad(s,n):
#     assert isinstance(s,bytearray),type(s)
#     while len(s)<n:s.append(32)

##########################################################################
##########################################################################

def get_bytes(s):
    assert isinstance(s,str),type(s)
    b=bytearray()
    for i in range(len(s)):b.append(ord(s[i]))
    return b

##########################################################################
##########################################################################

# def read4(b,i):return b[i+0]|b[i+1]<<8|b[i+2]<<16|b[i+3]<<24

# def write4(b,i,x):b[i+0],b[i+1],b[i+2],b[i+3]=x&0xff,x>>8&0xff,x>>16&0xff,x>>24&0xff

##########################################################################
##########################################################################

Level=collections.namedtuple('Level','path bbc_file_name title designer difficulty instr')

##########################################################################
##########################################################################

def main2(options):
    # values exclude the trailing 13 included for convenient use with
    # BASIC's $ operator. 
    max_instructions_length=200
    max_title_length=30
    max_designer_length=25
    max_difficulty_length=25

    # output=bytearray()

    # output.append(0)

    # stride=max_instructions_length+max_title_length+max_designer_length+max_difficulty_length
    # for i in range(4):output.append(stride>>i*8&0xff)

    # level_paths=[]

    placeholders=True

    levels=[]

    def level(path,designer,difficulty,title=None):
        # path=os.path.join(options.volume_path,path)

        with open(path,'rb') as f:data=f.read()

        def flags(level):
            assert level>=0 and level<4,level
            return data[4+level*575+20]

        def get_text(offset,count,what):
            s=bytearray()
            for i in range(offset,offset+count):
                c=data[i]
                if c==13:break
                if c<32:fatal('bad char in %s text: %d (0x%x) (+%d) (+0x%x)'%(what,c,c,i,i))
                s.append(c)
            # pad(s,count)
            return s
        
        if len(data)!=11*256: fatal('not a Ghouls level (wrong size): %s'%path)
        if data[0]!=0x60 or data[1]!=0xd7 or data[2]!=0x73 or data[3]!=0x0e:
            fatal('not a Ghouls level (wrong magic number): %s'%path)
            
        if (flags(0)&4)==0:
            fatal_if(not placeholders,'no instructions text: %s'%path)
            instr=bytearray(b'placeholder instruction text')
            #pad(instr,max_instructions_length)
        else:instr=get_text(9*256+0,max_instructions_length,'instructions')
            
        if (flags(2)&4)==0:
            fatal_if(not placeholders and title is None,'no title: %s'%path)
            if title is None:title=get_bytes(os.path.split(path)[1])#bytearray(b'placeholder title')
            else:title=get_bytes(title)
            #pad(title,max_title_length)
        else:title=get_text(9*256+201+161,max_title_length,'title')

        designer_bytes=get_bytes(html.unescape(designer))
        if len(designer_bytes)>max_designer_length:fatal('designer name too long (max %d): %s'%(max_designer_length,designer))
        #pad(designer_bytes,max_designer_length)

        difficulty_bytes=get_bytes(html.unescape(difficulty))
        if len(difficulty_bytes)>max_difficulty_length:fatal('difficulty too long (max %d): %s'%(max_difficulty_length,difficulty))
        #pad(difficulty_bytes,max_difficulty_length)

        inf_path='%s.inf'%path
        if not os.path.isfile(inf_path):
            # adopt the BeebLink rules...
            bbc_file_name=os.path.split(path)[1]
            inf_path=None
        else:
            with open(inf_path,'rt') as f:lines=f.readlines()
            bbc_file_name=lines[0].split()[0]

        levels.append(Level(path=path,
                            bbc_file_name=bbc_file_name,
                            title=title,
                            designer=designer_bytes,
                            difficulty=difficulty_bytes,
                            instr=instr))

    level('build/$.GLEVELS','David Hoskins','Authentic','G H O U L S')
    level('beeb/ghouls-revenge/2/$.PRACTIC','Kieran','Introductory')
    level('beeb/ghouls-revenge/2/$.SPIDERS','Kieran','Spidery')
    level('beeb/ghouls-revenge/2/$.HEIGHTS','Kieran','Elevated')
    level('beeb/ghouls-revenge/2/$.ALTERN','Kieran','Indescribable')
    level('beeb/ghouls-revenge/2/$.GETOUT','Kieran','Extractive')
    level('beeb/ghouls-revenge/2/$.CAVES','Kieran','Subterranean')
    level('beeb/ghouls-revenge/2/$.EGYPT','Stew','Ancient')
    level('beeb/ghouls-revenge/2/$.MARS','Stew','Extraplanetary')
    level('beeb/ghouls-revenge/2/$.BOTNST','VectorEyes','Miniscule')
    level('beeb/ghouls-revenge/2/$.COLLECT','VectorEyes','Ineffable')
    level('beeb/ghouls-revenge/2/$.GLITCHS','VectorEyes','Unexpected')
    level('beeb/ghouls-revenge/2/$.MASH','Dave','Frightening')
    level('beeb/ghouls-revenge/2/$.MORE','Dave','Killer')
    level('beeb/ghouls-revenge/2/$.FACILIT','Tom','Trust No-one')
    level('beeb/ghouls-revenge/2/$.BSIDES','Kieran','Remixed')

    # Custom levels
    instr=b''
    for line in textwrap.wrap('Load levels designed in the editor. Infuriate your friends. Infuriate your enemies.',39):
        instr+=b'\x86'          # CHR$134
        instr+=get_bytes(line)
        while len(instr)%40!=0:instr+=b' '
        
    levels.append(Level(path=None,
                        bbc_file_name=None,
                        title=b'** YOUR LEVELS HERE **',
                        designer=b'You!',
                        difficulty=b'Your choice',
                        instr=instr))

    def centre_title(title):
        assert len(title)<32
        title=(16-len(title)//2)*b' '+title
        #title+=(32-len(title))*b' '
        return title

    def convert_bbc_file_name(x):
        if x is None:return b''
        else:return get_bytes(x)

    def write_output(f):
        f.write('num_levels=%d\n'%len(levels))
        f.write('title_length=32\n')
        f.write('instructions_length=%d\n'%max_instructions_length)
        f.write('designer_length=%d\n'%max_designer_length)
        f.write('difficulty_length=%d\n'%max_difficulty_length)

        fields=set()
        def write_field(name,fun=None,terminator=0):
            assert name not in fields
            fields.add(name)

            for level_idx,level in enumerate(levels):
                f.write('level%d_%s:\n'%(level_idx,name))
                value=getattr(level,name)
                if fun is not None:value=fun(value)
                bytes_per_line=40
                for offset in range(0,len(value),bytes_per_line):
                    line=[]
                    string_part=None

                    def end_string_part():
                        nonlocal string_part
                        if string_part is not None:
                            string_part+='"'
                            line.append(string_part)
                            string_part=None

                    for offset2 in range(bytes_per_line):
                        if offset+offset2>=len(value):break
                        c=value[offset+offset2]
                        if c>=32 and c<=126:
                            if string_part is None:string_part='"'
                            string_part+=chr(c)
                        else:end_string_part();line.append(str(c))
                    end_string_part()
                    f.write('    .text %s\n'%','.join(line))
                if terminator is not None:
                    f.write('    .byte %d\n'%terminator)

            def write_addrs(suffix,operator):
                f.write('level_%s_addrs_%s:\n'%(name,suffix))
                for level_idx in range(len(levels)):
                    f.write('    .byte %slevel%d_%s\n'%(operator,level_idx,name))
            write_addrs('lo','<')
            write_addrs('hi','>')

        write_field('title',fun=centre_title)
        write_field('designer')
        write_field('difficulty')
        write_field('instr')
        write_field('bbc_file_name',fun=convert_bbc_file_name,terminator=13)

    if options.output_path is not None:
        if options.output_path=='-':write_output(sys.stdout)
        else:
            with open(options.output_path,'wt') as f:write_output(f)

    if options.output_list_path is not None:
        with open(options.output_list_path,'wt') as f:
            for level in levels:
                if level.path is not None:f.write(' "%s"'%level.path)
            f.write('\n')

##########################################################################
##########################################################################

def main(argv):
    parser=argparse.ArgumentParser()
    parser.add_argument('-o','--output',dest='output_path',metavar='FILE',help='''write output to %(metavar)s. Specify - for stdout''')
    parser.add_argument('--output-list',dest='output_list_path',metavar='FILE',help='''write GNU Make syntax level files list to %(metavar)s''')
    main2(parser.parse_args(argv[1:]))

##########################################################################
##########################################################################

if __name__=='__main__':main(sys.argv)
