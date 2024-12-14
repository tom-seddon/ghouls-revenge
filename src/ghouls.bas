HIMEM={&gmc_org}
DIMHI(10),N$(10):FORF=0TO9:N$(F)=CHR$132+"Ghoul Basher "+STR$(F+1):HI(F)=(20-F)*10:NEXT:DIMTI(3):FORF=0TO3:TI(F)=9999:NEXT
{?debug}ONERROR:MODE7:REPORT:PRINT" at line ";ERL:END
{#LI1=0
LI1=4
{?not debug}ONERRORGOTO{$L1350}
SC1=1:GO1=0
CALL{&reset_envelopes}:GOTO{$L1350}
{:L70}
REM***** GHOULS *****
PROCMODE(5)
!{&score_bcd}=0:LI=LI1:SC=SC1:?{&L0AF2}=60:GO=GO1
GOSUB{$reset_bonus}
{:L100}
FORF=1TO3:VDU19,F,0;0;:NEXT
PRINTTAB(0,5);:COLOUR3:GCOL0,1
LDATA={&levels_org}+4+(SC-1)*{$LevelData_size}:!{&level_draw_ptr}=LDATA:A%=0:X%=GO:Y%=0:IFTA:Y%=Y%OR{$init_level_yflag_time_attack}
IF(LDATA?{$LevelData_flags_offset}AND{$LevelData_flags_invert_scoring})<>0:Y%=Y%OR{$init_level_yflag_invert_scoring}
CALL{&entry_init_level}
VDU5:MOVE(20-LEN($(LDATA+{$LevelData_name_offset})))*64,28:PRINT$(LDATA+{$LevelData_name_offset}):VDU4
!{&ghosts_table}=0:!{&ghosts_table+3}=0:COLOUR1{# TODO: ghosts_table+3 should probably be ghosts_table+4...
IFTA:PRINTTAB(12,1)CHR${$udg_time+0}CHR${$udg_time+1}CHR${$udg_time+2}:!{&time_digits_address+2*16+4}=&60600000:ELSEPRINTTAB(14,1)CHR${$udg_bonus+0}CHR${$udg_bonus+1}CHR${$udg_bonus+2};
GCOL0,1:MOVE0,60:DRAW0,952:MOVE1279,60:DRAW1279,952:GCOL0,2:MOVE0,952:PLOT21,1279,952
IF(LDATA?{$LevelData_flags_offset}AND{$LevelData_flags_no_standard_treasure})=0:GCOL0,1:MOVE1080,800:DRAW1080,860:GCOL0,2:MOVE1092,864:DRAW1270,864:FORF=0TO31STEP4:F!&5CE0=F!{&sprite_goal_row0}:F!&5E20=F!{&sprite_goal_row1}:NEXT
IFLI<=1GOTO{$L160}
FORF=0TO((LI-2)*16)STEP16:FORG=0TO15STEP4:G!(F+&7D80)=G!{&sprite_pl_facing}:G!(F+&7EC0)=G!{&sprite_pl_facing+16}:NEXT,
{:L160}
IFLI>0:GOSUB{$reset_bonus}
FORF=0TO31:F?{&data_behind_player}=0:NEXT
IFNOTTA:CALL{&L1698}:CALL{&draw_bonus_digits}{#FORF=0TO4:PRINTTAB(F,1)CHR$(F?{&score_chars}):NEXT
VDU23,0,1,0;0;0;0;:VDU19,1,1;0;19,2,3;0;19,3,LDATA?{$LevelData_colour3_offset};0;
SOUND&12,4,0,18:SOUND&13,4,1,18:FORF=1TO40:VDU23,0,1,F;0;0;0;:*FX19
NEXT
!{&player_addr}=&5800+LDATA?{$LevelData_pl_start_x_offset}*16+(4+LDATA?{$LevelData_pl_start_y_offset})*320:CALL{&copy_data_behind_player}
IFTA:GOTO{$ghosts_initialised}
FORF=0TO GO STEP2
IFLDATA?{$LevelData_flags_offset}AND{$LevelData_flags_has_ghost_rect}:F!{&ghosts_table}=&5D00+FNRND(LDATA?{$LevelData_ghost_min_x_offset},LDATA?{$LevelData_ghost_max_x_offset})*16+FNRND(LDATA?{$LevelData_ghost_min_y_offset},LDATA?{$LevelData_ghost_max_y_offset})*320:ELSE:F!{&ghosts_table}=&6000+(RND(300)*16)
NEXT
{:ghosts_initialised}
?{&bonus_update_timer}=31
?&7D=0 {# the asm doesn't seem to use &7D...
CALL{&entry_game}:*FX15
IF?{&level_finished}=255GOTO{$L370}
FORG=0TO4STEP2:N=G?{&ghosts_table+1}*256+G?{&ghosts_table}:IFN>&5800 FORF=0TO15STEP4:F!N=F!{&sprite_ghost_happy_row0}:F!(N+320)=F!{&sprite_ghost_happy_row1}:NEXT
NEXT:{# TODO N=?{&platform_addr+1}*256+?{&platform_addr}:FORF=0TO31STEP4:F!N=F!{&sprite_floating_platform}:NEXT:N=?{&spider_addr+1}*256+?{&spider_addr}:IFN>&5800 FORF=0TO31STEP4:F!N=F!{&sprite_spider_1_row0}:F!(N+320)=F!{&sprite_spider_1_row1}:NEXT
SOUND&10,-15,3,18:FORF=200TO0STEP-.6:SOUND&11,0,F,1:NEXT:N=?{&player_addr+1}*256+?{&player_addr}:IF?(N+326)=224N=N+320 ELSEIF?(N-314)=224N=N-320
K=110:FORG={&sprite_pl_die_0} TO {&sprite_pl_die_7} STEP16:FORF=0TO15STEP4:F!N=F!G:NEXT
FORJ=K TO K+5STEP.3:SOUND&11,-12,J,1:SOUND&12,-12,J-12,1:NEXT:FORJ=K+5 TO K-10STEP-.8:SOUND&11,-12,J,1:SOUND&12,-12,J-12,1:NEXT:K=K-8:NEXT
FORF=0TO15STEP4:F!N=F!{&sprite_pl_die_8}:NEXT:FORG=0TO35STEP35:FORF=G TO G+40STEP1.5:SOUND&11,-15,F,1:NEXT:FORH=1TO400:NEXT:FORH=0TO15STEP4:H!N=H!{&data_behind_player}:NEXT,
IFLI>0:LI=LI-1:IFLI=0GOTO{$L1000}
IFLI=0:IF?{&bonus_bcd}=0:GOTO{$L1000}
FORF=1TO3000:NEXT
SOUND&10,4,4,18:CALL{&entry_slide_off}:VDU23,0,13,0;0;0;0;
GOTO{$L100} 
NEXT
END
{:L370}
IFFNST:IF?{&player_addr}=192 FORJ=0TO15STEP4:J!&5CC0=0:J!&5CD0=J!{&sprite_pl_facing}:J!&5E00=0:J!&5E10=J!{&sprite_pl_facing+16}:NEXT
IFTA:GOTO{$after_completion_tune}
ENVELOPE1,2,-1,1,-1,1,1,1,0,-3,0,-1,126,90:RESTORE{$L1830}:FORF=1TO39:READP
SOUND&11,1,P,4:SOUND&12,1,P+1,4:SOUND&13,1,P-1,4:FORK=1TO200:NEXT
NEXT:FORF=1TO4000:NEXT
{:after_completion_tune}
CALL{&reset_envelopes}
?{&L0AF2}=?{&L0AF2}-5:IF?{&L0AF2}<20?{&L0AF2}=20
IFNOTTA:GOSUB{$reset_bonus}:SC=SC+1:IFSC=5:PROCtower(TRUE):GOTO{$L100}
*FX15
SOUND&11,2,2,50:SOUND&12,2,130,50
IFTA:GOTO{$after_level_completion}
IFFNST:FORF=0TO15STEP4:F!&5CE0=F!{&sprite_ghost_happy_row0}:F!&5CF0=F!{&sprite_ghost_happy_row0}:F!&5E20=F!{&sprite_ghost_happy_row1}:F!&5E30=F!{&sprite_ghost_happy_row1}:NEXT
FORF=1TO1000:NEXT
IFFNST:SOUND&10,1,2,2:FORF=0TO15STEP4:F!&5CD0=0:F!&5E10=0:NEXT:FORF=0TO15STEP4:F!&5A50=F!{&sprite_pl_facing}:F!&5B90=F!{&sprite_pl_facing+16}:NEXT:FORF=1TO500:NEXT:FORF=0TO15STEP4:F!&5A50=0:F!&5B90=0:NEXT
GCOL0,2:MOVE0,952:PLOT21,1279,952:COLOUR2:PRINTTAB(1,14)STRING$(18," ")TAB(1,16)STRING$(18," ")TAB(1,15)"ESCAPE TO LEVEL ";SC"."
{:after_level_completion}
FORF=1TO700:NEXT:SOUND&11,2,100,50:FORF=1TO4000:NEXT
G=999:F=999:H=999
VDU30:P%=&FFF4:A%=19:FORF=0TO31:CALLP%:FORO%=0TO4:NEXT:VDU11:NEXT
IFTA:GOSUB{$time_attack_end}:GOTO{$time_attack_restart}
CLS:GOTO{$L100}
END
DEFPROCtower(FULL):G=6:F=16:GO=GO+2:IFGO=6GO=4
IFNOTFULL:GOTO{$finish_sequence}
FORG=0TO4STEP2:N=G?{&ghosts_table+1}*256+G?{&ghosts_table}:IFN>&5800 FORF=0TO15STEP4:F!N=0:F!(N+320)=0:NEXT, ELSENEXT
SOUND&10,-15,7,255:FORJ=7TO0STEP-1:SOUND&11,-8,J*16,1:FORH=1TO200:NEXT
FORG=0TO4STEP2:N=G?{&ghosts_table+1}*256+G?{&ghosts_table}:IFN>&5800 FORF=J TO15STEPJ+1:F?N=F?{&sprite_ghost_happy_row0}:F?(N+320)=F?{&sprite_ghost_angry_row1}:NEXT
NEXT,:SOUND&10,0,0,0
IFNOTFNST:FORF=1TO2500:NEXT:GOTO{$finish_sequence}
FORF=1TO1000:NEXT:FORH=1TO5:SOUND&10,1,2,2:FORF=0TO15STEP4:F!&5CD0=0:F!&5E10=0:NEXT:FORF=0TO15STEP4:F!&5B90=F!{&sprite_pl_facing}:F!&5CD0=F!{&sprite_pl_facing+16}:NEXT:FORF=1TO200:NEXT:FORF=0TO15STEP4:F!&5B90=0:F!&5CD0=0:NEXT
GCOL0,2:MOVE0,952:PLOT21,1279,952
FORF=0TO15STEP4:F!&5CD0=F!{&sprite_pl_facing}:F!&5E10=F!{&sprite_pl_facing+16}:NEXT:FORF=1TO200:NEXT
NEXT:IFFNST:FORF=0TO15STEP4:F!&5CD0=F!{&sprite_pl_right_0}:F!&5E10=F!{&sprite_pl_right_0+16}:NEXT
{:finish_sequence}
FORF=1TO3000:NEXT:CLS:VDU28,0,9,19,0,19,3,6;0;:COLOUR3:PRINTTAB(0,1);:IF((?{&level_flags_text_completion} AND{$LevelData_flags_text})<>0):IFLEN(${$levels_org+TextData_offset+TextData_completion_offset})>0:PRINT${$levels_org+TextData_offset+TextData_completion_offset};:ELSE:PRINT"COMPLETION TEXT HERE";
FORG=-1TO-15STEP-.02:SOUND&11,G,0,30:SOUND&12,G,0,30:SOUND&13,G,2,30:NEXT
VDU19,1,0;0;19,2,0;0;:GCOL0,2:MOVE300,700:FORF=0TO360STEP20:IFF=80ORF=120GCOL0,1 ELSEGCOL0,2
IFF=100GCOL0,0
MOVE300,500:PLOT85,300+232*SINRADF,500+200*COSRADF:NEXT
GCOL0,0:MOVE308,500:DRAW532,500:VDU23,0,13,40;0;0;0;19,2,3;0;:CLS
G=3:FORF=40TO17STEP-1:VDU23,0,13,F;0;0;0;19,1,G;0;:IFG=3G=0:SOUND&10,-15,7,-1:FORI=175TO245STEP2:SOUND&11,0,I,1:NEXT ELSE G=3:SOUND&10,0,0,0:FORI=0TO35:SOUND&10,0,0,0:NEXT
NEXT:IFLI>0:LI=LI+1:IFLI>6LI=6
FORF=1TO3500:NEXT:SC=1:VDU19,1,0;0;19,2,0;0;23,0,13,0;0;0;0;26:CLS:ENDPROC
{:L1000}
FORF=1TO1500:NEXT:COLOUR2:FORF=13TO15:PRINTTAB(5,F)STRING$(10," "):NEXT:PROCPRNT(6,14,"THE  END",400,0)
FORF=1TO2000:NEXT:CALL{&entry_slide_off}
PROCMODE(7)
S=FNBCD(?{&score_bcd+0})+FNBCD(?{&score_bcd+1})*100+FNBCD(?{&score_bcd+2})*10000
SC=10:FORF=9TO0STEP-1:IFHI(F)<S SC=F
NEXT
IFSC=10GOTO{$high_score_table}
FORF=10TOSC+1 STEP-1:HI(F)=HI(F-1):N$(F)=N$(F-1):NEXT
FORF=1TO2:PRINTTAB(3,F)CHR$141CHR$129"C"CHR$130"O"CHR$131"N"CHR$132"G"CHR$133"R"CHR$134"A"CHR$135"T"CHR$129"U"CHR$130"L"CHR$131"A"CHR$132"T"CHR$133"I"CHR$134"O"CHR$135"N"CHR$129"S":NEXT
PROCPRNT(7,4,CHR$131+"YOU ARE IN THE TOP TEN",45,1):PROCPRNT(7,6,CHR$130+"PLEASE ENTER YOUR NAME",80,1)
IFSC=0A$=" st" ELSEIFSC=1A$=" nd" ELSEIFSC=2A$=" rd" ELSEIFSC>2A$=" th"
FORF=15TO16:PRINTTAB(13,F)CHR$141CHR$129CHR$136;SC+1;A$:NEXT
PRINTTAB(7,10)CHR$134CHR$157CHR$132STRING$(20," ")CHR$156
*FX15
L$="":K=10:P=0:L=0:F=.1:RESTORE{$L2020}
{:L1150}
IFINKEY(-74)=-1GOTO{$L1250}
{:L1160}
IFF<.4READG,F:IFG=-1RESTORE{$L2010}:GOTO{$L1160} ELSE SOUND&11,2,G+48,F/5.5:SOUND&12,2,G,F/5.5
IFF>=.4F=F-.8
P=P+1:IFP=10P=1:L=(L+1 AND3)
IFL=3PRINTTAB(K+1,10)"]"ELSE IFL=1PRINTTAB(K+1,10)"["
I=INKEY(0):IFI=-1GOTO{$L1150}
F=F-.48
IFI=127ANDK=10 GOTO{$L1150}
IFI=127 K=K-1:L$=LEFT$(L$,K-10):PRINTTAB(K+2,10)" ":GOTO{$L1150}
IFK=26 ORI<32ORI>127GOTO{$L1150} ELSEK=K+1:L$=L$+CHR$I:PRINTTAB(K,10);CHR$I:F=F-.3:GOTO{$L1150}
{:L1250}
PRINTTAB(K+1,10)" "
N$(SC)=L$:HI(SC)=S:CLS
{:high_score_table}
FORF=0TO1:PRINTTAB(21-LEN(FNHSTI)DIV2-2,F)CHR$141CHR$130FNHSTI:NEXT
FORF=0TO9:PRINTTAB(3,F*2+3)CHR$134;RIGHT$(" "+STR$(F+1),2)" ..."TAB(10,F*2+3)" "CHR$135:PROCPRNT(12,F*2+3,N$(F),6,1):PRINTTAB(29,F*2+3)CHR$131"... ";HI(F):NEXT
IFSC=255GOTO{$L1320}
IFSC<>10PRINTTAB(6,SC*2+3)CHR$136
IFSC=10 PRINTTAB(13,23)CHR$134"YOU SCORED ";S
{:L1320}
PRINTTAB(8,24)CHR$133"Press SPACE BAR to start";
{:L1330}
IFINKEY(0)<>32GOTO{$L1330}
GOTO{$score_mode_start}
{:L1350}
REM*** INSTRUCTIONS **
GOSUB{$banner}:SOUND&11,2,5,50:SOUND&12,2,5,50:SOUND&13,2,6,50:FORF=1TO2500:NEXT 
FORF=10TO11:PRINTTAB(0,F)CHR$141CHR$130"Do you want sound in the game?"CHR$134:NEXT
A$=GET$
{:L1430}
FORF=10TO11:PRINTTAB(33,F)A$:NEXT:IFA$<>"N"ANDA$<>"Y" ANDA$<>"n"ANDA$<>"y"GOSUB{$bad_input}:GOTO{$L1430}
IFA$="N"ORA$="n" THEN !&262=1 ELSE !&262=0{#?&262 is the value set by OSBYTE 210 - sound suppression status
{#Game type
GOSUB{$PROCCLR}
FORF=0TO1:PRINTTAB(4,7+F)CHR$141CHR$130"CLASSIC":NEXT:PRINTTAB(1,7)CHR$133"1."TAB(5,9)CHR$134"4 lives! Make them count"
FORF=0TO1:PRINTTAB(4,11+F)CHR$141CHR$130"INFINITE LIVES":NEXT:PRINTTAB(1,11)CHR$133"2."TAB(5,13)CHR$134"Don't let the bonus timer reach 0"
FORF=0TO1:PRINTTAB(4,15+F)CHR$141CHR$130"TIME ATTACK":NEXT:PRINTTAB(1,15)CHR$133"3."TAB(5,17)CHR$134"Choose the level, beat the time"
FORF=0TO1:PRINTTAB(0,22+F)CHR$141CHR$130"Select game mode (1-3):"CHR$134:NEXT
{:GETMODE}
*FX15
A$=GET$:IFASCA$<32ORASCA$>=127:A$=" "
{#FORF=0TO1:PRINTTAB(20,22+F)A$:NEXT
IFA$<>"1"ANDA$<>"2"ANDA$<>"3"GOSUB{$bad_input}:GOTO{$GETMODE}
LI1=0:IFA$="1"LI1=4
TA=A$="3"
{#REM***** BRIEF *****
GOSUB{$PROCCLR}
PRINTTAB(0,5);:IF((?{&level_flags_text_instructions} AND{$LevelData_flags_text})<>0):IFLEN(${&levels_org+TextData_offset+TextData_instructions_offset})>0:PRINT${&levels_org+TextData_offset+TextData_instructions_offset};:ELSE:PRINTCHR$134"LEVEL INSTRUCTIONS HERE";
IFPOS<>0:PRINT
{#PRINTTAB(1,5)CHR$134"Situated in a deadly"CHR$129"haunted"CHR$134"mansion,"'CHR$134"you have to rescue your power jewels"'CHR$134"from the horrid ghosts that stole them."
PRINTCHR$130" Your quest will force you to confront"'CHR$130"cracked and contracting floors, moving"'CHR$130"platforms, springs, deadly spikes,"'CHR$130"nasty spiders -"CHR$129"and the ghost itself."
PRINTCHR$131" By eating a stray power jewel, you can"CHR$131"overpower and paralyse the ghost for a"'CHR$131"few seconds. But will that be enough?"
PRINTCHR$134" Good luck."
FORF=21TO22:PRINTTAB(4,F)CHR$141CHR$133"Press SPACE BAR to continue":NEXT
*FX15
{:L1540}
I=GET:IFI<>32GOTO{$L1540}
GOSUB{$PROCCLR}
PRINTTAB(1,5)CHR$134"The keys are as follows..."
PRINT'TAB(8)CHR$131"""Z"""CHR$132"-"CHR$135"MOVES YOU LEFT"''TAB(8)CHR$131"""X"""CHR$132"-"CHR$135"MOVES YOU RIGHT"''TAB(8)CHR$131"""RETURN"""CHR$132"-"CHR$135"TO JUMP"
PRINT'TAB(8)CHR$131"""P"""CHR$132"-"CHR$135"PAUSES GAME"''TAB(8)CHR$131"""O"""CHR$132"-"CHR$135"CANCELS PAUSE"
PRINT'"   "CHR$131"""ESCAPE"""CHR$132"-"CHR$135"RETURNS TO SOUND OPTION"TAB(15)"AND INSTRUCTIONS"
FORF=20TO21:PRINTTAB(1,F)CHR$141CHR$133"DO YOU WANT TO SEE GAME OBJECTS?"TAB(13,F+2)CHR$141CHR$130"(Y/N)":NEXT
SC1=1
{:instructions_yn}
*FX15,1
I$=GET$:IFI$="Y" ORI$="y"PROCMODE(5):GOSUB{$PROCSHOW}:IFTA:GOSUB{$banner}:GOTO{$time_attack_select_level}
{?debug}IFNOTTA:IFI$="C"ORI$="c":PROCMODE(5):PROCtower(FALSE):GOTO{$L100}
{?debug}IFNOTTA:IFI$="G"ORI$="g":GOTO{$more_ghosts}
{?debug}IFNOTTA:SC1=1:IFI$>="1"ANDI$<="4":SC1=VALI$
IFTA:GOSUB{$PROCCLR}:GOTO{$time_attack_select_level}
{# definitely score mode game at this point
{:score_mode_start}
{?not debug}ONERRORGOTO{$score_mode_error}
GOTO{$L70}
{:more_ghosts}
GO1=GO1+2:IFGO1=6:GO1=0
PRINTTAB(0,24)"GHOSTS=";1+GO1 DIV2;
GOTO{$instructions_yn}
{:time_attack_select_level}
FORI=0TO3:Y=5+I*4:FORF=0TO1:PRINTTAB(4,Y+F)CHR$141CHR$130$({&levels_org+4+LevelData_name_offset}+I*{$LevelData_size}):NEXT:PRINTTAB(1,Y)CHR$133;1+I"."TAB(5,Y+2)CHR$134"Best time: ";TI(I)DIV100"."RIGHT$("0"+STR$(TI(I)MOD100),2)"""":NEXT
FORF=0TO1:PRINTTAB(1,22+F)CHR$141CHR$130"Select level (1-4):"CHR$134:NEXT
{:GETLEVEL}
A$=GET$:IFA$<"1"ORA$>"4"GOSUB{$bad_input}:GOTO{$GETLEVEL}
SC1=VALA$:GO=0{#no ghosts in time attack mode
{?not debug}ONERRORGOTO{$time_attack_restart}
GOTO{$L70}
{:PROCSHOW}
FORF=1TO3:VDU19,F,0;0;:NEXT
COLOUR2:PRINTTAB(4,1);"GAME OBJECTS"
N=&5BC0:FORF=0TO15STEP4:F!N=F!{&sprite_pl_facing}:F!(N+320)=F!{&sprite_pl_facing+16}:NEXT:COLOUR1:PRINTTAB(2,4)" = YOU!!"
N=N+960:FORF=0TO15STEP4:F!N=F!{&sprite_ghost_angry_row0}:F!(N+320)=F!{&sprite_ghost_angry_row1}:NEXT:COLOUR1:PRINTTAB(2,7)" = GHOUL"
N=N+960:FORF=0TO31STEP4:F!N=F!{&sprite_spider_1_row0}:F!(N+320)=F!{&sprite_spider_1_row1}:NEXT:COLOUR1:PRINTTAB(2,10)" = SPIDER"
N=N+960:FORF=0TO31STEP4:F!N=F!{&sprite_floating_platform}:NEXT:COLOUR1:PRINTTAB(2,12)" = MAGIC PLATFORM"
N=N+736:FORG=N TO N+196STEP8:FORF=0TO7STEP4:F!G=F!{&sprite_conveyor+8}:NEXT,:PRINTTAB(2,15)" = MOVING FLOOR":FORF=0TO15STEP4:F!{&0x5800+14*320+0*16}=F!{&sprite_block}:F!{&0x5800+14*320+18*16}=F!{&sprite_block}:F!{&0x5800+14*320+19*16}=F!{&sprite_block}:NEXT
N={&0x5800+17*320+0*16}:FORF=0TO15STEP4:F!N=F!{&sprite_spikes}:NEXT:PRINTTAB(3,17)"= DEADLY SPIKE"
N={&0x5800+19*320+0*16}:FORF=0TO15STEP4:F!N=F!{&sprite_spring_row0}:F!(N+320)=F!{&sprite_spring_row1}:NEXT:PRINTTAB(3,19)"= SUPER SPRING"
N=&7380:FORF=0TO15STEP4:F!N=F!{&sprite_power_pill}:NEXT:PRINTTAB(2,22)" = POWER JEWEL"
N={&0x5800+24*320+0*16}:FORF=0TO15STEP4:F!N=F!{&sprite_dots}:NEXT:PRINTTAB(3,24)"= STRAY EDIBLES!"
N={&0x5800+26*320+0*16}:FORF=0TO31STEP4:F!N=F!{&sprite_goal_row0}:F!(N+320)=F!{&sprite_goal_row1}:NEXT:COLOUR1:PRINTTAB(2,27)" = STOLEN JEWELS"
COLOUR2:PRINTTAB(0,29)"PRESS SPACE TO PLAY."
VDU19,1,1;0;19,2,3;0;19,3,4;0;
*FX15
{:L1790}
I=GET:IFI<>32GOTO{$L1790}
CALL{&entry_slide_off}:RETURN
*FX15
PRINT:PRINT:END
{:L1830}
DATA41,69,89,101,117,137,117,101,89,69
DATA33,61,81,97,109,129,109,97,81,61
DATA25,53,73,89,101,121,101,89,73,53,21,49,69,81,97,117,129,145,165
DATA-1
DEFPROCPRNT(X,Y,A$,L,H):SOUND&10,-15,3,255:SOUND&11,0,0,255
PRINTTAB(X,Y);:FORJ=1TO LENA$:G=ASCMID$(A$,J,1):IFG<>32AND H=1SOUND&11,0,G*2,0
PRINTMID$(A$,J,1);:FORG=1TOL:NEXT,:SOUND&11,0,0,0:SOUND&10,0,0,0:ENDPROC
{:PROCCLR}
SOUND&10,-15,7,255:FORF=23TO5STEP-1:SOUND&11,0,128+F*5,1:PRINTTAB(0,F)CHR$(128+(F AND7))CHR$157STRING$(38," ");:NEXT
FORF=23TO5STEP-1:SOUND&11,0,150+((F*300)AND105),1:PRINTTAB(0,F)STRING$(39," ");:NEXT:SOUND&10,0,0,0:RETURN
{:reset_bonus}
IFLI=0:?{&bonus_bcd}={&infinite_lives_bonus_bcd_value}:ELSE:?{&bonus_bcd}={&initial_bonus_bcd_value}
RETURN
{:bad_input}
PRINTTAB(0,20)CHR$129"INPUT NOT CORRECT, TRY AGAIN":SOUND&10,-15,2,1:A$=GET$:PRINTTAB(1,20)STRING$(48," ");:RETURN
{:L2010}
DATA5,16,17,16,33,16,53,16,37,24,37,8,33,8,25,8,17,8,13,8,5,16,17,16,33,16,53,16,65,32,61,28
{:L2020}
DATA5,20,13,8,17,16,5,16,25,20,33,8,37,16,25,16,33,20,37,8,33,8,25,8,17,8,13,8,-1,-1
END
DEFFNRND(N,X):=N+INT(RND(1)*((X+1)-N))
DEFPROCMODE(N):VDU22,N,23;11;0;0;0;:ENDPROC
{:time_attack_end}
F=FNBCD(?{&time_bcd+1})*100+FNBCD(?{&time_bcd}):IFF<TI(SC-1):TI(SC-1)=F
RETURN
DEFFNBCD(X)=X DIV16*10+X MOD16
{:banner}
{?not debug}ONERRORGOTO{$L1350}
PROCMODE(7):*FX15,1
FORF=1TO2:PRINTTAB(20-LEN(FNTI)DIV2-5,F)CHR$141CHR$(131-F)FNTI:NEXT:PRINTTAB(10,3)CHR$147"``,,,p";:IFLEN(FNTI)MOD2>0PRINT"p";
PRINT"p,,,``"
RETURN
{:score_mode_error}
PROCMODE(7):SC=10:S=0
{?not debug}ONERRORGOTO{$L1350}
GOTO{$high_score_table}
{:time_attack_restart}
GOSUB{$banner}
GOTO{$time_attack_select_level}
DEFFNTIA:IF(?{$level_flags_text_name}AND{$LevelData_flags_text})<>0:={&levels_org+TextData_offset+TextData_name_offset}:ELSE:=0
DEFFNTI:IFFNTIA<>0:=$FNTIA:ELSE:="G H O U L S"
DEFFNHSTI:IFFNTIA<>0:=$FNTIA+": TOP 10":ELSE:="TOP TEN TODAY"
DEFFNST:=(LDATA?{$LevelData_flags_offset}AND{$LevelData_flags_no_standard_treasure})=0