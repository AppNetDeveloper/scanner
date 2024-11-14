#!/bin/bash

# Configuración del servidor MQTT
MQTT_SERVER="208.76.222.165"
MQTT_PORT="1883"
TOPIC="sensor/scanner/bluetooth"

# Definir el tiempo de escaneo en segundos
SCAN_DURATION=3  # Edita este valor para cambiar el tiempo de escaneo

# Función para enviar la dirección MAC por MQTT en formato JSON
send_to_mqtt() {
    local addr="$1"
    local change="$2"
    local rssi="$3"

    if [ -n "$rssi" ]; then
        local payload="{\"mac\": \"$addr\", \"change\": \"$change\", \"rssi\": \"$rssi\"}"
    else
        local payload="{\"mac\": \"$addr\", \"change\": \"$change\"}"
    fi

    echo "Enviando mensaje MQTT: $payload"
    mosquitto_pub -h "$MQTT_SERVER" -p "$MQTT_PORT" -t "$TOPIC" -m "$payload"
}

# Función para escanear dispositivos Bluetooth usando btmgmt
scan_bluetooth_devices() {
    echo "Escaneando dispositivos Bluetooth (BLE) con btmgmt durante $SCAN_DURATION segundos..."

    # Asegurarse de que el adaptador Bluetooth esté encendido
    btmgmt power on

    # Declarar un array asociativo para almacenar los MAC detectados en este escaneo
    declare -A devices_detected

    # Iniciar el escaneo LE con btmgmt durante el tiempo especificado
    timeout "${SCAN_DURATION}s" btmgmt find | while IFS= read -r line; do
        echo "Procesando línea: $line"
        if [[ "$line" =~ "dev_found" ]]; then
            # Extraer dirección MAC y RSSI
            addr=$(echo "$line" | awk '{print $3}')
            rssi=$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="rssi"){print $(i+1);break}}}')

            # Verificar si la dirección MAC no está vacía y si no ha sido procesada ya en este escaneo
            if [ -n "$addr" ] && [ -z "${devices_detected[$addr]}" ]; then
                # Marcar la dirección MAC como detectada
                devices_detected["$addr"]=1

                # Enviar mensaje MQTT
                send_to_mqtt "$addr" "Dispositivo detectado" "$rssi"
                echo "Dispositivo detectado: $addr - RSSI: $rssi"
            else
                echo "Dispositivo $addr ya fue procesado en este escaneo - no se envía MQTT"
            fi
        fi
    done
}

# Ejecutar escaneo continuo
while true; do
    scan_bluetooth_devices
    sleep 0.1  # Espera 1 segundo antes del próximo escaneo (puedes ajustar este tiempo)
done
