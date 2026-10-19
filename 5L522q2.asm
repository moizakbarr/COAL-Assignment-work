[org 0x0100]

jmp start

title:      db 'Abdul Moiz | 25L-0522', 0
paragraph:  db 'i ate biryani', 10
            db 'hello world', 10
            db 'yes kr yes kr yes kr', 10
            db 'no no no no', 10
            db 'Test text to check wrap and boundaries, Test text to check wrap and boundaries, Test text to check wrap and boundaries', 0
keyword:    db 'Over my dead body', 0
matches:    dw 0
barLeft:    db 'Total Matches Found: [', 0
barRight:   db '] | Viewport Status: ACTIVE', 0


getOffset:
    push bp
    mov bp, sp
    push bx
    push dx

    mov ax, [bp+6]              ; row
    mov bx, 80
    mul bx
    add ax, [bp+4]              ; col
    shl ax, 1

    pop dx
    pop bx
    pop bp
    ret 4

; ---------------------------------------------------
clearScreen:
    push es
    push ax
    push cx
    push di

    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov cx, 2000
    mov ax, 0x0720
    cld
    rep stosw

    pop di
    pop cx
    pop ax
    pop es
    ret

; ---------------------------------------------------
drawFrame:
    push es
    push ax
    push cx
    push di

    mov ax, 0xb800
    mov es, ax
    cld

    ; top edge, row 3
    push word 3
    push word 8
    call getOffset
    mov di, ax
    mov ax, 0x07CD
    mov cx, 64
    rep stosw

    ; bottom edge, row 21
    push word 21
    push word 8
    call getOffset
    mov di, ax
    mov ax, 0x07CD
    mov cx, 64
    rep stosw

    ; left edge, rows 4..20
    push word 4
    push word 8
    call getOffset
    mov di, ax
    mov ax, 0x07BA
    mov cx, 17
sideL:
    mov [es:di], ax
    add di, 160
    loop sideL

    ; right edge
    push word 4
    push word 71
    call getOffset
    mov di, ax
    mov ax, 0x07BA
    mov cx, 17
sideR:
    mov [es:di], ax
    add di, 160
    loop sideR

    ; corners
    push word 3
    push word 8
    call getOffset
    mov di, ax
    mov word [es:di], 0x07C9

    push word 3
    push word 71
    call getOffset
    mov di, ax
    mov word [es:di], 0x07BB

    push word 21
    push word 8
    call getOffset
    mov di, ax
    mov word [es:di], 0x07C8

    push word 21
    push word 71
    call getOffset
    mov di, ax
    mov word [es:di], 0x07BC

    pop di
    pop cx
    pop ax
    pop es
    ret


drawTitle:
    push bp
    mov bp, sp
    sub sp, 2                   
    push ax
    push bx
    push cx
    push si
    push di
    push es

    mov si, [bp+6]

    ; length of string
    mov bx, si
    xor cx, cx
measure:
    cmp byte [bx], 0
    je measured
    inc bx
    inc cx
    jmp measure
measured:
    mov [bp-2], cx

    ; column = 40 - length/2
    mov cx, [bp-2]
    shr cx, 1
    mov bx, 40
    sub bx, cx

    push word 4
    push bx
    call getOffset
    mov di, ax

    mov ax, 0xb800
    mov es, ax
    cld
titleChar:
    lodsb
    cmp al, 0
    je titleEnd
    mov ah, [bp+4]
    stosw
    jmp titleChar

titleEnd:
    pop es
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret 4


drawText:
    push bp
    mov bp, sp
    sub sp, 2                   
    push ax
    push bx
    push cx
    push si
    push di
    push es

    mov ax, 0xb800
    mov es, ax
    cld
    mov si, [bp+6]
    mov word [bp-2], 6

newRow:
    push word [bp-2]
    push word 10
    call getOffset
    mov di, ax
    xor cx, cx

nextChar:
    lodsb
    cmp al, 0
    je textEnd
    cmp al, 10
    je endRow
    mov ah, [bp+4]
    stosw
    inc cx
    cmp cx, 60
    je endRow
    jmp nextChar

endRow:
    inc word [bp-2]
    cmp word [bp-2], 21
    jl newRow

textEnd:
    pop es
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret 4


scroll_window_up:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es

    mov ax, [bp+4]              
    test ax, ax
    jz scrollDone

    mov ax, 0xb800
    mov ds, ax
    mov es, ax
    cld

   
    mov bx, [bp+8]
    sub bx, [bp+12]
    inc bx
    sub bx, [bp+4]

    
    push word [bp+12]
    push word [bp+10]
    call getOffset
    mov di, ax

 
    mov ax, [bp+12]
    add ax, [bp+4]
    push ax
    push word [bp+10]
    call getOffset
    mov si, ax

    ; width in words
    mov dx, [bp+6]
    sub dx, [bp+10]
    inc dx

   
    mov ax, 160
    sub ax, dx
    sub ax, dx

copyRow:
    mov cx, dx
    rep movsw
    add si, ax
    add di, ax
    dec bx
    jnz copyRow

    ; blank the vacated rows
    mov bx, [bp+4]
    mov si, ax
    mov ax, 0x0720
clearRow:
    mov cx, dx
    rep stosw
    add di, si
    dec bx
    jnz clearRow

scrollDone:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 10

; ---------------------------------------------------
; find_and_highlight(string, attr)
find_and_highlight:
    push bp
    mov bp, sp
    sub sp, 2                   
    push ax
    push bx
    push cx
    push si
    push di
    push es

    cld
    mov ax, 0xb800
    mov es, ax
    mov word [bp-2], 4

scanRow:
    push word [bp-2]
    push word 9
    call getOffset
    mov di, ax
    mov cx, 62

scanCell:
    mov bx, di                
    mov si, [bp+6]

cmpLoop:
    lodsb
    cmp al, 0
    je hit
    scasb
    jne skip
    inc di                 
    jmp cmpLoop

hit:
    inc word [matches]
    mov al, [bp+4]
paint:
    mov [es:di-1], al
    sub di, 2
    cmp di, bx
    ja paint

skip:
    mov di, bx
    add di, 2
    dec cx
    jnz scanCell

    inc word [bp-2]
    cmp word [bp-2], 21
    jb scanRow

    pop es
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret 4

; ---------------------------------------------------
; printNum(num, offset) -> ax = offset after the number
printNum:
    push bp
    mov bp, sp
    push bx
    push cx
    push dx
    push di
    push es

    mov ax, 0xb800
    mov es, ax
    mov ax, [bp+6]
    mov di, [bp+4]
    mov bx, 10
    xor cx, cx

splitDigits:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz splitDigits

writeDigits:
    pop dx
    add dl, '0'
    mov dh, 0x07
    mov [es:di], dx
    add di, 2
    loop writeDigits

    mov ax, di

    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop bp
    ret 4

; ---------------------------------------------------
drawStatus:
    push ax
    push si
    push di
    push es

    mov ax, 0xb800
    mov es, ax
    cld

    push word 23
    push word 0
    call getOffset
    mov di, ax

    mov ah, 0x07
    mov si, barLeft
leftPart:
    lodsb
    cmp al, 0
    je leftDone
    stosw
    jmp leftPart

leftDone:
    push word [matches]
    push di
    call printNum
    mov di, ax
    mov ah, 0x07

    mov si, barRight
rightPart:
    lodsb
    cmp al, 0
    je statusEnd
    stosw
    jmp rightPart

statusEnd:
    pop es
    pop di
    pop si
    pop ax
    ret

; ---------------------------------------------------
start:
    call clearScreen
    call drawFrame

    push title
    push word 0x1E
    call drawTitle

    push paragraph
    push word 0x07             
    call drawText

    
    push word 6                 ; top
    push word 9                 ; left
    push word 20                ; bottom
    push word 70                ; right
    push word 0                
    call scroll_window_up

    push keyword
    push word 0xCE
    call find_and_highlight

    call drawStatus

    mov ax, 0x4C00
    int 0x21