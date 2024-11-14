1. Instalar Supervisor
Si no tienes Supervisor instalado, instálalo con:

bash
Copiar código
sudo apt update
sudo apt install -y supervisor
2. Crear una Configuración para el Script en Supervisor
Crea un archivo de configuración para el script en el directorio de configuración de Supervisor:

bash
Copiar código
sudo nano /etc/supervisor/conf.d/bluetooth_scan.conf
3. Configurar el Script en Supervisor
Pega la siguiente configuración en el archivo:

ini
Copiar código
[program:bluetooth_scan]
command=/bin/bash /var/www/script/scan.sh
autostart=true
autorestart=true
stderr_logfile=/var/log/bluetooth_scan.err.log
stdout_logfile=/var/log/bluetooth_scan.out.log
user=root
Explicación de las Opciones
command: Especifica la ruta completa para ejecutar el script con bash.
autostart=true: Inicia el script automáticamente al iniciar Supervisor.
autorestart=true: Reinicia el script automáticamente si se detiene o falla.
stderr_logfile y stdout_logfile: Ubicación de los archivos de log para la salida de errores y la salida estándar.
user=root: Ejecuta el script como root, lo cual es útil si el script necesita permisos elevados (ajusta esto según tus necesidades).
4. Recargar Supervisor y Aplicar la Configuración
Recarga Supervisor para que reconozca la nueva configuración:

bash
Copiar código
sudo supervisorctl reread
sudo supervisorctl update
5. Iniciar el Proceso con Supervisor
Inicia el proceso gestionado por Supervisor:

bash
Copiar código
sudo supervisorctl start bluetooth_scan
6. Verificar el Estado y los Logs
Puedes verificar el estado del proceso en cualquier momento con:

bash
Copiar código
sudo supervisorctl status bluetooth_scan
Para revisar los logs, usa:

bash
Copiar código
cat /var/log/bluetooth_scan.out.log
cat /var/log/bluetooth_scan.err.log