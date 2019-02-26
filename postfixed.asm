%include "io.inc"

%define MAX_INPUT_SIZE 4096

section .bss
	expr: resb MAX_INPUT_SIZE
       Array_Length: resd 1 ;lungimea inputului
       val: resd 1      ;cifra curenta, ea va fi adaugata la numarul in formare
       nr: resd 1       ;numarul in formare din cifre consecutive ale inputului
       negativ: resb 1  ;arata daca numarul din input este negativ, pentru ca dupa formare, sa fie convertit in numar negativ
section .text
global CMAIN
CMAIN:

	push ebp
	mov ebp, esp

	GET_STRING expr, MAX_INPUT_SIZE

	; your code goes here
       ; aflarea lungimii inputului
       mov eax, expr
       xor ecx, ecx
test_bit:
       mov bl, byte [eax]
       test bl, bl
       je set_lung
       inc eax
       inc ecx
       jmp test_bit

       ;incarcarea lungimii in variabila Array_Length
set_lung:
       mov dword [Array_Length], ecx
      
       mov eax, 0
       mov ecx, 0
       mov ebx, 0
       mov edx, 0
loop_start:
       ;se vor citi caractere din sir pana cand ecx devine egal cu lungimea inputului, adica a citit tot
       cmp ecx, [Array_Length]
       jge incheiere_loop
       
       ;se citeste in al cate un caracter
       mov eax, 0
       mov byte al, [expr + ecx]
       
       ;daca este minus, trebuie stabilit daca este operand sau semn
       cmp al, '-'
       je verif_semn
       
       ;daca este mai mare decat /, conform tabelului ascii si considerand
       ;si tipurile de caractere pe care le putem avea in input, caracterul este cifra,
       ;iar aceasta trebuie convertita din caracter, in intreg
       cmp al, '/'
       jg creeaza_numar
       
       ;daca este /, se efectueaza impartirea
       cmp al, '/'
       je impartire
       
       ;daca este plus, se efectueaza suma
       cmp al, '+'
       je suma
       
       ;daca este *, se efectueaza immultirea
       cmp al, '*'
       je inmultire
       
       ;in cazul in care caracterul curent este precedat de o cifra si stim deja
       ;ca daca am ajuns in aceste punct, caracterul curent nu este cifra, rezulta ca
       ;am terminat de parcurs un numar si putem sa il punem in stiva
       cmp byte [expr + ecx - 1], '/'
       jng continua
       
       ;se verifica intai daca numarul este trebuie sa fie negat, si se converteste daca este nevoie
       cmp byte [negativ], 1
       je convert_neg
push_stiva:
       ;se pune in stiva numarul format si se reseteaza variabila care indica negativitatea,
       ;cat si cea care retine numarul in formare
       mov byte [negativ], 0
       push dword [nr]
       mov dword [nr], 0
       
       
continua:
       ;se continua parcurgerea inputului
       add ecx, 1
       jmp loop_start
       
creeaza_numar:
       ;se converteste caracterul curent in intreg
       sub al, '0'
       mov [val], eax
       mov eax, [nr]
       mov ebx, 10
       mul ebx
       add eax, [val]
       mov [nr], eax
       jmp continua
       
suma: 
       ;operatia de adunare si punerea rezltatului inapoi in stiva
       pop ebx
       pop edx
       add ebx, edx
       push ebx
       jmp continua
       
diferenta:
       ;operatia de scadere si punerea rezltatului inapoi in stiva
       pop ebx
       pop eax
       sub eax, ebx
       push eax
       jmp continua

inmultire:
       ;operatia de inmultire si punerea rezltatului inapoi in stiva
       pop eax
       pop ebx
       imul ebx
       push eax
       jmp continua
       
impartire:
       ;operatia de impartire si punerea rezltatului inapoi in stiva
       pop ebx
       pop eax
       cdq
       idiv ebx
       push eax
       jmp continua

verif_semn:
       ;daca dupa - urmeaza direct o cifra, atunci acesta este semn, altfel este operand
       cmp byte [expr + ecx + 1], '/'
       jg set_neg
       jng diferenta
       
set_neg:
       ;se seteaza variabila care retine negativitatea
       mov byte [negativ], 1
       jmp continua
       
convert_neg:
       ;se realizeaza convertirea in numar negativ
       mov eax, [nr]
       mov ebx, 2
       mul ebx
       sub [nr], eax
       jmp push_stiva

incheiere_loop:
       ;afisarea rezultatului
       pop eax
       PRINT_DEC 4, eax
       NEWLINE
  
	xor eax, eax
	pop ebp
	ret
