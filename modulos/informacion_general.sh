#!/bin/bash
# MÓDULO DE INFORMACIÓN GENERAL
# Desarrollado por: Amir Reyes

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

menu_informacion_general() {
    while true; do
        clear
        echo -e "${BLUE}"
        echo "=========================================="
        echo "         INFORMACIÓN GENERAL"
        echo "=========================================="
        echo -e "${NC}"
        echo "a. Listar información general de archivos"
        echo "b. Revisar espacio disponible en disco"
        echo "c. Revisar espacio usado por cada directorio"
        echo "d. Revisar estado de la memoria"
        echo "e. Usuarios activos en el sistema"
        echo "f. Versión del Kernel del S.O."
        echo "g. Volver al menú principal"
        echo
        echo -n "Seleccione una opción: "
        read opcion_info

        case $opcion_info in
            a|A)
                listar_info_archivos
                ;;
            b|B)
                espacio_disco
                ;;
            c|C)
                espacio_directorios
                ;;
            d|D)
                estado_memoria
                ;;
            e|E)
                usuarios_activos
                ;;
            f|F)
                version_kernel
                ;;
            g|G)
                return 0
                ;;
            *)
                echo -e "${RED}Opción inválida. Intente nuevamente.${NC}"
                pausa
                ;;
        esac
    done
}

# a. Listar información general de archivos o filesystems
listar_info_archivos() {
    echo -n "Ingrese la ruta del archivo o directorio: "
    read ruta
    
    if [ -z "$ruta" ]; then
        ruta="."
    fi
    
    if [ ! -e "$ruta" ]; then
        echo -e "${RED}Error: La ruta '$ruta' no existe${NC}"
    else
        echo -e "${GREEN}Información de: $ruta${NC}"
        echo "----------------------------------------"
        if [ -f "$ruta" ]; then
            # Es un archivo
            echo "Tipo: Archivo regular"
            echo "Tamaño: $(ls -lh "$ruta" | awk '{print $5}')"
            echo "Permisos: $(ls -l "$ruta" | awk '{print $1}')"
            echo "Usuario: $(ls -l "$ruta" | awk '{print $3}')"
            echo "Grupo: $(ls -l "$ruta" | awk '{print $4}')"
            echo "Última modificación: $(ls -l "$ruta" | awk '{print $6, $7, $8}')"
        elif [ -d "$ruta" ]; then
            # Es un directorio
            echo "Tipo: Directorio"
            echo "Tamaño total: $(du -sh "$ruta" 2>/dev/null | cut -f1)"
            echo "Permisos: $(ls -ld "$ruta" | awk '{print $1}')"
            echo "Usuario: $(ls -ld "$ruta" | awk '{print $3}')"
            echo "Grupo: $(ls -ld "$ruta" | awk '{print $4}')"
            echo "Número de archivos: $(find "$ruta" -maxdepth 1 -type f | wc -l)"
        else
            echo "Tipo: Otro tipo de archivo"
        fi
    fi
    pausa
}

# b. Revisar espacio disponible en disco
espacio_disco() {
    echo -e "${GREEN}Espacio disponible en disco:${NC}"
    echo "----------------------------------------"
    df -h
    pausa
}

# c. Revisar espacio utilizado por cada directorio
espacio_directorios() {
    echo -n "Ingrese la ruta a analizar (Enter para raíz): "
    read ruta
    
    if [ -z "$ruta" ]; then
        ruta="/"
    fi
    
    if [ ! -d "$ruta" ]; then
        echo -e "${RED}Error: El directorio '$ruta' no existe${NC}"
    else
        echo -e "${GREEN}Espacio utilizado en $ruta:${NC}"
        echo "----------------------------------------"
        du -h "$ruta" --max-depth=1 2>/dev/null | sort -hr | head -10
    fi
    pausa
}

# d. Revisar estado de la memoria
estado_memoria() {
    echo -e "${GREEN}Estado de la memoria:${NC}"
    echo "----------------------------------------"
    free -h
    echo
    echo -e "${YELLOW}Información adicional:${NC}"
    echo "----------------------------------------"
    echo "Memoria total: $(free -h | grep Mem | awk '{print $2}')"
    echo "Memoria usada: $(free -h | grep Mem | awk '{print $3}')"
    echo "Memoria libre: $(free -h | grep Mem | awk '{print $4}')"
    pausa
}

# e. Usuarios activos en el sistema
usuarios_activos() {
    echo -e "${GREEN}Usuarios activos:${NC}"
    echo "----------------------------------------"
    who
    echo
    echo -e "${GREEN}Usuarios conectados:${NC}"
    echo "----------------------------------------"
    users
    pausa
}

# f. Versión del Kernel del S.O.
version_kernel() {
    echo -e "${GREEN}Información del Sistema:${NC}"
    echo "----------------------------------------"
    echo "Kernel: $(uname -s)"
    echo "Versión: $(uname -r)"
    echo "Arquitectura: $(uname -m)"
    echo "Hostname: $(uname -n)"
    echo
    echo -e "${GREEN}Información de la Distribución:${NC}"
    echo "----------------------------------------"
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        echo "Nombre: $NAME"
        echo "Versión: $VERSION"
        echo "ID: $ID"
    else
        echo "No se pudo obtener información de la distribución"
    fi
    pausa
}

# Función de pausa
pausa() {
    echo
    read -p "Presione Enter para continuar..."
}
