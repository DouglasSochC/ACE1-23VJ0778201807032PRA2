; D = Definicion
; Pn = Parametro n
; *********************

; S: Pausa
; D: Para la ejecucion del programa hasta que el usuario presione cualquier boton del teclado para seguir
mPausaE MACRO
  MOV AH,7
  INT 21
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
mComandoT MACRO sz,var
    MOV AH,3F
    MOV BX,00
    MOV CX,sz
    LEA DX,var
    INT 21
ENDM

; S: Entrada Teclado
; D: Sirve para solicitar una entrada a traves del teclado, ademas una vez ingresada la entrada
; se debe de dar ENTER para seguir la ejecucion
; P1: buffer = Buffer de entrada
; P2: sz = Se indica la entrada maxima para el buffer
mEntradaT MACRO buffer, sz
    ; Se modifica la cantidad maxima que puede recibir el buffer
    MOV DI, offset buffer
    MOV AL, sz
    MOV [DI], AL

    ; Se solicita la entrada
    MOV DX, offset buffer
    MOV AH, 0A
    INT 21
ENDM

; S: Imprimir Buffer
; D: Se utiliza para imprimir en pantalla el contenido que tiene el buffer
; P1: buffer = Buffer de entrada
mImprimirBuffer MACRO buffer
  MOV BX, 01
  MOV DI, offset buffer
  INC DI ; Nos posicionamos en el segundo byte del buffer
  MOV CH, 00
  MOV CL, [DI] ; Se obtiene el tamanio de la cadena ingresada
  INC DI ; Nos posicionamos en el tercer byte del buffer
  MOV DX, DI
  MOV AH, 40
  INT 21
ENDM

; S: Copiar A Variable
; D: Se utiliza para copiar la informacion que contiene el buffer a una variable declarada en el segmento de datos
; P1: str1 = Variable a recibir y almacenar los datos
; P2: buffer = Buffer de entrada
mCopiarAVar MACRO str1, buffer
  LOCAL L_COPIAR

  MOV SI, offset str1 ; Se almacena la posicion en memoria de la variable
  MOV DI, offset buffer ; Se almacena la posicion en memoria del buffer
  INC DI  ; Se posiciona en el segundo byte para determinar el tamanio del buffer
  MOV CX, [DI]  ; Se almacena en CX el tamanio de la cadena de enterada del buffer para realizar el LOOP
  INC DI  ; Se posiciona en el contenido del buffer

  L_COPIAR:
    MOV AL, [DI] ; Se obtiene el caracter del buffer
    MOV [SI], AL ; Se almacena el caracter en la posicion en memoria
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

; ********
; INICIO
; ********
.MODEL SMALL
.STACK
.RADIX 16
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

  ; Util
  buffer_entrada db 20, 00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  comando db 13 dup(?)

  ; Estructura del producto
  prod_cod db 04 dup(0)
  prod_nombre db 32 dup(0)
  prod_precio db 02 dup(0)
  prod_unidad db 02 dup(0)

.CODE
    ; Inicio del programa
    MAIN PROC

      ; Inicializamos los registros
      MOV AX, @DATA
      MOV DS, AX

      ;INI - Se imprime el mensaje inicial
      ; mLimpiarC
      mImprimirVar msg_l1
      mImprimirVar msg_l2
      mImprimirVar msg_l3
      mImprimirVar msg_l4
      mImprimirVar salto_linea
      mImprimirVar msg_l5
      mImprimirVar msg_l6
      ;FIN - Se imprime el mensaje inicial

      ; ENTER
      MOV AH,0AH
      INT 21H

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
      mComandoT 1, comando

      mCompCads comando, opcion_pri_1, 1
      JE PRODUCTOS

      mCompCads comando, opcion_pri_2, 1
      JE VENTAS

      mCompCads comando, opcion_pri_3, 1
      JE HERRAMIENTAS

      JMP MENU

    MENU ENDP

    PRODUCTOS PROC

      ; Menu del producto
      mLimpiarC
      mImprimirVar menu_pro_l1
      mImprimirVar menu_pro_l2
      mImprimirVar menu_pro_l3
      mImprimirVar menu_pro_l4
      mImprimirVar menu_pro_l5
      mComandoT 1, comando

      mCompCads comando, opcion_pro_1, 1
      JE CREAR_PRODUCTO

      mCompCads comando, opcion_pro_2, 1
      JE ELIMINAR_PRODUCTO

      mCompCads comando, opcion_pro_3, 1
      JE MOSTRAR_PRODUCTO

      JMP PRODUCTOS

    PRODUCTOS ENDP

    CREAR_PRODUCTO PROC

      mLimpiarC
      mImprimirVar msg_crear_pro_l1
      mImprimirVar msg_crear_pro_l2

      ; Pedir codigo
      mImprimirVar msg_crear_pro_l3
      mEntradaT buffer_entrada, 05
      mCopiarAVar prod_cod, buffer_entrada
      mImprimirVar salto_linea

      ; Pedir nombre
      mImprimirVar msg_crear_pro_l4
      mEntradaT buffer_entrada, 21
      mCopiarAVar prod_nombre, buffer_entrada
      mImprimirVar salto_linea

      ; Pedir precio
      mImprimirVar msg_crear_pro_l5
      mEntradaT buffer_entrada, 03
      mCopiarAVar prod_precio, buffer_entrada
      mImprimirVar salto_linea

      ; Pedir unidad
      mImprimirVar msg_crear_pro_l6
      mEntradaT buffer_entrada, 03
      mCopiarAVar prod_unidad, buffer_entrada
      mImprimirVar salto_linea

      mImprimirVar msg_crear_pro_l7

    CREAR_PRODUCTO ENDP

    ELIMINAR_PRODUCTO PROC

    ELIMINAR_PRODUCTO ENDP

    MOSTRAR_PRODUCTO PROC

    MOSTRAR_PRODUCTO ENDP

    VENTAS PROC

    VENTAS ENDP

    HERRAMIENTAS PROC

    HERRAMIENTAS ENDP

    SALIR PROC
      .EXIT
    SALIR ENDP

    END MAIN