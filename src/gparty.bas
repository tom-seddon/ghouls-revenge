HIMEM={&gmc_org}:PROCMODE(7):*RUN GPSETUP
{#*LOAD GPMC {~gmc_org}
{#*LOAD GPTIMES {~scores_addr}
CALL{&reset_envelopes}
{:gparty_main_loop}
PROCMODE(7)
FORL=0TO1:PRINTTAB(14,L)CHR$(129+L)CHR$141"GHOULS PARTY":NEXT
SSET=-1
{:gparty_levels_ui_loop}
PRINTTAB(0,3);
FORSET=0TO?{&num_level_sets}-1:A=!({&level_set_names}+SET*2)AND&FFFF:VDU65+SET:PRINTCHR$134$A;STRING$(37-LEN$A," ")
IFSET=SSET:FORL=0TO3:PRINT"  ";1+L;CHR$131;:Y%=SET*4+L:X%=19:CALL{&gp_print_level_name}:SA={&scores_addr}+Y%*12:PRINTCHR$135RIGHT$("0"+STR$~SA?6,2)"."RIGHT$("0"+STR$~SA?7,2)CHR$130;:PROCNAME(SA+8):PROCNAME(SA+10):PRINT:NEXT
NEXTSET
G%=GET
IFSSET>=0ANDG%>=ASC"1"ANDG%<=ASC"4":LEVEL=SSET*4+G%-ASC"1":GOTO{$gparty_game}
IFG%>=ASC"a"ANDG%<=ASC"z":G%=G%AND&DF
IFG%>=ASC"A"ANDG%<ASC"Z"+?{&num_level_sets}:SSET=G%-ASC"A"
GOTO{$gparty_levels_ui_loop}
{:gparty_game}
LDATA={&level_addr}{#I started out trying to change the code so all occurrences could be sorted out at compile time, but the tedium made me give up
PROCMODE(5)
{:gparty_game_loop}
FORF=1TO3:VDU19,F,0;0;:NEXT
X%=LEVEL:CALL{$gp_unpack_level}:!{&level_draw_ptr}={&level_addr}:A%=0:X%=0:Y%={$init_level_yflag_time_attack}:CALL{&entry_init_level}
GCOL0,1:VDU5:MOVE(20-LEN(${&level_addr+LevelData_name_offset}))*64,28:PRINT${&level_addr+LevelData_name_offset}:VDU4
!{&ghosts_table}=0:!{&ghosts_table+3}=0:COLOUR1{# TODO: ghosts_table+3 should probably be ghosts_table+4...
PRINTTAB(12,1)CHR${$udg_time+0}CHR${$udg_time+1}CHR${$udg_time+2}:!{&time_digits_address+2*16+4}=&60600000
GCOL0,1:MOVE0,60:DRAW0,952:MOVE1279,60:DRAW1279,952:GCOL0,2:MOVE0,952:PLOT21,1279,952
IF?{&level_addr+LevelData_flags_offset}AND{$LevelData_flags_no_standard_treasure})=0:GCOL0,1:MOVE1080,800:DRAW1080,860:GCOL0,2:MOVE1092,864:DRAW1270,864:FORF=0TO31STEP4:F!&5CE0=F!{&sprite_goal_row0}:F!&5E20=F!{&sprite_goal_row1}:NEXT
FORF=0TO31:F?{&data_behind_player}=0:NEXT
VDU23,0,1,0;0;0;0;:VDU19,1,1;0;19,2,3;0;19,3,?{&level_addr+LevelData_colour3_offset};0;
SOUND&12,4,0,18:SOUND&13,4,1,18:FORF=1TO40:VDU23,0,1,F;0;0;0;:*FX19
NEXT
!{&player_addr}=&5800+LDATA?{$LevelData_pl_start_x_offset}*16+(4+LDATA?{$LevelData_pl_start_y_offset})*320:CALL{&copy_data_behind_player}
?{&bonus_update_timer}=31
CALL{&entry_game}:*FX15
IF?{&level_finished}=255GOTO{$gparty_success}
SOUND&10,-15,3,18:FORF=200TO0STEP-.6:SOUND&11,0,F,1:NEXT:N=?{&player_addr+1}*256+?{&player_addr}:IF?(N+326)=224N=N+320 ELSEIF?(N-314)=224N=N-320
K=110:FORG={&sprite_pl_die_0} TO {&sprite_pl_die_7} STEP16:FORF=0TO15STEP4:F!N=F!G:NEXT
FORJ=K TO K+5STEP.3:SOUND&11,-12,J,1:SOUND&12,-12,J-12,1:NEXT:FORJ=K+5 TO K-10STEP-.8:SOUND&11,-12,J,1:SOUND&12,-12,J-12,1:NEXT:K=K-8:NEXT
FORF=0TO15STEP4:F!N=F!{&sprite_pl_die_8}:NEXT:FORG=0TO35STEP35:FORF=G TO G+40STEP1.5:SOUND&11,-15,F,1:NEXT:FORH=1TO400:NEXT:FORH=0TO15STEP4:H!N=H!{&data_behind_player}:NEXT,
FORF=1TO3000:NEXT
SOUND&10,4,4,18:CALL{&entry_slide_off}:VDU23,0,13,0;0;0;0;
GOTO{$gparty_game_loop}
{:gparty_success}
END
DEFPROCMODE(M):VDU22,M:ENDPROC
DEFPROCNAME(A):VDU?({&gp_scores_charset}+(!A AND&FFFF)DIV1600MOD40),?({&gp_scores_charset}+(!A AND&FFFF)DIV40MOD40),?({&gp_scores_charset}+(!A AND&FFFF)MOD40):ENDPROC
