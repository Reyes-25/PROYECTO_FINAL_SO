# Manual de Usuario – Consola de Operaciones
Proyecto Final – Sistemas Operativos  
Autores: **Amir Reyes, Hector Ortega y Eric Cedeño**

---

## 1. Introducción  
La **Consola de Operaciones** es una herramienta en Bash diseñada para facilitar tareas básicas de administración en Linux.  
Permite gestionar procesos, usuarios, directorios y obtener información clave del sistema.

---

## 2. Requisitos del Sistema
- Linux, WSL2 o máquina virtual  
- Bash 5+  
- Permisos de superusuario para operaciones de seguridad  

---

## 3. Instalación
```bash
git clone https://github.com/Reyes-25/PROYECTO_FINAL_SO.git
cd PROYECTO_FINAL_SO
chmod +x *.sh modulos/*.sh lib/*.sh
```

---

## 4. Ejecución
Ejecutar la consola principal:

```bash
./consola_operaciones.sh
```

---

## 5. Menú Principal  
Al iniciar el script, verás:

```
===== CONSOLA DE OPERACIONES =====
1. Procesos  
2. Información General  
3. Archivos y Directorios  
4. Seguridad  
5. Salir
```

Selecciona la opción deseada ingresando el número.

---

## 6. Módulos del Sistema

### 6.1 Módulo de Procesos
Permite:
- Listar procesos activos  
- Buscar procesos  
- Ver procesos por usuario  
- Terminar procesos por PID o nombre  
- Ver procesos que consumen más recursos  

**Comando interno usado:** `ps`, `top`, `kill`, `pgrep`

---

### 6.2 Módulo de Información General
Permite obtener:
- Uso del disco  
- Memoria RAM disponible  
- Información del kernel  
- Usuarios conectados  
- Espacio usado por directorios  

**Comandos usados:** `df`, `du`, `free`, `uname`, `who`

---

### 6.3 Módulo de Archivos y Directorios
Incluye:
- Crear archivos y carpetas  
- Copiar y mover elementos  
- Cambiar permisos  
- Listar contenido  
- Buscar archivos por nombre  

**Comandos usados:** `ls`, `cp`, `mv`, `chmod`, `find`

---

### 6.4 Módulo de Seguridad
Permite:
- Crear usuarios  
- Modificar información (GECOS)  
- Cambiar contraseña  
- Eliminar usuarios  
- Gestionar grupos  
- Ver permisos y dueños  

**Comandos usados:** `useradd`, `usermod`, `passwd`, `groupadd`, `chown`

---

## 7. Flujo de Uso
1. Ejecutar la consola  
2. Elegir un módulo  
3. Seguir instrucciones en pantalla  
4. Escribir `enter` para volver al menú  

---

## 8. Recomendaciones
- No eliminar usuarios del sistema principal  
- Usar rutas absolutas cuando sea posible  
- Leer bien los mensajes de confirmación  

---

## 9. Créditos
Proyecto realizado por **Amir Reyes, Hector Ortega y Eric Cedeño**  
Universidad Tecnológica de Panamá  
2025

