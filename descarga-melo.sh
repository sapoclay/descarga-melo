#!/bin/bash

# Verificar si zenity está instalado
if ! command -v zenity &> /dev/null; then
    echo "Error: zenity no está instalado. Por favor, instálelo con: sudo apt-get install zenity"
    exit 1
fi

# Archivo para almacenar el historial de URLs
HISTORIAL_FILE="$HOME/.url_download_history"
touch "$HISTORIAL_FILE"

# Obtener las últimas 3 URLs del historial
ULTIMAS_URLS=$(tac "$HISTORIAL_FILE" | head -n 3)

# Preparar lista de URLs para zenity
LISTA_URLS="Nueva URL|Introducir una nueva URL"
while IFS= read -r url; do
    LISTA_URLS="$LISTA_URLS!$url|$url"
done <<< "$ULTIMAS_URLS"

# Función para mostrar la pestaña About
show_about() {
    # Texto de la ventana About sin imagen
    zenity --info \
        --title="Acerca de Descarga-melo" \
        --text="<span size='x-large'><b>Descarga-melo v1.0</b></span>\n\n<span size='large'>Una herramienta simple para descargar archivos con historial de URLs recientes.</span>\n\n<span>Esta aplicación te permite:\n• Descargar archivos desde URLs\n• Mantener un historial de las últimas 3 URLs utilizadas\n• Descargar archivos directamente al escritorio\n• Gestionar fácilmente las descargas anteriores</span>\n\n<b>Creado por:</b> entreunosyceros\n<b>Licencia:</b> Software Libre\n<b>Versión:</b> 1.0" \
        --ok-label="Volver" \
        --width=400 --height=300
}

# Mostrar diálogo con las opciones usando tabs
RESPUESTA=$(zenity --list \
    --title="Descarga-melo" \
    --text="Selecciona una URL anterior o introduce una nueva:" \
    --radiolist \
    --column="" \
    --column="Opción" \
    --column="URL" \
    TRUE "Nueva URL" "Introducir una nueva URL" \
    $(while IFS='|' read -r url desc; do
        echo "FALSE" "$url" "$desc"
    done <<< $(echo "$LISTA_URLS" | tr '!' '\n' | tail -n +2)) \
    --ok-label="Descargar" \
    --cancel-label="Cancelar" \
    --extra-button "About" \
    --extra-button "Limpiar historial" \
    --width=600 --height=400)

# Guardar el código de retorno inmediatamente
RETURN_CODE=$?

# Función para limpiar el historial
clean_history() {
    if zenity --question \
        --title="Limpiar historial" \
        --text="¿Estás seguro de que quieres eliminar todas las URLs guardadas?" \
        --ok-label="Sí" \
        --cancel-label="No"; then
        
        # Vaciar el archivo de historial
        > "$HISTORIAL_FILE"
        
        zenity --info \
            --title="Historial limpiado" \
            --text="Se han eliminado todas las URLs guardadas." \
            --ok-label="Aceptar"
            
        # Volver a mostrar el diálogo principal
        exec "$0"
    else
        # Volver a mostrar el diálogo principal si el usuario cancela
        exec "$0"
    fi
}

# Procesar respuesta
if [ "$RESPUESTA" = "About" ]; then
    show_about
    # Volver a mostrar el diálogo principal
    exec "$0"
elif [ "$RESPUESTA" = "Limpiar historial" ]; then
    clean_history
elif [ $RETURN_CODE -eq 1 ]; then
    # Usuario presionó Cancelar
    echo "Operación cancelada por el usuario"
    exit 0
elif [ $RETURN_CODE -ne 0 ]; then
    # Cualquier otro código de retorno de error
    echo "Error en la selección"
    exit 1
fi

# Procesar selección de URL
if [ "$RESPUESTA" = "Nueva URL" ]; then
    # Solicitar nueva URL
    URL=$(zenity --entry \
        --title="Nueva URL" \
        --text="Introduce la URL del paquete a descargar:" \
        --width=400)
    
    if [ -z "$URL" ]; then
        echo "Operación cancelada por el usuario"
        exit 0
    fi
else
    URL="$RESPUESTA"
fi

# Guardar URL en el historial
echo "$URL" >> "$HISTORIAL_FILE"

# Obtener el nombre del archivo desde la URL
FILENAME=$(basename "$URL")

# Ruta del escritorio del usuario
DESKTOP="$HOME/Escritorio"

# Crear directorio Escritorio si no existe
if [ ! -d "$DESKTOP" ]; then
    mkdir -p "$DESKTOP"
fi

echo "Descargando $FILENAME..."

# Descargar el archivo usando wget
wget -P "$DESKTOP" "$URL"

# Verificar si la descarga fue exitosa
if [ $? -eq 0 ]; then
    echo "Descarga completada: $DESKTOP/$FILENAME"
else
    echo "Error durante la descarga"
    exit 1
fi