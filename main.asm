; D = Definicion
; Pn = Parametro n
; *********************

; S: Pausa
; D: Pausa la ejecucion del programa hasta que el usuario presione ENTER
mPausaE MACRO
  mImprimirVar msg_util_1
  MOV AH, 0AH
  INT 21H
ENDM

; S: Limpiar Consola
; D: Limpia toda la consola
mLimpiarC MACRO
  MOV AH,0F
  INT 10
  MOV AH,0
  INT 10
ENDM

; S: Imprimir Variable
; D: Imprime un texto en pantalla el cual esta contenido en una variable definido en el bloque .DATA
; P1: texto
mImprimirVar MACRO texto
  MOV AH,09 ; Funcion 09H
  LEA DX,texto
  INT 21H
ENDM

; S: Comando Teclado
; D: Se encarga de leer un comando ingresado por el usuario a traves del teclado
; P1: sz = Tamanio maximo de caracteres a ingresar en consola
; P2: var = Variable en donde se almacenan los datos digitados en consola
mComandoT MACRO sz
    MOV AH,3F
    MOV BX,00
    MOV CX,sz
    LEA DX,comando
    INT 21
ENDM

; S: Entrada Teclado
; D: Sirve para solicitar una entrada a traves del teclado y almacenarla en un buffer,
; ademas una vez ingresada la entrada se debe de dar ENTER para seguir la ejecucion.
; P1: sz = Se indica la entrada maxima para el buffer
mEntradaT MACRO sz
    ; Se modifica la cantidad maxima que puede recibir el buffer_entrada
    MOV DI, offset buffer_entrada
    MOV AL, sz
    MOV [DI], AL

    ; Se solicita la entrada
    MOV DX, offset buffer_entrada
    MOV AH, 0A
    INT 21
ENDM

; S: Imprimir Buffer
; D: Se utiliza para imprimir en pantalla el contenido que tiene el buffer_entrada
mImprimirBuffer MACRO
  MOV BX, 01
  MOV DI, offset buffer_entrada
  INC DI ; Nos posicionamos en el segundo byte del buffer_entrada
  MOV CH, 00
  MOV CL, [DI] ; Se obtiene el tamanio de la cadena ingresada
  INC DI ; Nos posicionamos en el tercer byte del buffer_entrada
  MOV DX, DI
  MOV AH, 40
  INT 21
ENDM

; S: Imprimir Cadena
; D: Se utiliza para imprimir en pantalla el contenido que tiene el parametro solicitado
; esto es debido a que la cadena no contiene $ para indicar la finalizacion del mismo
; P1: str1 = Cadena a imprimir
; P2: sz = Tamanio de la cadena a imprimir
mImprimirCadena MACRO str1, sz
  LOCAL L_CARACTER

  MOV DI, offset str1
  MOV CX, sz

  L_CARACTER:
    MOV DL, [DI]
    MOV AH, 02H
    INT 21H
    INC DI
    LOOP L_CARACTER

  MOV DL, 0AH
  MOV AH, 02H
  INT 21H

  MOV DL, 0DH
  MOV AH, 02H
  INT 21H

ENDM

; S: Copiar A Variable
; D: Se utiliza para copiar la informacion que contiene el buffer_entrada a una variable declarada en el segmento de datos
; P1: str1 = Variable a recibir y almacenar los datos
mCopiarBufferAVar MACRO str1
  LOCAL L_COPIAR

  MOV SI, offset str1 ; Se almacena la posicion en memoria de la variable
  MOV DI, offset buffer_entrada ; Se almacena la posicion en memoria del buffer_entrada
  INC DI  ; Se posiciona en el segundo byte para determinar el tamanio del buffer_entrada
  MOV CH, 00
  MOV CL, [DI]  ; Se almacena en CX el tamanio de la cadena de enterada del buffer_entrada para realizar el LOOP
  INC DI  ; Se posiciona en el contenido del buffer_entrada

  L_COPIAR:
    MOV AL, [DI] ; Se obtiene el caracter del buffer_entrada
    MOV [SI], AL ; Se almacena el caracter en la posicion en memoria ERROR
    INC SI ; Se incrementa en 1
    INC DI ; Se incrementa en 1
    LOOP L_COPIAR ; Le resta 1 a CX y verifica que CX no sea 0, si no es 0 va a la etiqueta y si es 0 sigue de largo
ENDM

; S: Comparar Cadenas
; D: Se encarga de comparar 2 cadenas de un tamanio definido
; P1: str1 = Cadena 1
; P2: str2 = Cadena 2
; P3: sz = Tamanio a comparar de cada cadena
mCompCads MACRO str1, str2, sz

  LOCAL COMPARANDO, HECHO
  LEA SI, str1 ; Cargar la dirección de la primera cadena en SI
  LEA DI, str2 ; Cargar la dirección de la segunda cadena en DI
  MOV CX, sz ; Cargar la longitud de las cadenas en CX

  ; Bucle para comparar las cadenas
  COMPARANDO:
      ; Cargar un carácter de cada cadena en AL y AH
      MOV AL, [SI]
      MOV AH, [DI]

      ; Comparar los caracteres
      CMP AL, AH
      JNE HECHO ; Si los caracteres son diferentes, salir del bucle

      ; Incrementar los punteros y continuar con el siguiente carácter
      INC SI
      INC DI
      DEC CX ; Disminuir CX
      JNZ COMPARANDO ; Si CX no es cero, continuar comparando

  HECHO:
      ; El registro de indicadores (FLAGS) contiene el resultado de la comparación
ENDM

; S: Guardar Archivo Producto
; D: Se encarga de almacenar la estructura completa de un producto
mGuardarArchProd MACRO
  LOCAL ESCRIBIR

  ; Abriendo el archivo (para lectura/escritura) segun el nombre
  MOV AL, 02
  MOV AH, 3DH
  MOV DX, offset arch_productos
  INT 21

  JNC ESCRIBIR

  ; Creando archivo
  MOV CX, 0000
  MOV DX, offset arch_productos
  MOV AH, 3CH
  INT 21

  ESCRIBIR:
    ; Almacenando la direccion de memoria del archivo abierto
    MOV [handle_productos], AX

    ; Se posiciona el offset al final del archivo para almacenar mas informacion
    MOV CX, 00
    MOV DX, 00
    MOV BX, [handle_productos]
    MOV AL, 02
    MOV AH, 42
    INT 21

    ; Escribir el producto
    MOV BX, [handle_productos]
    MOV CX, 28 ; Se indica que la cantidad de bytes a escribir seran 40 (28H)
    MOV DX, offset prod_cod
    MOV AH, 40
    INT 21

    ; Cerrar archivo
    MOV BX, [handle_productos]
    MOV AH, 3EH
    INT 21
ENDM

; ********
; INICIO
; ********
.MODEL SMALL
.RADIX 16
.STACK
.DATA

  ; Mensaje Inicial
  msg_l1 db "Universidad de San Carlos de Guatemala", 0AH, 0DH, "$"
  msg_l2 db "Facultad de Ingenieria", 0AH, 0DH, "$"
  msg_l3 db "Escuela de Vacaciones", 0AH, 0DH, "$"
  msg_l4 db "Arquitectura de Computadoras y Ensambladores 1", 0AH, 0DH, "$"
  msg_l5 db "Nombre: Douglas Alexander Soch Catalan", 0AH, 0DH, "$"
  msg_l6 db "Carne: 201807032", 0AH, 0DH, "$"
  salto_linea db 0AH, 0DH, "$"

  ; Menu Principal
  menu_pri_l1 db "*********************", 0AH, 0DH, "$"
  menu_pri_l2 db "(P)roductos", 0AH, 0DH, "$"
  menu_pri_l3 db "(V)entas", 0AH, 0DH, "$"
  menu_pri_l4 db "(H)erramientas", 0AH, 0DH, "$"
  menu_pri_l5 db "*********************", 0AH, 0DH, "$"
  opcion_pri_1 db "P"
  opcion_pri_2 db "V"
  opcion_pri_3 db "H"

  ; Menu Producto
  menu_pro_l1 db "*********************", 0AH, 0DH, "$"
  menu_pro_l2 db "(C)rear", 0AH, 0DH, "$"
  menu_pro_l3 db "(E)liminar", 0AH, 0DH, "$"
  menu_pro_l4 db "(M)ostrar", 0AH, 0DH, "$"
  menu_pro_l5 db "*********************", 0AH, 0DH, "$"
  opcion_pro_1 db "C"
  opcion_pro_2 db "E"
  opcion_pro_3 db "M"

  ; Crear producto
  msg_crear_pro_l1 db "**********************", 0AH, 0DH, "$"
  msg_crear_pro_l2 db "CREANDO PRODUCTO NUEVO", 0AH, 0DH, "$"
  msg_crear_pro_l3 db "Codigo: ", "$"
  msg_crear_pro_l4 db "Nombre: ", "$"
  msg_crear_pro_l5 db "Precio: ", "$"
  msg_crear_pro_l6 db "Unidad: ", "$"
  msg_crear_pro_l7 db "**********************", 0AH, 0DH, "$"

  ; Mostrar producto
  error_mostrar_pro_1 db 0AH, 0DH, "No hay productos por mostrar", 0AH, 0DH, "$"
  msg_mostrar_pro_l1 db "Codigo: ", "$"
  msg_mostrar_pro_l2 db "Nombre: ", "$"
  msg_mostrar_pro_l3 db "Precio: ", "$"
  msg_mostrar_pro_l4 db "Unidad: ", "$"

  ; Util
  buffer_entrada db 20, 00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  comando db 13 dup(?)
  msg_util_1 db 0AH, 0DH, "Presione ENTER para continuar...", 0AH, 0DH, "$"

  ; Estructura del producto
  prod_cod db 04 dup(0)
  prod_nombre db 20 dup(0)
  prod_precio db 02 dup(0)
  prod_unidad db 02 dup(0)

  ; Archivos
  arch_credenciales db "PRA2.CNF",0
  handle_credenciales dw 0000
  arch_productos db "PROD.BIN",0
  handle_productos dw 0000

.CODE
.STARTUP

    ; Inicio del programa
    MAIN PROC

      ; mLimpiarC
      mImprimirVar msg_l1
      mImprimirVar msg_l2
      mImprimirVar msg_l3
      mImprimirVar msg_l4
      mImprimirVar salto_linea
      mImprimirVar msg_l5
      mImprimirVar msg_l6

      mPausaE

      JMP MENU

    MAIN ENDP

    MENU PROC

      ; Se imprime el menu principal
      mLimpiarC
      mImprimirVar menu_pri_l1
      mImprimirVar menu_pri_l2
      mImprimirVar menu_pri_l3
      mImprimirVar menu_pri_l4
      mImprimirVar menu_pri_l5

      ; Se espera la opcion elegida
      mComandoT 1

      mCompCads comando, opcion_pri_1, 1
      JE MENU_PRODUCTO

      mCompCads comando, opcion_pri_2, 1
      JE VENTAS

      mCompCads comando, opcion_pri_3, 1
      JE HERRAMIENTAS

      JMP MENU

    MENU ENDP

    MENU_PRODUCTO PROC

      ; Menu del producto
      mLimpiarC
      mImprimirVar menu_pro_l1
      mImprimirVar menu_pro_l2
      mImprimirVar menu_pro_l3
      mImprimirVar menu_pro_l4
      mImprimirVar menu_pro_l5
      mComandoT 1

      mCompCads comando, opcion_pro_1, 1
      JE CREAR_PRODUCTO

      mCompCads comando, opcion_pro_2, 1
      JE ELIMINAR_PRODUCTO

      mCompCads comando, opcion_pro_3, 1
      JE MOSTRAR_PRODUCTO

      JMP MENU_PRODUCTO

    MENU_PRODUCTO ENDP

    CREAR_PRODUCTO PROC

      mLimpiarC
      mImprimirVar msg_crear_pro_l1
      mImprimirVar msg_crear_pro_l2

      ; Pedir codigo
      mImprimirVar msg_crear_pro_l3
      mEntradaT 05
      mCopiarBufferAVar prod_cod
      mImprimirVar salto_linea

      ; Pedir nombre
      mImprimirVar msg_crear_pro_l4
      mEntradaT 21
      mCopiarBufferAVar prod_nombre
      mImprimirVar salto_linea

      ; Pedir precio
      mImprimirVar msg_crear_pro_l5
      mEntradaT 03
      mCopiarBufferAVar prod_precio
      mImprimirVar salto_linea

      ; Pedir unidad
      mImprimirVar msg_crear_pro_l6
      mEntradaT 03
      mCopiarBufferAVar prod_unidad
      mImprimirVar salto_linea

      mImprimirVar msg_crear_pro_l7

      ; Guardando la informacion obtenida
      mGuardarArchProd

      JMP MENU_PRODUCTO

    CREAR_PRODUCTO ENDP

    ELIMINAR_PRODUCTO PROC

    ELIMINAR_PRODUCTO ENDP

    MOSTRAR_PRODUCTO PROC

      mLimpiarC

      ; Abriendo el archivo (lectura)
      MOV AL, 00
      MOV AH, 3DH
      MOV DX, offset arch_productos
      INT 21

      JC @@error

      ; Almacenando la direccion de memoria del archivo abierto
      MOV [handle_productos], AX

      ; Se mostraran 5 estructuras de producto
      @@contador:
        MOV CX, 05

      @@mostrar:

        PUSH CX ; Se salva la cantidad de veces a mostrar un producto

        ; Leyendo una estructura de producto
        MOV BX, [handle_productos]
        MOV CX, 28
        MOV DX, offset prod_cod
        MOV AH, 3FH
        INT 21

        ; Si la estructura leida es 0 entonces se llego a la parte final del texto
        CMP AX, 0
        JZ @@parte_final

        ; Imprimiendo la estructura
        mImprimirVar msg_mostrar_pro_l1
        mImprimirCadena prod_cod, 04
        mImprimirVar msg_mostrar_pro_l2
        mImprimirCadena prod_nombre, 20
        mImprimirVar msg_mostrar_pro_l3
        mImprimirCadena prod_precio, 02
        mImprimirVar msg_mostrar_pro_l4
        mImprimirCadena prod_unidad, 02

        POP CX ; Se obtiene la cantidad de veces a mostrar un producto
        SUB CX, 1 ; Se reduce a uno

        JNZ @@mostrar

      @@leer_continuacion:

        ; Se lee el caracter para seguir leyendo o retornar al menu principal
        MOV AH, 08H
        INT 21H

        ; En el caso que sea ENTER
        CMP AL, 0DH
        JE @@contador

        ; En el caso que sea q
        CMP AL, 71H
        JE MENU_PRODUCTO

        ; En el caso que no sea alguna de las anteriores
        JMP @@leer_continuacion

      @@parte_final:
        POP CX
        JMP @@leer_continuacion

      ; Cerrar archivo
      MOV BX, [handle_productos]
      MOV AH, 3EH
      INT 21

      JMP @@correcto

      @@error:
        mImprimirVar error_mostrar_pro_1
        mPausaE

      @@correcto:
        JMP MENU_PRODUCTO

    MOSTRAR_PRODUCTO ENDP

    VENTAS PROC

    VENTAS ENDP

    HERRAMIENTAS PROC

    HERRAMIENTAS ENDP

    SALIR PROC
      .EXIT
    SALIR ENDP
END