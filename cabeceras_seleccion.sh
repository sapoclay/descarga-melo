#!/bin/bash

# Script para procesar líneas con patrón ##### NOMBRE ##### con selección de texto
# Permite seleccionar partes específicas de las líneas con el ratón

# Función para mostrar mensajes de error
mostrar_error() {
    zenity --error --text="$1" --title="Error"
}

# Función para mostrar información
mostrar_info() {
    zenity --info --text="$1" --title="Información"
}

# Verificar si zenity está instalado
if ! command -v zenity &> /dev/null; then
    echo "Error: zenity no está instalado."
    exit 1
fi

# Seleccionar archivo M3U
archivo_m3u=$(zenity --file-selection \
    --title="Seleccionar archivo M3U" \
    --file-filter="Archivos M3U (*.m3u, *.m3u8) | *.m3u *.m3u8" \
    --file-filter="Todos los archivos | *")

# Verificar si se seleccionó un archivo
if [ -z "$archivo_m3u" ]; then
    mostrar_info "No se seleccionó ningún archivo."
    exit 0
fi

# Verificar si el archivo existe
if [ ! -f "$archivo_m3u" ]; then
    mostrar_error "El archivo seleccionado no existe."
    exit 1
fi

# Buscar líneas con patrón específico
echo "Buscando líneas con patrón ##### NOMBRE #####..."
total_con_patron=$(grep -c "^#EXTINF.*tvg-name=\"##### .* #####\".*,##### .* #####" "$archivo_m3u")

if [ $total_con_patron -eq 0 ]; then
    mostrar_error "No se encontraron líneas con el patrón ##### NOMBRE ##### en el archivo."
    exit 1
fi

mostrar_info "Se encontraron $total_con_patron líneas con patrón ##### NOMBRE #####"

# Preguntar si quiere buscar dentro de las líneas encontradas
if zenity --question --text="Se encontraron $total_con_patron líneas con patrón ##### NOMBRE #####.

¿Deseas filtrar/buscar algo específico dentro de estas líneas antes de mostrarlas?

Sí = Buscar/filtrar contenido específico
No = Mostrar todas las líneas encontradas" --width=400; then
    
    # Pedir término de búsqueda
    termino_busqueda=$(zenity --entry \
        --title="Buscar en líneas EXTINF" \
        --text="Introduce el término que quieres buscar dentro de las líneas encontradas:
(Ej: 'FRANCE', 'SPORT', 'FHD', etc.)" \
        --width=400)
    
    if [ -n "$termino_busqueda" ]; then
        # Buscar el término dentro de las líneas con patrón completo
        lineas_filtradas=$(grep -i "^#EXTINF.*tvg-name=\"##### .* #####\".*,##### .* #####" "$archivo_m3u" | grep -i "$termino_busqueda" | wc -l)
        
        if [ $lineas_filtradas -eq 0 ]; then
            if ! zenity --question --text="No se encontraron líneas que contengan '$termino_busqueda'.

¿Deseas ver todas las líneas originales?"; then
                mostrar_info "Búsqueda cancelada."
                exit 0
            fi
            usar_filtro=false
        else
            mostrar_info "Se encontraron $lineas_filtradas líneas que contienen '$termino_busqueda'"
            usar_filtro=true
        fi
    else
        usar_filtro=false
    fi
else
    usar_filtro=false
fi

# Crear archivo temporal con las líneas encontradas
temp_display=$(mktemp)
temp_numeradas=$(mktemp)

# Mostrar progreso mientras procesa
(
    echo "0" ; echo "# Extrayendo líneas con patrón ##### NOMBRE #####..."
    
    # Extraer líneas según si hay filtro o no
    if [ "$usar_filtro" = true ]; then
        # Primero buscar líneas con patrón completo, luego filtrar por término
        grep -n "^#EXTINF.*tvg-name=\"##### .* #####\".*,##### .* #####" "$archivo_m3u" | grep -i "$termino_busqueda" > "$temp_numeradas"
        total_final=$(wc -l < "$temp_numeradas")
        echo "30" ; echo "# Aplicando filtro de búsqueda: '$termino_busqueda'..."
    else
        grep -n "^#EXTINF.*tvg-name=\"##### .* #####\".*,##### .* #####" "$archivo_m3u" > "$temp_numeradas"
        total_final=$total_con_patron
        echo "30" ; echo "# Preparando todas las líneas encontradas..."
    fi
    
    echo "50" ; echo "# Preparando líneas para visualización..."
    
    # Crear archivo de visualización con formato legible
    {
        echo "=== LÍNEAS EXTINF CON PATRÓN ##### NOMBRE ##### ==="
        echo "Archivo: $(basename "$archivo_m3u")"
        if [ "$usar_filtro" = true ]; then
            echo "Filtro aplicado: '$termino_busqueda'"
            echo "Líneas filtradas: $total_final de $total_con_patron totales"
        else
            echo "Total de líneas encontradas: $total_final"
        fi
        echo "Fecha: $(date)"
        echo ""
        echo "INSTRUCCIONES:"
        echo "- Puedes seleccionar cualquier parte del texto con el ratón"
        echo "- Usa Ctrl+A para seleccionar todo"
        echo "- Usa Ctrl+C para copiar la selección"
        echo "- Usa Ctrl+F para buscar texto dentro de esta ventana"
        echo "- Presiona 'Guardar selección' para guardar el contenido editado"
        echo "- Presiona 'Cerrar sin guardar' para salir sin guardar"
        echo ""
        echo "=========================================="
        echo ""
        
        contador=1
        while IFS= read -r linea_con_numero; do
            if [ -n "$linea_con_numero" ]; then
                # Extraer número de línea original y contenido
                linea_numero=$(echo "$linea_con_numero" | cut -d: -f1)
                linea_contenido=$(echo "$linea_con_numero" | cut -d: -f2-)
                
                echo "[$contador] Línea original: $linea_numero"
                
                # Resaltar el término buscado si se está filtrando
                if [ "$usar_filtro" = true ]; then
                    # Mostrar la línea con el término resaltado (usando >>> <<<)
                    linea_resaltada=$(echo "$linea_contenido" | sed "s/$termino_busqueda/>>> $termino_busqueda <<</gi")
                    echo "$linea_resaltada"
                else
                    echo "$linea_contenido"
                fi
                echo ""
                
                ((contador++))
            fi
        done < "$temp_numeradas"
        
        echo ""
        echo "=========================================="
        if [ "$usar_filtro" = true ]; then
            echo "NOTA: Se muestran solo las líneas que contienen '$termino_busqueda'"
            echo "El término aparece resaltado entre >>> <<<"
        fi
        echo "Total de líneas mostradas: $((contador-1))"
        
    } > "$temp_display"
    
    echo "100" ; echo "# Preparación completada"
    
) | zenity --progress \
    --title="Preparando líneas para visualización" \
    --text="Procesando..." \
    --width=400 \
    --auto-close

# Mostrar las líneas en una ventana de texto donde se puede seleccionar
zenity --text-info \
    --title="Líneas EXTINF con patrón ##### NOMBRE ##### - $(basename "$archivo_m3u")" \
    --filename="$temp_display" \
    --width=1400 \
    --height=700 \
    --font="monospace 10" \
    --editable \
    --ok-label="Guardar selección" \
    --cancel-label="Cerrar sin guardar" > "$temp_display.selected"

# Verificar si el usuario hizo alguna selección/edición
if [ $? -eq 0 ] && [ -s "$temp_display.selected" ]; then
    # El usuario presionó "Guardar selección"
    timestamp=$(date +%Y%m%d_%H%M%S)
    archivo_salida="${archivo_m3u%.*}_seleccion_${timestamp}.txt"
    
    # Guardar el contenido seleccionado/editado
    {
        echo "# Selección de líneas EXTINF con patrón ##### NOMBRE #####"
        echo "# Archivo origen: $(basename "$archivo_m3u")"
        echo "# Fecha: $(date)"
        if [ "$usar_filtro" = true ]; then
            echo "# Filtro aplicado: '$termino_busqueda'"
        fi
        echo "# Contenido seleccionado/editado por el usuario:"
        echo ""
        cat "$temp_display.selected"
    } > "$archivo_salida"
    
    # Mostrar resultado
    mensaje="Se guardó tu selección en:
$(basename "$archivo_salida")

¿Deseas abrir el archivo?"
    
    if zenity --question --text="$mensaje" --width=300; then
        if command -v xdg-open &> /dev/null; then
            xdg-open "$archivo_salida"
        elif command -v gedit &> /dev/null; then
            gedit "$archivo_salida" &
        else
            mostrar_info "Archivo guardado en: $archivo_salida"
        fi
    else
        mostrar_info "Archivo guardado en: $archivo_salida"
    fi
else
    mostrar_info "No se guardó ninguna selección."
fi

# Limpiar archivos temporales
rm -f "$temp_display" "$temp_numeradas" "$temp_display.selected"

echo "Proceso completado."
