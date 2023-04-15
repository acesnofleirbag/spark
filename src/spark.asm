bits 16
org 0x7c00

start: jmp boot

;; == constant and variables definitions ==
msg db "Welcome to spark bootloader", 0xa, 0xd, 0x0

boot:
    cli ;; no interrupts
    cld ;; all that we need to init

    mov ax, 0x50 ;; for test purpose (insert breakpoint at 0x500)

    ;; set the buffer
    mov es, ax
    xor bx, bx

    ;; == floppy disk details ==
    ;; AH = 02 <http://www.cs.cmu.edu/~ralf/files.html> - for an interrupt list
    ;; AL = number of sectors to read (1-128 dec.)
    ;; CH = track/cylinder number (0-1023 dec., see below)
    ;; CL = sector number (1-17 dec.)
    ;; DH = head number (0-15 dec.)
    ;; DL = drive number (0=A:, 1=2nd floppy, 0x80=drive0, 0x81=drive1)
    ;; ES:BX = pointer to buffer
    ;; Return:
    ;;      AH = status (see INT 13, STATUS)
    ;;      AL = number of sectors read
    ;;      CF = 0 if successful; 1 if error

    mov al, 2 ;; read 2 sectors
    mov ch, 0 ;; track 0
    mov cl, 2 ;; sector to read (2nd sector - where the kernel need to be*)
    mov dh, 0 ;; head number
    mov dl, 0 ;; drive number

    mov ah, 0x02 ;; read sectors from disk
    int 0x13 ;; call the BIOS routine
    jmp 0x50:0x0 ;; jmp and exec the sector

    hlt ;; halt the system

times 510 - ($-$$) db 0 ;; 512 bytes (first sector), and the rest is zero initialized
dw 0xAA55 ;; boot signature
