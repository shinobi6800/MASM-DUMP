option casemap:none

includelib kernel32.lib

ExitProcess PROTO :QWORD
GetStdHandle PROTO :QWORD
WriteConsoleA PROTO :QWORD, :QWORD, :QWORD, :QWORD, :QWORD
CreateToolhelp32Snapshot PROTO :QWORD, :QWORD
Process32First PROTO :QWORD, :QWORD
Process32Next PROTO :QWORD, :QWORD
OpenProcess PROTO :QWORD, :QWORD, :QWORD
GetProcessTimes PROTO :QWORD, :QWORD, :QWORD, :QWORD, :QWORD
GetSystemTimes PROTO :QWORD, :QWORD, :QWORD
Sleep PROTO :QWORD

STD_OUTPUT_HANDLE equ -11
TH32CS_SNAPPROCESS equ 2
PROCESS_QUERY_INFORMATION equ 0400h

PROCESSENTRY32 STRUCT
    dwSize DWORD ?
    cntUsage DWORD ?
    th32ProcessID DWORD ?
    th32DefaultHeapID QWORD ?
    th32ModuleID DWORD ?
    cntThreads DWORD ?
    th32ParentProcessID DWORD ?
    pcPriClassBase LONG ?
    dwFlags DWORD ?
    szExeFile BYTE 260 dup(?)
PROCESSENTRY32 ENDS

.data
    pe32 PROCESSENTRY32 <>
    hConsole dq ?

    oldSysIdle dq ?
    oldSysKernel dq ?
    oldSysUser dq ?

    newSysIdle dq ?
    newSysKernel dq ?
    newSysUser dq ?

    oldProcTime dq ?
    newProcTime dq ?

    header db "CPU%   PID     Process",13,10
           db "--------------------------",13,10,0
    space db "   ",0
    newline db 13,10,0
    percent db "%",0

.code
main PROC
    sub rsp, 28h

    ; Console
    mov rcx, STD_OUTPUT_HANDLE
    call GetStdHandle
    mov hConsole, rax

    lea rdx, header
    call PrintString

    ; System time snapshot #1
    lea rcx, oldSysIdle
    lea rdx, oldSysKernel
    lea r8,  oldSysUser
    call GetSystemTimes

    ; Sleep 1 second
    mov rcx, 1000
    call Sleep

    ; System time snapshot #2
    lea rcx, newSysIdle
    lea rdx, newSysKernel
    lea r8,  newSysUser
    call GetSystemTimes

    ; Create snapshot
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
    ; Open process
    mov ecx, PROCESS_QUERY_INFORMATION
    xor edx, edx
    mov r8d, pe32.th32ProcessID
    call OpenProcess
    test rax, rax
    jz next

    mov rdi, rax

    ; First process time
    sub rsp, 20h
    lea rdx, oldProcTime
    lea r8,  oldProcTime
    lea r9,  oldProcTime
    mov rcx, rdi
    call GetProcessTimes
    add rsp, 20h

    ; Second process time
    sub rsp, 20h
    lea rdx, newProcTime
    lea r8,  newProcTime
    lea r9,  newProcTime
    mov rcx, rdi
    call GetProcessTimes
    add rsp, 20h

    ; Delta proc time
    mov rax, newProcTime
    sub rax, oldProcTime

    ; Delta system time
    mov rbx, newSysKernel
    add rbx, newSysUser
    sub rbx, oldSysKernel
    sub rbx, oldSysUser

    ; CPU % = (proc_delta * 100) / system_delta
    imul rax, 100
    xor rdx, rdx
    div rbx

    ; Print CPU %
    call PrintNumber
    lea rdx, percent
    call PrintString
    lea rdx, space
    call PrintString

    ; Print PID
    mov eax, pe32.th32ProcessID
    call PrintNumber
    lea rdx, space
    call PrintString

    ; Print name
    lea rdx, pe32.szExeFile
    call PrintString
    lea rdx, newline
    call PrintString

next:
    lea rdx, pe32
    mov rcx, rbx
    call Process32Next
    test eax, eax
    jnz process_loop

done:
    xor rcx, rcx
    call ExitProcess
main ENDP

; ------------------------
; PrintString
; ------------------------
PrintString PROC
    sub rsp, 28h
    xor r8, r8
len:
    cmp byte ptr [rdx+r8], 0
    je out
    inc r8
    jmp len
out:
    mov rcx, hConsole
    mov r9, 0
    call WriteConsoleA
    add rsp, 28h
    ret
PrintString ENDP

; ------------------------
; PrintNumber (EAX)
; ------------------------
PrintNumber PROC
    sub rsp, 28h
    mov ecx, 10
    lea rdi, [rsp+20h]
    mov byte ptr [rdi], 0
loop:
    xor edx, edx
    div ecx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test eax, eax
    jnz loop
    mov rdx, rdi
    call PrintString
    add rsp, 28h
    ret
PrintNumber ENDP

END
