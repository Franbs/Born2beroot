#!/bin/bash

# uname para sacar el nombre del os y kernel y -a para mostrar todas las caracteristicas
arch=$(uname -a)

# en /proc/cpuinfo hay info de los procesadores, busco y cuento los procesadores y los physical id
physcpu=$(grep "physical id" /proc/cpuinfo | wc -l)
virtcpu=$(grep "processor" /proc/cpuinfo | wc -l)

# miro en MB la memoria, y cojo la total y la free, luego calculo el porcentaje
memtotal=$(free --mega | awk '/Mem:/ {print $2}')
memused=$(free --mega | awk '/Mem:/ {print $3}')
memperc=$(free --mega | awk '/Mem:/ {print $3/$2*100}')

# miro el espacio libre ocupado etc en MB, excluyo /boot, con awk creo variables que almacenan el valor y voy sumando todas las lineas, en la total lo convierto a Gb dividiendo entre 1024, y luego calculo el porcentaje de los dos campos en MB
disktotal=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_t += $2} END {printf ("%.1fGb\n"), disk_t/1024}')
diskused=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} END {print disk_u}')
diskperc=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} {disk_t+= $2} END {printf("%d\n"), disk_u/disk_t*100}')

# con top saco los procesosy el ueso de recursos etc, con -bn1 hago que se saque una instancia de top, busco la linea que tenga cpu(s) y le resto el idle a 100
cpuload=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')

# who (muestra quien esta conectado), con -b muestra la fecha del ultimo reinicio, asi que extraigo solo la fecha y hora
lastboot=$(who -b | awk '{print $3, $4}')

# (logical volume manager lvm)cuento las lineas en lsblk que hay lvm, si es mayor a 0 significa que hay volumenes lvm activos y  printo yes
lvmuse=$(if [ $(lsblk | grep "lvm" | wc -l) -gt 0 ]; then echo yes; else echo no; fi)

# muestro informacion sobre sockets (ss), filtro conexiones tcp (-t), filtro las lineas que contienen estab (conexiones establecidas) y las cuento
tcpcon=$(ss -ta | grep ESTAB | wc -l)

# saco los users y con wc -w cuento las palabras (-w words)
usernum=$(users | wc -w)

# cojo la ip del host, luego filtro la direccion mac dentro de las interfaces de red 
ip=$(hostname -I)
mac=$(ip link show | grep "link/ether" | awk '{print $2}')

# filtro el journal (registro del sistema) donde el comando ejecutado haya sido sudo, luego busco las lineas que sean comandos, y luego las cuento (-l lineas)
sudonum=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

wall "	#Architecture: $arch
	#CPU physical: $physcpu
	#vCPU: $virtcpu
	#Memory usage: $memused/${memtotal}MB (${memperc}%)
	#Disk usage: $diskused/$disktotal (${diskperc}%)
	#CPU load: $cpuload $cpu_fin%
	#Last boot: $lastboot
	#LVM use: $lvmuse
	#TCP Connections: $tcpcon ESTABLISHED
	#User log: $usernum
	#Network: IP $ip ($mac)
	#Sudo: $sudonum cmd"
