#include <stdio.h>
#include <string.h>
#include <wchar.h>
#include <fcntl.h>

int main() {
    // https://stackoverflow.com/questions/10882277/properly-print-utf8-characters-in-windows-console
    _setmode(_fileno(stdout), _O_U8TEXT);

    wprintf(L"%s\n", L"안녕하세요, UTF-8 World!\n");
    return 0;
}
