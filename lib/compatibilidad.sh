#!/bin/bash
# LIBRERÍA DE COMPATIBILIDAD
# Para WSL2, Linux Nativo y VirtualBox
# Desarrollado por: Amir Reyes

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Detectar entorno
detectar_entorno() {
    if grep -q "Microsoft\|WSL2" /proc/version 2>/dev/null; then
        echo "wsl2"
    elif [ -f /etc/os-release ]; then
        source /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Función universal para obtener información de procesos
obtener_procesos() {
    local cantidad=$1
    ps aux --sort=-%mem 2>/dev/null | head -n $((cantidad + 1)) || \
    ps -eo pid,user,comm,%mem --sort=-%mem 2>/dev/null | head -n $((cantidad + 1))
}

# Función universal para espacio en disco
obtener_espacio_disco() {
    df -h 2>/dev/null || \
    df -k 2>/dev/null
}

# Función universal para memoria
obtener_memoria() {
    free -h 2>/dev/null || \
    free -m 2>/dev/null
}

# Función universal para usuarios activos
obtener_usuarios_activos() {
    who 2>/dev/null || \
    users 2>/dev/null || \
    echo "No se pudo obtener información de usuarios"
}

# Verificar dependencias
verificar_dependencias() {
    local comandos=("ps" "df" "free" "who" "ls" "mkdir" "rm" "cp" "mv" "kill" "grep")
    local faltantes=()
    
    for cmd in "${comandos[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            faltantes+=("$cmd")
        fi
    done
    
    if [ ${#faltantes[@]} -ne 0 ]; then
        echo -e "${YELLOW}Advertencia: Comandos faltantes: ${faltantes[*]}${NC}"
        return 1
    fi
    echo -e "${GREEN}✓ Todos los comandos esenciales disponibles${NC}"
    return 0
}

# Función para pausa
pausa() {
    echo
    read -p "Presione Enter para continuar..."
}

# Mostrar información del sistema
mostrar_info_sistema() {
    local entorno=$(detectar_entorno)
    echo -e "${CYAN}=== INFORMACIÓN DEL SISTEMA ===${NC}"
    echo "Entorno: $entorno"
    echo "Kernel: $(uname -r)"
    echo "Sistema: $(uname -s)"
    echo "Arquitectura: $(uname -m)"
    
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        echo "Distribución: $PRETTY_NAME"
    fi
    echo
}

