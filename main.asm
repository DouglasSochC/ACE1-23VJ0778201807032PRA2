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
    MOV parseo_estado, 01

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

; S: Comparar Venta Temporalmente
; D: Se encarga de almacenar temporalmente una venta utilizando las estructuras del .DATA para ventas
mGuardarVentaTemp MACRO

  LOCAL L_NOMBRE

  ; Obteniendo la direccion en memoria de la variable auxiliar para ir recorriendo byte por byte
  MOV DI, offset venta_temporal

  ; Posicionando el puntero
  MOV AH, 00
  MOV AL, venta_indice
  ADD DI, AX

  ; ***************************************************************************
  ; Una vez posicionado el puntero, se inicia con la escritura de la estructura
  ; ***************************************************************************

  ; Se obtiene la FECHA COMPLETA
  MOV AH, 2AH
  INT 21

  ; Almacenando el dia
  MOV [DI], DL
  INC DI

  ; Almacenando el mes
  MOV [DI], DH
  INC DI

  ; Almacenando el anio
  SUB CX, 7D0H
  MOV [DI], CL
  INC DI

  ; Se obtiene la HORA COMPLETA
  MOV AH, 2CH
  INT 21

   ; Almacenando la hora
  MOV [DI], CH
  INC DI

  ; Almacenando el minuto
  MOV [DI], CL
  INC DI

  ; Almacenando el codigo del producto
  MOV SI, offset venta_prod_cod
  MOV CX, 0004H
  L_NOMBRE:
    MOV AL, [SI]
    MOV [DI], AL
    INC DI
    INC SI
  LOOP L_NOMBRE

  ; Almacenando las unidades a vender
  MOV AL, venta_num_unidad
  MOV [DI], AL

  ; Se indica donde esta el indice actual para almacenar nueva informacion de venta
  ADD venta_indice, 0AH
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

; S: Guardar Archivo Venta
; D: Se encarga de almacenar la estructura completa de un venta
mGuardarArchVenta MACRO

  LOCAL L_INICIO, L_ESCRIBIR

  ; Abriendo el archivo (para lectura/escritura) segun el nombre
  MOV AL, 02
  MOV AH, 3DH
  MOV DX, offset arch_ventas
  INT 21
  JNC L_INICIO ; Si ya existe el archivo se dirige a escribir los datos

  ; Creando archivo en el caso que no exista
  MOV CX, 0000
  MOV DX, offset arch_ventas
  MOV AH, 3CH
  INT 21

  ; Inicializando escritura
  L_INICIO:
    MOV [handle_ventas], AX ; Almacenando la direccion de memoria del archivo abierto

  L_ESCRIBIR:

    ; Escribir las ventas
    MOV BX, [handle_ventas]

    ; Se posiciona el apuntador al final del archivo
		MOV AL, 02
		MOV CX, 00
		MOV DX, 00
		MOV AH, 42
		int 21

    ; Se indica la cantidad de bytes a escribir
    MOV AH, 00
    MOV AL, venta_indice
    MOV CX, AX
    MOV DX, offset venta_temporal
    MOV AH, 40
    INT 21

    ; Cerrar archivo
    MOV BX, [handle_ventas]
    MOV AH, 3EH
    INT 21
ENDM

; S: Modificar Unidades Archivo Producto
; D: Se encarga de modificar el valor de las unidades de los productos contenidos en la variable 'venta_temporal'
mModificarUnidArchProd MACRO

  LOCAL L_TEMPORAL, L_BUSQUEDA, L_MODIFICADO, L_CERRAR_ARCHIVO, L_SIGUIENTE, L_CODIGO, L_FINAL

  ; Se verifica si ya hay registros en la variable 'venta_temporal' a traves del indice
  CMP venta_indice, 00H
  JE L_FINAL

  ; Abriendo el archivo (para lectura/escritura) para realizar la modificacion de unidades de cada producto
  MOV AL, 02
  MOV AH, 3DH
  MOV DX, offset arch_productos
  INT 21
  MOV [handle_productos], AX ; Almacenando la direccion de memoria del archivo abierto

  ; Se determina la cantidad productos que estan temporalmente para la venta y se almacenan en el registro CX
  MOV DX, 00H
  MOV AH, 00
  MOV AL, venta_indice
  MOV BX, 0AH
  DIV BX
  MOV CX, AX

  ; Se obtiene la posicion en memoria
  MOV DI, offset venta_temporal

  ; Se recorre la estructura temporal
  L_TEMPORAL:

    ; Se lee la variable temporal para buscar los productos con X codigo
    PUSH CX ; Debido a que hay un ciclo anidado es necesario almacenar el contador del primer ciclo
    MOV SI, offset venta_aux_prod_cod ; Se obtiene la posicion en memoria de esta variable auxiliar ya que aqui se escribira el codigo obtenido de 'venta_temporal'
    ADD DI, 05H ; Se recorre la variable hasta llegar a la posicion donde se encuentra el codigo del producto
    MOV CX, 04H ; Debido a que el codigo es de 4 bytes se realizara 4 iteraciones en el ciclo L_CODIGO
    L_CODIGO:
      MOV BH, [DI]
      MOV [SI], BH
      INC DI
      INC SI
    LOOP L_CODIGO
    MOV BH, 00
    MOV BL, [DI]
    MOV venta_aux_prod_unidad, BX
    INC DI

    PUSH DI ; Debido a que se debe modificar la cantidad de unidades del producto en el archivo, es necesario almacenar este DI por cualquier cosa
    ; RECORDAR: En 'venta_aux_prod_cod' obtengo el codigo de producto actual del 'venta_temporal'

    ; Leyendo el archivo y buscando el producto que tenga el codigo de 'venta_aux_prod_cod'
    L_BUSQUEDA:

      ; Leyendo el archivo
      MOV BX, [handle_productos]
      MOV CX, 28H
      MOV DX, offset aux_prod_cod
      MOV AH, 3FH
      INT 21
      PUSH AX ; Se almacena temporalmente la cantidad de bytes leidos en el archivo

        mCompCads aux_prod_cod, venta_aux_prod_cod, 04H
        JNE L_SIGUIENTE ; Si no salta quiere decir que encontro el producto y se modificara su unidad

        ; Se obtiene la posicion actual del puntero
        MOV AL, 01
        MOV AH, 42H
        MOV BX, [handle_productos]
        MOV CX, 00
        MOV DX, 00
        INT 21

        ; Se le reduce 28H bytes para posicionarlo en la posicion donde se encontro el producto
        SUB AX, 28H
        MOV venta_pos_prod_modificar, AX

        ; Se reposiciona el puntero del archivo en el lugar a modificar
        MOV AL, 00
        MOV AH, 42H
        MOV BX, [handle_productos]
        MOV CX, 00
        MOV DX, venta_pos_prod_modificar
        INT 21

        ; Se modifica la unidad actual
        MOV AX, venta_aux_prod_unidad
        SUB aux_prod_unidad, AX

        ; Se vuelve a escribir la estructura en el archivo de los productos
        MOV BX, [handle_productos]
        MOV CX, 28H
        MOV DX, offset aux_prod_cod
        MOV AH, 40
        INT 21

        ; Se reposiciona el puntero al inicio del archivo para que cada vez que modifique las unidades de un producto, el puntero de lectura inicie al principio
        MOV AL, 00
        MOV AH, 42H
        MOV BX, [handle_productos]
        MOV CX, 00
        MOV DX, 00
        INT 21

        ; Se indica que se ha actualizado el producto en el archivo PROD.BIN
        POP AX
        JMP L_MODIFICADO

      L_SIGUIENTE:
        POP AX
        CMP AX, 00 ; Si la estructura leida es 0 entonces ya se ha llegado a la parte final del archivo
    JNZ L_BUSQUEDA

    L_MODIFICADO:
      POP DI ; Se obtiene el DI para el siguiente ciclo
      POP CX ; Se obtiene el contador del primer ciclo
      DEC CX
  CMP CX, 00
  JNE L_TEMPORAL

  L_CERRAR_ARCHIVO:
    ; Cerrar archivo
    MOV BX, [handle_ventas]
    MOV AH, 3EH
    INT 21

  L_FINAL:


ENDM

; S: Validar Codigo
; D: Se encarga de validar que el parametro solicitado sigue la expresion regular [A-Z0-9]+ con un tamanio de 4 (4H)
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
    MOV parseo_estado, 01
    JMP L_SALIDA

  L_CORRECTO:
    MOV parseo_estado, 00

  L_SALIDA:
ENDM

; S: Validar Descripcion
; D: Se encarga de validar que el parametro solicitado sigue la expresion regular [A-Za-z0-9,.!]+ con un tamanio de 32 (20H)
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
    MOV parseo_estado, 01
    JMP L_SALIDA

  L_CORRECTO:
    MOV parseo_estado, 00

  L_SALIDA:
ENDM

; S: Validar Numero
; D: Se encarga de validar que el parametro solicitado sigue la expresion regular [0-9]+
; P1: str1 = Es la cadena que contiene el numero
; P2: sz = Es el tamanio de la cadena
mValidarNumero MACRO str1, sz
  LOCAL L_CARACTER, L_SIGUIENTE, L_CORRECTO, L_ERROR, L_SALIDA

  MOV DI, offset str1 ; Se almacena la posicion en memoria de la variable
  MOV CX, sz ; Se define el tamanio del str1

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
    MOV parseo_estado, 01
    JMP L_SALIDA

  L_CORRECTO:
    MOV parseo_estado, 00

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

  LOCAL L_DIVISION, L_ALMACENAR, L_CERO, L_FIN

  ; Inicializando los registros que se utilizaran para la conversion
  MOV AX, val1
  LEA SI, str1
  MOV DX, 0000
  MOV CX, 0000
  MOV BX, 000AH ; 10 (0AH)

  ; Verificando que el val1 sea mayor a 0
  CMP AX, 0000
  JE L_CERO

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
  JMP L_FIN

  L_CERO:
    MOV DL, 30H
    MOV [SI], DL

  L_FIN:

ENDM

; S: Convertir Numero A Cadena Vacia
; D: Se encarga de convertir un numero hexadecimal a su representacion en cadena, el str1 es la
; variable que contendra la cadena, se dice que esta funcion es vacia ya que si encuentra el hexadecimal 00H
; se seteara el hexadecimal de espacio (20H)
; P1: val1 = Variable que representa el numero
; P2: str1 = Variable en donde se almacenara la cadena
; P3: sz = Tamanio de la cadena
mConvertNumeroACadenaFecha MACRO val1, str1, sz

  LOCAL L_DIVISION, L_ALMACENAR, L_SIGUIENTE, L_ESPACIO, L_FIN

  ; Inicializando los registros que se utilizaran para la conversion
  MOV AX, val1
  LEA SI, str1
  MOV CX, sz
  MOV DX, 0000
  MOV BX, 000AH ; 10 (0AH)

  L_DIVISION:

    ; Se realiza la division para obtener el residuo el cual se queda en DX
    DIV BX
    ; Se almacena el residuo para su posterior uso
    PUSH DX
    ; Seteo DX a 0
    XOR DX, DX

  LOOP L_DIVISION

  MOV CX, sz
  L_ALMACENAR:
    ; Se obtiene el ultimo valor del DX
    POP DX
    CMP DX, 00
    JE L_ESPACIO

    ; Se le suma un valor de 30H (48) para indicar la representacion del caracter
    ADD DX, 30
    JMP L_SIGUIENTE

    L_ESPACIO:
      ; Se le suma un valor de 20H (32) para indicar el espacio
      ADD DX, 30

    L_SIGUIENTE:
      MOV [SI], DL ; Se almacena el caracter en la posicion actual del 'str1'
      INC SI ; Se incrementa en 1

  LOOP L_ALMACENAR
  JMP L_FIN

  L_FIN:

ENDM

; S: Limpiar Valores Nulos de una Cadena
; D: Se encarga quitar los hexadecimales 00H y setearlos como espacio (20H)
; P1: val1 = Variable que representa la cadena
; P2: sz = Tamanio de la cadena
mLimpiarValoresNulosCadena MACRO val1, sz

  LOCAL L_CICLO, L_ESPACIO, L_SIGUIENTE

  MOV SI, offset val1
  MOV CX, sz
  L_CICLO:

    MOV AL, [SI]
    CMP AL, 00H
    JE L_ESPACIO
    JMP L_SIGUIENTE

    L_ESPACIO:
      MOV AL, 20H
      MOV [SI], AL

    L_SIGUIENTE:
      INC SI
  LOOP L_CICLO
ENDM

; S: Convertir Cadena A Numero
; D: Se encarga de convertir una cadena en su representacion hexadecimal, el registro que contiene
; el resultado sera el AX
; P1: val1 = Variable que representa la cadena
; P2: sz = Tamanio de la cadena
mConvertCadenaANumero MACRO str1, sz

  LOCAL L_RECORRIDO, L_SALIDA, L_ERROR, L_STR_3

  MOV AX, 0000 ; Inicializando la salida
  MOV CX, sz ; Cantidad de caracteres
  MOV DI, offset str1 ; Obteniendo la posicion en memoria del string a convertir

  L_RECORRIDO:
    MOV BL, [DI] ; Se obtiene el caracter

    ; Se verifica si el caracter es nulo
    CMP BL, 00
    JE L_SALIDA

    ; En el caso que el caracter no es nulo, se busca su representacion en hexadecimal
    SUB BL, 30H
    MOV DX, 000AH ; Se multiplicara el valor obtenido * 10
    MUL DX  ; Significa AX * DX osea AX * 10
    JO L_ERROR ; Error en el caso que la multiplicacion de un desbordamiento

    MOV BH, 00H
    ADD AX, BX
    JC L_ERROR ; Error en el caso que la multiplicacion de un desbordamiento
    INC DI
  LOOP L_RECORRIDO

  MOV BX, sz
  CMP BX, 03H
  JE L_STR_3
  JMP L_SALIDA

  ; Se verifica si ocurre un desbordamiento en el caso que la estructura sea de un byte
  L_STR_3:
    CMP AH, 00
    JG L_ERROR
    JMP L_SALIDA

  L_ERROR:
    MOV parseo_estado, 02H

  L_SALIDA:
ENDM

; S: Verificar Disponibilidad de Producto
; D: Se encarga de verificar si hay unidades disponibles para realizar la venta de un producto, esta MACRO hace uso de la
; variable 'venta_estado' para representar la respuesta final de esta MACRO (0: Correcto ; 1: No existe ; 2: No hay unidades)
mVerificarDispProd MACRO

  LOCAL L_VERIFICAR_TOTAL_ARCHIVO, L_LEYENDO_ARCHIVO, L_VERIFICAR_TOTAL_TEMP, L_CODIGO, L_SIGUIENTE_1, L_SIGUIENTE_2, L_ERROR_CODIGO, L_ERROR_UNIDADES, L_FIN

  ; Se verifica si ya hay registros en la variable 'venta_temporal' a traves del indice
  CMP venta_indice, 00H
  JE L_VERIFICAR_TOTAL_ARCHIVO

  ; Se determina la cantidad productos que estan temporalmente para la venta y se almacenan en el registro CX
  MOV DX, 00H
  MOV AH, 00
  MOV AL, venta_indice
  MOV BX, 0AH
  DIV BX
  MOV CX, AX

  ; Se obtiene la posicion en memoria
  MOV DI, offset venta_temporal

  ; Se recorre la estructura temporal
  L_VERIFICAR_TOTAL_TEMP:

    ; Se lee la variable temporal para buscar los productos con X codigo
    PUSH CX ; Debido a que hay un ciclo anidado es necesario almacenar el contador del primer ciclo
    MOV SI, offset venta_aux_prod_cod ; Se obtiene la posicion en memoria de esta variable auxiliar ya que aqui se escribira el codigo obtenido de 'venta_temporal'
    ADD DI, 05H ; Se recorre la variable hasta llegar a la posicion donde se encuentra el codigo del producto
    MOV CX, 04H ; Debido a que el codigo es de 4 bytes se realizara 4 iteraciones en el ciclo L_CODIGO
    L_CODIGO:
      MOV BH, [DI]
      MOV [SI], BH
      INC DI
      INC SI
    LOOP L_CODIGO

    PUSH DI ; Se almacena el DI debido a que al comparar las cadenas este se perdera
    mCompCads venta_prod_cod, venta_aux_prod_cod, 04H ; Se realiza la comparacion entre el codigo ingresado por el usuario y el codigo obtenido temporalmente
    POP DI ; Se vuelve a obtener el DI
    JNE L_SIGUIENTE_1

    ; En el caso que si se halla encontrado el codigo de producto se sumara a 'venta_aux_total_num_unidad'
    MOV BH, 00H
    MOV BL, [DI]
    ADD venta_aux_total_num_unidad, BX
    INC DI

    L_SIGUIENTE_1:
      POP CX ; Se obtiene el contador del primer ciclo

  LOOP L_VERIFICAR_TOTAL_TEMP

  ; Se identifica el producto y la cantidad de unidades actuales que este tiene
  L_VERIFICAR_TOTAL_ARCHIVO:

    ; Se suma el ingreso actual a la variable que maneja el total de unidades
    MOV BH, 00
    MOV BL, venta_num_unidad
    ADD venta_aux_total_num_unidad, BX
    MOV AX, venta_aux_total_num_unidad

    ; Abriendo el archivo (lectura)
    MOV AL, 00
    MOV AH, 3DH
    MOV DX, offset arch_productos
    INT 21
    JC L_ERROR_CODIGO

    ; Almacenando la direccion de memoria del archivo abierto
    MOV [handle_productos], AX

    L_LEYENDO_ARCHIVO:

      ; Leyendo una estructura de producto
      MOV BX, [handle_productos]
      MOV CX, 28
      MOV DX, offset aux_prod_cod
      MOV AH, 3FH
      INT 21

      PUSH AX ; Se almacena la cantidad de caracteres leidos debido a que mCompCads utiliza AX
      mCompCads aux_prod_cod, venta_prod_cod, 04H
      POP AX ; Recupero el valor de AX de nuevo
      JNE L_SIGUIENTE_2

      ; Se verifica si hay en existencia, caso contrario se retorna un error
      MOV BX, aux_prod_unidad
      CMP venta_aux_total_num_unidad, BX
      JG L_ERROR_UNIDADES
      JNG L_FIN

      L_SIGUIENTE_2:
        ; Si la estructura leida es diferente de 0 entonces no se ha llegado a la parte final del archivo
        CMP AX, 00
    JNZ L_LEYENDO_ARCHIVO
    JMP L_ERROR_CODIGO

  L_ERROR_CODIGO:
    MOV venta_estado, 01H
    JMP L_FIN

  L_ERROR_UNIDADES:
    MOV venta_estado, 02H
    JMP L_FIN

  L_FIN:
    MOV venta_aux_total_num_unidad, 0000H
    mSetearValorAVar venta_aux_prod_cod, 00H, 04H

    ; Cerrar archivo
    MOV BX, [handle_productos]
    MOV AH, 3EH
    INT 21

ENDM

; S: Llenar Variable Reporte ABC
; D: Se encarga de llenar la variable temporal 'alfabeto_monto' con la informacion que posee el archivo de los productos
mLlenarVarRepABC MACRO

  LOCAL L_LEER, L_CERRAR_ARCHIVO, L_MINUSCULA, L_MAYUSCULA, L_SIGUIENTE, L_FIN, L_TEST

  ; Abriendo el archivo (para lectura)
  MOV AL, 00
  MOV AH, 3DH
  MOV DX, offset arch_productos
  INT 21
  JC L_FIN ; Si ya existe el archivo se dirige a escribir los datos
  MOV [handle_productos], AX ; Almacenando la direccion de memoria del archivo abierto

  L_LEER:

    ; Leyendo una estructura de producto
    MOV BX, [handle_productos]
    MOV CX, 28
    MOV DX, offset aux_prod_cod
    MOV AH, 3FH
    INT 21

    ; Si ya no lee mas estructuras de productos se sale del ciclo de lectura (L_LEER)
    CMP AX, 00
    JZ L_CERRAR_ARCHIVO

    ; Se busca el primer caracter del codigo del producto
    MOV SI, offset aux_prod_cod
    MOV AL, [SI]

    ; Se verifica si el caracter es mayor o igual a 'a'
    CMP AL, 61H
    JGE L_MINUSCULA

    ; Se verifica si el caracter es mayor o igual a 'A'
    CMP AL, 41H
    JGE L_MAYUSCULA
    JMP L_SIGUIENTE

    L_MINUSCULA:
      SUB AL, 61H
      JMP L_SETEAR

    L_MAYUSCULA:
      SUB AL, 41H
      JMP L_SETEAR

    L_SETEAR:

      ; Se obtiene en memoria la variable del alfabeto
      MOV SI, offset alfabeto_monto
      MOV BX, 02H
      MUL BX

      ; Se mueve a la posicion de la letra para obtener el valor a sumar
      ADD SI, AX
      MOV AX, [SI]
      ADD AX, aux_prod_unidad
      MOV [SI], AX

    L_SIGUIENTE:

  JMP L_LEER

  L_CERRAR_ARCHIVO:
    ; Cerrar archivo
    MOV BX, [handle_productos]
    MOV AH, 3EH
    INT 21

  L_FIN:

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
  encabezado db '[credenciales]'
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

  ; Menu Herramientas
  menu_herr_l1 db "****************************************", 0AH, 0DH, "$"
  menu_herr_l2 db "(1) Generacion de catalogo completo", 0AH, 0DH, "$"
  menu_herr_l3 db "(2) Reporte alfabetico de productos", 0AH, 0DH, "$"
  menu_herr_l4 db "(3) Reporte de ventas", 0AH, 0DH, "$"
  menu_herr_l5 db "(4) Reporte de productos sin existencias", 0AH, 0DH, "$"
  menu_herr_l6 db "****************************************", 0AH, 0DH, "$"
  opcion_herr_1 db "1"
  opcion_herr_2 db "2"
  opcion_herr_3 db "3"
  opcion_herr_4 db "4"

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

  ; Venta
  msg_venta_pro_l1 db "***************", 0AH, 0DH, "$"
  msg_venta_pro_l2 db "GENERANDO VENTA", 0AH, 0DH, "$"
  msg_venta_pro_l3 db "***************", 0AH, 0DH, "$"
  msg_venta_pro_l4 db "Codigo: ", "$"
  msg_venta_pro_l5 db "Unidades: ", "$"
  msg_venta_pro_l6 db "Por favor, confirme su venta (y|n): ", 0AH, 0DH, "$"
  msg_error_pro_l1 db "ERROR: No existe el codigo del producto ingresado", 0AH, 0DH, "$"
  msg_error_pro_l2 db "ERROR: No hay unidades disponibles para vender", 0AH, 0DH, "$"
  opcion_venta_salir db "fin"
  venta_temporal db 64H dup(0) ; Este array de bytes representa las 10 estructuras temporales que se necesitan para almacenar una venta (1 byte = dia ; 1 byte = mes ; 1 byte = anio ; 1 byte = hora ; 1 byte = minuto ; 4 bytes = codigo ; 1 byte = unidad)
  venta_indice db 00 ; Indica la posicion actual de escritura de una venta en la variable 'venta_temporal'
  venta_estado db 00 ; Indica el estado actual de la venta al verificar la disponibilidad de un producto - 0: Correcto ; 1: No existe ; 2: No hay unidades
  venta_aux_prod_cod db 04H dup(0) ; Se utilizara para ir verificando el codigo de un producto en la variable temporal
  venta_aux_prod_unidad dw 0000 ; Se utiliza para almacenar la cantidad de unidades que se reduciran en un producto al realizar la venta
  venta_aux_total_num_unidad dw 0000 ; Se utilizara para ir sumando el total de producto que se ira a vender
  venta_pos_prod_modificar dw 0000 ; Se utiliza para determinar la posicion actual del producto a modificar
  ; venta_num_total dw 0000

  ; Reporte catalogo completo
  tam_encabezado_html db 0CH
  tam_inicializacion_tabla db 5EH
  tam_inicializacion_tabla_abc db 32H
  tam_cierre_tabla db 08H
  tam_pie_html db 0EH
  encabezado_html db "<html><body>"
  inicializacion_tabla db '<table border="1"><tr><td>Codigo</td><td>Descripcion</td><td>Precio</td><td>Unidades</td></tr>'
  inicializacion_tabla_abc db '<table border="1"><tr><td>Letra</td><td>Monto</td>'
  cierre_tabla db "</table>"
  pie_html db "</body></html>"
  td_html db "<td>"
  tdc_html db "</td>"
  tr_html db "<tr>"
  trc_html db "</tr>"
  division_txt db 0AH, 0DH, "==========================================================", 0AH, 0DH
  encabezado_fecha_txt db "Fecha: "
  encabezado_cod_prod_txt db 0DH, "Codigo del producto: "
  encabezado_monto_txt db 0DH, "Monto: "
  salto_linea_txt db 0AH, 0DH
  rep1_aux_cadena db 05 dup(0) ; Utilizado para representar las unidades y precios de un producto

  ; Reporte ABC -> Hay que recordar que son 26 letras ; 2 bytes = monto -> Estructura de 56 bytes
  alfabeto_monto dw 1AH dup(0)
  alfabeto_letra db 00
  alfabeto_num_unidad dw 0000
  alfabeto_prod_unidad db 05 dup(0)

  ; Estructura de ingreso para una venta
  venta_prod_cod db 04H dup(0)
  venta_prod_unidad db 03H dup(0)
  venta_num_unidad db 00

  ; Util
  buffer_entrada db 20, 00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  comando db 13 dup(?)
  msg_util_1 db 0AH, 0DH, " Presione ENTER para continuar...", 0AH, 0DH, "$"
  msg_util_2 db 0AH, 0DH, "Reporte generado correctamente", 0AH, 0DH, "$"
  msg_error_formato db 0AH, 0DH, "El formato ingresado es incorrecto", 0AH, 0DH, "$"
  msg_error_desbordamiento db 0AH, 0DH, "El valor ingresado no es compatible con la capacidad de la maquina", 0AH, 0DH, "$"
  msg_error_ventas db 0AH, 0DH, "ERROR: No se ha realizado ventas", 0AH, 0DH, "$"
  msg_error_productos db 0AH, 0DH, "ERROR: No se ha ingresado productos al sistema", 0AH, 0DH, "$"
  parseo_estado db 0 ; Indica el estado actual de la verificacion de una entrada a traves de consola - 0: Correcto ; 1:Parseo incorrecto ; 2:Desbordamiento
  reporte_aux_fecha dW 0000 ; Servira como registro auxiliar para almacenar los valores obtenidos para las fechas
  reporte_titulo_fecha db "Reporte generado: " ; 18 bytes
  reporte_dia db 02H dup(0) ; 2 bytes
  reporte_separacion1 db  "/" ; 1 byte
  reporte_mes db 02H dup(0) ; 2 bytes
  reporte_separacion2 db  "/" ; 1 byte
  reporte_anio db 02H dup(0) ; 2 bytes
  reporte_separacion3 db " - " ; 3 bytes
  reporte_hora db 02H dup(0) ; 2 bytes
  reporte_separacion4 db ":" ; 1 bytes
  reporte_minutos db 02 dup(0) ; 2 bytes

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

  ; Estructura auxiliar de una venta
  aux_venta_prod_dia db 00
  aux_venta_prod_mes db 00
  aux_venta_prod_anio db 00
  aux_venta_prod_hora db 00
  aux_venta_prod_minuto db 00
  aux_venta_prod_cod db 04 dup(0)
  aux_venta_prod_unidad db 00

  ; Archivos
  arch_credenciales db "PRA2.CNF",0
  handle_credenciales dw 0000
  arch_productos db "PROD.BIN",0
  handle_productos dw 0000
  arch_ventas db "VENT.BIN",0
  handle_ventas dw 0000
  arch_rep_catalogo_completo db "CATALG.HTM",0
  handle_rep_catalogo_completo dw 0000
  arch_rep_abc db "ABC.HTM",0
  handle_rep_abc dw 0000
  arch_rep_sin_existencias db "FALTA.HTM",0
  handle_rep_sin_existencias dw 0000
  arch_rep_ventas db "REP.TXT",0
  handle_rep_ventas dw 0000

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

      ; Se verifica que el encabezado sea correcto
      mCompCads usu_encabezado, encabezado, 0EH
      JE @@usuario
      JMP @@error_credenciales

      @@usuario:
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
      JE MENU_HERRAMIENTAS

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

    MENU_HERRAMIENTAS PROC

      mLimpiarC
      mImprimirVar menu_herr_l1
      mImprimirVar menu_herr_l2
      mImprimirVar menu_herr_l3
      mImprimirVar menu_herr_l4
      mImprimirVar menu_herr_l5
      mImprimirVar menu_herr_l6
      mComandoT 1

      mCompCads comando, opcion_herr_1, 1
      JE REP_CATALOGO_COMPLETO

      mCompCads comando, opcion_herr_2, 1
      JE REP_ABC

      mCompCads comando, opcion_herr_3, 1
      JE REP_VENTAS

      mCompCads comando, opcion_herr_4, 1
      JE REP_SIN_EXISTENCIAS

      JMP MENU_HERRAMIENTAS

    MENU_HERRAMIENTAS ENDP

    CREAR_PRODUCTO PROC

      mLimpiarC
      mImprimirVar msg_crear_pro_l1
      mImprimirVar msg_crear_pro_l2
      mImprimirVar msg_crear_pro_l3

      ; Pedir codigo
      mImprimirVar msg_crear_pro_l4
      mEntradaT 05
      mCopiarBufferAVar prod_cod
      CMP parseo_estado, 01
      JE @@error
      mValidarCodigo prod_cod
      CMP parseo_estado, 01
      JE @@error
      mImprimirVar salto_linea

      ; Pedir descripcion
      mImprimirVar msg_crear_pro_l5
      mEntradaT 21
      mCopiarBufferAVar prod_descripcion
      CMP parseo_estado, 01
      JE @@error
      mValidarDescripcion prod_descripcion
      CMP parseo_estado, 01
      JE @@error
      mImprimirVar salto_linea

      ; Pedir precio
      mImprimirVar msg_crear_pro_l6
      mEntradaT 06
      mCopiarBufferAVar prod_precio
      CMP parseo_estado, 01
      JE @@error
      mValidarNumero prod_precio, 05H
      CMP parseo_estado, 01
      JE @@error
      mConvertCadenaANumero prod_precio, 05H
      CMP parseo_estado, 02
      JE @@desbordamiento_error
      MOV num_precio, AX
      mImprimirVar salto_linea

      ; Pedir unidad
      mImprimirVar msg_crear_pro_l7
      mEntradaT 06
      mCopiarBufferAVar prod_unidad
      CMP parseo_estado, 01
      JE @@error
      mValidarNumero prod_unidad, 05H
      CMP parseo_estado, 01
      JE @@error
      mConvertCadenaANumero prod_unidad, 05H
      CMP parseo_estado, 02
      JE @@desbordamiento_error
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
        MOV parseo_estado, 00
        mPausaE
        JMP CREAR_PRODUCTO

      @@desbordamiento_error:
        mImprimirVar msg_error_desbordamiento
        mSetearValorAVar prod_cod, 00H, 04H
        mSetearValorAVar prod_descripcion, 00H, 20H
        mSetearValorAVar prod_precio, 00H, 05H
        mSetearValorAVar prod_unidad, 00H, 05H
        MOV num_precio, 0000
        MOV num_unidad, 0000
        MOV parseo_estado, 00
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
        JMP MENU_PRINCIPAL

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
      CMP parseo_estado, 01
      JE @@error_formato
      mValidarCodigo prod_cod_eliminar
      CMP parseo_estado, 01
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
        MOV parseo_estado, 00
        mPausaE
        JMP ELIMINAR_PRODUCTO

      @@error_archivo:
        mImprimirVar error_eliminar_pro_1
        mPausaE
        JMP MENU_PRINCIPAL

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
        JMP MENU_PRINCIPAL

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
        JMP MENU_PRINCIPAL

    MOSTRAR_PRODUCTO ENDP

    VENTAS PROC

      mLimpiarC
      mImprimirVar msg_venta_pro_l1
      mImprimirVar msg_venta_pro_l2
      mImprimirVar msg_venta_pro_l3
      MOV venta_indice, 00H
      MOV CX, 0AH

      @@realizando_venta:

        PUSH CX

        ; Solicitando el codigo
        mImprimirVar msg_venta_pro_l4
        mEntradaT 05

        mCopiarBufferAVar venta_prod_cod ; Se valida que la entrada poseea por lo menos un caracter
        CMP parseo_estado, 01
        JE @@formato_error

        mCompCads venta_prod_cod, opcion_venta_salir, 03H ; Se valida si el usuario escribio fin
        JE @@finalizacion_venta

        mValidarCodigo venta_prod_cod ; Se valida que poseea el formato de codigo
        CMP parseo_estado, 01
        JE @@formato_error
        mImprimirVar salto_linea

        ; Solicitando las unidades
        mImprimirVar msg_venta_pro_l5
        mEntradaT 04

        mCopiarBufferAVar venta_prod_unidad ; Se valida que la entrada poseea por lo menos un caracter
        CMP parseo_estado, 01
        JE @@formato_error

        mValidarNumero venta_prod_unidad, 03H ; Se valida que poseea el formato de numero
        CMP parseo_estado, 01
        JE @@formato_error

        mConvertCadenaANumero venta_prod_unidad, 03H ; Se convierte la cadena a un numero y se almacena en 'num_unidad'
        CMP parseo_estado, 02
        JE @@desbordamiento_error
        MOV venta_num_unidad, AL

        mImprimirVar salto_linea
        JMP @@formato_correcto

        @@formato_error:
          mImprimirVar msg_error_formato
          mSetearValorAVar venta_prod_cod, 00H, 04H
          mSetearValorAVar venta_prod_unidad, 00H, 03H
          MOV venta_num_unidad, 0000
          MOV parseo_estado, 00
          mPausaE
          POP CX
          JMP @@realizando_venta

        @@desbordamiento_error:
          mImprimirVar msg_error_desbordamiento
          mSetearValorAVar venta_prod_cod, 00H, 04H
          mSetearValorAVar venta_prod_unidad, 00H, 03H
          MOV venta_num_unidad, 0000
          MOV parseo_estado, 00
          mPausaE
          POP CX
          JMP @@realizando_venta

        @@existencia_error:
          mImprimirVar msg_error_pro_l1
          mSetearValorAVar venta_prod_cod, 00H, 04H
          mSetearValorAVar venta_prod_unidad, 00H, 03H
          MOV venta_num_unidad, 00
          MOV venta_estado, 00
          mPausaE
          POP CX
          JMP @@realizando_venta

        @@disponibilidad_error:
          mImprimirVar msg_error_pro_l2
          mSetearValorAVar venta_prod_cod, 00H, 04H
          mSetearValorAVar venta_prod_unidad, 00H, 03H
          MOV venta_num_unidad, 00
          MOV venta_estado, 00
          mPausaE
          POP CX
          JMP @@realizando_venta

        ; Se verifica la disponibilidad del producto
        @@formato_correcto:
          mVerificarDispProd
          CMP venta_estado, 01H
          JE @@existencia_error
          CMP venta_estado, 02H
          JE @@disponibilidad_error

        @@producto_disponible:

          mGuardarVentaTemp

          ; Limpiando las variables temporales
          mSetearValorAVar venta_prod_cod, 00H, 04H
          mSetearValorAVar venta_prod_unidad, 00H, 03H
          MOV venta_num_unidad, 00

          ; Se indica que ya ha sido ingresado un producto en memoria
          POP CX
          DEC CX
          CMP CX, 00

      JNE @@realizando_venta

      @@finalizacion_venta:
        POP CX

      @@confirmacion_venta:
          mImprimirVar msg_venta_pro_l6

          ; Se lee el caracter para seguir leyendo el archivo o retornar al menu principal
          MOV AH, 08H
          INT 21H

          ; En el caso que sea 'y'
          CMP AL, 79H
          JE @@guardar_venta

          ; En el caso que sea 'n'
          CMP AL, 6EH
          JE @@salir

          ; En el caso que no sea alguna de las anteriores
          JMP @@confirmacion_venta

      @@guardar_venta:
        mGuardarArchVenta
        mModificarUnidArchProd

      ; Realiza el guardado de la venta
      @@salir:
        ; Limpiando las variables temporales
        mSetearValorAVar venta_temporal, 00H, 64H
        mSetearValorAVar venta_indice, 00H, 02H
        mSetearValorAVar venta_prod_cod, 00H, 04H
        mSetearValorAVar venta_prod_unidad, 00H, 03H
        MOV venta_num_unidad, 0000
        MOV parseo_estado, 00
        JMP MENU_PRINCIPAL

    VENTAS ENDP

    REP_CATALOGO_COMPLETO PROC

      ; Se elimina el archivo del reporte en el caso que ya exista
      MOV AH, 41H
      MOV DX, offset arch_rep_catalogo_completo
      INT 21

      ; Creando nuevamente el archivo
      MOV CX, 0000
      MOV DX, offset arch_rep_catalogo_completo
      MOV AH, 3CH
      INT 21

      ; Almacenando la direccion de memoria del archivo abierto
      MOV [handle_rep_catalogo_completo], AX

      ; Abriendo el archivo (para lectura)
      MOV AL, 00
      MOV AH, 3DH
      MOV DX, offset arch_productos
      INT 21
      JC @@error_existencia ; Si no existe el archivo se dirige a enviar un mensaje de error

      ; Almacenando la direccion de memoria del archivo abierto
      MOV [handle_productos], AX

      ; Obteniendo FECHA COMPLETA
      MOV AH, 2AH
      INT 21

      ; Almacenando el dia
      MOV AX, 0000
      MOV AL, DL
      MOV reporte_aux_fecha, AX
      PUSH CX
      PUSH DX
      mConvertNumeroACadena reporte_aux_fecha, reporte_dia
      POP DX

      ; Almacenando el mes
      MOV AX, 0000
      MOV AL, DH
      MOV reporte_aux_fecha, AX
      mConvertNumeroACadena reporte_aux_fecha, reporte_mes
      POP CX

      ; Almacenando el anio
      SUB CX, 7D0H
      MOV AX, 0000
      MOV AL, CL
      MOV reporte_aux_fecha, AX
      mConvertNumeroACadena reporte_aux_fecha, reporte_anio

      ; Se obtiene la HORA COMPLETA
      MOV AH, 2CH
      INT 21

      ; Almacenando la hora
      MOV AX, 0000
      MOV AL, CH
      MOV reporte_aux_fecha, AX
      PUSH CX
      mConvertNumeroACadena reporte_aux_fecha, reporte_hora
      POP CX

      ; Almacenando el minuto
      MOV AX, 0000
      MOV AL, CL
      MOV reporte_aux_fecha, AX
      mConvertNumeroACadena reporte_aux_fecha, reporte_minutos

      ; Se escribe la fecha y hora de este reporte
      MOV BX, [handle_rep_catalogo_completo]
      MOV CX, 22H
      MOV DX, offset reporte_titulo_fecha
      MOV AH, 40H
      INT 21

      ; Se escribe el encabezado del archivo del reporte
      MOV BX, [handle_rep_catalogo_completo]
      MOV CH, 00H
      MOV CL, tam_encabezado_html
      MOV DX, offset encabezado_html
      MOV AH, 40H
      INT 21

      ; Se escribe la inicializacion de la tabla del archivo del reporte
      MOV BX, [handle_rep_catalogo_completo]
      MOV CH, 00H
      MOV CL, tam_inicializacion_tabla
      MOV DX, offset inicializacion_tabla
      MOV AH, 40H
      INT 21

      ; Se inicia con la lectura de ventas y escritura del reporte
      @@reporte:

        ; Leyendo una estructura de un producto
        MOV BX, [handle_productos]
        MOV CX, 28H
        MOV DX, offset aux_prod_cod
        MOV AH, 3FH
        INT 21

        CMP AX, 00
        JZ @@cerrando_archivos

        PUSH AX ; Se almacena la cantidad de caracteres leidos debido a que mCompCads utiliza AX

          ; Se posiciona el puntero al final del archivo
          MOV CX, 00
          MOV DX, 00
          MOV BX, [handle_rep_catalogo_completo]
          MOV AL, 02
          MOV AH, 42
          INT 21

          ; Se escribe la etiqueta de inicializacion de la fila
          MOV BX, [handle_rep_catalogo_completo]
          MOV CX, 00H
          MOV CL, 04H
          MOV DX, offset tr_html
          MOV AH, 40H
          INT 21

          ; Etiqueta de apertura
          MOV BX, [handle_rep_catalogo_completo]
          MOV CX, 00H
          MOV CL, 04H
          MOV DX, offset td_html
          MOV AH, 40H
          INT 21

            ; Se escribe el codigo
            MOV BX, [handle_rep_catalogo_completo]
            MOV CX, 00H
            MOV CL, 04H
            MOV DX, offset aux_prod_cod
            MOV AH, 40H
            INT 21

          ; Etiqueta de cerrado
          MOV BX, [handle_rep_catalogo_completo]
          MOV CX, 00H
          MOV CL, 05H
          MOV DX, offset tdc_html
          MOV AH, 40H
          INT 21

          ; Etiqueta de apertura
          MOV BX, [handle_rep_catalogo_completo]
          MOV CX, 00H
          MOV CL, 04H
          MOV DX, offset td_html
          MOV AH, 40H
          INT 21

            ; Se escribe la descripcion
            MOV BX, [handle_rep_catalogo_completo]
            MOV CX, 00H
            MOV CL, 20H
            MOV DX, offset aux_prod_descripcion
            MOV AH, 40H
            INT 21

          ; Etiqueta de cerrado
          MOV BX, [handle_rep_catalogo_completo]
          MOV CX, 00H
          MOV CL, 05H
          MOV DX, offset tdc_html
          MOV AH, 40H
          INT 21

          ; Etiqueta de apertura
          MOV BX, [handle_rep_catalogo_completo]
          MOV CX, 00H
          MOV CL, 04H
          MOV DX, offset td_html
          MOV AH, 40H
          INT 21

            ; Se escribe el precio
            mSetearValorAVar rep1_aux_cadena, 00H, 05H
            mConvertNumeroACadena aux_prod_precio, rep1_aux_cadena
            MOV BX, [handle_rep_catalogo_completo]
            MOV CX, 00H
            MOV CL, 05H
            MOV DX, offset rep1_aux_cadena
            MOV AH, 40H
            INT 21

          ; Etiqueta de cerrado
          MOV BX, [handle_rep_catalogo_completo]
          MOV CX, 00H
          MOV CL, 05H
          MOV DX, offset tdc_html
          MOV AH, 40H
          INT 21

          ; Etiqueta de apertura
          MOV BX, [handle_rep_catalogo_completo]
          MOV CX, 00H
          MOV CL, 04H
          MOV DX, offset td_html
          MOV AH, 40H
          INT 21

            ; Se escribe las unidades
            mSetearValorAVar rep1_aux_cadena, 00H, 05H
            mConvertNumeroACadena aux_prod_unidad, rep1_aux_cadena
            MOV BX, [handle_rep_catalogo_completo]
            MOV CX, 00H
            MOV CL, 05H
            MOV DX, offset rep1_aux_cadena
            MOV AH, 40H
            INT 21

          ; Etiqueta de cerrado
          MOV BX, [handle_rep_catalogo_completo]
          MOV CX, 00H
          MOV CL, 05H
          MOV DX, offset tdc_html
          MOV AH, 40H
          INT 21

          ; Se escribe la etiqueta de finalizacion de la fila
          MOV BX, [handle_rep_catalogo_completo]
          MOV CX, 00H
          MOV CL, 05H
          MOV DX, offset trc_html
          MOV AH, 40H
          INT 21

        POP AX ; Recupero el valor de AX de nuevo
      JMP @@reporte


      @@cerrando_archivos:
        ; Se escribe la finalizacion de la tabla del archivo del reporte
        MOV BX, [handle_rep_catalogo_completo]
        MOV CH, 00H
        MOV CL, tam_cierre_tabla
        MOV DX, offset cierre_tabla
        MOV AH, 40H
        INT 21

        ; Se escribe el pie del archivo del reporte
        MOV BX, [handle_rep_catalogo_completo]
        MOV CH, 00H
        MOV CL, tam_pie_html
        MOV DX, offset pie_html
        MOV AH, 40H
        INT 21

        ; Cerrar archivo ventas
        MOV BX, [handle_productos]
        MOV AH, 3EH
        INT 21
        ; Cerrar archivo reporte
        MOV BX, [handle_rep_catalogo_completo]
        MOV AH, 3EH
        INT 21
        JMP @@fin

      @@error_existencia:
        ; Cerrar archivo reporte
        MOV BX, [handle_rep_catalogo_completo]
        MOV AH, 3EH
        INT 21

        ; Mensaje de advertencia
        mImprimirVar msg_error_productos
        mPausaE
        JMP MENU_PRINCIPAL

      @@fin:
        mImprimirVar msg_util_2
        mPausaE
        JMP MENU_PRINCIPAL

    REP_CATALOGO_COMPLETO ENDP

    REP_ABC PROC

      ; Se elimina el archivo del reporte en el caso que ya exista
      MOV AH, 41H
      MOV DX, offset arch_rep_abc
      INT 21

      ; Creando nuevamente el archivo
      MOV CX, 0000
      MOV DX, offset arch_rep_abc
      MOV AH, 3CH
      INT 21

      ; Almacenando la direccion de memoria del archivo abierto
      MOV [handle_rep_abc], AX

      ; Abriendo el archivo (para lectura)
      MOV AL, 00
      MOV AH, 3DH
      MOV DX, offset arch_productos
      INT 21
      JC @@error_existencia ; Si no existe el archivo se dirige a enviar un mensaje de error

      ; Almacenando la direccion de memoria del archivo abierto
      MOV [handle_productos], AX

      ; Llenando la informacion de los productos en la variable alfabeto_monto
      mLlenarVarRepABC

      ; Obteniendo FECHA COMPLETA
      MOV AH, 2AH
      INT 21

      ; Almacenando el dia
      MOV AX, 0000
      MOV AL, DL
      MOV reporte_aux_fecha, AX
      PUSH CX
      PUSH DX
      mConvertNumeroACadena reporte_aux_fecha, reporte_dia
      POP DX

      ; Almacenando el mes
      MOV AX, 0000
      MOV AL, DH
      MOV reporte_aux_fecha, AX
      mConvertNumeroACadena reporte_aux_fecha, reporte_mes
      POP CX

      ; Almacenando el anio
      SUB CX, 7D0H
      MOV AX, 0000
      MOV AL, CL
      MOV reporte_aux_fecha, AX
      mConvertNumeroACadena reporte_aux_fecha, reporte_anio

      ; Se obtiene la HORA COMPLETA
      MOV AH, 2CH
      INT 21

      ; Almacenando la hora
      MOV AX, 0000
      MOV AL, CH
      MOV reporte_aux_fecha, AX
      PUSH CX
      mConvertNumeroACadena reporte_aux_fecha, reporte_hora
      POP CX

      ; Almacenando el minuto
      MOV AX, 0000
      MOV AL, CL
      MOV reporte_aux_fecha, AX
      mConvertNumeroACadena reporte_aux_fecha, reporte_minutos

      ; Se escribe la fecha y hora de este reporte
      MOV BX, [handle_rep_abc]
      MOV CX, 22H
      MOV DX, offset reporte_titulo_fecha
      MOV AH, 40H
      INT 21

      ; Se escribe el encabezado del archivo del reporte
      MOV BX, [handle_rep_abc]
      MOV CH, 00H
      MOV CL, tam_encabezado_html
      MOV DX, offset encabezado_html
      MOV AH, 40H
      INT 21

      ; Se escribe la inicializacion de la tabla del archivo del reporte
      MOV BX, [handle_rep_abc]
      MOV CH, 00H
      MOV CL, tam_inicializacion_tabla_abc
      MOV DX, offset inicializacion_tabla_abc
      MOV AH, 40H
      INT 21

      ; Cantidad de letras a escribir en el reporte deben de ser 26 (1AH)
      MOV CX, 00H
      @@reporte:

        PUSH CX

        ; Se posiciona el puntero al final del archivo
        MOV CX, 00
        MOV DX, 00
        MOV BX, [handle_rep_abc]
        MOV AL, 02
        MOV AH, 42
        INT 21

        ; Se escribe la etiqueta de inicializacion de la fila
        MOV BX, [handle_rep_abc]
        MOV CX, 00H
        MOV CL, 04H
        MOV DX, offset tr_html
        MOV AH, 40H
        INT 21

        ; Etiqueta de apertura
        MOV BX, [handle_rep_abc]
        MOV CX, 00H
        MOV CL, 04H
        MOV DX, offset td_html
        MOV AH, 40H
        INT 21

          ; Se obtiene el indice actual del ciclo para representar a la letra
          POP CX
          MOV AX, CX
          PUSH CX
          MOV alfabeto_letra, AL
          ADD alfabeto_letra, 41H

          ; Se escribe el letra
          MOV BX, [handle_rep_abc]
          MOV CX, 01H
          MOV DX, offset alfabeto_letra
          MOV AH, 40H
          INT 21

          mSetearValorAVar alfabeto_letra, 00H, 02H

        ; Etiqueta de cerrado
        MOV BX, [handle_rep_abc]
        MOV CX, 00H
        MOV CL, 05H
        MOV DX, offset tdc_html
        MOV AH, 40H
        INT 21

        ; Etiqueta de apertura
        MOV BX, [handle_rep_abc]
        MOV CX, 00H
        MOV CL, 04H
        MOV DX, offset td_html
        MOV AH, 40H
        INT 21

          POP CX
          MOV AX, CX
          PUSH CX
          MOV BX, 2
          MUL BX

          MOV DI, offset alfabeto_monto
          ADD DI, AX

          MOV AX, [DI]
          MOV alfabeto_num_unidad, AX
          mConvertNumeroACadena alfabeto_num_unidad, alfabeto_prod_unidad

          ; Se escribe el monto
          MOV BX, [handle_rep_abc]
          MOV CX, 05H
          MOV DX, offset alfabeto_prod_unidad
          MOV AH, 40H
          INT 21

          mSetearValorAVar alfabeto_prod_unidad, 00, 05H

        ; Etiqueta de cerrado
        MOV BX, [handle_rep_abc]
        MOV CX, 00H
        MOV CL, 05H
        MOV DX, offset tdc_html
        MOV AH, 40H
        INT 21

        POP CX
        INC CX
      CMP CX, 1AH
      JNZ @@reporte

      @@cerrando_archivos:

        ; Se escribe la finalizacion de la tabla del archivo del reporte
        MOV BX, [handle_rep_abc]
        MOV CH, 00H
        MOV CL, tam_cierre_tabla
        MOV DX, offset cierre_tabla
        MOV AH, 40H
        INT 21

        ; Se escribe el pie del archivo del reporte
        MOV BX, [handle_rep_abc]
        MOV CH, 00H
        MOV CL, tam_pie_html
        MOV DX, offset pie_html
        MOV AH, 40H
        INT 21

        ; Cerrar archivo productos
        MOV BX, [handle_productos]
        MOV AH, 3EH
        INT 21

        ; Cerrar archivo reporte
        MOV BX, [handle_rep_abc]
        MOV AH, 3EH
        INT 21
        JMP @@fin

      @@error_existencia:
        ; Cerrar archivo reporte
        MOV BX, [handle_rep_abc]
        MOV AH, 3EH
        INT 21

        ; Mensaje de advertencia
        mImprimirVar msg_error_productos
        mPausaE
        JMP MENU_PRINCIPAL

      @@fin:
        mSetearValorAVar alfabeto_monto, 00H, 1AH
        mImprimirVar msg_util_2
        mPausaE
        JMP MENU_PRINCIPAL

    REP_ABC ENDP

    REP_VENTAS PROC
      ; Se elimina el archivo del reporte en el caso que ya exista
      MOV AH, 41H
      MOV DX, offset arch_rep_ventas
      INT 21

      ; Creando nuevamente el archivo
      MOV CX, 0000
      MOV DX, offset arch_rep_ventas
      MOV AH, 3CH
      INT 21

      ; Almacenando la direccion de memoria del archivo abierto
      MOV [handle_rep_ventas], AX

      ; Abriendo el archivo (para lectura)
      MOV AL, 00
      MOV AH, 3DH
      MOV DX, offset arch_ventas
      INT 21
      JC @@error_existencia ; Si no existe el archivo se dirige a enviar un mensaje de error

      ; Almacenando la direccion de memoria del archivo abierto
      MOV [handle_ventas], AX

      ; Obteniendo FECHA COMPLETA
      MOV AH, 2AH
      INT 21

      ; Almacenando el dia
      MOV AX, 0000
      MOV AL, DL
      MOV reporte_aux_fecha, AX
      PUSH CX
      PUSH DX
      mConvertNumeroACadenaFecha reporte_aux_fecha, reporte_dia, 02H
      POP DX

      ; Almacenando el mes
      MOV AX, 0000
      MOV AL, DH
      MOV reporte_aux_fecha, AX
      mConvertNumeroACadenaFecha reporte_aux_fecha, reporte_mes, 02H
      POP CX

      ; Almacenando el anio
      SUB CX, 7D0H
      MOV AX, 0000
      MOV AL, CL
      MOV reporte_aux_fecha, AX
      mConvertNumeroACadenaFecha reporte_aux_fecha, reporte_anio, 02H

      ; Se obtiene la HORA COMPLETA
      MOV AH, 2CH
      INT 21

      ; Almacenando la hora
      MOV AX, 0000
      MOV AL, CH
      MOV reporte_aux_fecha, AX
      PUSH CX
      mConvertNumeroACadenaFecha reporte_aux_fecha, reporte_hora, 02H
      POP CX

      ; Almacenando el minuto
      MOV AX, 0000
      MOV AL, CL
      MOV reporte_aux_fecha, AX
      mConvertNumeroACadenaFecha reporte_aux_fecha, reporte_minutos, 02H

      ; Se escribe la fecha y hora de este reporte
      MOV BX, [handle_rep_ventas]
      MOV CX, 22H
      MOV DX, offset reporte_titulo_fecha
      MOV AH, 40H
      INT 21

      ; Se inicia con la lectura de ventas y escritura del reporte
      @@reporte:

        ; Leyendo una estructura de una venta
        MOV BX, [handle_ventas]
        MOV CX, 0AH
        MOV DX, offset aux_venta_prod_dia
        MOV AH, 3FH
        INT 21

        CMP AX, 00
        JZ @@cerrando_archivos

        ; Se posiciona el puntero al final del archivo
        MOV CX, 00
        MOV DX, 00
        MOV BX, [handle_rep_ventas]
        MOV AL, 02
        MOV AH, 42
        INT 21

        ; Se escribe la division
        MOV BX, [handle_rep_ventas]
        MOV CX, 3EH
        MOV DX, offset division_txt
        MOV AH, 40H
        INT 21

        ; Se escribe el encabezado de la fecha
        MOV BX, [handle_rep_ventas]
        MOV CX, 07H
        MOV DX, offset encabezado_fecha_txt
        MOV AH, 40H
        INT 21

        ; Seteando la fecha completa en las variables adecuadas
        MOV AH, 00
        MOV AL, aux_venta_prod_dia
        MOV reporte_aux_fecha, AX
        mConvertNumeroACadenaFecha reporte_aux_fecha, reporte_dia, 02H

        MOV AH, 00
        MOV AL, aux_venta_prod_mes
        MOV reporte_aux_fecha, AX
        mConvertNumeroACadenaFecha reporte_aux_fecha, reporte_mes, 02H

        MOV AH, 00
        MOV AL, aux_venta_prod_anio
        MOV reporte_aux_fecha, AX
        mConvertNumeroACadenaFecha reporte_aux_fecha, reporte_anio, 02H

        MOV AH, 00
        MOV AL, aux_venta_prod_hora
        MOV reporte_aux_fecha, AX
        mConvertNumeroACadenaFecha reporte_aux_fecha, reporte_hora, 02H

        MOV AH, 00
        MOV AL, aux_venta_prod_minuto
        MOV reporte_aux_fecha, AX
        mConvertNumeroACadenaFecha reporte_aux_fecha, reporte_minutos, 02H

        ; Se escribe la fecha y hora de la venta realizada
        MOV BX, [handle_rep_ventas]
        MOV CX, 10H
        MOV DX, offset reporte_dia
        MOV AH, 40H
        INT 21

        ; Se escribe el encabezado del codigo del producto
        MOV BX, [handle_rep_ventas]
        MOV CX, 16H
        MOV DX, offset encabezado_cod_prod_txt
        MOV AH, 40H
        INT 21

          ; Se escribe la codigo del producto
          mLimpiarValoresNulosCadena aux_venta_prod_cod, 04H
          MOV BX, [handle_rep_ventas]
          MOV CX, 04H
          MOV DX, offset aux_venta_prod_cod
          MOV AH, 40H
          INT 21

        ; Se escribe el encabezado del monto de la venta
        MOV BX, [handle_rep_ventas]
        MOV CX, 08H
        MOV DX, offset encabezado_monto_txt
        MOV AH, 40H
        INT 21

          ; Se escribe el monto del producto
          mSetearValorAVar rep1_aux_cadena, 00H, 05H
          MOV AH, 00
          MOV AL, aux_venta_prod_unidad
          mConvertNumeroACadena AX, rep1_aux_cadena
          mLimpiarValoresNulosCadena rep1_aux_cadena, 05H
          MOV BX, [handle_rep_ventas]
          MOV CX, 00H
          MOV CL, 05H
          MOV DX, offset rep1_aux_cadena
          MOV AH, 40H
          INT 21
      JMP @@reporte


      @@cerrando_archivos:

        ; Cerrar archivo ventas
        MOV BX, [handle_ventas]
        MOV AH, 3EH
        INT 21
        ; Cerrar archivo reporte
        MOV BX, [handle_rep_ventas]
        MOV AH, 3EH
        INT 21
        JMP @@fin

      @@error_existencia:
        ; Cerrar archivo reporte
        MOV BX, [handle_rep_ventas]
        MOV AH, 3EH
        INT 21

        ; Mensaje de advertencia
        mImprimirVar msg_error_ventas
        mPausaE
        JMP MENU_PRINCIPAL

      @@fin:
        mImprimirVar msg_util_2
        mPausaE
        JMP MENU_PRINCIPAL
    REP_VENTAS ENDP

    REP_SIN_EXISTENCIAS PROC

      ; Se elimina el archivo del reporte en el caso que ya exista
      MOV AH, 41H
      MOV DX, offset arch_rep_sin_existencias
      INT 21

      ; Creando nuevamente el archivo
      MOV CX, 0000
      MOV DX, offset arch_rep_sin_existencias
      MOV AH, 3CH
      INT 21

      ; Almacenando la direccion de memoria del archivo abierto
      MOV [handle_rep_sin_existencias], AX

      ; Abriendo el archivo (para lectura)
      MOV AL, 00
      MOV AH, 3DH
      MOV DX, offset arch_productos
      INT 21
      JC @@error_existencia ; Si no existe el archivo se dirige a enviar un mensaje de error

      ; Almacenando la direccion de memoria del archivo abierto
      MOV [handle_productos], AX

      ; Obteniendo FECHA COMPLETA
      MOV AH, 2AH
      INT 21

      ; Almacenando el dia
      MOV AX, 0000
      MOV AL, DL
      MOV reporte_aux_fecha, AX
      PUSH CX
      PUSH DX
      mConvertNumeroACadena reporte_aux_fecha, reporte_dia
      POP DX

      ; Almacenando el mes
      MOV AX, 0000
      MOV AL, DH
      MOV reporte_aux_fecha, AX
      mConvertNumeroACadena reporte_aux_fecha, reporte_mes
      POP CX

      ; Almacenando el anio
      SUB CX, 7D0H
      MOV AX, 0000
      MOV AL, CL
      MOV reporte_aux_fecha, AX
      mConvertNumeroACadena reporte_aux_fecha, reporte_anio

      ; Se obtiene la HORA COMPLETA
      MOV AH, 2CH
      INT 21

      ; Almacenando la hora
      MOV AX, 0000
      MOV AL, CH
      MOV reporte_aux_fecha, AX
      PUSH CX
      mConvertNumeroACadena reporte_aux_fecha, reporte_hora
      POP CX

      ; Almacenando el minuto
      MOV AX, 0000
      MOV AL, CL
      MOV reporte_aux_fecha, AX
      mConvertNumeroACadena reporte_aux_fecha, reporte_minutos

      ; Se escribe la fecha y hora de este reporte
      MOV BX, [handle_rep_sin_existencias]
      MOV CX, 22H
      MOV DX, offset reporte_titulo_fecha
      MOV AH, 40H
      INT 21

      ; Se escribe el encabezado del archivo del reporte
      MOV BX, [handle_rep_sin_existencias]
      MOV CH, 00H
      MOV CL, tam_encabezado_html
      MOV DX, offset encabezado_html
      MOV AH, 40H
      INT 21

      ; Se escribe la inicializacion de la tabla del archivo del reporte
      MOV BX, [handle_rep_sin_existencias]
      MOV CH, 00H
      MOV CL, tam_inicializacion_tabla
      MOV DX, offset inicializacion_tabla
      MOV AH, 40H
      INT 21

      ; Se inicia con la lectura de ventas y escritura del reporte
      @@reporte:

        ; Leyendo una estructura de un producto
        MOV BX, [handle_productos]
        MOV CX, 28H
        MOV DX, offset aux_prod_cod
        MOV AH, 3FH
        INT 21

        CMP AX, 00
        JZ @@cerrando_archivos
        PUSH AX ; Se almacena la cantidad de caracteres leidos debido a que mCompCads utiliza AX

        ; Se verifica si la unidad es 0 para mostrarlo en el reporte
        CMP aux_prod_unidad, 0000H
        JNZ @@siguiente

          ; Se posiciona el puntero al final del archivo
          MOV CX, 00
          MOV DX, 00
          MOV BX, [handle_rep_sin_existencias]
          MOV AL, 02
          MOV AH, 42
          INT 21

          ; Se escribe la etiqueta de inicializacion de la fila
          MOV BX, [handle_rep_sin_existencias]
          MOV CX, 00H
          MOV CL, 04H
          MOV DX, offset tr_html
          MOV AH, 40H
          INT 21

          ; Etiqueta de apertura
          MOV BX, [handle_rep_sin_existencias]
          MOV CX, 00H
          MOV CL, 04H
          MOV DX, offset td_html
          MOV AH, 40H
          INT 21

            ; Se escribe el codigo
            MOV BX, [handle_rep_sin_existencias]
            MOV CX, 00H
            MOV CL, 04H
            MOV DX, offset aux_prod_cod
            MOV AH, 40H
            INT 21

          ; Etiqueta de cerrado
          MOV BX, [handle_rep_sin_existencias]
          MOV CX, 00H
          MOV CL, 05H
          MOV DX, offset tdc_html
          MOV AH, 40H
          INT 21

          ; Etiqueta de apertura
          MOV BX, [handle_rep_sin_existencias]
          MOV CX, 00H
          MOV CL, 04H
          MOV DX, offset td_html
          MOV AH, 40H
          INT 21

            ; Se escribe la descripcion
            MOV BX, [handle_rep_sin_existencias]
            MOV CX, 00H
            MOV CL, 20H
            MOV DX, offset aux_prod_descripcion
            MOV AH, 40H
            INT 21

          ; Etiqueta de cerrado
          MOV BX, [handle_rep_sin_existencias]
          MOV CX, 00H
          MOV CL, 05H
          MOV DX, offset tdc_html
          MOV AH, 40H
          INT 21

          ; Etiqueta de apertura
          MOV BX, [handle_rep_sin_existencias]
          MOV CX, 00H
          MOV CL, 04H
          MOV DX, offset td_html
          MOV AH, 40H
          INT 21

            ; Se escribe el precio
            mSetearValorAVar rep1_aux_cadena, 00H, 05H
            mConvertNumeroACadena aux_prod_precio, rep1_aux_cadena
            MOV BX, [handle_rep_sin_existencias]
            MOV CX, 00H
            MOV CL, 05H
            MOV DX, offset rep1_aux_cadena
            MOV AH, 40H
            INT 21

          ; Etiqueta de cerrado
          MOV BX, [handle_rep_sin_existencias]
          MOV CX, 00H
          MOV CL, 05H
          MOV DX, offset tdc_html
          MOV AH, 40H
          INT 21

          ; Etiqueta de apertura
          MOV BX, [handle_rep_sin_existencias]
          MOV CX, 00H
          MOV CL, 04H
          MOV DX, offset td_html
          MOV AH, 40H
          INT 21

            ; Se escribe las unidades
            mSetearValorAVar rep1_aux_cadena, 00H, 05H
            mConvertNumeroACadena aux_prod_unidad, rep1_aux_cadena
            MOV BX, [handle_rep_sin_existencias]
            MOV CX, 00H
            MOV CL, 05H
            MOV DX, offset rep1_aux_cadena
            MOV AH, 40H
            INT 21

          ; Etiqueta de cerrado
          MOV BX, [handle_rep_sin_existencias]
          MOV CX, 00H
          MOV CL, 05H
          MOV DX, offset tdc_html
          MOV AH, 40H
          INT 21

          ; Se escribe la etiqueta de finalizacion de la fila
          MOV BX, [handle_rep_sin_existencias]
          MOV CX, 00H
          MOV CL, 05H
          MOV DX, offset trc_html
          MOV AH, 40H
          INT 21

        @@siguiente:
          POP AX ; Recupero el valor de AX de nuevo
      JMP @@reporte


      @@cerrando_archivos:
        ; Se escribe la finalizacion de la tabla del archivo del reporte
        MOV BX, [handle_rep_sin_existencias]
        MOV CH, 00H
        MOV CL, tam_cierre_tabla
        MOV DX, offset cierre_tabla
        MOV AH, 40H
        INT 21

        ; Se escribe el pie del archivo del reporte
        MOV BX, [handle_rep_sin_existencias]
        MOV CH, 00H
        MOV CL, tam_pie_html
        MOV DX, offset pie_html
        MOV AH, 40H
        INT 21

        ; Cerrar archivo ventas
        MOV BX, [handle_productos]
        MOV AH, 3EH
        INT 21
        ; Cerrar archivo reporte
        MOV BX, [handle_rep_sin_existencias]
        MOV AH, 3EH
        INT 21
        JMP @@fin

      @@error_existencia:
        ; Cerrar archivo reporte
        MOV BX, [handle_rep_sin_existencias]
        MOV AH, 3EH
        INT 21

        ; Mensaje de advertencia
        mImprimirVar msg_error_productos
        mPausaE
        JMP MENU_PRINCIPAL

      @@fin:
        mImprimirVar msg_util_2
        mPausaE
        JMP MENU_PRINCIPAL

    REP_SIN_EXISTENCIAS ENDP

    SALIR PROC
      .EXIT
    SALIR ENDP
END