# 📡 Spectre Monitor Mode Script | v2.0 Pro Edition

**Herramienta de auditoría inalámbrica automatizada para Linux**

Este script lleva a la activación del **Modo Monitor** de manera simple y efectiva. Diseñado para chipsets Wi-Fi USB (TP-Link/Realtek), gestiona la transición de modo *Managed* a *Monitor* de forma limpia, robusta y con verificación de inyección.

---

### 🧬 Evolución del Proyecto
Este proyecto ha madurado desde una utilidad básica a una suite de auditoría:

* **v1.0 (Legacy):** Enfoque puramente funcional. Automatizaba `iw` e `ip link` para evitar comandos manuales.
* **v2.0 (Current - Pro Edition):** Reescritura completa del código (Refactor).
    * ✅ **Menú Interactivo:** Selección inteligente de tarjetas si se detectan múltiples interfaces.
    * 💀 **Identidad Spectre:** Banner ASCII, paleta de colores Ciberpunk y *spinners* de carga.
    * 💉 **Injection Test:** Verificación real de capacidad de ataque (`aireplay-ng --test`) integrada en el flujo.
    * 🛡️ **Robustez:** Validación de dependencias y manejo de errores mejorado.

> **Nota de Atribución:** Código base **V2.0** generado por IA (Antigravity), refactorizado, diseñado y perfeccionado por **Spectre_x46** para uso profesional.

---

## 🚀 Características Principales

- **Detección & Selección:** Ya no es "ciego". Si tienes más de una tarjeta, tú eliges cuál activar mediante un menú interactivo que muestra el driver.
- **Ejecución Segura:** Validación de permisos Root y limpieza quirúrgica de procesos conflictivos (`airmon-ng check kill`) antes de empezar.
- **Feedback Visual (UX):** Olvídate de la terminal congelada. Indicadores de progreso y códigos de color para estado (Éxito/Fallo/Alerta).
- **Lógica Idempotente:** Si la antena ya está en modo monitor, el script lo detecta y ofrece verificar la inyección en lugar de reiniciar la conexión.

---

## 🛠️ Instalación y Uso

### 1. Clonar el repositorio
Descarga la última versión estable (v2.0):

```bash
git clone https://github.com/Spectre-x46/tplink-monitor-mode.git
```

2. Preparar el entorno
Entra en la carpeta. Si clonaste con Git, los permisos deberían estar listos, pero aseguramos:

```Bash
cd tplink-monitor-mode
chmod +x auto-mon.sh
```

3. Ejecutar (Pro Mode)
Inicia la herramienta con privilegios de superusuario:

```Bash
sudo ./auto-mon.sh
```

---
  
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
