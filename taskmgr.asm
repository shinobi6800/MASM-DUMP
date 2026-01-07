option casemap:none

includelib kernel32.lib

ExitProcess PROTO :QWORD
GetStdHandle PROTO :QWORD
WriteConsoleA PROTO :QWORD, :QWORD, :QWORD, :QWORD, :QWORD
CreateToolhelp32Snapshot PROTO :QWORD, :QWORD
Process32First PROTO :QWORD, :QWORD
Process32Next PROTO :QWORD, :QWORD

STD_OUTPUT_HANDLE equ -11
TH32CS_SNAPPROCESS equ 2

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

.data
    pe32 PROCESSENTRY32 <>
    hConsole dq ?

    header db "PID     Threads   Process Name",13,10
           db "--------------------------------",13,10,0

    space db "   ",0
    newline db 13,10,0

.code
main PROC
    sub rsp, 28h

    ; Console handle
    mov rcx, STD_OUTPUT_HANDLE
    call GetStdHandle
    mov hConsole, rax

    ; Print header
    lea rdx, header
    call PrintString

    ; Snapshot
    mov rcx, TH32CS_SNAPPROCESS
    xor rdx, rdx
    call CreateToolhelp32Snapshot
    mov rbx, rax

    mov pe32.dwSize, SIZEOF PROCESSENTRY32

    lea rdx, pe32
    mov rcx, rbx
    call Process32First
    test eax, eax
    jz done

process_loop:
    ; PID
    mov eax, pe32.th32ProcessID
    call PrintNumber
    lea rdx, space
    call PrintString

    ; Thread count
    mov eax, pe32.cntThreads
    call PrintNumber
    lea rdx, space
    call PrintString

    ; Process name
    lea rdx, pe32.szExeFile
    call PrintString
    lea rdx, newline
    call PrintString

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
; PrintString
; =========================
PrintString PROC
    sub rsp, 28h
    xor r8, r8

len_loop:
    cmp byte ptr [rdx+r8], 0
    je write
    inc r8
    jmp len_loop

write:
    mov rcx, hConsole
    mov r9, 0
    call WriteConsoleA
    add rsp, 28h
    ret
PrintString ENDP

; =========================
; PrintNumber (EAX)
; =========================
PrintNumber PROC
    sub rsp, 28h

    mov ecx, 10
    lea rdi, [rsp+20h]
    mov byte ptr [rdi], 0

convert:
    xor edx, edx
    div ecx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test eax, eax
    jnz convert

    mov rdx, rdi
    call PrintString

    add rsp, 28h
    ret
PrintNumber ENDP

END