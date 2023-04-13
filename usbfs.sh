#!/bin/sh

# Inicialización de variables
CONTROL=0
PLACEPI="/home/pi"
PLACE="/home/pi/USBDRIVES/pi" # Ruta donde se montan los dispositivos USB
PLACE2="/home/pi/maquinaria" # Ruta donde se moverán los archivos xml
PLACE3="/home/pi/jumbos" # Ruta donde se crearán carpetas para cada dispositivo USB
XMLDRIVE="/home/pi/usbdrivesxml" # Ruta donde se copiarán los archivos xml
JUMBOSBKP="/home/pi/jumbosbkp" # Ruta donde se copiarán los bckp

# Crear directorios necesarios si no existen
mkdir -p "$PLACEPI/maquinaria" "$PLACEPI/jumbos" "/home/pi/usbdrivesxml" "$PLACEPI/jumbosbkp" "$PLACEPI/USBDRIVES"
mkdir -p "$PLACE2/17" "$PLACE2/18" "$PLACE2/21" "$PLACE2/24" "$PLACE2/boomer2"
mkdir -p "$PLACE2/15" "$PLACE2/23"
mkdir -p "$PLACE3/17" "$PLACE3/18" "$PLACE3/21" "$PLACE3/24" "$PLACE3/boomer2"
mkdir -p "$PLACE3/15" "$PLACE3/23"
#Crear directorios de maquinaria si no existen dentro de PLACE2="/home/pi/maquinaria"


# Cambiar permisos de carpetas para que sean accesibles
sudo chmod 777 -R $PLACE $PLACE2 $PLACE3 $XMLDRIVE $JUMBOSBKP $XMLDRIVE
sudo chmod 777 -R "$PLACE2/17" "$PLACE2/18" "$PLACE2/21" "$PLACE2/24" "$PLACE2/boomer2"
sudo chmod 777 -R "$PLACE2/15" "$PLACE2/23"
sudo chmod 777 -R "$PLACE3/17" "$PLACE3/18" "$PLACE3/21" "$PLACE3/24" "$PLACE3/boomer2"
sudo chmod 777 -R "$PLACE3/15" "$PLACE3/23"
sudo chmod 777 -R /home/pi/USBDRIVES/pi


# Iniciamos un loop mientras no se encuentren dispositivos USB conectados

while [ $CONTROL=0 ] ; do
	cat /etc/mtab | grep media >> /dev/null
	if [ $? -ne 0 ]; then
		CONTROL=0
	else
		CONTROL=1
		for USBDEV in $(df | grep media | awk -F / '{print $5}' | tr ' ' '_') # renombramos a guiones los espacios
		do
			USBNAME=$(echo $USBDEV | awk -F / '{print $3}')
			USBNAME=$(echo $USBNAME | sed 's/ /_/g') # reemplazamos espacios por guiones bajos
			mkdir -p "/home/pi/USBDRIVES/pi/$USBNAME"				
			sudo rsync "/media/$USBNAME/" "/home/pi/USBDRIVES/$USBNAME" -ahvzAXH --include-from="$PLACEPI/scriptcopia/usb-spy.files" --exclude='*.*' --prune-empty-dirs
		done
	fi
	


# Jumbo 15 = 8999189100
# Jumbo 17 = 8991850200
# Jumbo 18 = 8999192100
# Jumbo 21 = 8999110000
# Jumbo 23 = 8999365900
# Jumbo 24 = 8999397500

sudo find /home/pi/USBDRIVES -type f -name "*.XML" -exec cp {} /home/pi/usbdrivesxml \;
sudo find /home/pi/USBDRIVES -type f -name "*.xml" -exec cp {} /home/pi/usbdrivesxml \;
sudo find /home/pi/USBDRIVES -type f -name "*.log" -exec cp {} /home/pi/usbdrivesxml \;
sudo find /home/pi/USBDRIVES -type f -name "*.LOG" -exec cp {} /home/pi/usbdrivesxml \;

sudo mv $(grep -iRl "8999189100" /home/pi/usbdrivesxml/) /home/pi/maquinaria/15
sudo mv $(grep -iRl "8991850200" /home/pi/usbdrivesxml/) /home/pi/maquinaria/17
sudo mv $(grep -iRl "8999192100" /home/pi/usbdrivesxml/) /home/pi/maquinaria/18
sudo mv $(grep -iRl "8999110000" /home/pi/usbdrivesxml/) /home/pi/maquinaria/21
sudo mv $(grep -iRl "8999365900" /home/pi/usbdrivesxml/) /home/pi/maquinaria/23
sudo mv $(grep -iRl "8999381800" /home/pi/usbdrivesxml/) /home/pi/maquinaria/24
sudo mv $(grep -iRl "8999397500" /home/pi/usbdrivesxml/) /home/pi/maquinaria/boomer2



# Movemos los archivos de maquinaria a jumbos y le cambiamos el nombre por la fecha

# Iteramos sobre las carpetas 17, 18, 21 y 24 de la carpeta /home/pi/maquinaria/
    for carpeta in 15 16 17 18 21 23 24 boomer2; do
    # Cambiamos al directorio correspondiente
    cd "/home/pi/maquinaria/${carpeta}/"
    # Iteramos sobre los archivos en la carpeta actual
	for FILE in *.*; do
        # Obtenemos la extensión del archivo
        ext="${FILE##*.}"
        # Obtenemos el nombre del archivo sin extensión
        nomb="${FILE%.*}"
        # Verificamos si la extensión es xml o XML
          if [ "$ext" = "xml" ] || [ "$ext" = "XML" ] ; then
            # Obtenemos la fecha de finalización de registro del archivo
            v=$(cat "${cd}${nomb}.${ext}" | grep -oE '<IR:EndLogTime>.*</IR:EndLogTime>' | tr -d '-' | tr -d ':' | tr -d '<IREndLogTime>/')
            # Renombramos el archivo con la fecha de finalización de registro
            sudo mv "$FILE" "$v.$ext"
            #echo "Archivo renombrado con éxito: $nomb"
           else
            echo "Extensión NO válida: $ext"
         fi
       done
   done
  
  
  
  
  # Se recorre el directorio de maquinaria en busca de archivos XML para renombrarlos y moverlos a la carpeta correspondiente
    for carpeta2 in 15 16 17 18 21 23 24 boomer2; do
	 # Cambiamos al directorio correspondiente
    cd "/home/pi/maquinaria/${carpeta2}/"
    # Iteramos sobre los archivos en la carpeta actual
	for FILE in *.*; do
        # Obtenemos la extensión del archivo
        ext="${FILE##*.}"
        # Obtenemos el nombre del archivo sin extensión
        nomb="${FILE%.*}"
 		# Se extrae la fecha del archivo para renombrarlo
 		 if [ "$ext" = "log" ] || [ "$ext" = "LOG" ]; then
		 v=$(cat "${cd}${nomb}.${ext}" | grep -A 2 'Default.las'| tr -d ':' | tr -d '/' | tr -d 'Default.las' | tr -d '[[:space:]]')
		  # Renombramos el archivo con la fecha de finalización de registro
         sudo mv "$FILE" "$v.$ext"
        #echo "Archivo renombrado con éxito: $nomb"
		fi
	done
    done


# Buscar dispositivos de almacenamiento montados en /media
usb_devices=$(lsblk -o MOUNTPOINT | grep "/media/")

# Extraer el nombre del pendrive
if [ -n "$usb_devices" ]; then
    usb_device=$(echo "$usb_devices" | head -n 1)
    usb_name=$(basename "$usb_device")
    echo "Nombre del pendrive: $usb_name"
else
    echo "No se encontraron pendrives conectados."
fi


    for ruta in 15 17 18 21 23 24 boomer2; do
   
   # Crear carpetas en PLACE3 con el nombre del pen
		
		mkdir -p "/home/pi/jumbos/$ruta/$usb_name" 

		sudo chmod 777 -R "/home/pi/jumbos/$ruta/$usb_name"
		
		
		# Movemos los archivos renombrados a la carpeta correspondiente en /home/pi/jumbos/
		   
		#sudo mv -f /home/pi/maquinaria/"$ruta"/* /home/pi/jumbos/"$ruta"
		sudo mv -f /home/pi/maquinaria/"$ruta"/* "/home/pi/jumbos/$ruta/$usb_name"
	       			
    done
              

   
    
    
# Eliminamos los archivos en la carpeta /home/pi/usbdrivesxml/ y /home/pi/USBDRIVES/pi/

	sudo rm -r /home/pi/usbdrivesxml/*
	sudo rm -r /home/pi/USBDRIVES/pi/*

# Esperamos 5 segundos antes de salir del script
sleep 5
done
exit 0
