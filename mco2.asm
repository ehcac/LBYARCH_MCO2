BITS 64
DEFAULT REL
GLOBAL compute_acceleration

SECTION .data
scale_1000  dd 1000.0               ; Conversion factor for km to m
scale_3600  dd 3600.0               ; Conversion factor for hours to seconds

SECTION .text
compute_acceleration:
    ; Function parameters (Windows x64 calling convention):
    ; RCX = rows (number of cars)
    ; RDX = input_data pointer (float array: Vi, Vf, T for each car)
    ; R8  = results pointer (int array for acceleration results)
    
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32                
    
    ; Save callee-saved registers that we'll use
    push    rbx
    push    rsi
    push    rdi
    
    mov     rbx, rcx                ; RBX = row counter (number of cars)
    mov     rsi, rdx                ; RSI = input data pointer
    mov     rdi, r8                 ; RDI = results pointer
    
.process_car:
    cmp     rbx, 0
    je      .done
    
    ; Load floating point values into SIMD registers
    movss   xmm0, dword [rsi]       ; xmm0 = Vi (initial velocity in km/h)
    movss   xmm1, dword [rsi + 4]   ; xmm1 = Vf (final velocity in km/h)
    movss   xmm2, dword [rsi + 8]   ; xmm2 = T (time in seconds)
    
    ; Convert Vi from km/h to m/s using scalar SIMD floating-point instructions
    ; Formula: Vi_ms = Vi_kmh × (1000 ÷ 3600)
    movss   xmm3, xmm0              ; Copy Vi to working register
    mulss   xmm3, [rel scale_1000]  ; xmm3 = Vi × 1000 (km/h → m/h)
    divss   xmm3, [rel scale_3600] 
    
    ; Convert Vf from km/h to m/s using scalar SIMD floating-point instructions
    ; Formula: Vf_ms = Vf_kmh × (1000 ÷ 3600)
    movss   xmm4, xmm1              ; Copy Vf to working register
    mulss   xmm4, [rel scale_1000]  ; xmm4 = Vf × 1000 (km/h → m/h)
    divss   xmm4, [rel scale_3600]  ; xmm4 = (Vf × 1000) ÷ 3600 (m/h → m/s)
    
    ; Calculate acceleration using scalar SIMD floating-point instructions
    ; Formula: acceleration = (Vf - Vi) ÷ T
    subss   xmm4, xmm3              ; xmm4 = Vf_ms - Vi_ms (velocity change)
    divss   xmm4, xmm2              ; xmm4 = (Vf_ms - Vi_ms) ÷ T (acceleration)
    
    ; Convert floating-point result to integer with rounding
    cvtss2si eax, xmm4              ; Convert scalar single → signed integer
    mov     dword [rdi], eax        ; Store integer result in output array
    
    ; Advance to next car data
    add     rsi, 12                 ; Move input pointer: 3 floats × 4 bytes = 12 bytes
    add     rdi, 4                  ; Move result pointer: 1 int × 4 bytes = 4 bytes
    dec     rbx                     ; Decrement car counter
    jmp     .process_car
    
.done:
    ; Restore callee-saved registers
    pop     rdi
    pop     rsi
    pop     rbx
    
    add     rsp, 32                 ; Clean up shadow space
    pop     rbp
    ret
