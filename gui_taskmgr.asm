option casemap:none

includelib kernel32.lib
includelib user32.lib
includelib comctl32.lib

WinMain PROTO :QWORD, :QWORD, :QWORD, :QWORD
ExitProcess PROTO :QWORD
RegisterClassExA PROTO :QWORD
CreateWindowExA PROTO :QWORD,:QWORD,:QWORD,:QWORD,:QWORD,:QWORD,:QWORD,:QWORD,:QWORD,:QWORD,:QWORD
DefWindowProcA PROTO :QWORD,:QWORD,:QWORD,:QWORD
GetMessageA PROTO :QWORD,:QWORD,:QWORD,:QWORD
TranslateMessage PROTO :QWORD
DispatchMessageA PROTO :QWORD
InitCommonControls PROTO

WM_DESTROY equ 2
WS_OVERLAPPEDWINDOW equ 00CF0000h
WS_VISIBLE equ 10000000h
LVS_REPORT equ 1

.data
    className db "TaskMgrClass",0
    title db "Task Manager (MASM)",0
    listViewClass db "SysListView32",0

.code
start:
    sub rsp, 28h

    call InitCommonControls

    ; Register window class
    lea rcx, wc
    call RegisterClassExA

    ; Create main window
    xor rcx, rcx
    lea rdx, className
    lea r8, title
    mov r9d, WS_OVERLAPPEDWINDOW or WS_VISIBLE
    push 600
    push 800
    push 100
    push 100
    push 0
    push 0
    push 0
    push 0
    call CreateWindowExA

    ; Message loop
msg_loop:
    lea rcx, msg
    xor rdx, rdx
    xor r8, r8
    xor r9, r9
    call GetMessageA
    test eax, eax
    jz exit

    lea rcx, msg
    call TranslateMessage
    lea rcx, msg
    call DispatchMessageA
    jmp msg_loop

exit:
    xor rcx, rcx
    call ExitProcess

; ------------------------
; Window Procedure
; ------------------------
WndProc PROC hwnd:QWORD, msg:QWORD, wparam:QWORD, lparam:QWORD
    cmp msg, WM_DESTROY
    je destroy
    jmp def

destroy:
    xor rcx, rcx
    call ExitProcess

def:
    mov rcx, hwnd
    mov rdx, msg
    mov r8, wparam
    mov r9, lparam
    call DefWindowProcA
    ret
WndProc ENDP

wc:
    dq SIZEOF_WNDCLASSEX
    dq 0
    dq WndProc
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq 0
    dq className

msg dq 0

END start
