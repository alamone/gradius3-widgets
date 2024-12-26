; Gradius 3 Arcade JP ver mod - display numeric lives and current loop & stage at bottom right

; rom_version:	equ 0	; OLD = 0, NEW = 1
soundtestbgm: equ 0    ; set to 1 to change sound test to BGM only

; zanki_screen_offset_1p = $14C19F
; zanki_screen_offset_2p = $14C1CF
; zanki_screen_offset = $14
; test_1p = $4007f

; constants - common
stage_counter = $101051
loop_counter = $1039C3 ; loop_counter_store $101063 - @0069A8, is read as a byte, then shifted right by 1, then stored in loop_counter.  So for loop 2, "3" is read, then right shifted to "1", then +1 = 2nd loop
screen_position_loop1 = $14CE5B
screen_position_loop2 = $14CEDB
screen_position_pause = $14C83B
zanki_counter = $101050
last_bgm_played = $43f70
watchdog_timer = $e0000
in_game = $40005
sound_latch = $e8000
sound_irq = $f0000
start_button_state = $c8000

; constants - OLD and NEW version
 if rom_version=0
;free_space = $3fcd0 ; starting from FF
;free_space = $3fca0 ; starting from 00
free_space = $D424
 else
;free_space = $3fd9a ; starting from FF
;free_space = $3fd6a ; starting from 00
free_space = $D4AA
 endc

; patch address locations - common
romram_check = $24a
original_zanki_routine = $1a72
zanki_routine_return = $1a9a
display_widgets_injection = $17FE
zanki_display_injection = $1ACA
sound_play_routine = $2B5C
start_button_buffer_routine = $33B0
start_button_buffer_routine_return = $33F0

; patch address locations - OLD version
 if rom_version=0
stage_skip_dip_switch_check = $4266
stage_skip_routine = $428A
stage_skip_routine_return = $4292
original_stage_increment_routine = $6958
 else
; patch address locations - NEW version
stage_skip_dip_switch_check = $427C
stage_skip_routine = $42A0
stage_skip_routine_return = $42A8
original_stage_increment_routine = $696e
 endc
 
 ; 945.bin should be the interleaved combination of 945_s13.f15 and 945_s12.e15
 org  0
  incbin  "945.bin"

; make sound test play BGMs
 if soundtestbgm=1
 org $31CA
  dc.b $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
  dc.b $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
  dc.b $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
  dc.b $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
  dc.b $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
  dc.b $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
  dc.b $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
  dc.b $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
 endc
 
 ; always pass ROM/RAM check
 ; 24A change 60FE (infinite loop) to NOP 4E71
 org romram_check
  nop
 
 ; update display widgets injection [after stage clear]
 org display_widgets_injection
  jmp injection_display_widgets

; zanki display injection
 org zanki_display_injection
  jmp numeric_zanki_display

 ; remove check for odd dip switch (AAAAA) to allow stage skip using 1P start + service
 org stage_skip_dip_switch_check
  nop
  
 ; stage skip injection
 org stage_skip_routine
  jmp injection_stage_skip

 ; stage increment injection
 org original_stage_increment_routine
  jmp injection_stage_increment
  
 ; sound playback injection
 org sound_play_routine
  jmp injection_sound_play

 org start_button_buffer_routine
  jmp injection_start_button_buffer

 ; modded code
 org free_space

injection_start_button_buffer: ; use D5, D6, D7, A0.  D7 = start button state
 move.w  D7, $40040.l ; overwritten instruction - write D7 to start button buffer
 
 ; check if START is pressed (0x08)
 andi.w  #$0008, D7 ; mask D7 to start bit
 cmpi.b  #$8, D7    ; check if set
 bne .bypass        ; if not set, return

 ; check if game is active
 move.b  in_game, D5 ; D5 = in_game state
 cmpi.b  #$2, D5     ; check if game is active (active = 2, inactive = 0)
 bne .bypass         ; if inactive (e.g. attract mode), return   
 
 ; silence BGM
 clr.b   D6          ; D6 = 0
 move.b  D6, sound_latch
 move.b  D6, sound_irq
 
 ; display PAUSE
 lea     screen_position_pause, A1    ; set x, y pos to middle

 move.b  #$20, D7       ; D7 = 20 (P)
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr

 move.b  #$11, D7       ; D7 = 11 (A)
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr

 move.b  #$25, D7       ; D7 = 25 (U)
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr

 move.b  #$23, D7       ; D7 = 23 (S)
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr

 move.b  #$15, D7       ; D7 = 15 (E)
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 
 ; wait until START is depressed
.wait_depress
 move.w  start_button_state, D7 ; D7 = button state.  nothing pressed 00FF, start pressed 00F7
 move.b  #$1, watchdog_timer
 cmpi.w  #$00FF, D7
 bne .wait_depress
 
 ; check if ABC is pressed to give full equipment
 
 ; wait until START is pressed
.wait_press
 move.w  start_button_state, D7 ; D7 = button state.  nothing pressed 00FF, start pressed 00F7
 move.b  #$1, watchdog_timer
 cmpi.w  #$00F7, D7
 bne .wait_press
 
 ; wait until START is depressed
.wait_depress2
 move.w  start_button_state, D7 ; D7 = button state.  nothing pressed 00FF, start pressed 00F7
 move.b  #$1, watchdog_timer
 cmpi.w  #$00FF, D7
 bne .wait_depress2

 ; erase PAUSE display
 lea     screen_position_pause, A1    ; set x, y pos to middle

 move.b  #$10, D7       ; D7 = 10 ( )
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr

 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr

 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr

 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr

 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr
 
 ; resume BGM
 move.b  last_bgm_played, D7 ; D7 = last BGM played
 cmpi.w  #$80, D7       ; check if prelude
 bne .skip_prelude
 move.b  #$A0, D7       ; replace with mid-start prelude
.skip_prelude
 move.b  D7, sound_latch
 move.b  D7, sound_irq 
 
.bypass
 jmp start_button_buffer_routine_return
 
injection_display_widgets:
 jsr original_zanki_routine
 jsr stage_display
 jmp zanki_routine_return

injection_stage_increment:
 clr.l   $103940.l ; overwritten instruction
 jsr stage_display
 rts

injection_stage_skip:
 move.b  #$90, zanki_counter ; overwritten instruction - set lives to 0x90 on stage skip
 jsr original_zanki_routine ; update zanki display
 jmp stage_skip_routine_return

injection_sound_play:
 move.b  D7, $f0000.l ; overwritten instruction - write to sound irq.  Can use D6, D5, A0. D7 = sound code, will be 0x80+ if BGM
 cmpi.w  #$80, D7     ; check if BGM
 blt .is_sfx          ; if not BGM, just return
 move.b  D7, last_bgm_played ; write last BGM played var.
.is_sfx:
 rts
 
numeric_zanki_display:
 ; A1 = base address (2p: 14C1CF or 1p: 14C19F)
 ; A2 = end address (A1+0x14)
 ; D0 = zanki
 ; D1 = 1
 ; D6 = 0 (attribute byte?)
 ; D7 = 3F (ship icon)
 
 move.b  D7, ($4001,A1) ; write (D7 = 3F, ship icon)
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr
 move.b  #$0E, D7       ; D7 = 0E (:)
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr
 
 move.b  #$1, D7        ; D7 = 1
 sbcd.b  D7, D0         ; current ship doesn't count. previously: subi.b  #1, D0
 move.b  D0, D7         ; copy zanki to D7
 
 andi.l  #$000000F0, D0 ; mask D0 to second digit
 lsr.b   #$4, D0        ; shift right 4 bits
 
 cmpi.b  #0, D0         ; check if tens is zero
 beq .firstdigit        ; if so, skip writing second digit

; write second digit
 move.b  D0, ($4001,A1) ; write (D0 = tens digit)
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr 

; write first digit
.firstdigit: 
 andi.l  #$0000000F, D7 ; mask D7 to first digit
 move.b  D7, ($4001,A1) ; write (D7 = ones digit)
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr 

; write blank space
 move.b  #$10, D7       ; D7 = 10 ( ) - blank space for cleanup when digits go down
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command

 rts 

write_decimal:          ; write byte (D0) as one or two digit decimal to address A1, capped at 99.  D7 usable
 andi.l  #$000000FF, D0 ; mask D0 to single byte 
 cmpi.w  #100, D0       ; check if 3 digit number
 blt .less_than_100 
                        ; more than 2 digits, write 99
 move.b  #9, D7         ; D7 = 9 (9)
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr
 rts
 
.less_than_100:
 divu.w  #$000A, D0     ; divide by 10
 cmpi.b  #0, D0         ; less than 10?
 beq .less_than_10

 move.b  D0, ($4001,A1) ; write second digit
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr

.less_than_10:
 swap    D0             ; swap quotient and remainder
 move.b  D0, ($4001,A1) ; write first digit
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr
 
 rts 

stage_display:

 lea     screen_position_loop1, A1    ; set x, y pos to bottom right

 move.b  #$1C, D7       ; D7 = 1C (L)
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr

 move.b  #$1F, D7       ; D7 = 1F (O)
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr

 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr

 move.b  #$20, D7       ; D7 = 20 (P)
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr

 move.b  #$0E, D7       ; D7 = 0E (:)
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command

 lea     screen_position_loop2, A1    ; set x, y pos to bottom right

 move.b  loop_counter, D0 ; D0 = loop counter +1
 addi.b  #$01, D0

 bsr     write_decimal   ; write loop number
 
 move.b  #$2B, D7       ; D7 = 2B (-)
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command
 addq.w  #2, A1         ; update address ptr
 
 move.b  stage_counter, D0 ; D0 = stage counter +1
 addi.b  #$01, D0
 
 bsr write_decimal      ; write stage number

 move.b  #$10, D7       ; D7 = 10 ( ) - blank space for cleanup when digits go down (e.g. stage 10 to stage 1)
 move.b  D7, ($4001,A1) ; write
 move.b  D6, ($1,A1)    ; issue update command

 rts
