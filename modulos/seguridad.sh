#!/bin/bash
# MÓDULO DE SEGURIDAD
# Desarrollado por: Eric Cedeño

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Verifica si el comando requiere root; intenta usar sudo si no es root
run_priv() {
    if [ "$(id -u)" -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}

menu_seguridad() {
    while true; do
        clear
        echo -e "${BLUE}"
        echo "=========================================="
        echo "               SEGURIDAD"
        echo "=========================================="
        echo -e "${NC}"
        echo "a) Crear grupo"
        echo "b) Eliminar grupo"
        echo "c) Crear usuario"
        echo "d) Cambiar propiedades (GECOS) de usuario"
        echo "e) Cambiar usuarios de grupo (añadir/quitar)"
        echo "f) Eliminar usuario"
        echo "g) Cambiar contraseña de usuario"
        echo "h) Otorgar permisos sobre archivo/directorio (chmod/chown)"
        echo "i) Revocar permisos sobre archivo/directorio (chmod)"
        echo "j) Cambiar el dueño de un archivo o directorio (chown)"
        echo "k) Volver al menú principal"
        echo
        echo -n "Seleccione una opción: "
        read -r opcion_seg

        case $opcion_seg in
            a|A) crear_grupo ;;
            b|B) eliminar_grupo ;;
            c|C) crear_usuario ;;
            d|D) cambiar_gecos ;;
            e|E) cambiar_grupo_usuario ;;
            f|F) eliminar_usuario ;;
            g|G) cambiar_password ;;
            h|H) otorgar_permisos ;;
            i|I) revocar_permisos ;;
            j|J) cambiar_dueno ;;
            k|K) return 0 ;;
            *) echo -e "${RED}Opción inválida.${NC}"; pausa ;;
        esac
    done
}

crear_grupo() {
    echo -n "Nombre del nuevo grupo: "
    read -r grupo
    if [ -z "$grupo" ]; then
        echo -e "${RED}Nombre vacío.${NC}"
    else
        if getent group "$grupo" >/dev/null; then
            echo -e "${YELLOW}El grupo ya existe: $grupo${NC}"
        else
            run_priv groupadd "$grupo" && echo -e "${GREEN}Grupo creado: $grupo${NC}" || echo -e "${RED}Error creando grupo.${NC}"
        fi
    fi
    pausa
}

eliminar_grupo() {
    echo -n "Nombre del grupo a eliminar: "
    read -r grupo
    
    # Verificar si el grupo existe
    if ! getent group "$grupo" >/dev/null; then
        echo -e "${RED}El grupo '$grupo' no existe${NC}"
        pausa
        return
    fi
    
    # Lista de grupos críticos del sistema que NO se deben eliminar
    grupos_criticos=("root" "sudo" "adm" "wheel" "daemon" "bin" "sys" "tty" "disk" "lp" "mail" "news" "uucp" 
                    "man" "proxy" "kmem" "dialout" "fax" "voice" "cdrom" "floppy" "tape" "audio" "dip" 
                    "www-data" "backup" "operator" "list" "irc" "src" "gnats" "shadow" "utmp" "video" 
                    "sasl" "plugdev" "staff" "games" "users" "nogroup" "systemd-journal" "systemd-timesync"
                    "ssh" "ssl-cert" "lpadmin" "scanner" "kvm" "libvirtd" "docker" "mysql" "postgres"
                    "redis" "mongodb" "rabbitmq" "nginx" "apache" "www" "ftp" "samba" "nobody")
    
    # Verificar si es un grupo crítico
    for critico in "${grupos_criticos[@]}"; do
        if [ "$grupo" = "$critico" ]; then
            echo -e "${RED}¡ADVERTENCIA DE SEGURIDAD!${NC}"
            echo -e "${YELLOW}'$grupo' es un grupo crítico del sistema${NC}"
            echo -e "${YELLOW}Eliminarlo podría causar problemas graves en el sistema${NC}"
            echo -n "¿Está ABSOLUTAMENTE seguro de querer continuar? (s/n): "
            read -r confirmacion_critica
            if [[ ! "$confirmacion_critica" =~ ^[sS]$ ]]; then
                echo -e "${GREEN}Operación cancelada. Es más seguro mantener grupos del sistema.${NC}"
                pausa
                return
            fi
            break
        fi
    done
    
    # Verificar si el grupo tiene usuarios
    usuarios_en_grupo=$(getent group "$grupo" | cut -d: -f4)
    if [ -n "$usuarios_en_grupo" ]; then
        echo -e "${YELLOW}Advertencia: El grupo '$grupo' tiene los siguientes usuarios:${NC}"
        echo -e "${YELLOW}$usuarios_en_grupo${NC}"
        echo -e "${CYAN}Opciones disponibles:${NC}"
        echo "1) Eliminar el grupo de todos modos (los usuarios perderán acceso)"
        echo "2) Vaciar el grupo primero (remover todos los usuarios)"
        echo "3) Cancelar la operación"
        echo -n "Seleccione una opción (1-3): "
        read -r opcion_usuarios
        
        case $opcion_usuarios in
            1)
                echo -n "¿Confirmar eliminación del grupo con usuarios? (s/n): "
                read -r confirma1
                [[ "$confirma1" =~ ^[sS]$ ]] || return
                ;;
            2)
                echo -e "${CYAN}Vaciando el grupo '$grupo'...${NC}"
                # Remover todos los usuarios del grupo
                for usuario in $(echo "$usuarios_en_grupo" | tr ',' ' '); do
                    run_priv gpasswd -d "$usuario" "$grupo" 2>/dev/null && \
                    echo -e "${GREEN}Usuario '$usuario' removido del grupo${NC}" || \
                    echo -e "${YELLOW}No se pudo remover '$usuario' del grupo${NC}"
                done
                echo -e "${GREEN}Grupo vaciado. Procediendo con eliminación...${NC}"
                ;;
            3)
                echo -e "${GREEN}Operación cancelada${NC}"
                pausa
                return
                ;;
            *)
                echo -e "${RED}Opción inválida${NC}"
                pausa
                return
                ;;
        esac
    fi
    
    # Verificar si es grupo primario de algún usuario
    usuarios_grupo_primario=$(getent passwd | cut -d: -f1,4 | grep ":$grupo$" | cut -d: -f1 | tr '\n' ' ')
    if [ -n "$usuarios_grupo_primario" ]; then
        echo -e "${RED}¡ADVERTENCIA!${NC}"
        echo -e "${YELLOW}El grupo '$grupo' es grupo primario de los siguientes usuarios:${NC}"
        echo -e "${YELLOW}$usuarios_grupo_primario${NC}"
        echo -e "${YELLOW}No se puede eliminar un grupo que es grupo primario de usuarios${NC}"
        echo -e "${CYAN}Sugerencias:${NC}"
        echo "1) Cambiar el grupo primario de esos usuarios primero"
        echo "2) Eliminar o modificar los usuarios"
        pausa
        return
    fi
    
    # Confirmación final
    echo -e "${YELLOW}¿ESTÁ SEGURO de que desea eliminar permanentemente el grupo '$grupo'?${NC}"
    echo -e "${YELLOW}Esta acción NO se puede deshacer${NC}"
    echo -n "Escriba 'ELIMINAR' para confirmar: "
    read -r confirmacion_final
    
    if [ "$confirmacion_final" = "ELIMINAR" ]; then
        if run_priv groupdel "$grupo" 2>/dev/null; then
            echo -e "${GREEN}Grupo '$grupo' eliminado correctamente${NC}"
        else
            echo -e "${RED}Error al eliminar el grupo '$grupo'${NC}"
            echo -e "${YELLOW}Posibles causas:${NC}"
            echo "- El grupo no existe"
            echo "- Es grupo primario de algún usuario (verificado arriba)"
            echo "- No tiene permisos suficientes"
            echo "- Hay archivos/directorios que usan este grupo como grupo principal"
        fi
    else
        echo -e "${GREEN}Operación cancelada${NC}"
    fi
    pausa
}

crear_usuario() {
    echo -n "Nombre de usuario (login): "
    read -r user
    if [ -z "$user" ]; then
        echo -e "${RED}Usuario vacío.${NC}"
        pausa
        return
    fi

    if id "$user" &>/dev/null; then
        echo -e "${YELLOW}El usuario ya existe: $user${NC}"
        pausa
        return
    fi

    echo -n "Nombre completo (GECOS - Nombre): "
    read -r fullname
    echo -n "Número de oficina: "
    read -r office
    echo -n "Teléfono casa: "
    read -r phone
    # GECOS: Full Name,RoomNumber,WorkPhone,HomePhone
    gecos_field="${fullname},${office},${phone},"
    echo -n "¿Crear directorio home? (s/n): "
    read -r crear_home
    if [[ "$crear_home" =~ ^[sS]$ ]]; then
        run_priv useradd -m -c "$gecos_field" "$user" && echo -e "${GREEN}Usuario creado con home: $user${NC}" || echo -e "${RED}Error creando usuario.${NC}"
    else
        run_priv useradd -c "$gecos_field" "$user" && echo -e "${GREEN}Usuario creado: $user${NC}" || echo -e "${RED}Error creando usuario.${NC}"
    fi
    # Opcional: establecer contraseña ahora
    echo -n "¿Establecer contraseña ahora? (s/n): "
    read -r confpw
    if [[ "$confpw" =~ ^[sS]$ ]]; then
        echo "Estableciendo contraseña para $user. Se le pedirá al administrador la nueva contraseña."
        run_priv passwd "$user"
    fi
    pausa
}

cambiar_gecos() {
    echo -n "Usuario a modificar: "
    read -r user
    if ! id "$user" &>/dev/null; then
        echo -e "${RED}Usuario no existe: $user${NC}"
        pausa
        return
    fi
    echo -n "Nuevo nombre completo: "
    read -r fullname
    echo -n "Número oficina: "
    read -r office
    echo -n "Teléfono casa: "
    read -r phone
    gecos_field="${fullname},${office},${phone},"
    run_priv usermod -c "$gecos_field" "$user" && echo -e "${GREEN}GECOS actualizado para $user${NC}" || echo -e "${RED}Error actualizando GECOS.${NC}"
    pausa
}

cambiar_grupo_usuario() {
    echo -n "Usuario a modificar: "
    read -r user
    if ! id "$user" &>/dev/null; then
        echo -e "${RED}Usuario no existe: $user${NC}"
        pausa
        return
    fi
    echo "1) Cambiar grupo primario"
    echo "2) Añadir grupo suplementario (append)"
    echo "3) Reemplazar grupos suplementarios"
    echo -n "Seleccione opción: "
    read -r opt
    case $opt in
        1)
            echo -n "Grupo primario destino: "
            read -r g
            run_priv usermod -g "$g" "$user" && echo -e "${GREEN}Grupo primario cambiado.${NC}" || echo -e "${RED}Error.${NC}"
            ;;
        2)
            echo -n "Grupo a añadir (suplementario): "
            read -r g2
            run_priv usermod -a -G "$g2" "$user" && echo -e "${GREEN}Grupo añadido al usuario.${NC}" || echo -e "${RED}Error.${NC}"
            ;;
        3)
            echo -n "Lista de grupos (separados por coma): "
            read -r lista
            run_priv usermod -G "$lista" "$user" && echo -e "${GREEN}Grupos suplementarios reemplazados.${NC}" || echo -e "${RED}Error.${NC}"
            ;;
        *)
            echo -e "${RED}Opción inválida.${NC}"
            ;;
    esac
    pausa
}

eliminar_usuario() {
    echo -n "Usuario a eliminar: "
    read -r user
    if ! id "$user" &>/dev/null; then
        echo -e "${RED}Usuario no existe: $user${NC}"
        pausa
        return
    fi
    echo -n "Eliminar home también? (s/n): "
    read -r conf
    if [[ "$conf" =~ ^[sS]$ ]]; then
        run_priv userdel -r "$user" && echo -e "${GREEN}Usuario y home eliminados: $user${NC}" || echo -e "${RED}Error eliminando usuario.${NC}"
    else
        run_priv userdel "$user" && echo -e "${GREEN}Usuario eliminado: $user${NC}" || echo -e "${RED}Error eliminando usuario.${NC}"
    fi
    pausa
}

cambiar_password() {
    echo -n "Usuario para cambiar contraseña (Enter = actual): "
    read -r user
    [ -z "$user" ] && user="$USER"
    if ! id "$user" &>/dev/null; then
        echo -e "${RED}Usuario no existe: $user${NC}"
        pausa
        return
    fi
    echo -e "${YELLOW}Se abrirá el prompt de passwd para establecer la nueva contraseña.${NC}"
    run_priv passwd "$user"
    pausa
}

otorgar_permisos() {
    echo -n "Ruta archivo/directorio: "
    read -r ruta
    if [ ! -e "$ruta" ]; then
        echo -e "${RED}No existe: $ruta${NC}"
        pausa
        return
    fi
    echo "1) Cambiar permisos numéricos (chmod 644)"
    echo "2) Añadir permisos simbólicos (u+rwx,g+rx,...)"
    echo -n "Seleccione opción: "
    read -r o
    case $o in
        1)
            echo -n "Permisos numéricos (ej. 755): "
            read -r p
            run_priv chmod "$p" "$ruta" && echo -e "${GREEN}Permisos establecidos.${NC}" || echo -e "${RED}Error.${NC}"
            ;;
        2)
            echo -n "Permisos simbólicos (ej. u+rwx,g-w): "
            read -r p2
            run_priv chmod "$p2" "$ruta" && echo -e "${GREEN}Permisos simbólicos aplicados.${NC}" || echo -e "${RED}Error.${NC}"
            ;;
        *)
            echo -e "${RED}Opción inválida.${NC}"
            ;;
    esac
    pausa
}

revocar_permisos() {
    echo -n "Ruta archivo/directorio: "
    read -r ruta
    if [ ! -e "$ruta" ]; then
        echo -e "${RED}No existe: $ruta${NC}"
        pausa
        return
    fi
    echo -n "Permisos a revocar (ej. g+w,u+x): "
    read -r p
    # Para revocar se aplica chmod con -, por ejemplo chmod g-w
    run_priv chmod "$p" "$ruta" && echo -e "${GREEN}Permisos revocados.${NC}" || echo -e "${RED}Error.${NC}"
    pausa
}

cambiar_dueno() {
    echo -n "Ruta archivo/directorio: "
    read -r ruta
    if [ ! -e "$ruta" ]; then
        echo -e "${RED}No existe: $ruta${NC}"
        pausa
        return
    fi
    echo -n "Nuevo dueño (user[:group], si solo user deja group vacío): "
    read -r ug
    if [ -z "$ug" ]; then
        echo -e "${RED}Debe indicar el nuevo dueño.${NC}"
    else
        run_priv chown "$ug" "$ruta" && echo -e "${GREEN}Dueño actualizado: $ruta -> $ug${NC}" || echo -e "${RED}Error cambiando dueño.${NC}"
    fi
    pausa
}

pausa() {
    echo
    read -p "Presione Enter para continuar..."
}
