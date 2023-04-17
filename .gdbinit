define hook-stop
    # Translate the segment:offset into a physical address
    printf "[%4x:%4x] ", $cs, $eip
    x/i $cs * 16 + $eip
end

layout asm
layout reg

# This is for 16 bits - real mode (used on book)
# set architecture i8086

target remote localhost:26000
b *0x7c00
