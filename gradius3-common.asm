 ; 945.bin should be the interleaved combination of 945_s13.f15 and 945_s12.e15
 org  0
  incbin  "945.bin"
 
 ; always pass ROM/RAM check
 ; 24A change 60FE (infinite loop) to NOP 4E71
 org romram_check
  nop
 
 ; update display widgets injection [after stage clear]
 org display_widgets_injection
  jmp injection

; zanki display injection
 org zanki_display_injection
  jmp numeric_zanki_display

 ; remove check for odd dip switch (AAAAA) to allow stage skip using 1P start + service
 org stage_skip_dip_switch_check
  nop
  
 ; stage skip injection
 org stage_skip_routine
  jmp injection3

 ; stage increment injection
 org original_stageincrement_routine
  jmp injection2

 ; modded code
 org free_space
 
injection:
 jsr original_zanki_routine
 jsr stage_display
 jmp post_zanki_routine

injection2:
 clr.l   $103940.l ; overwritten instruction
 jsr stage_display
 rts

injection3:
 move.b  #$90, $101050.l ; overwritten instruction - set lives to 0x90 on stage skip
 jsr original_zanki_routine ; update zanki display
 jmp post_stage_skip_routine
 
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
