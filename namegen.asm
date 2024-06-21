.section .bss
    .lcomm adjectives, 100000  ; Space for 1000 * 100 chars
    .lcomm creatures, 100000
    .lcomm adjectives_count, 4
    .lcomm creatures_count, 4

.section .data
file_name:
    .asciz "fnamefile"
adjectives_file:
    .asciz "adjectives"
creatures_file:
    .asciz "creatures"
prompt:
    .asciz "Enter the amount of names to generate: "
error_msg:
    .asciz "Invalid input. Please enter a number greater than zero\n"
format:
    .asciz "%d"
name_format:
    .asciz "%s_%s-%05d\n"

.section .text
.global main

main:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp  ; Allocate stack space

    ; Seed the random number generator
    call time
    mov %rax, %rdi
    call srand

    ; Get lines from adjectives and creatures files
    lea adjectives_file(%rip), %rdi
    lea adjectives(%rip), %rsi
    lea adjectives_count(%rip), %rdx
    call get_lines

    lea creatures_file(%rip), %rdi
    lea creatures(%rip), %rsi
    lea creatures_count(%rip), %rdx
    call get_lines

    ; Check if files are non-empty
    cmp $0, adjectives_count
    jle error_exit
    cmp $0, creatures_count
    jle error_exit

    ; Get the number of names to generate
    call get_number_of_names
    mov %eax, -4(%rbp)  ; num_names

    ; Open output file
    lea file_name(%rip), %rdi
    call fopen
    test %rax, %rax
    jz error_exit
    mov %rax, -8(%rbp)  ; file pointer

    ; Generate names and write to file
    mov -4(%rbp), %ecx  ; num_names
generate_loop:
    cmp $0, %ecx
    jle done

    call generate_name
    mov %rax, %rdi
    mov -8(%rbp), %rsi  ; file pointer
    lea name_format(%rip), %rdx
    call fprintf

    dec %ecx
    jmp generate_loop

done:
    ; Close the file
    mov -8(%rbp), %rdi
    call fclose

    mov $0, %eax
    leave
    ret

error_exit:
    mov $1, %eax
    leave
    ret

get_lines:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp  ; Allocate stack space

    ; Arguments: file_path in %rdi, words in %rsi, count in %rdx
    mov %rdi, -24(%rbp)  ; file_path
    mov %rsi, -32(%rbp)  ; words
    mov %rdx, -40(%rbp)  ; count

    ; Open the file
    mov -24(%rbp), %rdi
    call fopen
    test %rax, %rax
    jz file_not_found

    ; Store file pointer
    mov %rax, -8(%rbp)

read_line:
    ; Call fgets
    mov -32(%rbp), %rsi  ; words
    add (%rdx), %rsi
    mov $100, %edx       ; MAX_LINE_LENGTH
    mov -8(%rbp), %rdi   ; file pointer
    call fgets
    test %rax, %rax
    jz close_file

    ; Remove newline character
    mov %rsi, %rdi
    call strlen
    sub $1, %rax
    movb $0, (%rax)

    ; Increment count
    add $1, (%rdx)

    jmp read_line

file_not_found:
    mov $1, %eax  ; Return error code
    leave
    ret

close_file:
    mov -8(%rbp), %rdi
    call fclose

    mov $0, %eax  ; Return success code
    leave
    ret

generate_name:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp  ; Allocate stack space

    ; Generate random indices and sequence
    mov adjectives_count, %edi
    call rand
    xor %edx, %edx
    div %edi
    mov %eax, -4(%rbp)  ; ad_index

    mov creatures_count, %edi
    call rand
    xor %edx, %edx
    div %edi
    mov %eax, -8(%rbp)  ; cr_index

    call rand
    mov $90001, %edi
    xor %edx, %edx
    div %edi
    add $10000, %eax
    mov %eax, -12(%rbp)  ; sequence

    ; Format name string
    lea adjectives(%rip), %rdi
    add -4(%rbp), %rdi
    lea creatures(%rip), %rsi
    add -8(%rbp), %rsi
    mov -12(%rbp), %rdx
    lea name(%rip), %rcx
    call sprintf

    mov $name, %rax  ; Return name
    leave
    ret

name:
    .space 100

get_number_of_names:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp  ; Allocate stack space

input_loop:
    ; Print prompt
    lea prompt(%rip), %rdi
    call printf

    ; Get user input
    lea -4(%rbp), %rsi
    lea format(%rip), %rdi
    call scanf

    ; Check input
    cmp $1, %eax
    jl invalid_input
    cmp $1, -4(%rbp)
    jl invalid_input

    ; Valid input
    mov -4(%rbp), %eax
    leave
    ret

invalid_input:
    ; Print error message
    lea error_msg(%rip), %rdi
    call printf
    jmp input_loop