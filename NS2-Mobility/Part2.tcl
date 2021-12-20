# deux domaines 1 fixe et 1 mobile. Le domaine fixe est formé de 2
# clusters contenant chacun 1 noeud, le domaine mobile contient deux clusters
# contenant respectivement 3 et 4 nœuds mobiles

# initialisation des options du lien sans fil
set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(ant) Antenna/OmniAntenna 
set val(ll) LL
set val(ifq) Queue/DropTail/PriQueue
set val(ifqlen) 50 
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(rp) DSDV 
set val(nn) 7 ;# number of mobilenodes
set num_bs_nodes 1
set num_wired_nodes 2

# Initialisation du simulateur
set ns [new Simulator]
# création du fichier de trace et namfile
set tracefile [open interconnected.tr w]
$ns trace-all $tracefile
set namfile [open interconnected.nam w]
$ns namtrace-all-wireless $namfile 500 500
#topographie
set topo [new Topography]
$topo load_flatgrid 500 500 
create-god $val(nn) ;#GOD General Operations Descriptor

$ns node-config -addressType hierarchical
AddrParams set domain_num_ 2 ;# number of domains: 1 domaine fixe, 1 domaine mobile
lappend cluster_num 2 2 ;# number of clusters in each domain
AddrParams set cluster_num_ $cluster_num 
lappend eilastlevel 1 1 4 4 ;# nodes in each cluster
AddrParams set nodes_num_ $eilastlevel 

set temp {0.0.0 0.1.0} ;# hierarchical addresses for wired domain
for {set i 0} {$i < $num_wired_nodes} {incr i} {
set W($i) [$ns node [lindex $temp $i]]
}

# configure for base-station node
$ns node-config -adhocRouting $val(rp) -llType $val(ll) -macType $val(mac) -ifqType $val(ifq) -ifqLen $val(ifqlen) -antType $val(ant) -propType $val(prop) -phyType $val(netif) -channelType $val(chan) -topoInstance $topo -wiredRouting ON -agentTrace ON -routerTrace ON -macTrace ON

set temp {1.0.0 1.0.1 1.0.2 1.0.3 1.1.0 1.1.1 1.1.2 1.1.3} ;# hierarchical addresses to be used for wireless domain

set BS(0) [ $ns node [lindex $temp 0]]
$BS(0) random-motion 0 ;# disable random motion
#provide some co-ordinates (fixed) to base station node and fixed nodes
$BS(0) set X_ 270.0
$BS(0) set Y_ 270.0
$BS(0) set Z_ 0.0
# création d'une ligne de communication full duplex entre les noeuds fixe
$ns duplex-link $W(0) $W(1) 5Mb 10ms DropTail
$ns duplex-link $W(1) $BS(0) 5Mb 10ms DropTail
# set the layout of links in NAM
$ns duplex-link-op $W(0) $W(1) orient down
$ns duplex-link-op $W(1) $BS(0) orient left-down

$ns at 0.0 "$W(0) label W0"
$ns at 0.0 "$W(1) label W1"
$ns at 0.0 "$BS(0) label BS"


#configure for mobilenodes
$ns node-config -wiredRouting OFF
for {set j 0} {$j < $val(nn)} {incr j} {
	set node_($j) [ $ns node [lindex $temp [expr $j+1]] ]
	$node_($j) base-station [AddrParams addr2id [$BS(0) node-addr]] ;# provide each mobilenode with address of its base-station 
	$node_($j) random-motion 0
}

#position initiale
$node_(0) set X_ 50.0
$node_(0) set Y_ 50.0
$node_(0) set Z_ 0.0
$node_(1) set X_ 490.0
$node_(1) set Y_ 285.0
$node_(1) set Z_ 0.0
$node_(2) set X_ 150.0
$node_(2) set Y_ 240.0
$node_(2) set Z_ 0.0
$node_(3) set X_ 65.0
$node_(3) set Y_ 194.0
$node_(3) set Z_ 0.0
$node_(4) set X_ 85.0
$node_(4) set Y_ 364.0
$node_(4) set Z_ 0.0
$node_(5) set X_ 305.0
$node_(5) set Y_ 104.0
$node_(5) set Z_ 0.0
$node_(6) set X_ 264.0
$node_(6) set Y_ 150.0
$node_(6) set Z_ 0.0

#movement
$ns at 10.0 "$node_(0) setdest 200.0 200.0 3.0"
$ns at 10.0 "$node_(2) setdest 480.0 300.0 5.0"
$ns at 20.0 "$node_(1) setdest 45.0 285.0 5.0"

$ns at 0.0 "$node_(3) setdest 130.0 20.0 5.0"
$ns at 0.0 "$node_(4) setdest 30.0 140.0 5.0"
$ns at 0.0 "$node_(5) setdest 230.0 5.0 5.0"
$ns at 0.0 "$node_(6) setdest 20.0 220.0 5.0"

for {set j 0} {$j < $val(nn)} {incr j} {
	$ns initial_node_pos $node_($j) 30
}

# Création de la couche TCP (agent TCP)
# Taille maximale de la fenêtre de congestion, en octets
Agent/TCP set window_ 20
set tcp0 [new Agent/TCP]
$ns attach-agent $node_(0) $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $W(0) $sink0
$ns connect $tcp0 $sink0
# Départ de la source FTP
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 10.0 "$ftp0 start"

$ns at 0.0 "$node_(0) label N0"

proc finish {} {
 global ns tracefile namfile
 $ns nam-end-wireless 200
 $ns flush-trace
 close $tracefile
 close $namfile
 exec nam interconnected.nam &
 exec awk -f loss.awk interconnected.tr > loss.csv &
 exec awk -f throughput.awk interconnected.tr > debit.csv &
 exec awk -f test_thruput.awk interconnected.tr > debit2.csv &
 exit 0
}

$ns at 200.0 "finish"
$ns run





