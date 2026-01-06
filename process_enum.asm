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