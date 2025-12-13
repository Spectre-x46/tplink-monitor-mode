# 📡 TP-Link Monitor Mode Script
Script en Bash automatizado para activar el **Modo Monitor** en tarjetas de red Wi-Fi USB (especialmente chipsets TP-Link/Realtek) en entornos Linux como **Parrot Security** o **Kali Linux**.

Este script utiliza herramientas nativas (`iw`, `ip link`) para realizar la transición de modo Managed a Monitor de forma limpia, evitando conflictos y asegurando que la interfaz mantenga su estabilidad.

## 🚀 Características

- ✅ **Detección Automática:** Identifica tu tarjeta Wi-Fi USB sin necesidad de editar el código manualmente.
- 🛡️ **Ejecución Segura:** Incluye validación de permisos Root y limpieza automática de procesos conflictivos (`airmon-ng check kill`).
- 🎨 **Interfaz Visual:** Feedback en tiempo real con código de colores para facilitar la lectura del estado.
- 🔧 **Lógica Idempotente:** Si la antena ya está en modo monitor, el script lo detecta y no interrumpe la conexión innecesariamente.

---

### 1. Clonar el repositorio
Abre tu terminal y descarga la herramienta:

```bash
git clone https://github.com/Spectre-x46/tplink-monitor-mode.git
```
   
### 2. Dar permisos de ejecución
Entra en la carpeta descargada y habilita el script:
```bash
cd tplink-monitor-mode
chmod +x auto-mon.sh
```

### 3. Ejecutar
Inicia el script con privilegios de superusuario:
```bash
sudo ./auto-mon.sh
```
  
## ⚠️ Solución de Problemas (VMware)

**¿La máquina virtual no detecta tu antena USB?**
Si al intentar conectar la antena desde el menú VM > Removable Devices no ocurre nada, o la antena no aparece al escribir lsusb o iwconfig en Parrot/Kali, es casi seguro que el servicio de arbitraje de VMware se ha bloqueado en tu sistema anfitrión (Windows).

**Sigue estos pasos quirúrgicos en tu WINDOWS anfitrión:**

1. Presiona Win + R en tu teclado.

2. Escribe services.msc y pulsa Enter.

3. En la lista de servicios, busca: VMware USB Arbitration Service.

**Diagnóstico y Solución:**

🔴 **Si está detenido o Deshabilitado:** 
1. Haz clic derecho > **Propiedades.**
2. En "Tipo de inicio", selecciona: **Automático.**
3. Haz clic en **Iniciar > Aplicar > Aceptar.**

🟡 **Si dice "En ejecución":** 
1. Haz clic derecho > **Reiniciar**. Contexto: A veces el servicio se bloquea internamente ("zombie state") aunque Windows diga que está corriendo. Reiniciarlo fuerza la reconexión de los drivers USB.
   
**Nota Crítica:** Si tras realizar estos pasos la antena sigue sin conectar, reinicia tu PC anfitrión (Windows) completamente. Esto obligará a VMware a cargar los controladores USB desde cero al arrancar.

---

**⚖️ Disclaimer**
Esta herramienta ha sido creada con fines educativos y de aprendizaje en ciberseguridad. El usuario es responsable de su uso en redes propias o autorizadas.
