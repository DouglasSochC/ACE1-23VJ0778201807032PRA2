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
mEntradaT MACRO buffer
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
.RADIX 16 ; Cambiamos la base numérica a hexadecimal
.DATA ;Aqui se predifine el segmento de dato osea aqui van a estar las variables de alto nivel

  ; Mensaje Inicial
  msg_l1 db "Universidad de San Carlos de Guatemala", 0AH, 0DH, "$"
  msg_l2 db "Facultad de Ingenieria", 0AH, 0DH, "$"
  msg_l3 db "Escuela de Vacaciones", 0AH, 0DH, "$"
  msg_l4 db "Arquitectura de Computadoras y Ensambladores 1", 0AH, 0DH, "$"
  msg_l5 db 0AH, 0DH, "$"
  msg_l6 db "Nombre: Douglas Alexander Soch Catalan", 0AH, 0DH, "$"
  msg_l7 db "Carne: 201807032", 0AH, 0DH, "$"

  ; Menu Principal
  menu_l1 db "*********************", 0AH, 0DH, "$"
  menu_l2 db "(P)roductos", 0AH, 0DH, "$"
  menu_l3 db "(V)entas", 0AH, 0DH, "$"
  menu_l4 db "(H)erramientas", 0AH, 0DH, "$"
  menu_l5 db "*********************", 0AH, 0DH, "$"
  opcion_1 db "P"
  opcion_2 db "V"
  opcion_3 db "H"
  
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
      mImprimirVar msg_l5
      mImprimirVar msg_l6
      mImprimirVar msg_l7
      ;FIN - Se imprime el mensaje inicial

      ; ENTER
      MOV AH,0AH
      INT 21H

      JMP MENU

    MAIN ENDP

    MENU PROC

      ; Se imprime el menu principal
      mLimpiarC
      mImprimirVar menu_l1
      mImprimirVar menu_l2
      mImprimirVar menu_l3
      mImprimirVar menu_l4
      mImprimirVar menu_l5

      ; Se espera la opcion elegida
      mComandoT 1, comando

      mCompCads comando, opcion_1, 1
      JE PRODUCTOS

      mCompCads comando, opcion_2, 1
      JE VENTAS

      mCompCads comando, opcion_3, 1
      JE HERRAMIENTAS

      JMP MENU

    MENU ENDP

    PRODUCTOS PROC
      ; Pedir nombre
      ; Pedir precio
      ; Pedir unidades
      mLimpiarC
      mEntradaT buffer_entrada
    PRODUCTOS ENDP

    VENTAS PROC

    VENTAS ENDP

    HERRAMIENTAS PROC

    HERRAMIENTAS ENDP

    SALIR PROC
      .EXIT
    SALIR ENDP

    END MAIN