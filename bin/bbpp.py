#!/usr/bin/python3
import sys,argparse,re,collections

##########################################################################
##########################################################################

SrcLine=collections.namedtuple('SrcLine','src_path src_number text')
BasicLine=collections.namedtuple('BasicLine','basic_number labels parts src_line')

ExprType=collections.namedtuple('StrExprType','expr begin end')
HexExprType=collections.namedtuple('HexExprType','expr begin end')
HexDigitsExprType=collections.namedtuple('HexExprType','expr begin end')
TextType=collections.namedtuple('TextType','text')
ConditionalType=collections.namedtuple('ConditionalType','expr begin end')

Label=collections.namedtuple('Label','name src_line src_column')

Value=collections.namedtuple('Value','name value src_line src_column')

class Any: pass

def add_text_part(parts,text):
    if len(parts)==0 and (len(text)==0 or text.isspace()): return None
    part=TextType(text=text)
    parts.append(part)
    return part

class OutputWriter:
    def __init__(self,path):
        self._path=path

    def __enter__(self):
        if self._path is None:
            self._f=None
            return sys.stdout
        else:
            self._f=open(self._path,'wt')
            return self._f

    def __exit__(self,exc_type,exc_value,traceback):
        if self._f is not None:
            self._f.close()
            self._f=None

def read_src_file(path,strip_trailing_spaces):
    src_lines=[]
    with open(path,'rt') as f:
        src_number=1
        for line in f.readlines():
            if strip_trailing_spaces: line=line.rstrip()
            elif line.endswith('\n'): line=line[:-1]

            src_lines.append(SrcLine(src_path=path,
                                     src_number=src_number,
                                     text=line))
            src_number+=1

    return src_lines

def loc_str(src_line,src_column):
    if src_line is None: return '<<command line>>'
    else: return '%s:%d:%d'%(src_line.src_path,
                             src_line.src_number,
                             src_column)

def main2(options):
    values_by_name={}
    
    def set_value(name,value,src_line,src_column):
        if name in values_by_name:
            sys.stderr.write('%s: already defined: %s\n'%(
                loc_str(src_line,src_column),
                name))
            value=values_by_name[name]
            if value.src_line is not None:
                sys.stderr.write('  %s: a previous definition of: %s\n'%(
                    loc_str(value.src_line,value.src_column),
                    name))
            
            sys.exit(1)

        values_by_name[name]=Value(name=name,
                                   value=value,
                                   src_line=src_line,
                                   src_column=src_column)

    for definition in options.definitions:
        parts=definition.split('=',1)
        name=parts[0]
        value=True if len(parts)==1 else parts[1]

        # try to turn it into something more useful...
        try: value=int(value,0)
        except:
            try: value=float(value)
            except:
                # how do you do this properly??
                if value=='True': value=True
                elif value=='False': value=False

        set_value(name,value,None,None)

    for path,prefix in options.asm_labels_files:
        with open(path,'rt') as f: src_lines=read_src_file(path,True)

        for src_line in src_lines:
            parts=src_line.text.split('=',1)
            if len(parts)!=2:
                sys.stderr.write('%s:%d: missing \'=\'\n'%(src_line.src_path,
                                                           src_line.src_number))
                sys.exit(1)

            name=prefix+parts[0].strip()

            # Since these are labels, they are numbers. So fix up
            # non-BBC hex syntax.
            value=parts[1].strip()
            if value.startswith('"') and value.endswith('"'):
                value=value[1:-1]
            elif value.startswith('$'): value=int(value[1:],16)
            else:
                try: value=int(value)
                except:
                    # Just ignore this case.
                    value=None
                    
            if value is not None: set_value(name,
                                            value,
                                            src_line,
                                            0)

    src_lines=read_src_file(options.input_path,
                            options.strip_trailing_spaces)

    basic_lines=[]
    next_basic_number=10
    basic_number_step=10
    next_line_labels=[]
    for src_line in src_lines:
        parts=[]
        begin=0
        end=None

        def syntax_error(begin,msg):
            sys.stderr.write('%s:%d:%d: %s\n'%(options.input_path,
                                               src_line.src_number,
                                               begin+1,
                                               msg))
            sys.exit(1)

        def add_expr(expr_type):
            parts.append(expr_type(expr=src_line.text[begin+1:end],
                                   begin=begin+1,
                                   end=end))
        
        while begin<len(src_line.text):
            end=src_line.text.find('{',begin)
            if end==-1:
                add_text_part(parts,src_line.text[begin:])
                begin=len(src_line.text)
            else:
                new_part=add_text_part(parts,src_line.text[begin:end])
                begin=end+1           # start of markup
                if begin>=len(src_line.text):
                    syntax_error(begin-1,'unterminated markup')
                    
                if src_line.text[begin]=='{':
                    # quoted {
                    add_text_part(parts,'{')
                    begin+=1
                elif src_line.text[begin]=='#':
                    # comment
                    if new_part is not None:
                        # Bit of a hack - remove any trailing spaces
                        # from last added text part.
                        #
                        # (This could probably be done more neatly,
                        # but that would mean I'd have had to actually
                        # think about it.)
                        parts[len(parts)-1]=TextType(text=new_part.text.rstrip())
                    break
                else:
                    end=src_line.text.find('}',begin)
                    if end==-1: syntax_error(begin-1,'unterminated markup')
                    
                    if src_line.text[begin]==':':
                        if len(parts)>0:
                            syntax_error(begin-1,'labels must be first thing on line')
                        next_line_labels.append(Label(src_line.text[begin+1:end],
                                                      src_line=src_line,
                                                      src_column=begin+1))
                    elif src_line.text[begin]=='$': add_expr(ExprType)
                    elif src_line.text[begin]=='~': add_expr(HexDigitsExprType)
                    elif src_line.text[begin]=='&': add_expr(HexExprType)
                    elif src_line.text[begin]=='?': add_expr(ConditionalType)
                    else: syntax_error(begin,'unknown markup type: %s'%src_line.text[begin])

                    begin=end+1

        # got a line?
        if len(parts)>0:
            basic_lines.append(BasicLine(basic_number=next_basic_number,
                                         labels=next_line_labels,
                                         parts=parts,
                                         src_line=src_line))
            next_basic_number+=basic_number_step
            next_line_labels=[]

    # assign labels and check for duplicates.
    for basic_line in basic_lines:
        for label in basic_line.labels:
            set_value(label.name,
                      basic_line.basic_number,
                      label.src_line,
                      label.src_column)

    # generate Python object tree that can be used as the locals dict
    # for expr.
    locals_root=Any()
    locals_root_names=set()
    for value in values_by_name.values():
        name_parts=value.name.split('.')
        assert len(name_parts)>0

        obj=locals_root
        for i in range(len(name_parts)):
            if i<len(name_parts)-1:
                next_obj=getattr(obj,name_parts[i],None)
                if next_obj is None:
                    next_obj=Any()
                    setattr(obj,name_parts[i],next_obj)
                obj=next_obj
            else:
                assert not hasattr(obj,name_parts[i])
                setattr(obj,name_parts[i],value.value)

            if i==0: locals_root_names.add(name_parts[i])

    locals_dict={}
    for name in locals_root_names:
        assert name not in locals_dict
        locals_dict[name]=getattr(locals_root,name)

    globals_dict={
        '__builtins__':{},
    }

    # print everything out.
    with OutputWriter(options.output_path) as f:
        for basic_line in basic_lines:
            def eval_expr(f,part):
                try: return eval(part.expr,globals_dict,locals_dict)
                except (SyntaxError,NameError) as e:
                    sys.stderr.write('%s: %s\n'%(
                        loc_str(basic_line.src_line,part.begin+1),
                        e))
                    sys.stderr.write('  Expression: %s\n'%part.expr)
                    sys.exit(1)
                
            def print_expr(f,part,must_be_int,fmt):
                value=eval_expr(f,part)
                if must_be_int and not isinstance(value,int):
                    sys.stderr.write('%s: not integer expression\n'%(
                        loc_str(basic_line.src_line,part.begin+1)))
                    sys.exit(1)
                f.write(fmt%value)

            f.write('%d'%basic_line.basic_number)
            pos=f.tell()
            for part in basic_line.parts:
                if type(part) is TextType: f.write(part.text)
                elif type(part) is ExprType: print_expr(f,part,False,'%s')
                elif type(part) is HexDigitsExprType: print_expr(f,part,True,'%X')
                elif type(part) is HexExprType: print_expr(f,part,True,'&%X')
                elif type(part) is ConditionalType:
                    value=eval_expr(f,part)
                    if not isinstance(value,bool):
                        sys.stderr.write('%s: not bool expression\n'%(
                            loc_str(basic_line.src_line,part.begin+1)))
                        sys.exit(1)
                    if not value: break
                else: assert False
            if f.tell()==pos:
                # nothing was written for this line. If there are any
                # labels, print a ':' so it's still available as a
                # GOTO or GOSUB target.
                #
                # This situation arises in Ghouls from using {? to
                # exclude a whole line in the debug version.
                #
                # This is a bodge and should be done better.
                if len(basic_line.labels)>0: f.write(':')
            f.write('\n')

##########################################################################
##########################################################################

def main(argv):
    parser=argparse.ArgumentParser('bbpp - BBC BASIC preprocessor')

    parser.add_argument('--strip-trailing-spaces',action='store_true',help='''strip trailing spaces from input lines''')

    parser.add_argument('--asm-symbols',dest='asm_labels_files',default=[],metavar='FILE PREFIX',nargs=2,action='append',help='''read asm symbols from FILE, creating value names by prepending PREFIX''')

    parser.add_argument('-D',metavar='DEFINE',action='append',dest='definitions',default=[],help='''define value. %(metavar)s can be NAME (value is True), or NAME=VALUE to assign a specific value''')

    parser.add_argument('-o',dest='output_path',metavar='FILE',help='''write output to %(metavar)s (or stdout if not specified)''')
    
    parser.add_argument('input_path',metavar='FILE',help='''read input from %(metavar)s''')

    main2(parser.parse_args(argv))

##########################################################################
##########################################################################
    
if __name__=='__main__': main(sys.argv[1:])
