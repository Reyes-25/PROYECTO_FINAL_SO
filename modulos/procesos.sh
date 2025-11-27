#!/bin/bash
# MÓDULO DE PROCESOS
# Desarrollado por: Amir Reyes

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

menu_procesos() {
    while true; do
        clear
        echo -e "${BLUE}"
        echo "=========================================="
        echo "            GESTIÓN DE PROCESOS"
        echo "=========================================="
        echo -e "${NC}"
        echo "a. Revisar los procesos activos"
        echo "b. Eliminar un proceso usando el PID"
        echo "c. Eliminar un proceso usando el nombre"
        echo "d. Listar los X procesos que más memoria consumen"
        echo "e. Ver información detallada de un proceso específico"
        echo "f. Mostrar un proceso en específico por nombre"
        echo "g. Ver procesos de un usuario en específico"
        echo "h. Volver al menú principal"
        echo
        echo -n "Seleccione una opción: "
        read opcion_procesos

        case $opcion_procesos in
            a|A)
                revisar_procesos_activos
                ;;
            b|B)
                eliminar_proceso_pid
                ;;
            c|C)
                eliminar_proceso_nombre
                ;;
            d|D)
                listar_procesos_memoria
                ;;
            e|E)
                info_detallada_proceso
                ;;
            f|F)
                mostrar_proceso_nombre
                ;;
            g|G)
                procesos_usuario
                ;;
            h|H)
                return 0
                ;;
            *)
                echo -e "${RED}Opción inválida. Intente nuevamente.${NC}"
                pausa
                ;;
        esac
    done
}

# a. Revisar los procesos activos
revisar_procesos_activos() {
    echo -e "${GREEN}Procesos activos:${NC}"
    echo "----------------------------------------"
    ps aux --sort=-%cpu | head -20
    pausa
}

# b. Eliminar un proceso usando el PID
eliminar_proceso_pid() {
    echo -n "Ingrese el PID del proceso a eliminar: "
    read pid
    
    if [ -z "$pid" ]; then
        echo -e "${RED}Error: No se ingresó ningún PID${NC}"
    elif ! ps -p "$pid" > /dev/null 2>&1; then
        echo -e "${RED}Error: El proceso con PID $pid no existe${NC}"
    else
        echo -e "${YELLOW}Proceso encontrado:${NC}"
        ps -p "$pid" -o pid,user,comm
        echo -n "¿Está seguro de eliminar este proceso? (s/n): "
        read confirmacion
        if [ "$confirmacion" = "s" ] || [ "$confirmacion" = "S" ]; then
            if kill "$pid" 2>/dev/null; then
                echo -e "${GREEN}Proceso $pid eliminado${NC}"
            else
                echo -e "${RED}Error: No se pudo eliminar el proceso${NC}"
            fi
        else
            echo -e "${YELLOW}Operación cancelada${NC}"
        fi
    fi
    pausa
}

# c. Eliminar un proceso usando el nombre
eliminar_proceso_nombre() {
    echo -n "Ingrese el nombre del proceso a eliminar: "
    read nombre
    
    if [ -z "$nombre" ]; then
        echo -e "${RED}Error: No se ingresó ningún nombre${NC}"
    else
        pids=$(pgrep "$nombre")
        if [ -z "$pids" ]; then
            echo -e "${RED}No se encontraron procesos con el nombre: $nombre${NC}"
        else
            echo -e "${YELLOW}Procesos encontrados:${NC}"
            for pid in $pids; do
                ps -p "$pid" -o pid,user,comm --no-headers
            done
            echo -n "¿Está seguro de eliminar estos procesos? (s/n): "
            read confirmacion
            if [ "$confirmacion" = "s" ] || [ "$confirmacion" = "S" ]; then
                if kill $pids 2>/dev/null; then
                    echo -e "${GREEN}Procesos eliminados${NC}"
                else
                    echo -e "${RED}Error: No se pudieron eliminar algunos procesos${NC}"
                fi
            else
                echo -e "${YELLOW}Operación cancelada${NC}"
            fi
        fi
    fi
    pausa
}

# d. Listar los X procesos que más memoria consumen
listar_procesos_memoria() {
    echo -n "Ingrese la cantidad de procesos a mostrar: "
    read cantidad
    
    if [ -z "$cantidad" ] || ! [[ "$cantidad" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Error: Ingrese un número válido${NC}"
    else
        echo -e "${GREEN}Top $cantidad procesos que más memoria consumen:${NC}"
        echo "----------------------------------------"
        ps aux --sort=-%mem | head -n $(($cantidad + 1))
    fi
    pausa
}

# e. Ver información detallada de un proceso específico
info_detallada_proceso() {
    echo -n "Ingrese el nombre del proceso: "
    read nombre
    
    if [ -z "$nombre" ]; then
        echo -e "${RED}Error: No se ingresó ningún nombre${NC}"
    else
        pid=$(pgrep -o "$nombre")
        if [ -z "$pid" ]; then
            echo -e "${RED}No se encontró el proceso: $nombre${NC}"
        else
            echo -e "${GREEN}Información detallada del proceso (PID: $pid):${NC}"
            echo "----------------------------------------"
            echo "Comando: $(ps -p $pid -o comm --no-headers)"
            echo "Usuario: $(ps -p $pid -o user --no-headers)"
            echo "Estado: $(ps -p $pid -o stat --no-headers)"
            echo "Uso de CPU: $(ps -p $pid -o %cpu --no-headers)%"
            echo "Uso de MEM: $(ps -p $pid -o %mem --no-headers)%"
        fi
    fi
    pausa
}

# f. Mostrar un proceso en específico por nombre
mostrar_proceso_nombre() {
    echo -n "Ingrese el nombre del proceso: "
    read nombre
    
    if [ -z "$nombre" ]; then
        echo -e "${RED}Error: No se ingresó ningún nombre${NC}"
    else
        echo -e "${GREEN}Procesos con nombre '$nombre':${NC}"
        echo "----------------------------------------"
        ps aux | grep -i "$nombre" | grep -v grep
    fi
    pausa
}

# g. Ver procesos de un usuario en específico
procesos_usuario() {
    echo -n "Ingrese el nombre de usuario: "
    read usuario
    
    if [ -z "$usuario" ]; then
        echo -e "${RED}Error: No se ingresó ningún usuario${NC}"
    elif ! id "$usuario" &>/dev/null; then
        echo -e "${RED}Error: El usuario $usuario no existe${NC}"
    else
        echo -e "${GREEN}Procesos del usuario $usuario:${NC}"
        echo "----------------------------------------"
        ps -u "$usuario" -o pid,user,comm,%cpu,%mem
    fi
    pausa
}

# Función de pausa
pausa() {
    echo
    read -p "Presione Enter para continuar..."
}

