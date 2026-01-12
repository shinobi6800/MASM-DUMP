.386
.model flat, stdcall
.stack 4096

ExitProcess PROTO :DWORD
printf PROTO C :PTR BYTE, :VARARG

.data
    numbers DWORD 5, 10, 15, 20, 25
    count   DWORD 5

    sumMsg  BYTE "Sum = %d", 13, 10, 0
    avgMsg  BYTE "Average = %d", 13, 10, 0

.code

; ----------------------------------
; PROC: CalculateSum
; ESI -> array
; ECX -> number of elements
; RETURNS: EAX = sum
; ----------------------------------
CalculateSum PROC
    xor eax, eax        ; sum = 0

sum_loop:
    add eax, [esi]      ; sum += array[i]
    add esi, 4          ; move to next DWORD
    loop sum_loop

    ret
CalculateSum ENDP

main PROC
    ; setup array pointer and counter
    lea esi, numbers
    mov ecx, count

    call CalculateSum   ; result in EAX

    ; print sum
    push eax
    push OFFSET sumMsg
    call printf
    add esp, 8

    ; calculate average
    cdq                 ; sign-extend eax into edx
    mov ebx, count
    div ebx             ; eax = sum / count

    ; print average
    push eax
    push OFFSET avgMsg
    call printf
    add esp, 8

    push 0
    call ExitProcess
main ENDP

END main
