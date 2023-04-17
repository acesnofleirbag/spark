/* Minimal script linker
 *
 * Usage:
 *      ld -m [arch] -o [binname] -T [linker-script] [object-files]
 *
 * arch: elf_x86_64 for x86_64 architecture
 * binname: Result bin file name
 * linker-script: A file like this one in format
 * object-files: Files with '*.o' extension
 */

ENTRY(main)

PHDRS
{
    /* 
     * Flags to indicate that the first segment is part of the ELF header is interesting to put on the linker script
     * file
     *
     * It's possible to static map the virtual address to the real address on the memory with AT([memaddr]), e.g:
     * AT(0x1234)
     */
    headers PT_LOAD FILEHDR; /* optional: AT(0x500) */

    /* FLAGS(...): Add Read, Write, Execute flags to the segment */
    code PT_LOAD; /* optional: FLAGS(0x1 | 0x2 | 0x4) */
}

SECTIONS
{
    /* Base address for next instructions */
    . = 0x10000;

    /* 
     * Starting on base address (0x10000) get all .text section in every file ('*' wildcard)
     * and combine on the '.text' section in the final binary file
     *
     * We create a segment 'code' with type PT_LOAD that represent a code segment on the final binary file and with that
     * was replaced the default GNU_STACK segment for '.text' section
     */
    .text : { *(.text) } :code

    /* Base address for next instructions */
    . = 0x8000000;

    /* 
     * Starting on base address (0x8000000) get all '.data' section in every file ('*' wildcard)
     * and combine on the '.data' section in the final binary file
     */
    .data : { *(.data) }

    /* 
     * Starting on base address (0x8000000) get all '.bss' section in every file ('*' wildcard)
     * and combine on the '.bss' section in the final binary file
     */
    .bss : { *(.bss) }

    /* Special section to discard object file sections (in this case removing exception handler section) */
    /DISCARD/ : { *(.eh_frame) }
}
