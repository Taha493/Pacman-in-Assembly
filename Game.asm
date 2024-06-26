INCLUDE Irvine32.inc
includelib Winmm.lib
Include Macros.inc
BUFFER_SIZE = 5000

PlaySound PROTO,
        pszSound:PTR BYTE, 
        hmod:DWORD, 
        fdwSound:DWORD
.data

soundPath db "sound1.wav", 0
soundPath2 db "death.wav", 0
soundPath3 db "intro", 0

over1 byte "  ______       _                      _______          _____                    _______   ______          ",0
over2 byte " /            / \       |\      /|    |               /     \      \        /   |         |     |         ",0
over3 byte "|            /   \      | \    / |    |              |       |      \      /    |         |     |         ",0
over4 byte "|    ___    /_____\     |  \  /  |    |----          |       |       \    /     |____     |\----         ",0
over5 byte "|      |   /       \    |   \/   |    |              |       |        \  /      |         | \            ",0
over6 byte " \_____|  /         \   |        |    |______         \_____/          \/       |______   |  \   ",0

title2 byte " _____       _          ______                       _                    ", 0ah, 0
title3 byte "|     |     / \        /          |\      /|        / \       |\    |     ", 0ah, 0
title4 byte "|_____|    /   \      |           | \    / |       /   \      | \   |     ", 0ah, 0
title5 byte "|         /_____\     |           |  \  /  |      /_____\     |  \  |     ", 0ah, 0
title6 byte "|        /       \    |           |   \/   |     /       \    |   \ |     ", 0ah, 0
title7 byte "|       /         \    \______    |        |    /         \   |    \|     ", 0ah, 0

ground BYTE "------------------------------------------------------------------------------------------------------------------------",0
ground1 BYTE "|",0ah,0  
ground2 BYTE "|",0

LengthOfWalls dw 0

temp byte ?

temp2 dw ?

strScore BYTE "Your score is: ",0
strLevel BYTE "Level: ",0
strLives BYTE "Lives: ",0


score WORD 0

level db 1

lives db 3

xPos BYTE 1
yPos BYTE 15

xPosG1 db 118
yPosG1 db 10

xPosG2 db 110
yPosG2 db 18

xPosG3 db 2
yPosG3 db 10

xPosG4 db 9
yPosG4 db 18

boolG1 db 0
boolG2 db 0

boolG3 db 0
boolG4 db 0

DisplayScoreBool db 0

TeleX db ?
TeleY db ?

FruitX db ?
FruitY db 15

EatBool db 0
xCoinPos BYTE ?
yCoinPos BYTE ?

inputChar BYTE ?

CoinsCount dw 0

CurrentCoinsCount dw 0

PlayerName db 15 dup(?)


CoinsX db 2000 dup(?)
CoinsY db 2000 dup(?)

CoinsArray db 4000 dup(?)
WallsX db 1000 dup(?)
WallsY db 1000 dup(?)

WallsX2 db 1,2,3,4,5,7,8


inFileCount dw 0

    Name1 db 15 dup(" "), 0
    Name2 db 15 dup(" "), 0
    Name3 db 15 dup(" "), 0

    HighScore1 db 4 dup(" "), 0
    HighScore2 db 4 dup(" "), 0
    HighScore3 db 4 dup(" "), 0

    
    buffer BYTE BUFFER_SIZE DUP(?)
	;filename BYTE 80 DUP(0)
	fileHandle HANDLE ?

    filename BYTE "HighScore.txt", 0
    stringLength DWORD ?
    bytesWritten DWORD ?
    
    str1 BYTE "Cannot create file ", 0
    str2 BYTE "Bytes written to file :", 0
    str3 BYTE "Enter up to 500 characters and press [Enter]: ", 0

.code
main PROC
	Mov eax, Blue 
	call Welcome
	call crlf

main ENDP

DisplayInstruction PROC
call clrscr
mov eax, red
call SetTextColor

mov dl, 55
	mov dh, 4
	call Gotoxy
	mWrite "INSTRUCTIONS"
	call crlf

mov eax, brown
call SetTextColor
mov dl, 40
	mov dh, 10
	call Gotoxy
mWrite "1. Use W, S, A, D keys to move your character."
call crlf
mov dl, 40
	mov dh, 14
	call Gotoxy
mWrite "2. Eat the coins to increase your score."
call crlf

    mov dl, 40
	mov dh, 18
	call Gotoxy
mWrite "3. Avoid contacting with the enemies."
call crlf

    mov dl, 40
	mov dh, 22
	call Gotoxy
mWrite "4. Press 'B' to go back to the menu."
call crlf

call ReadChar
cmp al, "b"
je Menu

jmp DisplayInstruction
DisplayInstruction ENDP



Quit PROC
call clrscr
mov eax, red
call SetTextColor
mov dl, 40
	mov dh, 10
	call Gotoxy
mWrite "GAME HAS BEEN CLOSED SUCCESSFULLY."
mov eax, white
call SetTextColor
call crlf
exit
Quit ENDP


Gameover PROC

call clrscr
mov eax, red
call SetTextColor

mov dl, 13
mov dh, 10
call Gotoxy
mov edx, offset over1
call writestring

mov dl, 13
mov dh, 11
call Gotoxy
mov edx, offset over2
call writestring

mov dl, 13
mov dh, 12
call Gotoxy
mov edx, offset over3
call writestring

mov dl, 13
mov dh, 13
call Gotoxy
mov edx, offset over4
call writestring

mov dl, 13
mov dh, 14
call Gotoxy
mov edx, offset over5
call writestring

mov dl, 13
mov dh, 15
call Gotoxy
mov edx, offset over6
call writestring

mov eax, brown
call setTextColor
mov dl, 50
mov dh, 20
call Gotoxy

mov edx, offset PlayerName
call writestring
mWrite "'s score was: "
movzx eax, score
call writedec
call crlf
INVOKE PlaySound, OFFSET soundPath2, NULL, 0
call ReadChar
jmp Gameover
Gameover ENDP


StartGame PROC
call clrscr
mov eax, blue
call SetTextColor
call CreateBoundary
mov eax, yellow
call SetTextColor
call DrawCoin
mov eax, lightgreen + (lightgreen * 16)
call SetTextColor
call DrawWalls
call DrawPlayer
mov eax, yellow(yellow*16)
call Teleportation
call DrawGhost
call DrawGhost2
call Fruit
INVOKE PlaySound, OFFSET soundPath3, NULL, 0
;call ReadChar

;call waitmsg

dec xPosG4

 gameLoop:
        
        
        cmp EatBool, 1
        je CheckG1X

        mov eax, 0
        mov al, FruitX
        cmp xPos, al
        jne CheckG1X

        mov eax, 0
        mov al, FruitY
        cmp yPos, al
        je Bonus


        CheckG1X:
        mov eax, 0
        mov al, xPos
        cmp xPosG1, al
        jne MotionG1

        CheckG1Y:
        mov ebx, 0
        mov bl, yPos
        cmp yPosG1, bl
        je LostLive

        MotionG1:
        cmp xPosG1, 118
        je BoolFalse

        cmp xPosG1, 110
        je BoolTrue

        cmp boolG1, 0
        je RenderGhost1Left

        cmp boolG1, 1
        je RenderGhost1Right

        jmp CheckGhost2

        BoolTrue:
        mov boolG1, 1
        jmp RenderGhost1Right


        BoolFalse:
        mov boolG1, 0

        RenderGhost1Left:
        call UpdateGhost
        dec xPosG1
        call DrawGhost
        jmp CheckGhost2


        RenderGhost1Right:
        call UpdateGhost
        inc xPosG1
        call DrawGhost
        jmp CheckGhost2




        CheckGhost2:
        mov eax, 0
        mov al, xPos
        cmp xPosG2, al
        je CheckG2Y

        cmp xPosG2, 118
        je BoolFalse2

        cmp xPosG2, 110
        je BoolTrue2

        cmp boolG2, 0
        je RenderGhost2Left

        cmp boolG2, 1
        je RenderGhost2Right

        jmp CheckLevel3


        CheckG2Y:
        mov ebx, 0
        mov bl, yPos
        cmp yPosG2, bl
        je LostLive

        BoolTrue2:
        mov boolG2, 1
        jmp RenderGhost2Right


        BoolFalse2:
        mov boolG2, 0

        RenderGhost2Left:
        call UpdateGhost2
        dec xPosG2
        call DrawGhost2
        jmp CheckLevel3


        RenderGhost2Right:
        call UpdateGhost2
        inc xPosG2
        call DrawGhost2
        jmp CheckLevel3


        CheckLevel3:
        cmp level, 3
        jne gameloop2


        CheckGhost3:
        mov eax, 0
        mov al, xPos
        cmp xPosG3, al
        je CheckG3Y

        cmp xPosG3, 2
        je BoolFalse3

        cmp xPosG3, 9
        je BoolTrue3

        cmp boolG3, 0
        je RenderGhost3Right

        cmp boolG3, 1
        je RenderGhost3Left

        jmp CheckGhost4


        CheckG3Y:
        mov ebx, 0
        mov bl, yPos
        cmp yPosG3, bl
        je LostLive

        BoolTrue3:
        mov boolG3, 1
        jmp RenderGhost3Left


        BoolFalse3:
        mov boolG3, 0

        RenderGhost3Right:
        call UpdateGhost3
        inc xPosG3
        call DrawGhost3
        jmp CheckGhost4

        RenderGhost3Left:
        call UpdateGhost3
        dec xPosG3
        call DrawGhost3
        jmp CheckGhost4



        CheckGhost4:
        mov eax, 0
        mov al, xPos
        dec al
        cmp xPosG4, al
        jne MotionG4

        CheckG4Y:
        mov ebx, 0
        mov bl, yPos
        cmp yPosG4, bl
        je LostLive


        MotionG4:
        cmp xPosG4, 2
        je BoolFalse4

        cmp xPosG4, 9
        je BoolTrue4

        cmp boolG4, 0
        je RenderGhost4Right

        cmp boolG4, 1
        je RenderGhost4Left

        jmp gameloop2

        BoolTrue4:
        mov boolG4, 1
        jmp RenderGhost4Left


        BoolFalse4:
        mov boolG4, 0

        RenderGhost4Right:
        call UpdateGhost4
        inc xPosG4
        call DrawGhost4
        jmp gameloop2

        RenderGhost4Left:
        call UpdateGhost4
        dec xPosG4
        call DrawGhost4
        jmp gameloop2


        gameloop2:

        mov ebx, 0
        mov bl, TeleY
        cmp yPos, bl
        jne SkipTeleY
        mov ebx, 0
        mov bl, TeleX
        cmp xPos, bl
        jne SkipTeleY

        call UpdatePlayer
        mov xPos, 118
        mov yPos, 28
        call DrawPlayer
        call Teleportation
        call UpdateGhost
        mov xPosG1, 118
        mov yPosG1, 10
        call DrawGhost
        call UpdateGhost2
        mov xPosG2, 110
        mov yPosG2, 18
        call DrawGhost2
        cmp level, 3
        jne SkipG3andG4one
        call UpdateGhost3
        mov xPosG3, 2
        mov yPosG3, 10
        call DrawGhost3
        call UpdateGhost4
        mov xPosG4, 9
        mov yPosG4, 18
        call DrawGhost4
        SkipG3andG4one:
        jmp gameloop
        
        SkipTeleY:
        ; getting points:
        cmp score, 675
        je RenderLevel2
        cmp score, 1326
        je RenderLevel3
        cmp score, 1977
        je RenderGameOver

        COMMENT &

        mov esi, offset CoinsX
        mov edi, offset CoinsY
        mov bl,xPos
        mov ecx, 0
        mov cx, CoinsCount
        CheckX:
        cmp bl,[esi] 
        je CheckY
        inc esi
        Loop CheckX
        jne notCollecting
        CheckY:
        mov bl,yPos
        cmp bl,[edi]
        je Collecting
        inc edi
        Loop CheckY
        jne notCollecting
        ; player is intersecting coin:
        Collecting:
        inc score
        dec CurrentCoinsCount
        ;call CreateRandomCoin
        ;call DrawCoin
        &

        ; check if pacman is intersecting the food 
        mov bl,xPos
        mov bh,yPos
        mov edx,0
        mov eax,0
        mov esi,offset CoinsArray
        ;mov edi,offset yCoordinateOfFood

         mov ecx,4000
        searchInScoreArray:
        cmp [esi],eax
        ; mov ax,[esi]
        ; cmp ax,-2
        je terminate
        mov edx,[esi] 
        cmp bl,dl
        je checkAdjacent
        add esi,2
        loop searchInScoreArray
        jmp terminate
        checkAdjacent:
        inc esi
        mov dh,[esi]
        cmp bh,dh
        Return:

        je incScore
        inc esi
        loop searchInScoreArray
        jmp drawScore
        incScore:
        INVOKE PlaySound, OFFSET soundPath, NULL, 11h
        inc score
        mov eax, 0
        mov [esi], al
        jmp Return
        terminate:

        drawScore:
        mov eax,lightmagenta
        call SetTextColor
        mov dl,0
        mov dh,0
        call Gotoxy
        mov edx,OFFSET strScore
        call WriteString
        mov ax,score
        call WriteDec

        drawLevel:
        mov eax,lightmagenta
        call SetTextColor
        mov dl,110
        mov dh,0
        call Gotoxy
        mov edx,OFFSET strLevel
        call WriteString
        mov al,level
        call WriteDec


        drawLives:
        mov eax,lightmagenta
        call SetTextColor
        mov dl,55
        mov dh,0
        call Gotoxy
        mov edx,OFFSET strLives
        call WriteString
        mov al,lives
        call WriteDec

        jmp UserInput

        CreateCoins:

        cmp level, 1
        je RenderLevel2

        cmp level, 2
        je RenderLevel3

        cmp level, 3
        jg RenderGameOver


        RenderLevel2:
        call Level2
        inc score
        inc level
        jmp RenderPlayerAndGhosts
        ;jmp gameloop

        RenderLevel3:
        call Level3
        inc level
        inc score
        jmp RenderPlayerAndGhosts

        ;jmp gameloop

        RenderGameOver:
        call GameOver
        jmp gameloop


        Bonus:
        add score, 25
        mov EatBool, 1
        jmp gameloop

        LostLive:
        INVOKE PlaySound, OFFSET soundPath2, NULL, 0
        dec lives
        cmp lives, 0
        je RenderGameOver
        RenderPlayerAndGhosts:
        call UpdatePlayer
        mov xPos, 1
        mov yPos, 15
        call DrawPlayer
        call UpdateGhost
        mov xPosG1, 118
        mov yPosG1, 10
        call DrawGhost
        call UpdateGhost2
        mov xPosG2, 110
        mov yPosG2, 18
        call DrawGhost2
        cmp level, 3
        jne SkipG3andG4
        call UpdateGhost3
        mov xPosG3, 2
        mov yPosG3, 10
        call DrawGhost3
        call UpdateGhost4
        mov xPosG4, 9
        mov yPosG4, 18
        call DrawGhost4
        SkipG3andG4:
        jmp gameloop

        COMMENT &
        ; gravity logic:
        gravity:
        cmp yPos,27
        jg onGround
        ; make player fall:
        call UpdatePlayer
        inc yPos
        call DrawPlayer
        mov eax,80
        call Delay
        jmp gravity
        onGround:
        &

        ; get user key input:
        UserInput:
        call ReadChar
        mov inputChar,al

        
        cmp inputChar,"w"
        je moveUp

        cmp inputChar,"s"
        je moveDown

        cmp inputChar,"a"
        je moveLeft

        cmp inputChar,"d"
        je moveRight

        
        cmp inputChar, "n"
        je CreateCoins
        

        jmp gameloop2



        moveUp:
        cmp yPos, 2
        jle UpperLimit

        mov ecx, 1000
        movzx eax, yPos
        dec eax
        mov esi, offset WallsX
        mov ebx, 0
        LoopUpX:
        mov bl, [esi]
        cmp bl, al
        je CheckWallY
        inc esi
        Loop LoopUpX

        call UpdatePlayer
        dec yPos
        call DrawPlayer
        jmp gameLoop
         CheckWallY:
        mov edi, offset WallsY
        mov ecx, 1000
        movzx ebx, xPos 
        ;dec ebx
        mov eax, 0
        LoopUpY:
        mov al, [edi]
        cmp al, bl
        je UpperLimit
        inc edi
        Loop LoopUpY
        call UpdatePlayer
        dec yPos
        call DrawPlayer
        UpperLimit:
        jmp gameLoop

        moveDown:
        cmp yPos, 28
        jge lowerlimit

         mov ecx, 1000
        movzx eax, yPos
        inc eax
        mov esi, offset WallsX
        mov ebx, 0
        LoopDownX:
        mov bl, [esi]
        cmp bl, al
        je CheckWallYDown
        inc esi
        Loop LoopDownX

        call UpdatePlayer
        inc yPos
        call DrawPlayer

        jmp gameLoop
         CheckWallYDown:
        mov edi, offset WallsY
        mov ecx, 1000
        movzx ebx, xPos 
        ;dec ebx
        mov eax, 0
        LoopDownY:
        mov al, [edi]
        cmp al, bl
        je lowerlimit
        inc edi
        Loop LoopDownY
        
        call UpdatePlayer
        inc yPos
        call DrawPlayer
        lowerlimit:
        jmp gameLoop

        moveLeft:
        cmp xPos, 1
        jle LeftLimit

        mov ecx, 1000
        movzx eax, yPos
        ;inc eax
        mov esi, offset WallsX
        mov ebx, 0
        LoopLeftX:
        mov bl, [esi]
        cmp bl, al
        je CheckWallYLeft
        inc esi
        Loop LoopLeftX
        call UpdatePlayer
        dec xPos
        call DrawPlayer
        jmp gameLoop


         CheckWallYLeft:
        mov edi, offset WallsY
        mov ecx, 1000
        movzx ebx, xPos 
        dec ebx
        mov eax, 0
        LoopLeftY:
        mov al, [edi]
        cmp al, bl
        je LeftLimit
        inc edi
        Loop LoopLeftY
         call UpdatePlayer
        dec xPos
        call DrawPlayer
        LeftLimit:
        jmp gameLoop

        moveRight:
        cmp xPos, 118
        jge RightLimit

         mov ecx, 1000
        movzx eax, yPos
        ;inc eax
        mov esi, offset WallsX
        mov ebx, 0
        LoopRightX:
        mov bl, [esi]
        cmp bl, al
        je CheckWallYRight
        inc esi
        Loop LoopRightX
        call UpdatePlayer
        inc xPos
        call DrawPlayer
        jmp gameLoop

        CheckWallYRight:
        mov edi, offset WallsY
        mov ecx, 1000
        movzx ebx, xPos 
        inc ebx
        mov eax, 0
        LoopRightY:
        mov al, [edi]
        cmp al, bl
        je RightLimit
        inc edi
        Loop LoopRightY
        call UpdatePlayer
        inc xPos
        call DrawPlayer
        RightLimit:
        jmp gameLoop

        jmp gameLoop

StartGame ENDP



Teleportation PROC
call Randomize
mov eax, yellow(yellow*16)
call setTextColor
mov dl, 6
mov TeleX, dl
mov eax, 0
mov eax, 25
call RandomRange
add eax, 3
mov dh, al
mov TeleY, dh
call gotoxy
mov al, " "
call writeChar
ret

Teleportation ENDP
CreateBoundary PROC
    mov eax,blue
    call SetTextColor
    mov dl,0
    mov dh,29
    call Gotoxy
    mov edx,OFFSET ground
    call WriteString



    mov dl,0
    mov dh,1
    call Gotoxy
    mov edx,OFFSET ground
    call WriteString

    mov ecx,28
    mov dh,1
    l1:
    mov dl,0
    call Gotoxy
    mov edx,OFFSET ground1
    call WriteString
    ;inc dh
    loop l1


    mov ecx,28
    mov dh,1
    mov temp,dh
    l2:
    mov dh,temp
    mov dl,119
    call Gotoxy
    mov edx,OFFSET ground2
    call WriteString
    inc temp
    loop l2

    ;call CreateRandomCoin
    ;call DrawCoin
    ;call Randomize

ret
CreateBoundary ENDP

DrawWalls PROC

call Randomize
mov ecx, 12
mov eax, 20
call RandomRange
add eax, 3
mov LengthOfWalls, ax
mov dh, 4
mov dl, 9
mov esi, offset WallsX
mov edi, offset WallsY
mov [esi], dh
mov [edi], dl
TotalWalls:
mov temp2, ax
mov ebx, 0
mov bx, LengthOfWalls
add bl, dl
cmp bx, 105
jl BackToDrawWall
MoveDown:
add dh, 8
cmp dh, 28
jg StopDrawingWalls
mov dl, 9
jmp BackToDrawWall
BackToDrawWall:
mov ebx, ecx
movzx ecx, LengthOfWalls
EachWall:
inc dl
call gotoxy
mov [esi], dh
mov [edi], dl
mov al, "_"
call WriteChar
inc edi
inc esi
Loop EachWall
inc dl
mov eax, black(black * 16)
call setTextColor
call Gotoxy
mov eax, 0
mov al, " "
inc dl
call Gotoxy
mov al, " "
inc dl
call WriteChar
mov ecx, ebx
mov eax, lightgreen(lightgreen * 16)
call setTextColor
jmp TotalWalls
StopDrawingWalls:
ret
DrawWalls ENDP

Fruit PROC
mov eax, lightmagenta
call setTextColor
call Randomize
mov eax, 90
call RandomRange
add eax, 17
mov FruitX, al
mov dl, al
mov dh, FruitY
call gotoxy
mov eax, 0
mov al, "O"
call writeChar
ret
Fruit ENDP

DrawPlayer PROC
    ; draw player at (xPos,yPos):
    mov eax,yellow ;(blue*16)
    call SetTextColor
    mov dl,xPos
    mov dh,yPos
    call Gotoxy
    mov al,"X"
    call WriteChar
    ret
DrawPlayer ENDP

UpdatePlayer PROC
    mov dl,xPos
    mov dh,yPos
    call Gotoxy
    mov al," "
    call WriteChar
    ret
UpdatePlayer ENDP

DrawGhost PROC

    mov eax, lightgray
    call SetTextColor
    mov dl,xPosG1
    mov dh,yPosG1
    call Gotoxy
    mov al,"O"
    call WriteChar
    ret
DrawGhost ENDP

UpdateGhost PROC
    mov eax, lightgray
    call setTextColor
    mov dl,xPosG1
    mov dh,yPosG1
    call Gotoxy
    mov al," "
    call WriteChar
    ret
UpdateGhost ENDP


DrawGhost2 PROC

    mov eax, lightgray
    call SetTextColor
    mov dl,xPosG2
    mov dh,yPosG2
    call Gotoxy
    mov al,"O"
    call WriteChar
    ret
DrawGhost2 ENDP

UpdateGhost2 PROC
    mov dl,xPosG2
    mov dh,yPosG2
    call Gotoxy
    mov al," "
    call WriteChar
    ret
UpdateGhost2 ENDP


DrawGhost3 PROC

    mov eax, lightgray
    call SetTextColor
    mov dl,xPosG3
    mov dh,yPosG3
    call Gotoxy
    mov al,"O"
    call WriteChar
    ret
DrawGhost3 ENDP

UpdateGhost3 PROC
    mov dl,xPosG3
    mov dh,yPosG3
    call Gotoxy
    mov al," "
    call WriteChar
    ret
UpdateGhost3 ENDP

DrawGhost4 PROC

    mov eax, lightgray
    call SetTextColor
    mov dl,xPosG4
    mov dh,yPosG4
    call Gotoxy
    mov al,"O"
    call WriteChar
    ret
DrawGhost4 ENDP

UpdateGhost4 PROC
    mov dl,xPosG4
    mov dh,yPosG4
    call Gotoxy
    mov al," "
    call WriteChar
    ret
UpdateGhost4 ENDP

DrawCoin PROC
    mov eax,yellow
    call SetTextColor
    mov dl,7
    mov dh,2
    call Gotoxy
    COMMENT &
    mov esi, offset CoinsX
    mov edi, offset CoinsY
    mov [esi], dl
    mov [edi], dh
    &

    mov esi, offset CoinsArray
    mov [esi], dl
    inc esi
    mov [esi], dh
    mov ecx, 26
    mov CoinsCount, cx
    mov ecx, 50
NoOfColumns:
     add CurrentCoinsCount, 27
     mov ebx, 0
     mov ebx, ecx
     mov dh, 1
     add dl, 2
     mov cx, 13
        DrawCoins:
            add dh, 2
            cmp dl, 50
            je StopCreatingFood
            COMMENT &
            inc esi
            inc edi
            mov [esi], dl
            mov [edi], dh
            &
            inc esi
            mov [esi], dl
            inc esi
            mov [esi], dh
            call Gotoxy
            mov al,"."
            call WriteChar
             Loop DrawCoins
      mov ecx, ebx
Loop NoOfColumns
mov bx, CurrentCoinsCount
mov CoinsCount, bx
dec CurrentCoinsCount
StopCreatingFood:
    ret
DrawCoin ENDP

COMMENT &
CreateRandomCoin PROC
    mov eax,28
    inc eax
    call RandomRange
    mov xCoinPos,al
    mov eax, 18
    inc eax
    call RandomRange
    mov yCoinPos,al
    ret
CreateRandomCoin ENDP
&

Welcome PROC
mov eax, lightgreen

call SetTextColor

mov dl, 28
mov dh, 10
call Gotoxy
mov edx, offset title2
call writestring

mov dl, 28
mov dh, 11
call Gotoxy
mov edx, offset title3
call writestring

mov dl, 28
mov dh, 12
call Gotoxy
mov edx, offset title4
call writestring

mov dl, 28
mov dh, 13
call Gotoxy
mov edx, offset title5
call writestring

mov dl, 28
mov dh, 14
call Gotoxy
mov edx, offset title6
call writestring

mov dl, 28
mov dh, 15
call Gotoxy
mov edx, offset title7
call writestring

mov eax, lightmagenta
call SetTextColor
mov dl, 47
mov dh, 20
call Gotoxy
mWrite "Enter your name: "
mov edx, offset PlayerName
mov ecx, 15
call readstring
call crlf

mov eax, green
call SetTextColor
mov dl, 50
mov dh, 21
call Gotoxy
mWrite "Welcome "
mov edx, offset PlayerName
call writestring
mWrite "!!!"


mov eax, lightmagenta
call SetTextColor
mov dl, 42
mov dh, 22
call Gotoxy
mWrite "Press any key to start the game..."
call ReadChar
jmp Menu
Welcome ENDP

Menu PROC
	mov eax, lightblue
	call SetTextColor
	call Clrscr
	mov dl, 55
	mov dh, 2
	call Gotoxy
	mWrite "START"
	call crlf

	mov dl, 55
	mov dh, 10
	call Gotoxy
	mWrite "HIGHSCORE"
	call WriteString
	call crlf

	mov dl, 55
	mov dh, 18
	call Gotoxy
	mWrite "INSTRUCTION"
	call crlf

	mov dl, 55
	mov dh, 26
	call Gotoxy
	mWrite "QUIT"
	call crlf

	mov eax, 0
	call ReadChar

	cmp al, "i"
	je DisplayInstruction

	cmp al, "q"
	je Quit

	cmp al, "s"
	je StartGame

    cmp al, "h"
    je DisplayScores

	jmp Menu
Menu ENDP


DisplayScores PROC

cmp DisplayScoreBool, 1
je WriteScores
mov eax, 0
call ReadScores

WriteScores:
    call Clrscr
    mov edx, 0
    mov dl, 47
    mov dh, 4
    call Gotoxy
    mov eax, red
    call SetTextColor
	mWrite "ALL TIME BEST HIGHSCORES"
    call crlf

    mov edx, 0
    mov dl, 50
    mov dh, 10
    call Gotoxy
    mov eax, lightgreen
    call SetTextColor
	mov edx, offset Name1
    call writestring
     mov eax, brown
    call SetTextColor
    mov edx, offset Highscore1
    call writestring
	mWrite "                             "  
    call crlf

    mov edx, 0
    mov dl, 50
    mov dh, 16
    call Gotoxy
    mov eax, lightgreen
    call SetTextColor
	mov edx, offset Name2
    call writestring
    mov eax, brown
    call SetTextColor
    mov edx, offset Highscore2
    call writestring
	mWrite "                             "  
    call crlf


    mov edx, 0
    mov dl, 50
    mov dh, 22
    call Gotoxy
    mov eax, lightgreen
    call SetTextColor
	mov edx, offset Name3
    call writestring
    mov eax, brown
    call SetTextColor
    mov edx, offset Highscore3
    call writestring
	mWrite "                             "  
    call crlf

    mov DisplayScoreBool, 1
    call ReadChar
    cmp al, "b"
    je Menu

    jmp WriteScores

DisplayScores ENDP

DrawWallsLevel2 PROC

call Randomize
mov ecx, 12
mov eax, 20
call RandomRange
add eax, 3
mov LengthOfWalls, ax
mov dh, 4
mov dl, 9
mov esi, offset WallsX
mov edi, offset WallsY
mov [esi], dh
mov [edi], dl
TotalWalls:
mov temp2, ax
mov ebx, 0
mov bx, LengthOfWalls
add bl, dl
cmp bx, 105
jl BackToDrawWall
MoveDown:
add dh, 4
cmp dh, 28
jg StopDrawingWalls
mov dl, 9
jmp BackToDrawWall
BackToDrawWall:
mov ebx, ecx
movzx ecx, LengthOfWalls
EachWall:
inc dl
call gotoxy
mov [esi], dh
mov [edi], dl
mov al, "_"
call WriteChar
inc edi
inc esi
Loop EachWall
inc dl
mov eax, black(black * 16)
call setTextColor
call Gotoxy
mov eax, 0
mov al, " "
inc dl
call Gotoxy
mov al, " "
inc dl
call WriteChar
mov ecx, ebx

mov eax, red(red * 16)
call setTextColor
jmp TotalWalls
StopDrawingWalls:
ret
DrawWallsLevel2 ENDP

DrawWallsLevel3 PROC
call Randomize
mov ecx, 12
mov eax, 20
call RandomRange
add eax, 3
mov LengthOfWalls, ax
mov dh, 4
mov dl, 9
mov esi, offset WallsX
mov edi, offset WallsY
mov [esi], dh
mov [edi], dl
TotalWalls:
mov temp2, ax
mov ebx, 0
mov bx, LengthOfWalls
add bl, dl
cmp bx, 105
jl BackToDrawWall
MoveDown:
add dh, 2
cmp dh, 28
jg StopDrawingWalls
mov dl, 9
jmp BackToDrawWall
BackToDrawWall:
mov ebx, ecx
movzx ecx, LengthOfWalls
EachWall:
inc dl
call gotoxy
mov [esi], dh
mov [edi], dl
mov al, "_"
call WriteChar
inc edi
inc esi
Loop EachWall
inc dl
call Gotoxy
mov eax, black(black * 16)
call setTextColor
mov eax, 0
mov al, " "
inc dl
call Gotoxy
mov al, " "
inc dl
call WriteChar
mov ecx, ebx
mov eax, brown(brown * 16)
call setTextColor
jmp TotalWalls
StopDrawingWalls:
ret
DrawWallsLevel3 ENDP

ReadScores Proc
    ; Read the file.
    mov edx,OFFSET filename
	call OpenInputFile
	mov fileHandle, eax
	
	cmp eax, INVALID_HANDLE_VALUE ; error opening file?
	jne letsOpenFile 
	
	;mWrite "Cannot open file"	; prompt that we cannot open file
	
    letsOpenFile:
		mov edx, OFFSET buffer	; Read the file into a buffer.
		mov ecx, BUFFER_SIZE
		call ReadFromFile

    ; showing .txt contents

	call crlf   ; newline

	mov edx, offset buffer   ; mov string offset in edx
    mov esi, offset Name1
    GetName1:
    mov eax, 0
    mov al, [edx]
    cmp al, 32
    je S1
    mov [esi], al
    inc edx
    inc esi
    inc inFileCount
    jmp GetName1

    S1:
    inc inFileCount
    mov edx, offset buffer
    mov ebx, 0
    mov bx, inFileCount
    add edx, ebx
    mov esi, offset HighScore1
    GetScore1:
     mov eax, 0
    mov al, [edx]
    cmp al, 32
    je N2
    mov [esi], al
    inc edx
    inc esi
    inc inFileCount
    jmp GetScore1

    N2:

    inc inFileCount
    mov edx, offset buffer
    mov ebx, 0
    mov bx, inFileCount
    add edx, ebx
    mov esi, offset Name2
    GetName2:
     mov eax, 0
    mov al, [edx]
    cmp al, 32
    je S2
    mov [esi], al
    inc edx
    inc esi
    inc inFileCount
    jmp GetName2

    S2:
    inc inFileCount
    mov edx, offset buffer
    mov ebx, 0
    mov bx, inFileCount
    add edx, ebx
    mov esi, offset HighScore2
    GetScore2:
     mov eax, 0
    mov al, [edx]
    cmp al, 32
    je N3
    mov [esi], al
    inc edx
    inc esi
    inc inFileCount
    jmp GetScore2

    N3:
    inc inFileCount
    mov edx, offset buffer
    mov ebx, 0
    mov bx, inFileCount
    add edx, ebx
    mov esi, offset Name3
    GetName3:
     mov eax, 0
    mov al, [edx]
    cmp al, 32
    je S3
    mov [esi], al
    inc edx
    inc esi
    inc inFileCount
    jmp GetName3

    S3:
    inc inFileCount
    mov edx, offset buffer
    mov ebx, 0
    mov bx, inFileCount
    add edx, ebx
    mov esi, offset HighScore3
    GetScore3:
     mov eax, 0
    mov al, [edx]
    cmp al, 32
    je Output
    mov [esi], al
    inc edx
    inc esi
    inc inFileCount
    jmp GetScore3

    Output:
    COMMENT &
    mov edx, offset Name1
    call writestring
    mov edx, offset HighScore1
    call writestring

    mov edx, offset Name2
    call writestring
    mov edx, offset HighScore2
    call writestring

    mov edx, offset Name3
    call writestring
    mov edx, offset HighScore3
    call writestring
    &
close_file:
		mov eax,fileHandle
		call CloseFile
	ret
ReadScores ENDP


Level2 PROC
call clrscr
mov eax, blue
call SetTextColor
call CreateBoundary
mov eax, yellow
call SetTextColor
call DrawCoin
mov eax, red(red*16)
call SetTextColor
call DrawWallsLevel2
call DrawPlayer
call Teleportation
call Fruit
ret
Level2 ENDP

Level3 PROC
call clrscr
mov eax, blue
call SetTextColor
call CreateBoundary
mov eax, yellow
call SetTextColor
call DrawCoin
mov eax, brown(brown*16)
call SetTextColor
call DrawWallsLevel3
call DrawPlayer
call Teleportation
call DrawGhost3
call DrawGhost4
call Fruit
ret
Level3 ENDP

END main