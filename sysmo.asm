.386
.model flat, stdcall
option casemap:none

include windows.inc
include kernel32.inc
includelib kernel32.lib

.data
    filename    db "syslog.txt", 0
    buffer      db 256 dup(0)
    bytesWritten dd ?

    memStatus MEMORYSTATUSEX <>
    hFile       HANDLE ?

.code

WriteLog PROC uses esi edi
    invoke WriteFile, hFile, OFFSET buffer, eax, OFFSET bytesWritten, NULL
    ret
WriteLog ENDP

main PROC
    ; create / open log file
    invoke CreateFileA,
        OFFSET filename,
        GENERIC_WRITE,
        FILE_SHARE_READ,
        NULL,
        OPEN_ALWAYS,
        FILE_ATTRIBUTE_NORMAL,
        NULL

    mov hFile, eax

    ; move to end of file
    invoke SetFilePointer, hFile, 0, 0, FILE_END

main_loop:
    ; get memory info
    mov memStatus.dwLength, SIZEOF MEMORYSTATUSEX
    invoke GlobalMemoryStatusEx, OFFSET memStatus

    ; write text manually
    lea esi, buffer
    mov eax, memStatus.ullAvailPhys
    shr eax, 20                 ; convert to MB

    ; simple number to ASCII 
    add eax, '0'
    mov [esi], al
    mov byte ptr [esi+1], 13
    mov byte ptr [esi+2], 10

    mov eax, 3                  ; bytes to write
    call WriteLog

    invoke Sleep, 3000           ; wait 3 seconds
    jmp main_loop

main ENDP

END main
