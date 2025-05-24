# Descarga-melo. 
## Descarga de paquetes con un pequeño historial

![about-descarga-melo](https://github.com/user-attachments/assets/79d6504c-84ee-4072-9af2-073e328019c3)

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
- Historial ampliado: puedes ver, borrar individualmente o reutilizar cualquier URL previa
- Mantiene un archivo de historial en `$HOME/.url_download_history`
- Permite limpiar todo el historial o gestionar URLs una a una
- Descarga automática usando wget
- Verifica automáticamente si Zenity está instalado
- Permite cancelar la operación en cualquier momento

## Requisitos

- Sistema operativo Linux. Funciona con Ubuntu y con Debian.
- Zenity (para la interfaz gráfica)
- wget (para las descargas)

## Instalación

1. Es necesario tener instalado Zenity:
```bash
sudo apt-get install zenity
```

2. Descarga este script y dale permisos de ejecución:
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
   - Historial completo de URLs utilizadas (puedes descargar o borrar cualquiera)
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
