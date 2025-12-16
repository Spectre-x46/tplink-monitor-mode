#!/bin/bash

# ==============================================================================
#      SPECTRE MONITOR MODE | PRO EDITION
#  v2.0 | High-Performance Wireless Auditing Tool
# ==============================================================================
# ATRIBUCIÓN DEL CÓDIGO:
# El núcleo funcional y diseño de la V2.0 fue generado inicialmente por una 
# IA (Antigravity), y posteriormente modificado, pulido y adaptado por 
# Spectre_x46 para incluir el menú de selección, el spinner y el test de inyección.
# Autor original de la idea y refinamiento: Spectre_x46.
# ------------------------------------------------------------------------------

# --- [ PALETA SPECTRE PRO ] ---
COLOR_MAIN="\e[38;5;51m"      # Cyan Neon (Tron UI)
COLOR_SUB="\e[38;5;39m"       # Deep Sky Blue (Texto secundario)
COLOR_INFO="\e[38;5;153m"     # Light Blue Grey (Datos técnicos)
COLOR_ACCENT="\e[38;5;214m"   # Gold / Orange (Alertas visuales)
COLOR_DANGER="\e[38;5;202m"   # Orange Red (Errores críticos)
COLOR_SUCCESS="\e[38;5;48m"   # Spring Green (Éxito operación)
COLOR_MUTED="\e[38;5;240m"    # Dark Grey (Comentarios/Bordes)
RESET="\e[0m"

# --- [ FUNCIONES VISUALES ] ---

function spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    tput civis # Ocultar cursor
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
    tput cnorm # Restaurar cursor
}

                                                                                          
function print_banner() {
    clear
    echo -e "${COLOR_MAIN}"
    echo "  ███████╗██████╗ ███████╗ ██████╗████████╗██████╗ ███████╗        ██╗  ██╗██╗  ██╗ ██████╗ "
    echo "  ██╔════╝██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔══██╗██╔════╝        ╚██╗██╔╝██║  ██║██╔════╝ "
    echo "  ███████╗██████╔╝█████╗  ██║        ██║   ██████╔╝█████╗           ╚███╔╝ ███████║███████╗ "
    echo "  ╚════██║██╔═══╝ ██╔══╝  ██║        ██║   ██╔══██╗██╔══╝           ██╔██╗ ╚════██║██╔═══██╗"
    echo "  ███████║██║     ███████╗╚██████╗   ██║   ██║  ██║███████╗███████╗██╔╝ ██╗     ██║╚██████╔╝"
    echo "  ╚══════╝╚═╝     ╚══════╝ ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝     ╚═╝ ╚═════╝ "
    echo -e "${COLOR_ACCENT}      >>> MONITOR MODE ACTIVATOR | v2.0 PRO EDITION <<<"
    echo -e "${COLOR_MUTED}  =========================================================${RESET}"
    echo ""
}

# --- [ VERIFICACIONES INICIALES ] ---

print_banner

# 1. Validación ROOT
if [ "$(id -u)" != "0" ]; then
    echo -e "${COLOR_DANGER}  [✖] ERROR FATAL: Acceso Denegado.${RESET}"
    echo -e "${COLOR_INFO}      Este protocolo requiere privilegios de SUPERUSUARIO.${RESET}"
    echo -e "${COLOR_ACCENT}      >>> Ejecuta: sudo $0${RESET}"
    echo ""
    exit 1
fi

# 2. Verificar dependencias
echo -e "${COLOR_MAIN}  [*] Iniciando escaneo de sistema...${RESET}"
dependencies=(iw ip airmon-ng aireplay-ng)
for dep in "${dependencies[@]}"; do
    if ! command -v $dep &> /dev/null; then
        echo -e "${COLOR_DANGER}      [!] Herramienta no encontrada: $dep${RESET}"
        echo -e "${COLOR_INFO}      Instala aircrack-ng e iproute2.${RESET}"
        exit 1
    fi
done
sleep 0.5

# --- [ DETECCIÓN DE INTERFAZ ] ---

echo -e "${COLOR_MAIN}  [*] Buscando adaptadores inalámbricos...${RESET}"

INTERFACES=$(iw dev | grep Interface | awk '{print $2}')
NUM_INTERFACES=$(echo "$INTERFACES" | wc -l)

if [ -z "$INTERFACES" ]; then
    echo -e "${COLOR_DANGER}  [✖] ERROR: No se detectaron interfaces inalámbricas.${RESET}"
    echo -e "${COLOR_MUTED}      Verifica tu adaptador USB.${RESET}"
    exit 1
fi

TARGET_IFACE=""

if [ "$NUM_INTERFACES" -eq 1 ]; then
    # Solo una interfaz, selección automática
    TARGET_IFACE=$INTERFACES
    echo -e "${COLOR_SUCCESS}  [✓] Interfaz única detectada: ${COLOR_ACCENT}$TARGET_IFACE${RESET}"
else
    # Múltiples interfaces, MENÚ DE SELECCIÓN OBLIGATORIO
    echo -e "${COLOR_ACCENT}  [!] Múltiples interfaces detectadas. SELECCIÓN MANUAL REQUERIDA.${RESET}"
    echo -e "${COLOR_MUTED}      --------------------------------------------------${RESET}"
    
    # Crear array de interfaces
    IFACE_ARRAY=($INTERFACES)
    i=0
    for iface in "${IFACE_ARRAY[@]}"; do
        DRIVER=$(ethtool -i $iface 2>/dev/null | grep driver | awk '{print $2}')
        echo -e "      ${COLOR_MAIN}[$i]${RESET} ${COLOR_SUB}$iface${RESET} ${COLOR_MUTED}(Driver: $DRIVER)${RESET}"
        ((i++))
    done
    echo -e "${COLOR_MUTED}      --------------------------------------------------${RESET}"
    
    # Bucle de selección
    while true; do
        echo -ne "${COLOR_ACCENT}  >>> Selecciona el número de tu interfaz USB [0-$(($i-1))]: ${RESET}"
        read -r SELECTION
        if [[ "$SELECTION" =~ ^[0-9]+$ ]] && [ "$SELECTION" -ge 0 ] && [ "$SELECTION" -lt "$i" ]; then
            TARGET_IFACE=${IFACE_ARRAY[$SELECTION]}
            echo -e "${COLOR_SUCCESS}  [✓] Seleccionado: ${COLOR_MAIN}$TARGET_IFACE${RESET}"
            break
        else
            echo -e "${COLOR_DANGER}  [✖] Selección inválida. Intenta de nuevo.${RESET}"
        fi
    done
fi

# Verificación inicial de estado
CURRENT_MODE=$(iw dev $TARGET_IFACE info | grep type | awk '{print $2}')
if [ "$CURRENT_MODE" == "monitor" ]; then
    echo -e "${COLOR_SUCCESS}  [✓] La interfaz $TARGET_IFACE YA está en modo MONITOR.${RESET}"
    # No salimos aquí, queremos dar la opción de continuar al test de inyección si el usuario quiere,
    # pero para simplicidad, asumimos que si ya está en monitor, quizá quiere resetearla o probarla.
    # Por ahora seguimos el flujo para asegurar limpieza, o saltamos al test.
    echo -e "${COLOR_INFO}      Saltando activación, procediendo a verificación...${RESET}"
else
    # --- [ EJECUCIÓN DEL PROTOCOLO ] ---
    echo ""
    echo -e "${COLOR_SUB}  >>> PREPARANDO ENTORNO DE COMBATE...${RESET}"

    # 1. Kill Check
    echo -ne "${COLOR_INFO}  [*] Neutralizando procesos conflictivos (airmon-ng)... ${RESET}"
    airmon-ng check kill > /dev/null 2>&1 &
    spinner $!
    echo -e "${COLOR_SUCCESS} [NEUTRALIZADO]${RESET}"

    # 2. Down
    echo -ne "${COLOR_INFO}  [*] Desactivando interfaz ${COLOR_SUB}$TARGET_IFACE${COLOR_INFO}... ${RESET}"
    ip link set $TARGET_IFACE down &
    spinner $!
    echo -e "${COLOR_SUCCESS} [DOWN]${RESET}"

    # 3. Change Mode
    echo -ne "${COLOR_INFO}  [*] Estableciendo modo MONITOR... ${RESET}"
    iw dev $TARGET_IFACE set type monitor &
    spinner $!
    echo -e "${COLOR_SUCCESS} [OK]${RESET}"

    # 4. Up
    echo -ne "${COLOR_INFO}  [*] Reactivando interfaz... ${RESET}"
    ip link set $TARGET_IFACE up &
    spinner $!
    echo -e "${COLOR_SUCCESS} [UP]${RESET}"
fi

echo ""

# --- [ VERIFICACIÓN FINAL & INYECCIÓN ] ---

FINAL_MODE=$(iw dev $TARGET_IFACE info | grep type | awk '{print $2}')

if [ "$FINAL_MODE" != "monitor" ]; then
    echo -e "${COLOR_DANGER}  [✖] FALLO CRÍTICO: La interfaz no entró en modo monitor.${RESET}"
    echo -e "${COLOR_MUTED}  Estado actual: $FINAL_MODE${RESET}"
    exit 1
fi

echo -e "${COLOR_MAIN}  [*] Iniciando PRUEBA DE FUEGO (Injection Test)...${RESET}"
echo -e "${COLOR_MUTED}  (Esto verificará si tu tarjeta realmente puede atacar)${RESET}"
echo ""

# Ejecutar aireplay-ng --test
# Usamos un timeout por si se queda colgado buscando APs
timeout 10s aireplay-ng --test $TARGET_IFACE > /tmp/injection_test.log 2>&1 &
PID_TEST=$!
spinner $PID_TEST

# Verificar resultado del log
if grep -q "Injection is working" /tmp/injection_test.log; then
    INJECTION_STATUS="${COLOR_SUCCESS}CONFIRMADO (Injection is working!)${RESET}"
    IS_SUCCESS=true
else
    INJECTION_STATUS="${COLOR_DANGER}FALLIDO (No se detectó inyección)${RESET}"
    IS_SUCCESS=false
    # Mostrar ultimas lineas del error
    echo -e "${COLOR_DANGER}  [!] Error output:${RESET}"
    tail -n 3 /tmp/injection_test.log
fi

rm /tmp/injection_test.log

echo ""
if [ "$IS_SUCCESS" = true ]; then
    echo -e "${COLOR_MAIN}  █████████████████████████████████████████████████${RESET}"
    echo -e "${COLOR_MAIN}  █ ${COLOR_SUCCESS}OPERACIÓN EXITOSA: SISTEMA LISTO PARA COMPROMISO ${COLOR_MAIN}█${RESET}"
    echo -e "${COLOR_MAIN}  █████████████████████████████████████████████████${RESET}"
else
    echo -e "${COLOR_ACCENT}  █████████████████████████████████████████████████${RESET}"
    echo -e "${COLOR_ACCENT}  █ ${COLOR_DANGER}ADVERTENCIA: MONITOR ACTIVO PERO INYECCIÓN FALLÓ ${COLOR_ACCENT}█${RESET}"
    echo -e "${COLOR_ACCENT}  █████████████████████████████████████████████████${RESET}"
fi

echo -e "${COLOR_INFO}  Target:    ${COLOR_ACCENT}$TARGET_IFACE${RESET}"
echo -e "${COLOR_INFO}  Mode:      ${COLOR_SUCCESS}$FINAL_MODE${RESET}"
echo -e "${COLOR_INFO}  Injection: $INJECTION_STATUS${RESET}"
echo -e "${COLOR_MUTED}  -------------------------------------------------${RESET}"
