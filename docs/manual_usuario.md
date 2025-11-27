# Manual de Desarrollo - Dev 1 (Amir Reyes)
## Módulos 1, 2 y Librería de Compatibilidad

---

## 📁 ESTRUCTURA DESARROLLADA

### **Scripts Principales Creados:**
- `consola_operaciones.sh` - **Script principal del sistema**
- `modulos/procesos.sh` - **Módulo completo de gestión de procesos**
- `modulos/informacion_general.sh` - **Módulo de información del sistema**
- `lib/compatibilidad.sh` - **Librería de compatibilidad multiplataforma**

---

## 🔧 MÓDULO 1: PROCESOS (`modulos/procesos.sh`)

### **Funciones Implementadas:**

#### **1. `menu_procesos()`**
- **Propósito**: Menú principal del módulo de procesos
- **Características**: 
  - Interfaz con colores
  - Navegación circular (siempre vuelve al menú)
  - Opción de retorno al menú principal

#### **2. `revisar_procesos_activos()`**
```bash
# Función: Muestra los 20 procesos más activos por CPU
ps aux --sort=-%cpu | head -20

