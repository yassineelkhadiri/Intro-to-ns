# Initialisation du simulateur

set ns [new Simulator]

# Création de fichiers de traces

set ftrace [open fout.tr w]
set nf [open out.nam w]

# traces animées

$ns namtrace-all $nf

# Procédure fermant les fichiers de traces

proc finish {} {
global ns ftrace nf
$ns flush-trace
close $nf
close $ftrace
exec nam out.nam &
exit 0
}

# Procédure permettant d'obtenir la taille de la fenêtre de congestion

# toutes les 0.01s

proc tracefenetre {} {
global tcp0 ftrace
set ns [Simulator instance]
set time 0.01
set now [$ns now]
puts $ftrace "$now [$tcp0 set cwnd_]"
$ns at [expr $now+$time] "tracefenetre"
}

# Initialisation de certains paramètres TCP

# Taille des paquets TCP, en octets

Agent/TCP set packetSize\_ 1500

# Taille maximale de la fenêtre de congestion, en paquets

Agent/TCP set maxcwnd* 30
Agent/TCPSink/DelAck set interval* 0.00001

# Création du noeud n0 et de ses caractéristiques

# les connexions TCP étant unidirectionnelles, il y a une source et un puits par connexion

# Création du noeud n0

set n0 [$ns node]

# Création de la couche TCP (agent TCP), côté source

set tcp0 [new Agent/TCP]

# Attachement de la couche TCP au noeud

$ns attach-agent $n0 $tcp0

# Création de la couche applicative FTP

set ftp [new Application/FTP]

# Attachement de la couche applicative à la couche TCP

$ftp attach-agent $tcp0

# Création du noeud n1

set n1 [$ns node]

# Création de la couche TCP, côté puits

set tcp1 [new Agent/TCPSink/DelAck]

# Attachement de la couche TCP au noeud

$ns attach-agent $n1 $tcp1

# Création du lien point à point bidirectionnel entre les deux noeuds

# Le débit du lien est de 10Mb/s et le délai de propagation est de 10ms

$ns duplex-link $n0 $n1 10Mb 10ms DropTail

# Création de la connexion entre les deux couches TCP

$ns connect $tcp0 $tcp1

# Départ de la source FTP à la date 0.0 s

$ns at 0.0 "$ftp start"

# Arrêt de la source FTP à la date 0.7 s

$ns at 0.7 "$ftp stop"

# Exécution de la procédure tracefenetre

$ns at 0.0 "tracefenetre"

# Exécution de la procédure finish à la date 0.8 s

$ns at 0.8 "finish"

# Exécution de la simulation

$ns run
