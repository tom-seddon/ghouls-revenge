HIMEM={&gmc_org}:PROCMODE(7):DIMNAMEBUF 8,PREVSA 12
*LOAD GPTIMES {~scores_addr}
CALL{&reset_envelopes}
ONERROR:IFERR=17:GOTO{$gparty_main_loop}:ELSE:MODE7:REPORT:PRINT" at line ";ERL:END
PLAYED=FALSE
SSET=-1
LEVEL=-1
{:gparty_main_loop}
PROCMODE(7)
*FX15 1
FORL=0TO1:PRINTTAB(14,L)CHR$(129+L)CHR$141"GHOULS PARTY":NEXT
HIGH=0:IFPLAYED:SA={&scores_addr}+LEVEL*12:IF(!{&time_bcd} AND&FFFF)<(SA!6 AND&FFFF):PREVSA!0=SA!0:PREVSA!4=SA!4:PREVSA!8=SA!8:SA?6=?{&time_bcd}:SA?7=?{&time_bcd+1}:HIGH=1
{:gparty_levels_ui_loop}
{#PRINTTAB(0,2)"S=";SSET" L=";LEVEL" PL=";PLAYED"        "
PRINTTAB(0,3);
FORSET=0TO?{&num_level_sets}-1:A=!({&level_set_names}+SET*2)AND&FFFF:VDU65+SET:PRINTCHR$134$A;STRING$(37-LEN$A," ")
IFSET<>SSET:GOTO{$nextset}
FORL=0TO3:PRINT"  ";1+L;CHR$131;:Y%=SET*4+L:X%=19:CALL{&gp_print_level_name}:SA={&scores_addr}+Y%*12:VDU135:PROCPRINTTIME(SA!6):VDU130
IFHIGH=1ANDY%=LEVEL:PRINT:ELSE:PROCNAME(SA+8):PROCNAME(SA+10):PRINT
IFHIGH>0ANDY%=LEVEL:PRINTTAB(9)CHR$134"PREVIOUS BEST";:VDU135:PROCPRINTTIME(PREVSA!6):VDU130:PROCNAME(PREVSA+8):PROCNAME(PREVSA+10):PRINT:
IFPLAYED ANDHIGH=0 ANDY%=LEVEL:PRINTTAB(15)CHR$134"LAST GO";:VDU135:PROCPRINTTIME(!{&time_bcd}):PRINT
NEXT
{:nextset}
NEXTSET
IFVPOS<24:FORI=VPOS TO24:PRINTTAB(0,I)STRING$(39," ");:NEXT
IFHIGH=1:PROCHIGHSCORE:HIGH=2:GOTO{$gparty_levels_ui_loop}
G%=FNTOUPPER(GET)
IFSSET>=0ANDG%>=ASC"1"ANDG%<=ASC"4":LEVEL=SSET*4+G%-ASC"1":GOTO{$gparty_game}
IFG%>=ASC"A"ANDG%<ASC"A"+?{&num_level_sets}:SSET=G%-ASC"A"
GOTO{$gparty_levels_ui_loop}
{:gparty_game}
PLAYED=FALSE
LDATA={&level_addr}{#I started out trying to change the code so all occurrences could be sorted out at compile time, but the tedium made me give up
PROCMODE(5)
{:gparty_game_loop}
FORF=1TO3:VDU19,F,0;0;:NEXT
X%=LEVEL:CALL{$gp_unpack_level}:!{&level_draw_ptr}={&level_addr}:A%=0:X%=0:Y%={$init_level_yflag_time_attack}:CALL{&entry_init_level}
GCOL0,1
VDU5:MOVE(20-LEN($(LDATA+{$LevelData_name_offset})))*64,28:PRINT$(LDATA+{$LevelData_name_offset}):VDU4:PROCCUR(0)
!{&ghosts_table}=0:!{&ghosts_table+3}=0:COLOUR1{# TODO: ghosts_table+3 should probably be ghosts_table+4...
PRINTTAB(12,1)CHR${$udg_time+0}CHR${$udg_time+1}CHR${$udg_time+2}:!{&time_digits_address+2*16+4}=&60600000
GCOL0,1:MOVE0,60:DRAW0,952:MOVE1279,60:DRAW1279,952:GCOL0,2:MOVE0,952:PLOT21,1279,952
IF(LDATA?{$LevelData_flags_offset}AND{$LevelData_flags_no_standard_treasure})=0:GCOL0,1:MOVE1080,800:DRAW1080,860:GCOL0,2:MOVE1092,864:DRAW1270,864:FORF=0TO31STEP4:F!&5CE0=F!{&sprite_goal_row0}:F!&5E20=F!{&sprite_goal_row1}:NEXT
FORF=0TO31:F?{&data_behind_player}=0:NEXT
VDU23,0,1,0;0;0;0;:VDU19,1,1;0;19,2,3;0;19,3,LDATA?{$LevelData_colour3_offset};0;
SOUND&12,4,0,18:SOUND&13,4,1,18:FORF=1TO40:VDU23,0,1,F;0;0;0;:*FX19
NEXT
!{&player_addr}=&5800+LDATA?{$LevelData_pl_start_x_offset}*16+(4+LDATA?{$LevelData_pl_start_y_offset})*320:CALL{&copy_data_behind_player}
?{&bonus_update_timer}=31
CALL{&entry_game}:*FX15,1
IFW%:GOTO{$gparty_success}
IF?{&level_finished}=255GOTO{$gparty_success}
SOUND&10,-15,3,18:FORF=200TO0STEP-.6:SOUND&11,0,F,1:NEXT:N=?{&player_addr+1}*256+?{&player_addr}:IF?(N+326)=224N=N+320 ELSEIF?(N-314)=224N=N-320
K=110:FORG={&sprite_pl_die_0} TO {&sprite_pl_die_7} STEP16:FORF=0TO15STEP4:F!N=F!G:NEXT
FORJ=K TO K+5STEP.3:SOUND&11,-12,J,1:SOUND&12,-12,J-12,1:NEXT:FORJ=K+5 TO K-10STEP-.8:SOUND&11,-12,J,1:SOUND&12,-12,J-12,1:NEXT:K=K-8:NEXT
FORF=0TO15STEP4:F!N=F!{&sprite_pl_die_8}:NEXT:FORG=0TO35STEP35:FORF=G TO G+40STEP1.5:SOUND&11,-15,F,1:NEXT:FORH=1TO400:NEXT:FORH=0TO15STEP4:H!N=H!{&data_behind_player}:NEXT,
FORF=1TO3000:NEXT
SOUND&10,4,4,18:CALL{&entry_slide_off}:VDU23,0,13,0;0;0;0;
GOTO{$gparty_game_loop}
{:gparty_success}
CALL{&reset_envelopes}
*FX15,1
SOUND&11,2,2,50:SOUND&12,2,130,50
FORF=1TO700:NEXT:SOUND&11,2,100,50:FORF=1TO4000:NEXT
G=999:F=999:H=999
VDU30:P%=&FFF4:A%=19:FORF=0TO31:CALLP%:FORO%=0TO4:NEXT:VDU11:NEXT
PLAYED=TRUE
GOTO{$gparty_main_loop}
DEFFNBCD(X)=X DIV16*10+X MOD16
DEFPROCMODE(M):VDU22,M:PROCCUR(0):ENDPROC
DEFPROCCUR(FLAG):VDU23,1,FLAG,0,0,0,0,0,0,0:ENDPROC
DEFPROCNAME(A):VDU?({&gp_scores_charset}+(!A AND&FFFF)DIV1600MOD40),?({&gp_scores_charset}+(!A AND&FFFF)DIV40MOD40),?({&gp_scores_charset}+(!A AND&FFFF)MOD40):ENDPROC
DEFFNTOUPPER(X):IFX>=ASC"a"ANDX<=ASC"z":=X AND&DF:ELSE:=X
DEFPROCPRINTTIME(A):PRINTRIGHT$("0"+STR$~((A AND&FF00)DIV256),2)"."RIGHT$("0"+STR$~(A AND&FF),2);:ENDPROC
DEFPROCPOKEW(A,X):?A=X:A?1=X DIV256:ENDPROC
DEFPROCHIGHSCORE
*FX15,1
NAMEBUF!0=0:NAMEBUF!4=0
Y=3+LEVEL DIV4+1+LEVEL MOD4
X=30
PRINTTAB(X,Y)"      "
N=0
PROCCUR(1)
{:gparty_highscore_loop}
PRINTTAB(X+N,Y);
G=FNTOUPPER(GET)
IFG=13:GOTO{$gparty_highscore_done}
IFG=127:IFN>0:N=N-1:PRINTTAB(X+N,Y)" ":GOTO{$gparty_highscore_loop}
I=INSTR(${$gp_scores_charset},CHR$G)
IFI=0:GOTO{$gparty_highscore_loop}
IFN>=6:GOTO{$gparty_highscore_loop}
NAMEBUF?N=I-1:N=N+1:VDUG
GOTO{$gparty_highscore_loop}
{:gparty_highscore_done}
PROCCUR(0)
FORI=N TO5:NAMEBUF?I=0:NEXT
SA={&scores_addr}+LEVEL*12
PROCPOKEW(SA+8,NAMEBUF?0*40*40+NAMEBUF?1*40+NAMEBUF?2)
PROCPOKEW(SA+10,NAMEBUF?3*40*40+NAMEBUF?4*40+NAMEBUF?5)
FORF=0TO3:PRINTTAB(0,11+F)CHR$132CHR$157STRING$(38," "):NEXT
FORF=0TO1:PRINTTAB(15,12+F)CHR$131CHR$141"SAVING":NEXT
*SAVE GPTIMES {~scores_addr} + 300 FFFFFFFF FFFFFFFF
ENDPROC
