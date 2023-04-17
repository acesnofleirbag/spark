// gcc -g -masm=intel -c src/main.c -o build/main.o
// ld -m elf_x86_64 -o build/main -T src/main.lds build/main.o

void foo() {}

int main(int argc, char** argv) {
    // Cannot be used default `return 0` on directed linkage because pop a random value from the 'ebp' register and no
    // library is used here
    asm("mov eax, 0x1\n"
        "mov ebx, 0x0\n"
        "int 0x80");
}
