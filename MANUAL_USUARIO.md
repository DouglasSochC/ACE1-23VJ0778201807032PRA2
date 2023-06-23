### Universidad de San Carlos de Guatemala
### Escuela de Ingeniería en Ciencias y Sistemas
### Facultad de Ingeniería
### Arquitectura de Computadoras y Ensambladores 1
### 1er. Semestre 2023

## Descripcion
El siguiente prototipo es un sistema para punto de venta. Este sistema tendrá la capacidad de gestionar el inventario de productos y control de ventas. Además, se tendrá un módulo de reporteria que trabajará sobre los datos almacenados por el sistema.

### Contenido

- Requisitos
- Interfaz
- Encabezado
- Inicio de sesión
- Producto
    - Creación de producto
    - Eliminación de producto
    - Ver productos
- Venta
- Herramientas
    - Reporte de catalogo completo
    - Reporte alfabetico de productos
    - Reporte de ventas
    - Reporte de productos sin existencia

## Requisitos

* DOSbox  0.74-3
* Lenguaje ensamblador - MASM 6.11

## Interfaz

Este sistema será manejado por una interfaz en modo texto. Se le brindarán al usuario una serie de menús para que pueda acceder a cada una de las funcionalidades solicitadas.

## Encabezado

El programa, antes de cualquier cosa, muestra un encabezado indicando la información del desarrollo del sistema.

![Descripción de la imagen](/doc_img/img1.png "Encabezado")

## Inicio de sesión

El sistema no contará con un menú de inicio de sesión especifico, el mecanismo de autenticación será basado en la presencia y verificación del contenido, de un archivo de configuración que contendrá las credenciales del usuario.

El archivo de configuración deberá llamarse PRA2.CNF y deberá contar con la siguiente estructura:

```sh
[credenciales]
usuario = "dcatalan"
clave = "201807032"
```


En el caso que las credenciales sean correctas, se mostrará la siguiente pantalla, haciendo alusión a que se ha iniciado sesión correctamente:

![Descripción de la imagen](/doc_img/img2.png "Inicio Sesión Correcto")

## Producto
Manejo de productos en el sistema.

### Creación de producto

Para esta sección simplemente se le solicitarán al usuario los datos requeridos, se validarán según corresponda y se añadirá el producto en un archivo.

![Descripción de la imagen](/doc_img/img3.png "Creación producto")

Si todo ha salido correctamente, serás redirigido al menú principal. En caso de que haya ocurrido algún error, el sistema te notificará sobre dicho inconveniente.

### Eliminación de producto

Para esta parte se le solicitará al usuario el codigo de un producto, se validará, y si corresponde al código de un producto en el archivo, este, será eliminado.

![Descripción de la imagen](/doc_img/img4.png "Eliminación del producto")

Si todo ha salido correctamente, se le solicitara confirmación de la eliminación en el caso que todo salga correctamente serás redirigido al menú principal. 

En caso de que haya ocurrido algún error, el sistema te notificará sobre dicho inconveniente.

### Ver productos

Aqui podrá ver los productos que han sido almacenados en grupos de cinco. Una vez mostrados los primeros cinco productos, se solicitará al usuario que presione 'ENTER' si desea continuar o 'q' si desea terminar la operación, retornando así al menu principal

![Descripción de la imagen](/doc_img/img5.png "Ver productos")

## Venta

El sistema contará con una sección en la que el usuario podrá registrar una venta. Por lo cual hay que considerar lo siguiente:

* Cada venta podrá tener como máximo 10 items.
* Se le solicitará al usuario el codigo del producto y las unidades a vender.
* Una vez finalizado el proceso de ingreso de items se deberá consultar al usuario si desea continuar o cancelar la venta.

![Descripción de la imagen](/doc_img/img6.png "Venta")

En el caso que ya no necesite seguir ingresando mas ventas, unicamente tendrá que escribir 'fin' en la solicitud de codigo, para que pueda terminar de realizar la venta.

En el caso que todo haya salido correctamente, será necesario que el usuario confirme la venta escribiendo el caracter 'y'.

En el caso que haya ocurrido un error, el sistema le notificara.

## Herramientas

La sección de herramientas contendrá una serie de utilizades cuya función principal será la generación de diversos reportes.

### Reporte de catalogo completo

Esta opción permitira generar el listado completo de productos en formato HTML. El nombre de este reporte es CATALG.HTM

![Descripción de la imagen](/doc_img/img7.png "Reporte Catalogo Completo")

### Reporte alfabetico de productos

En este reporte, en HTML, se mostrará la cantidad de productos cuya descripción inicie con cada una de las letras del abecedario, sin diferenciar entre mayúsculas y minúsculas. El nombre de este reporte es ABC.HTM

![Descripción de la imagen](/doc_img/img8.png "Reporte Alfabetico")

### Reporte de ventas

Este reporte mostrará todas las ventas realizadas. El nombre de este reporte es REP.TXT

![Descripción de la imagen](/doc_img/img9.png "Reporte Ventas")

### Reporte de productos sin existencia

Este reporte mostrara los productos que se hallan quedado sin existencias. El nombre de este reporte es FALTA.HTM

![Descripción de la imagen](/doc_img/img10.png "Reporte Productos Sin Existencia")