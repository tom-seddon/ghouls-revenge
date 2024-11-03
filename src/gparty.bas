CLOSE#0:HIMEM={&gmc_org}:PROCMODE(7):*LOAD GPMC {~gmc_org}
CALL{&reset_envelopes}
FORSET=0TO?{&num_level_sets}-1:ADDR=!({&level_set_names}+SET*2)AND&FFFF:PRINT$ADDR
FORL=0TO3:PRINT"  ";L". ";:X%=25:Y%=SET*4+L:CALL{&gp_print_level_name}:PRINT"*":NEXT
NEXT
END
DEFPROCMODE(M):VDU22,M:ENDPROC
