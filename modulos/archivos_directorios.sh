#!/bin/bash
# MÓDULO DE ARCHIVOS Y DIRECTORIOS
# Desarrollado por: Hector Ortega

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

menu_archivos_directorios() {
    while true; do
        clear
        echo -e "${BLUE}"
        echo "=========================================="
        echo "    GESTIÓN DE ARCHIVOS Y DIRECTORIOS     "
        echo "=========================================="
        echo -e "${NC}"
        echo "a) Listar contenido de un directorio"
        echo "b) Crear directorio (simple)"
        echo "c) Crear directorios (múltiples)"
        echo "d) Crear directorio recursivo (con -p)"
        echo "e) Renombrar archivo o directorio"
        echo "f) Copiar archivo o directorio"
        echo "g) Mover archivo o directorio"
        echo "h) Eliminar archivo o directorio"
        echo "i) Buscar archivos por nombre"
        echo "j) Cambiar permisos (chmod)"
        echo "k) Cambiar propietario (chown)"
        echo "l) Ver información detallada de archivos"
        echo "m) Crear archivo nuevo"
        echo "n) Editar archivo con nano"
        echo "o) Ver contenido de archivo"
        echo "p) Volver al menú principal"
        echo
        echo -n "Seleccione una opción: "
        read -r opcion_arch

        case $opcion_arch in
            a|A) listar_directorio ;;
            b|B) crear_directorio_simple ;;
            c|C) crear_directorios_multiples ;;
            d|D) crear_directorio_recursivo ;;
            e|E) renombrar_elemento ;;
            f|F) copiar_elemento ;;
            g|G) mover_elemento ;;
            h|H) eliminar_elemento ;;
            i|I) buscar_archivos ;;
            j|J) cambiar_permisos ;;
            k|K) cambiar_propietario ;;
            l|L) ver_informacion_detallada ;;
            m|M) crear_archivo ;;
            n|N) editar_archivo ;;
            o|O) ver_contenido_archivo ;;
            p|P) return 0 ;;
            *) echo -e "${RED}Opción inválida.${NC}"; pausa ;;
        esac
    done
}

listar_directorio() {
    echo -n "Ingrese la ruta del directorio (Enter = actual): "
    read -r ruta
    [ -z "$ruta" ] && ruta="."
    if [ -d "$ruta" ]; then
        echo -e "${GREEN}Contenido de: $ruta${NC}"
        ls -lah "$ruta"
    else
        echo -e "${RED}No es un directorio válido: $ruta${NC}"
    fi
    pausa
}

crear_directorio_simple() {
    echo -n "Nombre/ ruta del nuevo directorio: "
    read -r dir
    if [ -z "$dir" ]; then
        echo -e "${RED}Nombre vacío.${NC}"
    else
        mkdir "$dir" 2>/dev/null && echo -e "${GREEN}Directorio creado: $dir${NC}" || echo -e "${RED}Error al crear: $dir${NC}"
    fi
    pausa
}

crear_directorios_multiples() {
    echo -n "Ingrese nombres/ rutas separados por espacio: "
    read -r line
    if [ -z "$line" ]; then
        echo -e "${RED}Nada ingresado.${NC}"
    else
        for d in $line; do
            mkdir -p "$d" 2>/dev/null && echo -e "${GREEN}Creado: $d${NC}" || echo -e "${YELLOW}No creado: $d (posible error)${NC}"
        done
    fi
    pausa
}

crear_directorio_recursivo() {
    echo -n "Ruta recursiva a crear (ej: a/b/c): "
    read -r ruta
    if [ -z "$ruta" ]; then
        echo -e "${RED}Ruta vacía.${NC}"
    else
        mkdir -p "$ruta" 2>/dev/null && echo -e "${GREEN}Directorio recursivo creado: $ruta${NC}" || echo -e "${RED}Error al crear: $ruta${NC}"
    fi
    pausa
}

renombrar_elemento() {
    echo -n "Ruta/archivo actual: "
    read -r origen
    echo -n "Nuevo nombre / ruta: "
    read -r destino
    if [ -e "$origen" ]; then
        mv "$origen" "$destino" 2>/dev/null && echo -e "${GREEN}Renombrado: $origen -> $destino${NC}" || echo -e "${RED}Error al renombrar.${NC}"
    else
        echo -e "${RED}No existe: $origen${NC}"
    fi
    pausa
}

copiar_elemento() {
    echo -n "Ruta origen: "
    read -r o
    echo -n "Ruta destino: "
    read -r d
    if [ -e "$o" ]; then
        cp -r "$o" "$d" 2>/dev/null && echo -e "${GREEN}Copiado: $o -> $d${NC}" || echo -e "${RED}Error al copiar.${NC}"
    else
        echo -e "${RED}Origen no existe: $o${NC}"
    fi
    pausa
}

mover_elemento() {
    echo -n "Ruta origen: "
    read -r o
    echo -n "Ruta destino: "
    read -r d
    if [ -e "$o" ]; then
        mv "$o" "$d" 2>/dev/null && echo -e "${GREEN}Movido: $o -> $d${NC}" || echo -e "${RED}Error al mover.${NC}"
    else
        echo -e "${RED}Origen no existe: $o${NC}"
    fi
    pausa
}

eliminar_elemento() {
    echo -n "Ruta del elemento a eliminar: "
    read -r e
    if [ -z "$e" ]; then
        echo -e "${RED}Nada ingresado.${NC}"
    elif [ ! -e "$e" ]; then
        echo -e "${RED}No existe: $e${NC}"
    else
        echo -n "¿Seguro que desea eliminar '$e'? (s/n): "
        read -r conf
        if [[ "$conf" =~ ^[sS]$ ]]; then
            rm -rf "$e" 2>/dev/null && echo -e "${GREEN}Eliminado: $e${NC}" || echo -e "${RED}Error al eliminar.${NC}"
        else
            echo -e "${YELLOW}Operación cancelada.${NC}"
        fi
    fi
    pausa
}

buscar_archivos() {
    echo -n "Ingrese el directorio donde desea buscar (Enter = actual): "
    read -r directorio
    [ -z "$directorio" ] && directorio="."
    
    if [ ! -d "$directorio" ]; then
        echo -e "${RED}No es un directorio válido: $directorio${NC}"
        pausa
        return
    fi
    
    echo -n "Nombre o patrón a buscar (ej: '*.log' o 'archivo'): "
    read -r n
    if [ -z "$n" ]; then
        echo -e "${RED}Nada ingresado.${NC}"
    else
        echo -e "${GREEN}Buscando '$n' en: $directorio${NC}"
        echo -e "${GREEN}Resultados:${NC}"
        
        cd "$directorio" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo -e "${RED}No se pudo acceder al directorio: $directorio${NC}"
        else
            find . -iname "$n" 2>/dev/null | sed -n '1,200p'
            echo -e "\n${YELLOW}(Búsqueda completada en: $(pwd))${NC}"
            cd - > /dev/null
        fi
    fi
    pausa
}

cambiar_permisos() {
    echo -n "Ruta del archivo/directorio: "
    read -r r
    if [ ! -e "$r" ]; then
        echo -e "${RED}No existe: $r${NC}"
    else
        echo -n "Permisos (ej. 755 o u+rwx,g+rx): "
        read -r p
        chmod "$p" "$r" 2>/dev/null && echo -e "${GREEN}Permisos actualizados.${NC}" || echo -e "${RED}Error al cambiar permisos.${NC}"
    fi
    pausa
}

cambiar_propietario() {
    echo -n "Ruta del archivo/directorio: "
    read -r ruta
    if [ ! -e "$ruta" ]; then
        echo -e "${RED}No existe: $ruta${NC}"
    else
        echo -n "Nuevo propietario (ej. usuario:grupo o solo usuario): "
        read -r owner
        chown "$owner" "$ruta" 2>/dev/null && echo -e "${GREEN}Propietario actualizado.${NC}" || echo -e "${RED}Error. ¿Tiene permisos?${NC}"
    fi
    pausa
}

ver_informacion_detallada() {
    echo -n "Ruta del archivo/directorio: "
    read -r ruta
    if [ ! -e "$ruta" ]; then
        echo -e "${RED}No existe: $ruta${NC}"
    else
        echo -e "${CYAN}=== INFORMACIÓN DETALLADA ===${NC}"
        echo -e "${YELLOW}Estadísticas:${NC}"
        stat "$ruta" 2>/dev/null || ls -la "$ruta"
        echo -e "\n${YELLOW}Tipo de archivo:${NC}"
        file "$ruta"
        echo -e "\n${YELLOW}Permisos detallados:${NC}"
        ls -ld "$ruta"
    fi
    pausa
}

crear_archivo() {
    echo -n "Nombre del archivo a crear: "
    read -r archivo
    if [ -z "$archivo" ]; then
        echo -e "${RED}Nombre vacío.${NC}"
    elif [ -e "$archivo" ]; then
        echo -e "${YELLOW}El archivo ya existe. ¿Sobrescribir? (s/n): ${NC}"
        read -r sobrescribir
        if [[ "$sobrescribir" =~ ^[sS]$ ]]; then
            > "$archivo" && echo -e "${GREEN}Archivo sobrescrito: $archivo${NC}" || echo -e "${RED}Error al crear.${NC}"
        fi
    else
        touch "$archivo" 2>/dev/null && echo -e "${GREEN}Archivo creado: $archivo${NC}" || echo -e "${RED}Error al crear.${NC}"
    fi
    pausa
}

editar_archivo() {
    echo -n "Ruta del archivo a editar: "
    read -r archivo
    if [ ! -e "$archivo" ]; then
        echo -e "${YELLOW}El archivo no existe. ¿Crearlo? (s/n): ${NC}"
        read -r crear
        if [[ "$crear" =~ ^[sS]$ ]]; then
            archivo="$archivo"
        else
            return
        fi
    fi
    
    if command -v nano &> /dev/null; then
        nano "$archivo"
        echo -e "${GREEN}Archivo editado: $archivo${NC}"
    elif command -v vi &> /dev/null; then
        echo -e "${YELLOW}nano no encontrado. Usando vi.${NC}"
        vi "$archivo"
    elif command -v vim &> /dev/null; then
        echo -e "${YELLOW}nano no encontrado. Usando vim.${NC}"
        vim "$archivo"
    else
        echo -e "${RED}No se encontró ningún editor de texto.${NC}"
    fi
    pausa
}

ver_contenido_archivo() {
    echo -n "Ruta del archivo a ver: "
    read -r archivo
    if [ ! -f "$archivo" ]; then
        echo -e "${RED}No es un archivo válido o no existe.${NC}"
    else
        echo -e "${CYAN}=== CONTENIDO DE: $archivo ===${NC}"
        echo -e "${YELLOW}Primeras 50 líneas:${NC}"
        head -50 "$archivo"
        echo -e "\n${YELLOW}Últimas 50 líneas:${NC}"
        tail -50 "$archivo"
        echo -e "\n${YELLOW}Tamaño:${NC} $(wc -l < "$archivo") líneas, $(wc -c < "$archivo") bytes"
    fi
    pausa
}

pausa() {
    echo
    read -p "Presione Enter para continuar..."
}
