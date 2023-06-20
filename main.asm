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
; en el caso que en el buffer de entrada no se halla ingresado algun caracter, entonces no se realizara el copiado de datos
; y ademas se seteara 01H la variable 'bool_aux' debido a que a ocurrido un error
; P1: str1 = Variable a recibir y almacenar los datos
mCopiarBufferAVar MACRO str1
  LOCAL L_COPIAR, L_ERROR, L_SALIR

  MOV SI, offset str1 ; Se almacena la posicion en memoria de la variable
  MOV DI, offset buffer_entrada ; Se almacena la posicion en memoria del buffer_entrada
  INC DI  ; Se posiciona en el segundo byte para determinar el tamanio del buffer_entrada
  MOV CH, 00
  MOV CL, [DI]  ; Se almacena en CX el tamanio de la cadena de enterada del buffer_entrada para realizar el LOOP

  ; Se verifica si la cantidad de caracteres ingresados en el buffer es 0
  CMP CL, 00H
  JE L_ERROR

  INC DI  ; Se posiciona en el contenido del buffer_entrada

  L_COPIAR:
    MOV AL, [DI] ; Se obtiene el caracter del buffer_entrada
    MOV [SI], AL ; Se almacena el caracter en la posicion en memoria ERROR
    INC SI ; Se incrementa en 1
    INC DI ; Se incrementa en 1
  LOOP L_COPIAR ; Le resta 1 a CX y verifica que CX no sea 0, si no es 0 va a la etiqueta y si es 0 sigue de largo
  JMP L_SALIR

  L_ERROR:
    MOV bool_aux, 01

  L_SALIR:
ENDM

; S: Comparar Cadenas
; D: Se encarga de comparar 2 cadenas de un tamanio definido, si las dos cadenas son iguales hay que utilizar el JE
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
  LOCAL L_INICIO, L_ESPACIO, L_POSICIONAMIENTO, L_RECORRER, L_ESCRIBIR

  ; Abriendo el archivo (para lectura/escritura) segun el nombre
  MOV AL, 02
  MOV AH, 3DH
  MOV DX, offset arch_productos
  INT 21
  JNC L_INICIO ; Si ya existe el archivo se dirige a escribir los datos

  ; Creando archivo en el caso que no exista
  MOV CX, 0000
  MOV DX, offset arch_productos
  MOV AH, 3CH
  INT 21

  ; Inicializando escritura
  L_INICIO:
    MOV [handle_productos], AX ; Almacenando la direccion de memoria del archivo abierto
    MOV CX, 00 ; Registro que ayudara a almacenar la cantidad de ciclos a realizar para ubicarse en el espacio disponible

  ; Se busca un espacio disponible para almacenar el nuevo producto
  L_ESPACIO:

    ADD CX, 01H ; Se agrega un recorrido
    PUSH CX ; Se guarda el registro en el stack por posible uso posterior

    ; Leyendo una estructura de producto
    MOV BX, [handle_productos]
    MOV CX, 28H
    MOV DX, offset aux_prod_cod
    MOV AH, 3FH
    INT 21

    PUSH AX ; Se almacena la cantidad de caracteres leidos debido a que mCompCads utiliza AX
    mCompCads aux_prod_cod, aux_prod_vacio, 04H
    POP AX ; Recupero el valor de AX de nuevo
    POP CX ; Se recupera la informacion
    JE L_POSICIONAMIENTO

    ; Si la estructura leida es 0 entonces ya se ha llegado a la parte final del archivo
    CMP AX, 0
  JNZ L_ESPACIO

  L_POSICIONAMIENTO:
    PUSH CX ; Se guarda el registro en el stack por posible uso posterior

    ; Se posiciona el offset al inicio del archivo
    MOV CX, 00
    MOV DX, 00
    MOV BX, [handle_productos]
    MOV AL, 00
    MOV AH, 42
    INT 21

    POP CX ; Se recupera la informacion
    SUB CX, 01 ; Se resta en una unidad para estar en la posicion adecuada

  ; Si el CX es igual a 0 quiere decir que se desea almacenar en la estructura del primer registro ingresado
  CMP CX, 00H
  JZ L_ESCRIBIR

  L_RECORRER:
    PUSH CX

    ; Leyendo una estructura de producto
    MOV BX, [handle_productos]
    MOV CX, 28
    MOV DX, offset aux_prod_cod
    MOV AH, 3FH
    INT 21

    POP CX
  LOOP L_RECORRER
  JMP L_ESCRIBIR

  L_ESCRIBIR:

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

; S: Validar Codigo
; D: Se encarga de validar que el parametro solicitado sigue la expresion regular [A-Z0-9]+ 4 (04H)
; en el caso que halla un error la variable 'bool_aux' es 01H y en el caso que no halla, el valor de 'bool_aux' es 00H
mValidarCodigo MACRO str1
  LOCAL L_CARACTER, L_SIGUIENTE, L_LETRA, L_CORRECTO, L_ERROR, L_SALIDA

  MOV DI, offset str1 ; Se almacena la posicion en memoria de la variable
  MOV CX, 04H ; Se define el tamanio del str1

  L_CARACTER:
    MOV AL, [DI] ; Se obtiene el caracter del str1

    CMP AL, 00H ; Compara AL con null
    JE L_SIGUIENTE ; Salta a L_SIGUIENTE en el caso que no halla un valor a comparar

    CMP AL, 30H ; Compara AL con el caracter '0'
    JB L_ERROR ; Salta a L_ERROR si AL es menor que '0'

    CMP AL, 39H ; Compara AL con el caracter '9'
    JA L_LETRA ; Salta a L_LETRA si AL es mayor que '9' porque se verifica que este entre 'A' y 'Z'
    JMP L_SIGUIENTE

      L_LETRA:
        CMP AL, 41H ; Compara AL con el caracter 'A'
        JB L_ERROR ; Salta a L_ERROR si AL es menor que 'A'

        CMP AL, 5AH ; Compara AL con el caracter 'Z'
        JA L_ERROR ; Salta a L_ERROR si AL es mayor que 'Z'

      L_SIGUIENTE:
        INC DI ; Se incrementa en 1

    LOOP L_CARACTER ; Le resta 1 a CX y verifica que CX no sea 0, si no es 0 va a la etiqueta y si es 0 sigue de largo
  JMP L_CORRECTO

  L_ERROR:
    MOV bool_aux, 01
    JMP L_SALIDA

  L_CORRECTO:
    MOV bool_aux, 00

  L_SALIDA:
ENDM

; S: Validar Descripcion
; D: Se encarga de validar que el parametro solicitado sigue la expresion regular [A-Za-z0-9,.!]+ con un tamanio de 32 (20H)
; en el caso que halla un error la variable 'bool_aux' es 01H y en el caso que no halla, el valor de 'bool_aux' es 00H
mValidarDescripcion MACRO str1
  LOCAL L_CARACTER, L_SIGUIENTE, L_MAYUSCULA, L_MINUSCULA, L_ESPECIAL, L_CORRECTO, L_ERROR, L_SALIDA

  MOV DI, offset str1 ; Se almacena la posicion en memoria de la variable
  MOV CX, 20H ; Se define el tamanio del str1

  L_CARACTER:
    MOV AL, [DI] ; Se obtiene el caracter del str1

    CMP AL, 00H ; Compara AL con null
    JE L_SIGUIENTE ; Salta a L_SIGUIENTE en el caso que no halla un valor a comparar

    CMP AL, 30H ; Compara AL con el caracter '0'
    JB L_ESPECIAL ; Salta a L_ESPECIAL si AL es menor que '0'

    CMP AL, 39H ; Compara AL con el caracter '9'
    JA L_MAYUSCULA ; Salta a L_MAYUSCULA si AL es mayor que '9' porque se verifica que este entre 'A' y 'Z'
    JMP L_SIGUIENTE

      L_ESPECIAL:
        CMP AL, 2CH
        JE L_SIGUIENTE

        CMP AL, 2EH
        JE L_SIGUIENTE

        CMP AL, 21H
        JE L_SIGUIENTE

        JMP L_ERROR

      L_MAYUSCULA:
        CMP AL, 41H ; Compara AL con el caracter 'A'
        JB L_ERROR ; Salta a L_ERROR si AL es menor que 'A'

        CMP AL, 5AH ; Compara AL con el caracter 'Z'
        JA L_MINUSCULA ; Salta a L_MINUSCULA si AL es mayor que 'Z'
        JMP L_SIGUIENTE

      L_MINUSCULA:
        CMP AL, 61H ; Compara AL con el caracter 'a'
        JB L_ERROR ; Salta a L_ERROR si AL es menor que 'a'

        CMP AL, 7AH ; Compara AL con el caracter 'z'
        JA L_ERROR ; Salta a L_ERROR si AL es mayor que 'z'

      L_SIGUIENTE:
        INC DI ; Se incrementa en 1

    LOOP L_CARACTER ; Le resta 1 a CX y verifica que CX no sea 0, si no es 0 va a la etiqueta y si es 0 sigue de largo
  JMP L_CORRECTO

  L_ERROR:
    MOV bool_aux, 01
    JMP L_SALIDA

  L_CORRECTO:
    MOV bool_aux, 00

  L_SALIDA:
ENDM

; S: Validar Numero
; D: Se encarga de validar que el parametro solicitado sigue la expresion regular [0-9]+ con un tamanio de 5 (05H)
; en el caso que halla un error la variable 'bool_aux' es 01H y en el caso que no halla, el valor de 'bool_aux' es 00H
mValidarNumero MACRO str1
  LOCAL L_CARACTER, L_SIGUIENTE, L_CORRECTO, L_ERROR, L_SALIDA

  MOV DI, offset str1 ; Se almacena la posicion en memoria de la variable
  MOV CX, 05H ; Se define el tamanio del str1

  L_CARACTER:
    MOV AL, [DI] ; Se obtiene el caracter del str1

    CMP AL, 00H ; Compara AL con null
    JE L_SIGUIENTE ; Salta a L_SIGUIENTE en el caso que no halla un valor a comparar

    CMP AL, 30H ; Compara AL con el caracter '0'
    JB L_ERROR ; Salta a L_ERROR si AL es menor que '0'

    CMP AL, 39H ; Compara AL con el caracter '9'
    JA L_ERROR ; Salta a L_ERROR si AL es mayor que '9'

    L_SIGUIENTE:
      INC DI ; Se incrementa en 1

    LOOP L_CARACTER ; Le resta 1 a CX y verifica que CX no sea 0, si no es 0 va a la etiqueta y si es 0 sigue de largo
  JMP L_CORRECTO

  L_ERROR:
    MOV bool_aux, 01
    JMP L_SALIDA

  L_CORRECTO:
    MOV bool_aux, 00

  L_SALIDA:
ENDM

; S: Setear Valor A Variable
; D: Se encarga de setear un valor (val) en todo el recorrido que se realiza (por sz) al str1
; P1: str1 = Variable que se le setearan los valores
; P2: val = Valor a setear a str1
; P3: sz = Recorrido a realizar para setear a 'str1' el 'val'
mSetearValorAVar MACRO str1, val, sz
  LOCAL L_CARACTER

  MOV DI, offset str1 ; Se almacena la posicion en memoria de la variable
  MOV CX, sz ; Se define el tamanio del str1
  MOV AL, val

  L_CARACTER:
    MOV [DI], AL ; Se setea el 'val'
    INC DI ; Se incrementa en 1
  LOOP L_CARACTER

ENDM

; S: Convertir Numero A Cadena
; D: Se encarga de convertir un numero hexadecimal a su representacion en cadena, el str1 es la
; variable que contendra la cadena
; P1: val1 = Variable que representa el numero
; P2: str1 = Variable en donde se almacenara la cadena
mConvertNumeroACadena MACRO val1, str1

  LOCAL L_DIVISION, L_ALMACENAR

  ; Inicializando los registros que se utilizaran para la conversion
  MOV AX, val1
  LEA SI, str1
  MOV DX, 0000
  MOV CX, 0000
  MOV BX, 000AH ; 10 (0AH)

  L_DIVISION:
    CMP AX, 00H
    JE L_ALMACENAR
    ; Se realiza la division para obtener el residuo el cual se queda en DX
    DIV BX
    ; Se almacena el residuo para su posterior uso
    PUSH DX
    ; Se incrementa a uno para que posteriormente se pueda recorrer el stack y asi determinar la cadena
    INC CX
    ; Seteo DX a 0
    XOR DX, DX
  JMP L_DIVISION

  L_ALMACENAR:
    ; Se obtiene el ultimo valor del DX
    POP DX
    ; Se le suma un valor de 30H (48) para indicar la representacion del caracter
    ADD DX, 30

    MOV [SI], DL ; Se almacena el caracter en la posicion actual del 'str1'
    INC SI ; Se incrementa en 1

  LOOP L_ALMACENAR

ENDM

; S: Convertir Cadena A Numero
; D: Se encarga de convertir una cadena en su representacion hexadecimal, el registro que contiene
; el resultado sera el AX
; P1: val1 = Variable que representa la cadena
mConvertCadenaANumero MACRO str1

  LOCAL L_RECORRIDO, L_SALIDA

  MOV AX, 0000 ; Inicializando la salida
  MOV CX, 0005 ; Cantidad de caracteres

  MOV DI, offset str1

  L_RECORRIDO:
    MOV BL, [DI] ; Se obtiene el caracter

    ; Se verifica si el caracter es nulo
    CMP BL, 00
    JE L_SALIDA

    SUB BL, 30H
    MOV DX, 000AH ; Se multiplicara el valor obtenido * 10
    MUL DX  ; Significa AX * DX

    MOV BH, 00H
    ADD AX, BX
    INC DI
  LOOP L_RECORRIDO

  L_SALIDA:
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

  ; Inicio sesion
  error_ini_ses_1 db 0AH, 0DH, "Acceso denegado", 0AH, 0DH, "$"
  error_ini_ses_2 db 0AH, 0DH, "Las credenciales son incorrectas", 0AH, 0DH, "$"
  msg_ini_ses_1 db 0AH, 0DH, "Acceso exitoso", 0AH, 0DH, "$"
  usuario db 'usuario = "dcatalan"'
  clave db 'clave = "201807032"'
  usu_encabezado db 0FH dup (0) ; Tamanio 15 (0FH)
  usu_usuario db 15 dup(0)  ; Tamanio 21 (15H)
  usu_clave db 14 dup(0)  ; Tamanio 20 (14H)

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
  msg_crear_pro_l3 db "**********************", 0AH, 0DH, "$"
  msg_crear_pro_l4 db "Codigo: ", "$"
  msg_crear_pro_l5 db "Nombre: ", "$"
  msg_crear_pro_l6 db "Precio: ", "$"
  msg_crear_pro_l7 db "Unidad: ", "$"

  ; Mostrar producto
  error_mostrar_pro_1 db 0AH, 0DH, "No hay productos por mostrar", 0AH, 0DH, "$"
  msg_mostrar_pro_l1 db "********************", 0AH, 0DH, "$"
  msg_mostrar_pro_l2 db "PRODUCTOS INGRESADOS", 0AH, 0DH, "$"
  msg_mostrar_pro_l3 db "********************", 0AH, 0DH, "$"
  msg_mostrar_pro_l4 db "Codigo: ", "$"
  msg_mostrar_pro_l5 db "Nombre: ", "$"

  ; Eliminar producto
  msg_eliminar_pro_l1 db "*******************", 0AH, 0DH, "$"
  msg_eliminar_pro_l2 db "PRODUCTO A ELIMINAR", 0AH, 0DH, "$"
  msg_eliminar_pro_l3 db "*******************", 0AH, 0DH, "$"
  msg_eliminar_pro_l4 db "Ingrese el codigo del producto a eliminar: ", "$"
  msg_eliminar_pro_l5 db "Por favor, confirme la eliminacion (y|n): ", 0AH, 0DH, "$"
  msg_eliminar_pro_l6 db "Producto eliminado correctamente", 0AH, 0DH, "$"
  error_eliminar_pro_1 db "No hay productos para eliminar", "$"
  error_eliminar_pro_2 db "El codigo ingresado no existe", "$"
  prod_cod_eliminar db 04 dup(0)

  ; Util
  buffer_entrada db 20, 00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  comando db 13 dup(?)
  msg_util_1 db 0AH, 0DH, " Presione ENTER para continuar...", 0AH, 0DH, "$"
  msg_error_formato db 0AH, 0DH, "El formato ingresado es incorrecto", 0AH, 0DH, "$"
  bool_aux db 0 ; Sirve como auxiliar para validar las entradas realizadas por el usuario

  ; Estructura del producto
  prod_cod db 04 dup(0)
  prod_descripcion db 20 dup(0)
  num_precio dw 0000
  num_unidad dw 0000
  prod_precio db 05 dup(0)
  prod_unidad db 05 dup(0)

  ; Estructura auxiliar de producto
  aux_prod_cod db 04 dup(0)
  aux_prod_descripcion db 20 dup(0)
  aux_prod_precio dw 0000
  aux_prod_unidad dw 0000
  aux_prod_vacio db 04 dup(0) ; Se utiliza para auxiliar al momento de verificar un espacio disponible en el archivo de productos

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

      JMP INICIO_SESION

    MAIN ENDP

    INICIO_SESION PROC

      ; Abriendo el archivo (lectura)
      MOV AL, 00
      MOV AH, 3DH
      MOV DX, offset arch_credenciales
      INT 21
      JC @@error_archivo

      ; Almacenando la direccion de memoria del archivo abierto
      MOV [handle_credenciales], AX

      ; Leyendo una estructura de las credenciales
      MOV BX, [handle_credenciales]
      MOV CX, 38H
      MOV DX, offset usu_encabezado
      MOV AH, 3FH
      INT 21

      ; Se verifica que el usuario sea correcto
      mCompCads usu_usuario, usuario, 14H
      JE @@contrasenia
      JMP @@error_credenciales

      ; Se verifica que la contrasenia sea correcta
      @@contrasenia:
        mCompCads usu_clave, clave, 13H
        JE @@correcto
        JMP @@error_credenciales

      @@error_archivo:
        mImprimirVar error_ini_ses_1
        JMP SALIR

      @@error_credenciales:
        mImprimirVar error_ini_ses_2
        JMP SALIR

      @@correcto:
        mImprimirVar msg_ini_ses_1
        mPausaE
        JMP MENU_PRINCIPAL

    INICIO_SESION ENDP

    MENU_PRINCIPAL PROC

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

      JMP MENU_PRINCIPAL

    MENU_PRINCIPAL ENDP

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
      mImprimirVar msg_crear_pro_l3

      ; Pedir codigo
      mImprimirVar msg_crear_pro_l4
      mEntradaT 05
      mCopiarBufferAVar prod_cod
      CMP bool_aux, 01
      JE @@error
      mValidarCodigo prod_cod
      CMP bool_aux, 01
      JE @@error
      mImprimirVar salto_linea

      ; Pedir descripcion
      mImprimirVar msg_crear_pro_l5
      mEntradaT 21
      mCopiarBufferAVar prod_descripcion
      CMP bool_aux, 01
      JE @@error
      mValidarDescripcion prod_descripcion
      CMP bool_aux, 01
      JE @@error
      mImprimirVar salto_linea

      ; Pedir precio
      mImprimirVar msg_crear_pro_l6
      mEntradaT 06
      mCopiarBufferAVar prod_precio
      CMP bool_aux, 01
      JE @@error
      mValidarNumero prod_precio
      CMP bool_aux, 01
      JE @@error
      mConvertCadenaANumero prod_precio
      MOV num_precio, AX
      mImprimirVar salto_linea

      ; Pedir unidad
      mImprimirVar msg_crear_pro_l7
      mEntradaT 06
      mCopiarBufferAVar prod_unidad
      CMP bool_aux, 01
      JE @@error
      mValidarNumero prod_unidad
      CMP bool_aux, 01
      JE @@error
      mConvertCadenaANumero prod_unidad
      MOV num_unidad, AX
      mImprimirVar salto_linea

      JMP @@correcto

      @@error:
        mImprimirVar msg_error_formato
        mSetearValorAVar prod_cod, 00H, 04H
        mSetearValorAVar prod_descripcion, 00H, 20H
        mSetearValorAVar prod_precio, 00H, 05H
        mSetearValorAVar prod_unidad, 00H, 05H
        MOV num_precio, 0000
        MOV num_unidad, 0000
        MOV bool_aux, 00
        mPausaE
        JMP CREAR_PRODUCTO

      @@correcto:
        ; Guardando la informacion obtenida
        mGuardarArchProd
        ; Limpiando variables temporales
        mSetearValorAVar prod_cod, 00H, 04H
        mSetearValorAVar prod_descripcion, 00H, 20H
        mSetearValorAVar prod_precio, 00H, 05H
        mSetearValorAVar prod_unidad, 00H, 05H
        MOV num_precio, 0000
        MOV num_unidad, 0000
        ; Regresando al menu de producto
        JMP MENU_PRODUCTO

    CREAR_PRODUCTO ENDP

    ELIMINAR_PRODUCTO PROC

      mLimpiarC
      mImprimirVar msg_eliminar_pro_l1
      mImprimirVar msg_eliminar_pro_l2
      mImprimirVar msg_eliminar_pro_l3

      ; Solicitar codigo
      mImprimirVar msg_eliminar_pro_l4
      mEntradaT 05
      mCopiarBufferAVar prod_cod_eliminar
      CMP bool_aux, 01
      JE @@error_formato
      mValidarCodigo prod_cod_eliminar
      CMP bool_aux, 01
      JE @@error_formato
      mImprimirVar salto_linea

      @@buscar_registro:

        ; Abriendo el archivo (lectura/escritura)
        MOV AL, 02
        MOV AH, 3DH
        MOV DX, offset arch_productos
        INT 21

        JC @@error_archivo

        ; Almacenando la direccion de memoria del archivo abierto
        MOV [handle_productos], AX

        ; Cantidad de ciclos a realizar para estar en la posicion de eliminacion de una estructura
        MOV CX, 00

        @@leyendo_archivo:
          ADD CX, 01H ; Se indica que ha pasado un ciclo para encontrar la estructura
          PUSH CX ; Se almacena el CX por que posiblemente se utilice posteriormente

          ; Leyendo una estructura de producto
          MOV BX, [handle_productos]
          MOV CX, 28
          MOV DX, offset prod_cod
          MOV AH, 3FH
          INT 21

          PUSH AX ; Se almacena la cantidad de caracteres leidos debido a que mCompCads utiliza AX
          mCompCads prod_cod, prod_cod_eliminar, 04H
          POP AX ; Recupero el valor de AX de nuevo
          POP CX ; Recupero el valor de CX de nuevo
          JE @@posicionamiento_puntero

          ; Si la estructura leida es diferente de 0 entonces no se ha llegado a la parte final del archivo
          CMP AX, 00
        JNZ @@leyendo_archivo
        JMP @@error_codigo_no_encontrado

      @@posicionamiento_puntero:
        PUSH CX ; Se almacena en el stack la cantidad de ciclos a realizar

        ; Se posiciona el offset al inicio del archivo para recorrerlo
        MOV CX, 00
        MOV DX, 00
        MOV BX, [handle_productos]
        MOV AL, 00
        MOV AH, 42
        INT 21

        POP CX ; Se recupera el valor de CX para la cantidad de ciclos a realizar
        SUB CX, 01H ; Se le resta un ciclo para estar en la posicion exacta de eliminacion

      ; Si el CX es igual a 0 quiere decir que se desea eliminar el primer registro ingresado
      CMP CX, 00H
      JZ @@confirmar_eliminacion

      @@recorrido:

        PUSH CX ; Se guarda el CX en el stack debido a que se utilizara posteriormente

        ; Leyendo una estructura de producto
        MOV BX, [handle_productos]
        MOV CX, 28
        MOV DX, offset prod_cod
        MOV AH, 3FH
        INT 21

        POP CX ; Se recupera el valor de CX
      LOOP @@recorrido
      JMP @@confirmar_eliminacion

      @@error_formato:
        mImprimirVar msg_error_formato
        mSetearValorAVar prod_cod_eliminar, 00H, 04H
        MOV bool_aux, 00
        mPausaE
        JMP ELIMINAR_PRODUCTO

      @@error_archivo:
        mImprimirVar error_eliminar_pro_1
        mPausaE
        JMP MENU_PRODUCTO

      @@error_codigo_no_encontrado:
        mImprimirVar error_eliminar_pro_2
        mPausaE
        JMP @@salir

      @@confirmar_eliminacion:
        mImprimirVar msg_eliminar_pro_l5

        ; Se lee el caracter para seguir leyendo el archivo o retornar al menu principal
        MOV AH, 08H
        INT 21H

        ; En el caso que sea 'y'
        CMP AL, 79H
        JE @@eliminar

        ; En el caso que sea 'n'
        CMP AL, 6EH
        JE @@salir

        ; En el caso que no sea alguna de las anteriores
        JMP @@confirmar_eliminacion

      @@eliminar:

        ; Limpiando variables temporales
        mSetearValorAVar prod_cod, 00H, 04H
        mSetearValorAVar prod_descripcion, 00H, 20H
        mSetearValorAVar prod_precio, 00H, 05H
        mSetearValorAVar prod_unidad, 00H, 05H
        MOV num_precio, 0000
        MOV num_unidad, 0000

        ; Escribir el producto
        MOV BX, [handle_productos]
        MOV CX, 28 ; Se indica que la cantidad de bytes a escribir seran 40 (28H)
        MOV DX, offset prod_cod
        MOV AH, 40
        INT 21

        ; Respuesta de eliminacion
        mImprimirVar msg_eliminar_pro_l6
        mPausaE

      @@salir:
        ; Cerrar archivo
        MOV BX, [handle_productos]
        MOV AH, 3EH
        INT 21

        ; Limpiando variable de codigo a eliminar
        mSetearValorAVar prod_cod_eliminar, 00H, 04H

        ; Limpiando variables temporales
        mSetearValorAVar prod_cod, 00H, 04H
        mSetearValorAVar prod_descripcion, 00H, 20H
        mSetearValorAVar prod_precio, 00H, 05H
        mSetearValorAVar prod_unidad, 00H, 05H
        MOV num_precio, 0000
        MOV num_unidad, 0000

        ; Retornando al menu de producto
        JMP MENU_PRODUCTO

    ELIMINAR_PRODUCTO ENDP

    MOSTRAR_PRODUCTO PROC

      mLimpiarC

      ; Abriendo el archivo (lectura)
      MOV AL, 00
      MOV AH, 3DH
      MOV DX, offset arch_productos
      INT 21

      JC @@error_archivo

      ; Almacenando la direccion de memoria del archivo abierto
      MOV [handle_productos], AX

      mImprimirVar msg_mostrar_pro_l1
      mImprimirVar msg_mostrar_pro_l2
      mImprimirVar msg_mostrar_pro_l3

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

        PUSH AX
        mCompCads prod_cod, aux_prod_vacio, 04H
        POP AX
        JZ @@siguiente

        ; Imprimiendo la estructura
        mImprimirVar msg_mostrar_pro_l4
        mImprimirCadena prod_cod, 04H
        mImprimirVar msg_mostrar_pro_l5
        mImprimirCadena prod_descripcion, 20H

        ; Limpiando variables temporales
        mSetearValorAVar prod_cod, 00H, 04H
        mSetearValorAVar prod_descripcion, 00H, 20H

        POP CX ; Se obtiene la cantidad de veces a mostrar un producto
        SUB CX, 1 ; Se reduce a uno
        PUSH CX

        @@siguiente:
          POP CX
          SUB CX, 00H

      JNZ @@mostrar

      @@leer_continuacion:

        ; Se lee el caracter para seguir leyendo el archivo o retornar al menu principal
        MOV AH, 08H
        INT 21H

        ; En el caso que sea ENTER
        CMP AL, 0DH
        JE @@contador

        ; En el caso que sea 'q'
        CMP AL, 71H
        JE @@correcto

        ; En el caso que no sea alguna de las anteriores
        JMP @@leer_continuacion

      @@parte_final:
        POP CX
        JMP @@leer_continuacion

      JMP @@correcto

      @@error_archivo:
        mImprimirVar error_mostrar_pro_1
        mPausaE
        JMP @@salir

      @@correcto:
        ; Cerrar archivo
        MOV BX, [handle_productos]
        MOV AH, 3EH
        INT 21

      @@salir:
        ; Limpiando variables temporales
        mSetearValorAVar prod_cod, 00H, 04H
        mSetearValorAVar prod_descripcion, 00H, 20H
        mSetearValorAVar prod_precio, 00H, 05H
        mSetearValorAVar prod_unidad, 00H, 05H
        MOV num_precio, 0000
        MOV num_unidad, 0000
        ; Regresando al menu de producto
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