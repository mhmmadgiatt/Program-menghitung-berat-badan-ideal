;Deksripsi  : Progam menghitung berat badan ideal berdasarkan tinggi badan dan jenis kelamin

org 0x100                       ; origin100h (ruang kosong sebanyak 100h diatas program)
global start                    ; deklarasi global start
section .text                   ; secton untuk menyiapkan kodingan

%macro write_string 1           ; fungsi cetak string dengan interupt 21h, parameternya adalah '1'
    mov   dx, %1                ; string yang ada di dalam '1' dipindahkan ke register dx
    mov   ah, 0x9               ; register ah diisi dengan 9 yang berfungsi untuk print string
    int   0x21                  ; interupt 21 dijalankan sehingga string tercetak
%endmacro

start:                         ; label start
    write_string judul         ; print judul
    write_string tinggi        ; print string peminta input tinggi

    mov dl, 10                 ; nilai dl berisi angka 10 dan dl berfungsi untuk perkalian
    mov bl, 0                  ; mengosongkan nilai bl dan disini bl sebagai penyimpan angka berat badan

input_tb:                      ; user akan menginput tinggi badan dengan cara memasukkan char satu per satu
    mov ah, 01h                ; interupt untuk menginput char dan menyimpan di al
    int 21h                    ; interupt 21h akan menerjemahkan ah yang berisi 1 
                               ; lalu sistem akan menerima input 1 buah char  

    cmp al, 13                 ; mengecek apakah user menekan tombol 'enter' atau tidak, jika iya maka program akan lompat ke jenis kelamin
    je loop_1          
    
    ; shift satuan ke kiri     
    sub al, 48                 ; menyatakan bilangan input desimal menjadi bilangan ASCII
    mov cl, al                 ; angka yang baru diinput atau angka yang ada di al dipindah ke cl
    mov al, bl                 ; angka-angka yang sudah diinput sebelumnya yang ada di bl dipindah ke al
    mul dl                     ; angka-angka sebelumnya yang sekarang ada di al dikalikan 10
    add al, cl                 ; angka-angka sebelumnya yang sudah dikalikan 10 ditambahkan dengan angka yang diinput atau angka yang ada di cl
    mov bl, al                 ; angka yang seudah dikali akan simpan di bl
    jmp input_tb               ; user menginput 1 char lagi

    ; CONTOH
    ; misalkan kita ingin memasukkan angka 172
    ; angka input sebelumnya adalah 1 yang berarti sudah melakukan loop sekali dan berada di bl
    ; lalu al berisi angka inputan selanjutnya (al = 7) dan diamankan ke cl sehingga cl = 7
    ; nilai di bl dimasukkan ke al dan nilai di register al dikali 10 (ada di dl)
    ; kemudian nilai al menjadi 10 (1 x 10) ditambah dengan nilai yang ada di cl (cl = 7)
    ; al menjadi 17 (10 + 7)
    ; lalu amankan al ke bl untuk proses iterasi selanjutnya

loop_1:                        ; untuk mengantisipasi user jikalau user menginput selain angka 1 atau 2 sebagai jenis kelamin
    write_string gender 
    mov ah, 01h
    int 21h                    ; user menginput angka

    cmp al, 49                 ; mengecek angka inputan user (ASCII 1 = DESIMAL 49)
    je laki_laki               ; jika inputan user (1) maka akan loncat ke laki_laki

    cmp al, 50                 ; mengecek angka inputan user (ASCII 2 = DESIMAL 50) 
    jne loop_1                 ; jika inputan user tidak(2), maka akan loncat ke loop_1

perempuan:                     ; menghitung rumus berat badan ideal untuk wanita
                               ; rumusnya:  (tinggi badan - 100) - (15% x (tinggi badan - 100))                  
    mov al, bl                 ; memindahkan angka di bl ke al
    sub ax, 356                ; ax = 256 + al. Tinggi badan akan dikurang 100. Maka ax = ax - 256 - 100 = ax - 356
    mov cx, ax                 ; angka yang ada di ax dipindahkan ke cx
    mov bx, 15                 ; nilai bx mengambil angka 15 dan bx berfungsi sebagai perkalian
    mul bx                     ; ax dikalikan  dengan bx = 15 dan hasilnya disimpan di ax
    mov bx, 100                ; nilai bx mengambil angka 100 dan bx nya akan digunakan untuk pembagian
    mov dx, 0x0                ; mengosongkan nilai dx
    div bx                     ; ax dibagi dengan bx = 100 dan hasilnya disimpan di ax   
    sub cx, ax                 ; cx dikurang dengan ax dan hasilnya disimpan di cx
                    
    jmp write_dec               ; jump ke write_dec

laki_laki:                      ; menghitung rumus berat badan ideal untuk laki-laki
                                ; rumusnya:  (tinggi badan - 100) - (10% x (tinggi badan - 100))
    mov al, bl                  ; memindahkan angka di bl ke al
    sub ax, 356                 ; ax = 256 + al. Tinggi badan akan dikurang 100. Maka ax = ax - 256 - 100 = ax - 356
    mov cx, ax                  ; angka yang ada di ax dipindahkan ke cx
    mov bx, 10                  ; nilai bx mengambil angka 10 dan bx berfungsi untuk pembagian
    mov dx, 0x0                 ; mengosongkan nilai dx
    div bx                      ; ax dibagi dengan bx = 10 dan hasilnya disimpan di ax 
    sub cx, ax                  ; cx dikurang dengan ax dan hasilnya disimpan di cx
                    
write_dec:
    mov ax, cx                  ; memindahkan berat badan idealnya dari cx ke ax kemudian di print
	mov bx, 10		            ; nilai bx mengambil angka 10 sebagai pembagi
	mov cx, 0x0		            ; cx dikosongkan yang mana berfungsi untuk menghitung jumlah digit

div_by_ten:			            ; bagi 10 untuk setiap digitnya kemudian ambil sisanya. 
					            ; Tapi, jika langsung di print entar kebalik misal 172 jadi 271
    mov dx, 0x0		            ; kosongkan dx yang akan menampung sisa pembagian
    div bx			            ; kemudian ax dibagi bx = 10, sisanya(angka satuan) akan disimpan di dx
    push dx			            ; supaya tidak terbalik, push sisa ke stack
    inc cx			            ; increment jumlah digit
    cmp ax, 0x0		            ; kalo angka sudah habis semua berarti ax = 0
    jne div_by_ten	            ; jika ax != 0, maka bagi lagi angka yang tersisa dengan 10
					            ; misal buat 172
					            ; sebelum iterasi: <- stack top, cx = 0
					            ; iterasi 1: 2 <- stack top, cx = 1
					            ; iterasi 2: 7 2 <- stack top, cx = 2
					            ; iterasi 3: 1 7 2 <- stack top, cx = 3

write_kata:
    write_string berat          ; print string penampil berat badan ideal
    
print:
	pop dx			            ; karena stack sifatnya LIFO maka yang di ambil adalah digit yang terakhir di push.
					            ; pop (ambil dan hapus) dari stack ke dx 
					            ; sebelum iterasi: 1 7 2 <- stack top; dx = tidak tau
					            ; iterasi 1: 7 2 <- stack top; dx = 1
					            ; iterasi 2: 2 <- stack top; dx = 7
					            ; iterasi 3: <- stack top; dx = 2
    add dl, 48		            ; karena angka hanya satu digit maka yang terisi hanya dl
                                ; karena masih dalam ASCII maka untuk mengubahnya menjadi desimal maka ditambah 48
    mov ah, 0x2		            ; interrupt untuk print 1 character
    int 0x21
    dec cx			            ; decrement jumlah digit
    jnz print		            ; kalo masih ada digit (cx != 0), loop lagi ke print

    write_string kg
                
loop_2:                         ; user akan diberi pilihan mau keluar program atau jalanin program lagi
    write_string pilihan  
    mov ah, 01h
    int 21h

    cmp al, 49                  ; mengecek angka inputan user (ASCII 1 = DESIMAL 49)
    je start                    ; jika inputan user (1) maka akan loncat ke start

    cmp al, 50                  ; mengecek angka inputan user (ASCII 2 = DESIMAL 50) 
    jne loop_2                  ; jika inputan user tidak(2), maka akan loncat ke loop_2

exit:
    write_string penutup
    mov ah, 0x4C	            ; interrupt buat exit
	mov al, 0x0                 ; return 0
	int 0x21                    ; exit program

section .data
judul: db 0xD, 0xA, 0xD, 0xA, "PROGRAM PENGHITUNG BERAT BADAN IDEAL BERDASARKAN TINGGi",  0xD, 0xA, "$" 
tinggi: db "Input Tinggi Badan : $"
gender: db "Apa jenis kelamin anda?", 0xD, 0xA, "1. Laki-Laki", 0xD, 0xA, "2. Perempuan", 0xD, 0xA, "Masukkan pilihan anda:", 0xD, 0xA, "$"
berat: db 0xD, 0xA, "Berat badan ideal anda adalah : $"
kg: db " kg", 0xD, 0xA, 0xD, 0xA, "$"
pilihan: db "Apakah anda ingin menjalankan program lagi?", 0xD, 0xA, "1. Ya", 0xD, 0xA, "2. Tidak", 0xD, 0xA,  "Masukkan pilihan anda:", 0xD, 0xA, "$"
penutup: db 0xD, 0xA, 0xD, 0xA, "TERIMA KASIH SUDAH MENGGUNAKAN PROGRAM INI", 0xD, 0xA, "$"