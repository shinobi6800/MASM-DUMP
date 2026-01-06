option casemap:none

; =========================
; Libraries
; =========================
includelib kernel32.lib
includelib user32.lib

; =========================
; Prototypes
; =========================
ExitProcess PROTO :QWORD
GetStdHandle PROTO :QWORD
WriteConsoleA PROTO :QWORD, :QWORD, :QWORD, :QWORD, :QWORD

CreateToolhelp32Snapshot PROTO :QWORD, :QWORD
Process32First PROTO :QWORD, :QWORD
Process32Next PROTO :QWORD, :QWORD
; =========================
; Constants
; =========================
STD_OUTPUT_HANDLE equ -11
TH32CS_SNAPPROCESS equ 2

; =========================
; Structures
; =========================
PROCESSENTRY32 STRUCT
    dwSize              DWORD ?
    cntUsage            DWORD ?
    th32ProcessID       DWORD ?
    th32DefaultHeapID   QWORD ?
    th32ModuleID        DWORD ?
    cntThreads          DWORD ?
    th32ParentProcessID DWORD ?
    pcPriClassBase      LONG ?
    dwFlags             DWORD ?
    szExeFile           BYTE 260 dup(?)
PROCESSENTRY32 ENDS

; =========================
; Data
; =========================
.data
    pe32 PROCESSENTRY32 <>
    newline db 13, 10
    hConsole dq ?

; =========================
; Code
; =========================
.code
main PROC
    sub rsp, 28h                ; shadow space

    ; Get console handle
    mov rcx, STD_OUTPUT_HANDLE
    call GetStdHandle
    mov hConsole, rax

    ; Create process snapshot
    mov rcx, TH32CS_SNAPPROCESS
    xor rdx, rdx
    call CreateToolhelp32Snapshot
    mov rbx, rax                ; save snapshot handle

    ; Initialize structure size
    mov pe32.dwSize, SIZEOF PROCESSENTRY32

    ; Get first process
    lea rdx, pe32
    mov rcx, rbx
    call Process32First
    test eax, eax
    jz done

process_loop:
    ; Print process name
    lea rdx, pe32.szExeFile
    call PrintString

    ; New line
    lea rdx, newline
    call PrintString

    ; Next process
    lea rdx, pe32
    mov rcx, rbx
    call Process32Next
    test eax, eax
    jnz process_loop

done:
    xor rcx, rcx
    call ExitProcess

main ENDP

; =========================
; Print String Function
; =========================
PrintString PROC
    sub rsp, 28h

    ; Calculate string length
    xor r8, r8
len_loop:
    cmp byte ptr [rdx + r8], 0
    je write
    inc r8
    jmp len_loop

write:
    mov rcx, hConsole
    mov rdx, rdx
    mov r9, 0
    call WriteConsoleA

    add rsp, 28h
    ret
PrintString ENDP

END