;--------------------------------------------------------------------------------------
; GVAHIM 
; 
;--------------------------------------------------------------------------------------


ideal
model large
stack 1024

include "c:\gvahim\gvahim.mac"

;--------------------------------------------------------------------------------------
; Constants
;---------------------------------------------------------------------------------------
picture_preparation_array_seg EQU 04000h
dataseg
;--------------------------------------------------------------------------------------
; Begin Data definitions
;--------------------------------------------------------------------------------------
;; 
;; YOUR VARIABLES HERE (DB, DW, ..)
;; 

extra_space db ?								;for msleep fun'
save_place_of_shapes db 320*200 dup (0)
orientation db 0								;So we can know which Greece to draw the shape
kind_of_shape db 0								;so we can know which shape to paint
kind_of_array db ?
y_yes_no db ?									;for knowing to stop paint
x_left_yes_no db ?
x_right_yes_no db ?
full_line db ?									;1=full,0=no full
game_over db ?									;1=over,0=not over
;--------------------------------------------------------------------------------------
; End   Data definitions 
;--------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------
; Begin Instructions 
;--------------------------------------------------------------------------------------
codeseg


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Proc putpixel
	push_regs <SI,AX,DX,DI> ;dx becomes 0 when we mul di(the answer goes to ax:dx and it all fits in ax so dx is 0)- so we push it too
 
	mov AX, 320
	mul DI ; AX = 320 * y
	add  SI, AX ; SI = x + (320 * y)-[thats the formula for the offset]
	push es
	push picture_preparation_array_seg
	pop es

	mov [es:si], cl ; PUT PIXEL !(into array)
	pop es
	pop_regs <DI,DX,AX,SI>
ret
endp putpixel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc putpixel_to_save_array
	push_regs <SI,AX,DX,DI> 					;dx becomes 0 when we mul di(the answer goes to ax:dx and it all fits in ax so dx is 0)- so we push it too
 
	mov AX, 320
	mul DI 										; AX = 320 * y
	add  SI, AX 								; SI = x + (320 * y)-[thats the formula for the offset]
	lea ax, [save_place_of_shapes] 		;you set ax as the begining of the array
	add si, ax  								;you add to ax the distance from the begining of the array
	mov [si], cl 								; PUT PIXEL !(into array)

	pop_regs <DI,DX,AX,SI>
ret
endp putpixel_to_save_array
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc copy_preparation_screen_to_real
	push_regs <cx,es,si,di,ax,ds>
	push picture_preparation_array_seg
	pop ds
	mov cx, 320*200
	mov si,0
	push 0A000h
	pop es 
	mov di,0
	rep movsb
	
	pop_regs <ds,ax,di,si,es,cx>
ret
endp copy_preparation_screen_to_real

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc copy_save_array_to_preparation_screen
	push_regs <ax,bx,cx,si>
	mov cx,0
	lea si, [save_place_of_shapes]
	mov bx ,si
	mov ax,bx
	add ax,320*200
	
@@loop1:
	mov cx, [bx]
	push ds
	push picture_preparation_array_seg
	pop ds
	lea si,[picture_preparation_array_seg]
	add si,cx
	mov [ds:si],cx
	pop ds
	inc cx
	inc bx
	cmp bx,ax
	jb @@loop1
	
	pop_regs <si,cx,bx,ax>
	ret
endp copy_save_array_to_preparation_screen
;;;;;;;;;;;ד;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc clear_prep_screen
	push_regs <ax,cx,es,di>
	
	mov cx, 320*200									
	xor ax,ax 					;cool way to mov ax 0
	mov di, 0
	push picture_preparation_array_seg
	pop es
	rep stosb
	
	pop_regs <di,es,cx,ax>
ret
endp clear_prep_screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc get_to_text_mode
	push ax

	mov al, 03h
	mov ah, 0					;put the computer in text mode with inturapt
	int 10h

	pop ax
ret
endp get_to_text_mode
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	;si=x,di=y,cl=color
proc square
	push_regs <bx,ax,si,di,dx>
	mov dx,si			;so we can know from were to stsrt every line
	mov bx,si
	add bx,10			;so we can know when to stop the line
	mov ax,di
	add ax,10	
	cmp [kind_of_array],0		;1 paint to the save_place_of_shapes
	jne save_array				;0 paint to the prep screen
	je regular_array

regular_array:
	@@row: 
		call PutPixel
		inc si
		cmp si,bx		;puts the line
		jb @@row
	@@plos:
		inc di
		mov si,dx
		cmp di,ax		;when to stop put lines
		jb @@row
		jae @@end

save_array:
	@@2row: 
		call PutPixel_to_save_array
		inc si
		cmp si,bx		;puts the line
		jb @@2row
	@@2plos:
		inc di
		mov si,dx
		cmp di,ax		;when to stop put lines
		jb @@2row
		
	
	@@end:
		pop_regs <dx,di,si,ax,bx>
		ret
endp square
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc get_to_graphic_mode
push ax

	mov al, 13h ;set mode
	mov ah, 0							;put the computer in graphic mode with inturapt
	int 10h ;graphics mode
pop ax

ret 
endp get_to_graphic_mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc paint_shape_one
	push_regs <si,di,cx>    ;you give the function si=x,di=y and it paint you thae shape in your posion(x,y) 
	
	mov cl,4h
	cmp [orientation],0
	je @@regular
	cmp [orientation],1
	je @@roll
	cmp [orientation],2
	je @@regular
	cmp [orientation],3
	je @@roll
@@regular:
	call square
	add si,10
    call square				;paint the shape with squares
	add di,10
	call square
	add si,10
	call square
	jmp @@end
@@roll:
	call square
	add di,10
	call square
	sub si,10
	call square
	add di,10
	call square
	jmp @@end
@@end:
	pop_regs <cx,di,si>
ret
endp paint_shape_one
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc paint_shape_two
	push_regs <si,di,cx>
	
	mov cl,9h
	cmp [orientation],0
	je @@regular
	cmp [orientation],1
	je @@roll
	cmp [orientation],2
	je @@regular
	cmp [orientation],3
	je @@roll
@@regular:
	call square
	add di,10				;paint the shape with squares
	call square
	add di,10
	call square
	jmp @@end
@@roll:
	call square
	sub si,10
	call square
	sub si,10
	call square
@@end:	
	pop_regs <cx,di,si>
ret
endp paint_shape_two
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc regular_three
	call square
	add si,10
	call square
	sub di,10
	call square
	add di,10
	add si,10
	call square
	ret
endp regular_three
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc paint_shape_three
	push_regs <cx,di,si>
	
	mov cl,5h
	cmp [orientation],0
	je @@regular
	cmp [orientation],1
	je @@roll_1
	cmp [orientation],2
	je @@roll_2
	cmp [orientation],3
	je @@roll_3
@@regular:	
	call regular_three
	jmp @@end
@@roll_1:
	call square
	add di,10
	call square
	add si,10
	call square
	sub si,10
	add di,10
	call square
	jmp @@end
@@roll_2:
	call square
	add si,10
	call square
	add di,10
	call square
	sub di,10
	add si,10
	call square
	jmp @@end
@@roll_3:
	call square
	add di,10
	call square
	sub si,10
	call square
	add si,10
	add di,10
	call square
	jmp @@end
@@end:	
	pop_regs <si,di,cx>
ret
endp paint_shape_three
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc paint_shape_four
	push_regs <si,di,cx>
	
	mov cl,2h
	cmp [orientation],0
	je @@regular
	cmp [orientation],1
	je @@roll
	cmp [orientation],2
	je @@regular
	cmp [orientation],3
	je @@roll
@@regular:
	call square
	add si,10
	call square
	sub di,10
	call square
	add si,10
	call square
	jmp @@end
@@roll:
	call square
	add di,10
	call square
	add si,10
	call square
	add di,10
	call square
@@end:	
	pop_regs <cx,di,si>
ret
endp paint_shape_four
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc paint_shape_five
	push_regs <si,di,cx>
	
	mov cl,1h
	cmp [orientation],0
	je @@regular
	cmp [orientation],1
	je @@roll_1
	cmp [orientation],2
	je @@roll_2
	cmp [orientation],3
	jmp @@roll_3
@@regular:	
	call square
	add di,10
	call square
	add si,10
	call square
	add si,10
	call square
	jmp @@end
@@roll_1:
	call square
	sub si,10
	call square
	add di,10
	call square
	add di,10
	call square
	jmp @@end
@@roll_2:
	call square
	sub di,10
	call square
	sub si,10
	call square
	sub si,10
	call square
	jmp @@end
@@roll_3:
	call square
	add si,10
	call square
	sub di,10
	call square
	sub di,10
	call square
	jmp @@end
@@end:	
	pop_regs <cx,di,si>
ret
endp paint_shape_five
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc paint_shape_six
	push_regs <cx,si,di>
	
	mov cl,0eh
	call square
	add di,10
	call square
	add si,10
	call square
	sub di,10
	call square

	pop_regs <di,si,cx>
ret
endp paint_shape_six
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc paint_shape_seven
	push_regs <cx,di,si>
	
	mov cl,0fh
	cmp [orientation],0
	je @@regular
	cmp [orientation],1
	je @@roll_1
	cmp [orientation],2
	je @@roll_2
	cmp [orientation],3
	jmp @@roll_3
@@regular:
	call square
	add si,10
	call square
	add si,10
	call square
	sub di,10
	call square
	jmp @@end
@@roll_1:
	call square
	add di,10
	call square
	add di,10
	call square
	add si,10
	call square
	jmp @@end
@@roll_2:
	call square
	sub si,10
	call square
	sub si,10
	call square
	add di,10
	call square
	jmp @@end
@@roll_3:
	call square
	sub di,10
	call square
	sub di,10
    call square
	sub si,10
	call square
	jmp @@end
@@end:	
	pop_regs <si,di,cx>
ret
endp paint_shape_seven
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
proc msleep
push ax			;how many mili sec wait
push bx
push cx			;if you want more than 65000 ,evry num wil be 65000 more(1=65000)
push dx
push si ;we will change it in this proc so we need to push it 

;mov cx,2 ;so cx:dx wont be affected

;will mult the input number by 1000 because the input is in mili and we want in micro 
mov bx, ax ;moving the number we want to mult into the correct register
mov ax, 1000 ;moving the number we want to mult by into the correct register
mul bx ;multing bx(which used to be the input ax) by (the new)ax(1000)
mov dx, ax ;moving what came out into dx(the number of micro secs to wait

lea si, [extra_space] ;the bug will send to an extra space where it wont hurt anybody

push ax ;the bug will change ax but it won't matter
mov ah, 86h
int 15h
pop ax

pop si  
pop dx
pop cx
pop bx
pop ax
ret

endp msleep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc get_key_if_pressed 
mov ah, 1
int 16h

jz @@not_available ;if not availabe zf will be turned on
mov ah, 0
int 16h ;to clear buffer and reset


@@not_available:
;do nothing if isn't available



ret
endp get_key_if_pressed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc random_zero_to_6
	push_regs <bx,dx>				;random num in ah
	mov ah,2ch
	int 21h
	mov al,3
	mul dl
	mov bl,7
	div bl
	pop_regs <dx,bx>
ret
endp random_zero_to_6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
proc kind_of_shape_to_paint
	cmp [kind_of_shape],0
	je @@shape_one
	cmp [kind_of_shape],1			; for knowing what shape to paint
	je @@shape_two
	cmp [kind_of_shape],2
	je @@shape_three
	cmp [kind_of_shape],3
	je @@shape_four
	cmp [kind_of_shape],4
	je @@shape_five
	cmp [kind_of_shape],5
	je @@shape_six
	jmp @@shape_seven
	
	@@shape_one:
		call paint_shape_one
		ret
	@@shape_two:
		call paint_shape_two
		ret
	@@shape_three:
		call paint_shape_three
		ret
	@@shape_four:
		call paint_shape_four
		ret
	@@shape_five:
		call paint_shape_five
		ret
	@@shape_six:
		call paint_shape_six
		ret
	@@shape_seven:
		call paint_shape_seven
		ret
endp kind_of_shape_to_paint
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc line_calculator
push_regs <ax,di,si,dx>

mov ax,320
mov bx,di
mul bx
add ax,si
mov bx ,ax

pop_regs <dx,si,di,ax>
ret
endp line_calculator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

proc stop_in_y_all_of_the_shapes
push bx
	call line_calculator
	
	cmp [kind_of_shape],0
	je @@shape_one
	cmp [kind_of_shape],1			; for knowing what shape bump
	je @@shape_two
	cmp [kind_of_shape],2
	je @@shape_three
	cmp [kind_of_shape],3
	je @@shape_four
	cmp [kind_of_shape],4
	je @@shape_five
	cmp [kind_of_shape],5
	je @@shape_six
	jmp @@shape_seven
	
@@shape_one:
	call stop_in_y_shape_one
	pop bx
	ret	
@@shape_two:
	call stop_in_y_shape_two
	pop bx
	ret
@@shape_three:
	call stop_in_y_shape_three
	pop bx
	ret	
@@shape_four:
	call stop_in_y_shape_four
	pop bx
	ret		
@@shape_five:
	call stop_in_y_shape_five
	pop bx
	ret
@@shape_six:
	call stop_in_y_shape_six
	pop bx
	ret
@@shape_seven:
	call stop_in_y_shape_seven
	pop bx
	ret

endp stop_in_y_all_of_the_shapes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc stop_in_y_shape_one
	push bx
	cmp [orientation],0
	je @@regular
	cmp [orientation],1
	je @@roll
	cmp [orientation],2
	je @@regular
	jmp @@roll
	
	@@regular: 
		add bx,320*11
		cmp [save_place_of_shapes+bx],0
		ja @@end
		add bx,10
		add bx,320*10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		add bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@roll:
		add bx,320*21
		cmp [save_place_of_shapes+bx],0
		ja @@end
		add bx,320*10
		sub bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@end:
		mov [kind_of_array],1
		call kind_of_shape_to_paint
		mov [y_yes_no],1
		pop bx
		ret		
endp stop_in_y_shape_one
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc stop_in_y_shape_two
	push bx
	cmp [orientation],0
	je @@1regular
	cmp [orientation],1
	je @@1roll
	cmp [orientation],2
	je @@1regular
	jmp @@1roll
	
	@@1regular:
		add bx,320*31
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@1roll:
		add bx,320*11
		cmp [save_place_of_shapes+bx],0
		ja @@end
		sub bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		sub bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@end:
		mov [kind_of_array],1
		call kind_of_shape_to_paint
		mov [y_yes_no],1
		pop bx
		ret	
endp stop_in_y_shape_two
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc stop_in_y_shape_three
	push bx
	cmp [orientation],0
	je @@2regular
	cmp [orientation],1
	je @@2roll
	cmp [orientation],2
	je @@3roll
	jmp @@4roll
	
	@@2regular:
		add bx,320*11
		cmp [save_place_of_shapes+bx],0
		ja @@end
		add bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		add bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@2roll:
		add bx,320*31
		cmp [save_place_of_shapes+bx],0
		ja @@end
		sub bx,320*10
		add bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@3roll:
		add bx,320*11
		cmp [save_place_of_shapes+bx],0
		ja @@end
		add bx,320*10
		add bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		sub bx,320*10
		add bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@4roll:
		add bx,320*31
		cmp [save_place_of_shapes+bx],0
		ja @@end
		sub bx,320*10
		sub bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx 
		ret
	@@end:
		mov [kind_of_array],1
		call kind_of_shape_to_paint
		mov [y_yes_no],1
		pop bx
		ret			
endp stop_in_y_shape_three
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc stop_in_y_shape_four
	push bx
	cmp [orientation],0
	je @@3regular
	cmp [orientation],1
	je @@5roll
	cmp [orientation],2
	je @@3regular
	jmp @@5roll
	
	@@3regular:
		add bx,320*11
		cmp [save_place_of_shapes+bx],0
		ja @@end
		add bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		sub bx,320*10
		add bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@5roll:
		add bx,320*21
		cmp [save_place_of_shapes+bx],0
		ja @@end
		add bx,320*10
		add bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end		
		pop bx
		ret
	@@end:
		mov [kind_of_array],1
		call kind_of_shape_to_paint
		mov [y_yes_no],1
		pop bx
		ret
endp stop_in_y_shape_four
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc stop_in_y_shape_five
	push bx
	cmp [orientation],0
	je @@4regular
	cmp [orientation],1
	je @@6roll
	cmp [orientation],2
	je @@7roll
	jmp @@8roll
	
	@@4regular:
		add bx,320*21
		cmp [save_place_of_shapes+bx],0
		ja @@end
		add bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		add bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@6roll:
		add bx,320*11
		cmp [save_place_of_shapes+bx],0
		ja @@end		
		add bx,320*20
		sub bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@7roll:
		add bx,320
		cmp [save_place_of_shapes+bx],0
		ja @@end
		sub bx,321*10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		sub bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@8roll:
		add bx,320
		cmp [save_place_of_shapes+bx],0
		ja @@end
		add bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@end:
		mov [kind_of_array],1
		call kind_of_shape_to_paint
		mov [y_yes_no],1
		pop bx
		ret
endp stop_in_y_shape_five
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
proc stop_in_y_shape_six
	push bx
	add bx,320*21
	cmp [save_place_of_shapes+bx],0
	ja @@end
	add bx,10
	cmp [save_place_of_shapes+bx],0
	ja @@end
	pop bx
	ret
	@@end:
		mov [kind_of_array],1
		call kind_of_shape_to_paint
		mov [y_yes_no],1
		pop bx
		ret
endp stop_in_y_shape_six
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc stop_in_y_shape_seven
	push bx
	cmp [orientation],0
	je @@5regular
	cmp [orientation],1
	je @@9roll
	cmp [orientation],2
	je @@10roll
	jmp @@11roll	
	
	@@5regular:
		add bx,320*11
		cmp [save_place_of_shapes+bx],0
		ja @@end
		add bx ,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		add bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@9roll:
		add bx,320*31
		cmp [save_place_of_shapes+bx],0
		ja @@end
		add bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@10roll:
		add bx,320*11
		cmp [save_place_of_shapes+bx],0
		ja @@end
		sub bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		sub bx,10
		add bx,320*10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@11roll:
		add bx,320
		cmp [save_place_of_shapes+bx],0
		ja @@end
		sub bx,320*20
		sub bx,10
		cmp [save_place_of_shapes+bx],0
		ja @@end
		pop bx
		ret
	@@end:
		mov [kind_of_array],1
		call kind_of_shape_to_paint
		mov [y_yes_no],1
		pop bx
		ret		
endp stop_in_y_shape_seven
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc all_shapes_left_right
push_regs <ax,bx>

	call line_calculator
	
	cmp [kind_of_shape],0
	je @@shape_one
	cmp [kind_of_shape],1			; for knowing what shape to paint
	je @@shape_two
	cmp [kind_of_shape],2
	je @@shape_three
	cmp [kind_of_shape],3
	je @@shape_four
	cmp [kind_of_shape],4
	je @@shape_five
	cmp [kind_of_shape],5
	je @@shape_six
	jmp @@shape_seven
	
	@@shape_one:
		call chek_left_right_shape_one
		pop_regs <bx,ax>
		ret
	@@shape_two:
		call chek_left_right_shape_two
		pop_regs <bx,ax>
		ret
	@@shape_three:
		call chek_left_right_shape_three
		pop_regs <bx,ax>
		ret
	@@shape_four:
		call chek_left_right_shape_four
		pop_regs <bx,ax>
		ret
	@@shape_five:
		call chek_left_right_shape_five
		pop_regs <bx,ax>
		ret
	@@shape_six:
		call chek_left_right_shape_six
		pop_regs <bx,ax>
		ret
	@@shape_seven:
		call chek_left_right_shape_seven
		pop_regs <bx,ax>
		ret

endp all_shapes_left_right
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
proc chek_left_right_shape_one
	push bx
	
	cmp [orientation],0
	je @@regular
	cmp [orientation],1
	je @@roll
	cmp [orientation],2
	je @@regular
	jmp @@roll
	
	@@regular:
		dec bx
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,32
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx
		ret
	@@roll:
		sub bx,11
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,22
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx
		ret
	@@end_left:
		mov [x_left_yes_no],1
		pop bx
		ret
	@@end_right:
		mov[x_right_yes_no],1
		pop bx
		ret
endp chek_left_right_shape_one
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc chek_left_right_shape_two
	push bx
		
	cmp [orientation],0
	je @@regular
	cmp [orientation],1
	je @@roll
	cmp [orientation],2
	je @@regular
	jmp @@roll		
		
	@@regular:
		dec bx
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,12
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx
		ret
	@@roll:
		sub bx,31
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,32
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx
		ret
	@@end_left:
		mov [x_left_yes_no],1
		pop bx 
		ret
	@@end_right:
		mov [x_right_yes_no],1
		pop bx
		ret
endp chek_left_right_shape_two
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc chek_left_right_shape_three
	push bx
	
	cmp [orientation],0
	je @@regular
	cmp [orientation],1
	je @@roll
	cmp [orientation],2
	je @@2roll
	jmp @@3roll	
	
	@@regular:
		dec bx
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,32
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx
		ret
	@@roll:
		dec bx
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,22
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx 
		ret
	@@2roll:
		dec bx
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,32
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx 
		ret
	@@3roll:
		sub bx,21
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,22
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx 
		ret
	@@end_left:
		mov [x_left_yes_no],1
		pop bx
		ret
	@@end_right:
		mov [x_right_yes_no],1
		pop bx
		ret
endp chek_left_right_shape_three
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc chek_left_right_shape_four
	push bx
	
	cmp [orientation],0
	je @@regular
	cmp [orientation],1
	je @@roll
	cmp [orientation],2
	je @@regular
	jmp @@roll	
	
	@@regular:
		dec bx
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,32
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx
		ret
	@@roll:
		dec bx
		cmp[save_place_of_shapes+bx],0
		ja @@end_left
		add bx,22
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx 
		ret
	@@end_left:
		mov [x_left_yes_no],1
		pop bx 
		ret
	@@end_right:
		mov [x_right_yes_no],1
		pop bx
		ret
endp chek_left_right_shape_four
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc chek_left_right_shape_five
	push bx
	
	cmp [orientation],0
	je @@regular
	cmp [orientation],1
	je @@roll
	cmp [orientation],2
	je @@2roll
	jmp @@3roll

	@@regular:
		dec bx
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,32
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx 
		ret
	@@roll:
		sub bx,21
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,22
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx
		ret
	@@2roll:
		 sub bx,31
		 cmp [save_place_of_shapes+bx],0
		 ja @@end_left
		 add bx,32
		 cmp [save_place_of_shapes+bx],0
		 ja @@end_right
		 pop bx
		 ret
	@@3roll:
		dec bx
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,22
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx
		ret
	@@end_left:
		mov [x_left_yes_no],1
		pop bx
		ret
	@@end_right:
	   mov [x_right_yes_no],1
	   pop bx
	   ret
endp chek_left_right_shape_five
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc chek_left_right_shape_six
	push bx
	
	dec bx
	cmp [save_place_of_shapes+bx],0
	ja @@end_left
	add bx,22
	cmp [save_place_of_shapes+bx],0
	ja @@end_right
	pop bx
	ret
	@@end_left:
		mov [x_left_yes_no],1
		pop bx
		ret
	@@end_right:
		mov [x_right_yes_no],1
		pop bx
		ret
endp chek_left_right_shape_six
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc chek_left_right_shape_seven
	push bx
	
	cmp [orientation],0
	je @@regular
	cmp [orientation],1
	je @@roll
	cmp [orientation],2
	je @@2roll
	jmp @@3roll	
	
	@@regular:
		dec bx
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,32
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx
		ret
	@@roll:
		dec bx
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,22
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx 
		ret
	@@2roll:
		sub bx,31
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,32
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx
		ret
	@@3roll:
		sub bx,21
		cmp [save_place_of_shapes+bx],0
		ja @@end_left
		add bx,22
		cmp [save_place_of_shapes+bx],0
		ja @@end_right
		pop bx
		ret
	@@end_left:
		mov [x_left_yes_no],1
		pop bx
		ret
	@@end_right:
		mov [x_right_yes_no],1
		pop bx
		ret
endp chek_left_right_shape_seven
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc chek_line_full_in_squares
	push_regs <dx,ax,bx,cx,di>
	mov [full_line],1
	mov bx,320						;the fun get a num of line in di
	mov ax,di
	mul bx
	mov bx,ax
	mov cx,ax
	add cx,320
	@@loop1:
		cmp [save_place_of_shapes+bx],0
		je @@no_full
		inc bx
		cmp bx,cx
		jb @@loop1
		pop_regs <di,cx,bx,ax>
		ret
	@@no_full:
		mov [full_line],0
		pop_regs <di,cx,bx,ax,dx>
		ret
endp chek_line_full_in_squares
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc delete_line
	push_regs <ax,bx,cx,di,dx>
	mov bx,320
	mov ax,di
	mul bx
	mov bx,ax
	mov cx,ax
	add cx,320						;the fun get a num of line in di
	@@loop:
		mov [save_place_of_shapes+bx],0
		inc bx
		cmp bx,cx
		jb @@loop
		pop_regs <dx,di,cx,bx,ax>
		ret
endp delete_line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc mov_line1_to_line2
	push_regs <ax,bx,cx,dx,di>
	mov bx,320
	mov ax,di
	mul bx
	mov bx,ax
	mov di,ax
	add di,320
	mov dx,ax									;the fun get a num of a line in di ,and put this line in line di+1
	add dx,320
	@@loop:
		mov cl,[save_place_of_shapes+bx]
		mov [save_place_of_shapes+di],cl
		inc bx
		inc di
		cmp bx,dx
		jb @@loop
		pop_regs <di,dx,cx,bx,ax>
		ret
endp mov_line1_to_line2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc mov_all_before_line2_one_line
	push_regs <bx,di>
	mov bx,di
	mov di,1
	@@loop:
		cmp di,bx
		je @@end
		call mov_line1_to_line2
		inc di
		jmp @@loop
	@@end:
	pop_regs <di,bx>
	ret
endp mov_all_before_line2_one_line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc chek_all_lines_and_decide_to_delete_and_mov
	push di
	@@loop:
		mov di,199
		call chek_line_full_in_squares
		cmp [full_line],0
		ja @@delete_and_mov
		dec di
		cmp di,0
		ja @@loop
		pop di
		ret
	@@delete_and_mov:
		call delete_line
		dec di
		call mov_all_before_line2_one_line
		jmp @@loop
		pop di
		ret
endp chek_all_lines_and_decide_to_delete_and_mov
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc chek_if_game_over
	push bx
	mov [game_over],0
	mov bx,0

	@@loop:
		cmp [save_place_of_shapes+bx],0
		ja @@over
		inc bx
		cmp bx,320
		jb @@loop
	pop bx 
	ret
	@@over:
		mov [game_over],1
		pop bx
		ret
endp chek_if_game_over
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc paint_frame_to_save_array
	push_regs <di,si,cx>
	mov di,0
	mov si,0
	mov cl,7h
	@@loop:
		call putpixel_to_save_array
		inc si
		cmp si,320
		jb @@loop
	mov di,199
	mov si,0
	@@loop1:
		call putpixel_to_save_array
		inc si
		cmp si,320
		jb @@loop1
	mov di,1
	mov si,0
	@@loop2:
		call putpixel_to_save_array
		inc di
		cmp di,199
		jb @@loop2
	mov di,1
	mov si,319
	@@loop3:
		call putpixel_to_save_array
		inc di
		cmp di,199
		jb @@loop3
	pop_regs <cx,si,di>
	ret
endp paint_frame_to_save_array
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc main_paint
	push_regs <ax,bx,cx,dx,si,di>	
	
	call get_to_graphic_mode 
	mov [y_yes_no],0
	mov si,160
	mov di,40
	mov cx,4

@@main_loop:	
	call paint_frame_to_save_array
	call chek_if_game_over
	;call chek_all_lines_and_decide_to_delete_and_mov
	;call copy_save_array_to_preparation_screen
	call kind_of_shape_to_paint
	call copy_preparation_screen_to_real
	call clear_prep_screen
	mov ax,65000
	call msleep
	call get_key_if_pressed
	cmp al,"q"
	je @@end_of_the_paint
	cmp al, "a"
	je @@mov_left
	cmp al, "d"
	je @@mov_right
	cmp al,"s"
	je @@move_fast
	cmp al,"w"
	je @@roll
	
	add di, 10
	call stop_in_y_all_of_the_shapes
	cmp [y_yes_no],0
	ja @@end_of_the_paint
	jmp @@main_loop
	
	@@mov_left:
		call all_shapes_left_right
		cmp [x_left_yes_no],0
		ja @@main_loop
		sub si, 10
		jmp @@main_loop
	@@mov_right:
		call all_shapes_left_right
		cmp [x_right_yes_no],0
		ja @@main_loop
		add si,10
		jmp @@main_loop
	@@move_fast:
		mov cx,0
		jmp @@main_loop
	@@roll:
		inc [orientation]
		cmp [orientation],4
		je @@middle_roll
		jmp @@main_loop
			@@middle_roll:
			mov [orientation],0
			jmp @@main_loop
@@end_of_the_paint:
	pop_regs <di,si,dx,cx,bx,ax>
	ret
endp main_paint



ENTRY: 

    ;; Load data segment to DS
    mov  ax, @data
    mov  ds, ax

	;; 
    ;; YOUR PROGRAM HERE
    ;; 
	call paint_frame_to_save_array
loop2:
	;cmp al,"q"
	;je end_of_the_game
	;cmp [game_over],1
	;je end_of_the_game
	call random_zero_to_6
	mov [kind_of_shape],ah
	call main_paint
	jmp loop2
end_of_the_game:
	ret
    ;; Exite
	
    mov  ax, 4c00h
    int  21h
	;Last command

;--------------------------------------------------------------------------------------
; End   Instructions 
;--------------------------------------------------------------------------------------
include "c:\gvahim\gvahim.asm"
end ENTRY

