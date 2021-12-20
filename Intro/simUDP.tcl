# création d'un simulateur
set ns [new Simulator]
# création du fichier de trace utilisé par l’afficheur et indication à ns de l'utiliser
set nf [open out.nam w]
$ns namtrace-all $nf
#  lorsque  la  simulation  sera  terminée,  cette  procédure  est  appelée  pour  lancer automatiquement l’afficheur
proc finish {} {
global ns nf
$ns flush-trace
close $nf
exec nam out.nam &
exit 0
}
# création de deux noeuds
set n0 [$ns node]
set n1 [$ns node]
# création d'une ligne de communication full duplex entre les noeuds n0 et n1
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
# création d'un agent UDP implanté dans n0
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
#  création  d'un  trafic  CBR  pour  le  nœud  0  générateur  de  paquets  à  vitesse
#constante  paquets  de  500  octets,  générés  toutes  les  5  ms.  Ce  trafic  est  attaché  au
#udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0
# création d'un agent vide, destiné à recevoir les paquets implanté dans n1
set null0 [new Agent/Null]
$ns attach-agent $n1 $null0
# le trafic issus de l'agent udp0 est envoyé vers null0
$ns connect $udp0 $null0
# scénario de début et de fin de génération des paquets par cbr0
$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"
# la simulation va durer 5 secondes de temps simulé
$ns at 5.0 "finish"
# début de la simulation
$ns run