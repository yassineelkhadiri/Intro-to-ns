# initialiser le Simulateur
set ns_ [new Simulator]

#initialiser du fichier de trace
set tracefd [open traceFile.tr w]
$ns_ trace-all $tracefd
 
# Initialiser l'animateur
set namtrace [open simulation.nam w]
$ns_ namtrace-all-wireless $namtrace 500 400

# Procedure fermante
proc finish {} {
global ns_ namtrace
$ns_ flush-trace
close $namtrace
exec nam simulation.nam &
}


# Definir les parametres de configuration des noeuds
set val(chan) Channel/WirelessChannel   ;# channel type
set val(prop) Propagation/TwoRayGround  ;# radio-propagation model
set val(ant) Antenna/OmniAntenna        ;# Antenna type
set val(ll) LL                          ;# Link layer type
set val(ifq) Queue/DropTail/PriQueue	;# Interface queue type
set val(ifqlen) 50						;# max packet in ifq
set val(netif) Phy/WirelessPhy			;# network interface type
set val(mac) Mac/802_11					;# MAC type
set val(rp) DSDV						;# ad-hoc routing protocol
set val(nn) 3							;# number of mobilenodes
set val(x) 500							;# X dimension de la topographie
set val(y) 400							;# Y dimension de la topographie


# Definir la grille qui constitue la definition de la zone de simulation
set topo [ new Topography]
$topo load_flatgrid 500 400

# Creer General Operations Director (GOD) object. Il est utilisé pour stocker des informations globales sur l'etat de l'environnement, réseau, ou noeuds qui doivent être connues de toutes les entités de la simulation.
create-god $val(nn)

# Configuration les noeuds
set chan_1_ [new $val(chan)]
$ns_ node-config -addressingType flat
$ns_ node-config -adhocRouting $val(rp)\
				 -llType $val(ll)\
				 -macType $val(mac)\
				 -ifqType $val(ifq)\
				 -ifqLen $val(ifqlen)\
				 -antType $val(ant)\
				 -propType $val(prop)\
				 -phyType $val(netif)\
				 -topoInstance $topo\
				 -channelType $val(chan)\
				 -agentTrace ON\
				 -routerTrace ON\
				 -macTrace ON\
				 -movementTrace ON

#Creer des noeuds et configurer leur position
for {set i 0} {$i < $val(nn)} {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0
}


#Position du noeud 0
$node_(0) set X_ 5.0
$node_(0) set Y_ 5.0
$node_(0) set Z_ 0.0

#Position du noeud 1
$node_(1) set X_ 490.0
$node_(1) set Y_ 285.0
$node_(1) set Z_ 0.0

#Position du noeud 2
$node_(2) set X_ 150.0
$node_(2) set Y_ 240.0
$node_(2) set Z_ 0.0

# Gerer les movements des noeuds
	# Movement du noeud 0 apres 10s vitesse 3m/s
	$ns_ at 10.0 "$node_(0) setdest 250.0 250.0 3.0"

	# Movement du noeud 1 apres 20s vitesse 5m/s
	$ns_ at 20.0 "$node_(1) setdest 45.0 285.0 5.0"

	# Movement du noeud 2 apres 10s vitesse 5m/s
	$ns_ at 10.0 "$node_(2) setdest 480.0 300.0 5.0"

# Definition des agents TCP
set tcp [new Agent/TCP]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp
$ns_ attach-agent $node_(1) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#Taille maximale de la fenêtre de congestion, en paquets 
#Agent/TCP set maxcwnd_ 30
$ns_ at 10.0 "$ftp start" 
$ns_ at 150.0 "finish"

puts "Starting Simulation..."
$ns_ run
