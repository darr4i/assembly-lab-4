; Assembler directives
.386
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\dialogs.inc
include \masm32\macros\macros.asm

include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

; Data section
.data
MY_SUCCESS_TITLE_MESSAGE       db "Successful login", 0
MY_ERROR_TITLE_MESSAGE         db "Login failed", 0
MY_PROMPT_MESSAGE              db "Please, enter your password below:", 0
MY_NAME_MESSAGE                db "Name: Rabiichuk D.O.", 0
MY_BIRTHDAY_MESSAGE            db "Birthday data: 09.12.2004", 0
MY_SCOREBOOK_MESSAGE           db "Score book number: 8915", 0
MY_ERROR_MESSAGE               db "Oops..you entered the wrong password!", 0

; Password and key data
my_password            db "KwqFT", 0
my_password_length      equ $ - my_password
my_key                 db "zEBra", 0
my_password_buffer     db 32 dup (?)

; Code section
.code

; Macro to display a message box with the provided text
ShowMessageBox MACRO messageText:REQ 
;;hidden comment
    invoke MessageBox, 0, addr messageText, addr MY_SUCCESS_TITLE_MESSAGE, 0
ENDM

; Procedure to check the entered password
checking_my_password proc
    mov ebx, 0

checking_password_loop:
    mov al, my_password_buffer[ebx] 
    cmp al, 0  
    je checking_password_end 
    
    mov ah, my_key[ebx] 
    xor al, ah ;;hidden comment
    
    mov ah, my_password[ebx] 
    cmp al, ah 
    jne wrong_password 
        
    inc ebx 
    jmp checking_password_loop 
        
checking_password_end:
    xor eax, eax 
    ret
    
wrong_password:
    mov eax, 1 
    ret
checking_my_password endp

; Procedure for handling dialog window messages
dialogWindow proc hWindow: dword, message: dword, wParam: dword, lParam: dword   
    .if message == WM_COMMAND
        .if wParam == IDOK
            invoke GetDlgItemText, hWindow, 650, addr my_password_buffer, 32
            pushad
            call checking_my_password
            test eax, eax
            jnz @F  
            popad
            ; Show name message box
            ShowMessageBox MY_NAME_MESSAGE
            ; Show birthday message box
            ShowMessageBox MY_BIRTHDAY_MESSAGE
            ; Show score book number message box
            ShowMessageBox MY_SCOREBOOK_MESSAGE
            invoke ExitProcess, NULL
            jmp @EndDialog
@@:
            popad
            ShowMessageBox MY_ERROR_MESSAGE
            jmp @EndDialog
@EndDialog:
        .elseif wParam == IDCANCEL
            invoke ExitProcess, NULL
        .endif
    .elseif message == WM_CLOSE
        invoke ExitProcess, NULL
    .endif
    xor eax, eax ; Return 0
    ret
dialogWindow endp

; Macro for encrypting input string
EncryptInputString MACRO inputString:REQ 
    mov ebx, 0
encrypt_loop: 
    mov al, inputString[ebx]
    cmp al, 0
    je encrypt_end ;;hidden comment
    ; Encryption algorithm here (for example, XOR with a key)
    mov ah, my_key[ebx]
    xor al, ah
    mov inputString[ebx], al
    inc ebx
    jmp encrypt_loop
encrypt_end:
ENDM

; Macro for comparing encrypted input string with password hash
CompareEncryptedString MACRO inputString:REQ 
    mov ebx, 0
    xor ecx, ecx ; Counter for matching characters
compare_loop:
    mov al, inputString[ebx]
    cmp al, 0
    je compare_end ;;hidden comment
    ; Hash comparison algorithm here
    mov ah, my_password[ebx]
    cmp al, ah
    jne mismatch
    inc ecx
    inc ebx
    jmp compare_loop
mismatch:
    ; If a mismatch is found, reset the counter and return false
    xor ecx, ecx
    ret
compare_end:
    ; If all characters match, return the number of matching characters
    mov eax, ecx
ENDM


; Main program entry point
main PROC
    ; Dialog box creation
 Dialog "Lab4 Rabiichuk D.O.", "Calibri",14, \
        WS_OVERLAPPED OR WS_SYSMENU OR DS_CENTER, \
        4,8,8,200,80,1024
    DlgStatic "Enter your password",SS_CENTER,30,15,150,30,1000
    DlgEdit WS_BORDER,20,30,160,11,650
    DlgButton "Enter", WS_TABSTOP,20,40,40,20,IDOK
    DlgButton "Decline", WS_TABSTOP,140,40,40,20,IDCANCEL

    CallModalDialog 0, 0, dialogWindow, NULL
    ret
main ENDP

END main 
; End of program
