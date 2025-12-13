#!/bin/bash

# --- VARIABLES DE COLOR (Modo Daltónico/ Spectre_x46)
turquesa="\e[1;36m"
purpura="\e[1;35m"
azul="\e[1;34m"
reset="\e[0m"

# --- VALIDACIÓN DE SUPERUSUARIO (ROOT) ---
if [ "$(id -u)" != "0" ]; then
   echo -e "${purpura}[!] ERROR: Este script requiere permisos de superusuario.${reset}"
   echo -e "${azul}[*] Por favor, ejecútalo así: sudo $0${reset}"
   exit 1
fi

# 1. Imprimir mensaje de inicio con colores
echo -e "${purpura}[!] Iniciando Protocolo de Modo Monitor...${reset}"


# 2. Detectar la interfaz Automaticamente
# Busca cualquier interfaz que empiece por "wl"
INTERFAZ=$(ip link show | grep wl | awk -F: '{print $2}' | sed 's/ //g' | head -n 1)

# Verificamos si realmente encontró una antena
if [ -z "$INTERFAZ" ]; then
    echo -e "${purpura}[ERROR] No se detectó ninguna antena Wifi USB.${reset}"
    exit 1
fi

echo -e "${turquesa}[+] Interfaz Detectada: $INTERFAZ${reset}"

# 3. Usamos la variable $INTERFAZ que el script encontró solo.
if iwconfig $INTERFAZ | grep -q "Mode:Monitor"; then
    echo -e "${turquesa}[+] La interfaz $INTERFAZ ya está en MODO MONITOR.${reset}"
    echo -e "${purpura}No se requieren cambios. Saliendo...${reset}"
    exit 0
fi
  
# 4. Matar procesos conflictivos (El "Check Kill")
echo -e "${azul}[!] Eliminando procesos conflictivos...${reset}"
airmon-ng check kill > /dev/null 2>&1

# 6. ACTIVACIÓN DE MODO MONITOR 
echo -e "${azul}[*] Activando Modo Monitor en $INTERFAZ...${reset}"

ip link set $INTERFAZ down
iw dev $INTERFAZ set type monitor
ip link set $INTERFAZ up

# --- 7. VERIFICACIÓN FINAL ---
echo -e "${purpura}[+] ¡Listo! Verificando estado:${reset}"
iwconfig $INTERFAZ
