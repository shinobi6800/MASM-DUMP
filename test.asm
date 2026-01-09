option casemap:none

includelib kernel32.lib
ExitProcess PROTO:QWORD

.code
    main PROC
    xor rcx , rcx
    call ExitProcess
    main ENDP
    END