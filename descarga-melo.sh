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
        --text="<span size='x-large'><b>Descarga-melo v1.0</b></span>\n\n<span size='large'>Una herramienta simple para descargar archivos con historial de URLs.</span>\n\n<span>Esta aplicación te permite:\n• Introducir una o varias URLs nuevas para descargar\n• Mantener un historial de las URLs utilizadas\n• Reutilizar URLs del historial para nuevas descargas\n• Copiar URLs del historial al portapapeles\n• Limpiar todo el historial cuando lo necesites\n• Reintentar descargas fallidas automáticamente\n• Personalizar el nombre de los archivos descargados\n• Elegir la carpeta de destino para las descargas\n• Abrir los archivos o su carpeta al terminar</span>\n\n<b>Creado por:</b> entreunosyceros\n<b>Licencia:</b> Software Libre\n<b>Versión:</b> 1.0" \
        --ok-label="Volver" \
        --width=500 --height=400
}

# Mostrar diálogo principal con las opciones
RESPUESTA=$(zenity --list \
    --title="Descarga-melo" \
    --text="Selecciona una opción:" \
    --radiolist \
    --column="" \
    --column="Opción" \
    TRUE "Nueva URL" \
    $(while IFS= read -r url; do
        echo "FALSE" "$url"
    done < "$HISTORIAL_FILE") \
    --ok-label="Siguiente" \
    --cancel-label="Cancelar" \
    --extra-button "About" \
    --extra-button "Limpiar historial" \
    --width=1000 --height=600)

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
    # Solicitar nuevas URLs (una o varias, separadas por salto de línea)
    URLS=$(zenity --text-info \
        --editable \
        --title="Nuevas URLs" \
        --text="Introduce una o varias URLs (una por línea):" \
        --filename=<(echo -e "https://ejemplo1.com/archivo1.zip\nhttps://ejemplo2.com/archivo2.pdf\nhttps://ejemplo3.com/archivo3.mp4") \
        --width=500 --height=200)
    
    if [ -z "$URLS" ]; then
        echo "Operación cancelada por el usuario"
        exit 0
    fi
    # Convertir a array
    IFS=$'\n' read -rd '' -a URL_ARRAY <<<"$URLS"
else
    # URL seleccionada del historial
    URL_SELEC="$RESPUESTA"
    
    # Preguntar qué hacer con la URL seleccionada
    TEXTO_ESCAPADO=$(echo "$URL_SELEC" | sed 's/&/\&amp;/g')
    ACCION=$(zenity --list \
        --title="Seleccionar acción" \
        --text="¿Qué deseas hacer con la URL seleccionada?\n\nURL: $TEXTO_ESCAPADO" \
        --column="Acción" \
        "Descargar" \
        "Copiar al portapapeles" \
        --ok-label="Aceptar" \
        --cancel-label="Cancelar" \
        --width=800 --height=300)
    
    if [ -z "$ACCION" ]; then
        echo "Operación cancelada por el usuario"
        exit 0
    fi

    if [ "$ACCION" = "Copiar al portapapeles" ]; then
        echo -n "$URL_SELEC" | xclip -selection clipboard
        zenity --info --text="URL copiada al portapapeles"
        exec "$0"
    elif [ "$ACCION" = "Descargar" ]; then
        URL_ARRAY=("$URL_SELEC")
    else
        echo "Operación cancelada por el usuario"
        exit 0
    fi
fi

# Selección de carpeta de destino
DESTINO=$(zenity --file-selection --directory --title="Selecciona la carpeta de destino" --filename="$HOME/Escritorio/")
if [ -z "$DESTINO" ]; then
    echo "Operación cancelada por el usuario"
    exit 0
fi

for URL in "${URL_ARRAY[@]}"; do
    # Validación básica de URL
    if ! [[ "$URL" =~ ^https?:// ]]; then
        zenity --error --text="URL no válida: $URL"
        continue
    fi
    # Guardar URL en el historial si no existe
    grep -qxF "$URL" "$HISTORIAL_FILE" || echo "$URL" >> "$HISTORIAL_FILE"
    # Nombre de archivo personalizado
    DEFAULT_FILENAME=$(basename "$URL")
    FILENAME=$(zenity --entry \
        --title="Nombre de archivo" \
        --text="Introduce el nombre con el que se guardará el archivo (deja vacío para usar el nombre original):" \
        --entry-text="$DEFAULT_FILENAME" \
        --width=400)
    if [ -z "$FILENAME" ]; then
        FILENAME="$DEFAULT_FILENAME"
    fi
    # Descargar con barra de progreso y reintentos
    EXITO=0
    for intento in {1..3}; do
        wget -O "$DESTINO/$FILENAME" "$URL" 2>&1 | \
        stdbuf -oL grep --line-buffered "%" | \
        stdbuf -oL awk '{gsub(/%/, ""); if ($1 ~ /^[0-9]+$/) print $1;}' | \
        zenity --progress --title="Descargando $FILENAME (Intento $intento)" --percentage=0 --auto-close --width=400
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            EXITO=1
            break
        else
            zenity --question --text="Error al descargar $FILENAME. ¿Reintentar? ($intento/3)" --ok-label="Reintentar" --cancel-label="Omitir"
            [ $? -ne 0 ] && break
        fi
    done
    if [ $EXITO -eq 1 ]; then
        zenity --notification --text="Descarga completada: $FILENAME"
        # Preguntar si desea abrir el archivo o carpeta
        zenity --question --title="Abrir archivo" --text="¿Deseas abrir el archivo descargado o la carpeta de destino?" --ok-label="Abrir archivo" --cancel-label="Abrir carpeta"
        if [ $? -eq 0 ]; then
            xdg-open "$DESTINO/$FILENAME"
        else
            xdg-open "$DESTINO"
        fi
    else
        zenity --error --text="No se pudo descargar $FILENAME tras varios intentos."
    fi
    # Siguiente descarga (si hay más)
    sleep 1
done