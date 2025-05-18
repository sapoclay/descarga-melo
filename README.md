# Descarga-melo. 
## Descarga de paquetes con un pequeño historial

![about-descarga-melo](https://github.com/user-attachments/assets/79d6504c-84ee-4072-9af2-073e328019c3)

Este script bash proporciona una interfaz gráfica para descargar archivos desde URLs, manteniendo un historial de las últimas descargas realizadas.

## Características

- Interfaz gráfica usando Zenity
- Mantiene un historial de las últimas 3 URLs utilizadas
- Permite introducir nuevas URLs o reutilizar URLs anteriores
- Descarga automática al escritorio del usuario
- Muestra el progreso y estado de la descarga

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

## Uso

1. Ejecuta el script:
```bash
./descarga-melo.sh
```

2. Se abrirá una ventana con las siguientes opciones:
   - "Nueva URL": Para introducir una nueva dirección de descarga
   - Lista de las últimas 3 URLs utilizadas (si existen)

3. Si seleccionas "Nueva URL", se abrirá una ventana donde podrás introducir la dirección del archivo a descargar.

4. El archivo se descargará automáticamente en tu escritorio.

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
