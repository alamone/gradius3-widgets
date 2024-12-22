; Gradius 3 Arcade JP ver mod - display numeric lives and current loop & stage at bottom right
; FOR NEW VERSION

; zanki_screen_offset_1p = $14C19F
; zanki_screen_offset_2p = $14C1CF
; zanki_screen_offset = $14
; test_1p = $4007f

; constants - OLD and NEW version
stage_counter = $101051
loop_counter = $1039C3 ; loop_counter_store $101063 - @0069A8, is read as a byte, then shifted right by 1, then stored in loop_counter.  So for loop 2, "3" is read, then right shifted to "1", then +1 = 2nd loop
screen_position_loop1 = $14CE5B
screen_position_loop2 = $14CEDB
zanki_counter = $101050

; constants - OLD version
;free_space = $3fcd0

; constants - NEW version
free_space = $3fd9a

; patch address locations - OLD and NEW version
romram_check = $24a
original_zanki_routine = $1a72
display_widgets_injection = $0017FE
post_zanki_routine = $1a9a
zanki_display_injection = $1ACA

; patch address locations - OLD version
;stage_skip_dip_switch_check = $4266
;stage_skip_routine = $428A
;post_stage_skip_routine = $4292
;original_stageincrement_routine = $6958

; patch address locations - NEW version
stage_skip_dip_switch_check = $427C
stage_skip_routine = $42A0
post_stage_skip_routine = $42A8
original_stageincrement_routine = $696e
