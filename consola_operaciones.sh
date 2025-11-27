#!/bin/bash
# CONSOLA DE OPERACIONES - EMPRESA XYZ
# Proyecto Final de Sistemas Operativos

# Colores para la interfaz
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Cargar módulos de Dev 1 (Amir Reyes)
source "modulos/procesos.sh"
source "modulos/informacion_general.sh"
source "lib/compatibilidad.sh"

mostrar_header() {
    clear
    echo -e "${BLUE}"
    echo "=========================================="
    echo "      CONSOLA DE OPERACIONES"
    echo "           EMPRESA XYZ"
    echo "=========================================="
    echo -e "${NC}"
}

mostrar_menu_principal() {
    mostrar_header
    echo "1. Procesos"
    echo "2. Información General"
    echo "3. Archivos-Directorios"
    echo "4. Seguridad"
    echo "5. Salir"
    echo
    echo -n "Seleccione una opción del Menú: "
}

pausa() {
    echo
    read -p "Presione Enter para continuar..."
}

main() {
    while true; do
        mostrar_menu_principal
        read opcion
        
        case $opcion in
            1)
                menu_procesos
                ;;
            2)
                menu_informacion_general
                ;;
            3)
                echo -e "${YELLOW}Módulo Archivos-Directorios${NC}"
                echo "👤 Asignado a: Hector Ortega"
                echo "⏰ Estado: Pendiente"
                pausa
                ;;
            4)
                echo -e "${YELLOW}Módulo Seguridad${NC}"
                echo "👤 Asignado a: Eric Cedeño"
                echo "⏰ Estado: Pendiente"
                pausa
                ;;
            5)
                echo -e "${GREEN}Saliendo del sistema...${NC}"
                echo -e "${CYAN}¡Hasta pronto!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opción inválida. Intente nuevamente.${NC}"
                pausa
                ;;
        esac
    done
}

# Mensaje de inicio
echo -e "${CYAN}Iniciando Consola de Operaciones...${NC}"
sleep 1

# Iniciar programa
main

