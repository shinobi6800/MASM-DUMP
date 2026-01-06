option casemap:none

; ---- Libraries ----
includelib kernel32.lib
includelib user32.lib

; ---- Function Prototypes ----
ExitProcess PROTO :QWORD
MessageBoxA PROTO :QWORD, :QWORD, :QWORD, :QWORD

; ---- Data Section ----
.data
    msg     db "I love u very much , happy new year and all the best", 0
    title   db "Message", 0

; ---- Code Section ----
.code
main PROC
    sub rsp, 28h        ; shadow space + stack alignment (IMPORTANT)

    xor rcx, rcx        ; hWnd = NULL
    lea rdx, msg        ; lpText
    lea r8, title       ; lpCaption
    xor r9, r9          ; MB_OK
    call MessageBoxA

    xor rcx, rcx
    call ExitProcess

main ENDP
END
