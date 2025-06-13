# Scripts de utilidades M3U

Este repositorio contiene scripts útiles para trabajar con archivos M3U y descargas.

## Scripts disponibles

### 1. Descarga-melo 
#### Descarga de paquetes con un pequeño historial

![about-descarga-melo](https://github.com/user-attachments/assets/79d6504c-84ee-4072-9af2-073e328019c3)

### 2. Cabeceras-selección
#### Procesador y selector de líneas EXTINF con patrón específico

Este script bash proporciona una interfaz gráfica para descargar archivos desde URLs, manteniendo un historial de las últimas descargas realizadas.

## Características avanzadas

- Interfaz gráfica usando Zenity
- Permite introducir una o varias URLs a la vez (descarga múltiple)
- Selección de carpeta de destino para guardar los archivos
- Barra de progreso gráfica durante la descarga
- Notificación de escritorio al finalizar cada descarga
- Validación básica de URLs antes de descargar
- Soporte para reintentos automáticos si la descarga falla (hasta 3 intentos)
- Permite abrir el archivo descargado o la carpeta de destino al finalizar
- Historial simple: puedes ver, copiar al portapapeles o reutilizar cualquier URL previa
- Mantiene un archivo de historial en `$HOME/.url_download_history`
- Permite limpiar todo el historial desde el menú principal
- Descarga automática usando wget
- Verifica automáticamente si Zenity está instalado
- Permite cancelar la operación en cualquier momento

## Requisitos

- Sistema operativo Linux. Funciona con Ubuntu y con Debian.
- Zenity (para la interfaz gráfica)
- wget (para las descargas)
- xclip (para poder copiar las URL del historial al portapapeles)

## Instalación

1. Es necesario tener instalado Zenity:
```bash
sudo apt-get install zenity
```

2. Es necesario tener instalado xclip:
```bash
sudo apt-get install xclip
```

3. Descarga este script y dale permisos de ejecución:
```bash
chmod +x descarga-melo.sh
```

## Uso actualizado

1. Ejecuta el script:
```bash
./descarga-melo.sh
```

2. Se abrirá una ventana con las siguientes opciones:
   - "Nueva URL": Para introducir una o varias direcciones de descarga (una por línea)
   - Historial de URLs previas (con opciones para descargar o copiar al portapapeles)
   - Limpiar historial

3. Si seleccionas "Nueva URL", podrás introducir varias URLs a la vez. Luego podrás elegir la carpeta de destino y el nombre de cada archivo.

4. El script mostrará una barra de progreso y notificará al finalizar cada descarga. Si falla, podrás reintentar.

5. Al terminar, puedes abrir el archivo descargado o la carpeta de destino.

## Almacenamiento del historial

El script mantiene un archivo de historial en:
```
$HOME/.url_download_history
```

Este archivo almacena las URLs utilizadas previamente y se usa para mostrar las opciones de descarga recientes.

## Notas

- El script verifica automáticamente si Zenity está instalado
- Si la descarga falla, se mostrará un mensaje de error
- Puedes cancelar la operación en cualquier momento

---

## Cabeceras-selección (cabeceras_seleccion.sh)

Script especializado para procesar archivos M3U y encontrar líneas EXTINF con un patrón específico, permitiendo al usuario seleccionar y extraer partes del contenido con el ratón.

### Características

- **Búsqueda específica**: Encuentra líneas EXTINF que contengan el patrón `##### NOMBRE #####` tanto en `tvg-name` como al final de la línea
- **Filtrado inteligente**: Permite buscar términos específicos dentro de las líneas encontradas
- **Selección con ratón**: Interfaz gráfica que permite seleccionar cualquier parte del texto con el ratón
- **Resaltado de términos**: Cuando aplicas un filtro, los términos buscados aparecen resaltados
- **Edición de contenido**: Posibilidad de editar el contenido antes de guardarlo
- **Búsqueda en tiempo real**: Función Ctrl+F dentro de la ventana de resultados

### Requisitos

- Sistema operativo Linux
- Zenity (para la interfaz gráfica)
- Archivo M3U con líneas EXTINF

### Instalación

1. Asegúrate de tener Zenity instalado:
```bash
sudo apt-get install zenity
```

2. Dale permisos de ejecución al script:
```bash
chmod +x cabeceras_seleccion.sh
```

### Uso

1. Ejecuta el script:
```bash
./cabeceras_seleccion.sh
```

2. **Selecciona tu archivo M3U**: Se abrirá un diálogo para elegir el archivo

3. **Información del análisis**: El script te mostrará cuántas líneas con el patrón específico encontró

4. **Opción de filtrado** (opcional): Puedes filtrar las líneas por un término específico:
   - `FRANCE` - Para ver solo líneas relacionadas con Francia
   - `SPORT` - Para ver solo líneas deportivas
   - `4K` - Para ver solo líneas en 4K
   - `FHD` - Para ver solo líneas en alta definición
   - Cualquier otro término que busques

5. **Visualización y selección**: Se abrirá una ventana con todas las líneas encontradas donde puedes:
   - **Seleccionar texto con el ratón**: Arrastra para seleccionar cualquier parte
   - **Ctrl+A**: Seleccionar todo el contenido
   - **Ctrl+C**: Copiar la selección al portapapeles
   - **Ctrl+F**: Buscar texto dentro de la ventana
   - **Editar**: Modificar el contenido directamente

6. **Guardar**: Presiona "Guardar selección" para exportar el contenido seleccionado/editado

### Patrón de líneas que busca

El script está diseñado específicamente para encontrar líneas EXTINF con esta estructura:

```
#EXTINF:-1 tvg-id="" tvg-name="##### NOMBRE #####" tvg-logo="" group-title="GRUPO",##### NOMBRE #####
```

**Ejemplos de líneas que encuentra:**
```
#EXTINF:-1 tvg-id="" tvg-name="##### FRANCE 4K #####" tvg-logo="" group-title="FR| FRANCE 4K",##### FRANCE 4K #####
#EXTINF:-1 tvg-id="" tvg-name="##### SPORTS FHD #####" tvg-logo="" group-title="FR| FRANCE FHD",##### SPORTS FHD #####
#EXTINF:-1 tvg-id="" tvg-name="##### GENERAL FHD #####" tvg-logo="" group-title="FR| FRANCE FHD",##### GENERAL FHD #####
```

### Funciones de búsqueda

- **Búsqueda insensible a mayúsculas**: No importa si escribes `france`, `FRANCE` o `France`
- **Términos resaltados**: Los términos buscados aparecen entre `>>> <<<` para fácil identificación
- **Búsqueda flexible**: Busca en cualquier parte de la línea EXTINF

### Archivos de salida

Los archivos se guardan con el formato:
```
archivo_original_seleccion_YYYYMMDD_HHMMSS.txt
```

El archivo incluye:
- Información del archivo origen
- Fecha y hora de procesamiento
- Filtro aplicado (si se usó)
- Contenido seleccionado/editado por el usuario

### Ejemplos de uso común

1. **Buscar canales franceses**:
   - Filtro: `FRANCE`
   - Resultado: Solo líneas que contengan "FRANCE"

2. **Buscar canales deportivos**:
   - Filtro: `SPORT`
   - Resultado: Solo líneas que contengan "SPORT"

3. **Buscar canales en 4K**:
   - Filtro: `4K`
   - Resultado: Solo líneas que contengan "4K"

### Notas importantes

- El script solo procesa líneas que tengan exactamente el patrón `##### NOMBRE #####`
- Las líneas deben tener la estructura completa para ser consideradas válidas
- La función de búsqueda mantiene la integridad de las líneas encontradas
- Puedes editar el contenido antes de guardarlo
