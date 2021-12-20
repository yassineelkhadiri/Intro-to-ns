#Création d'un simulateur
set ns [new Simulator]
#Création du fichier de trace utilisé par l'afficheur
set nf [open out.nam w]
$ns namtrace-all $nf
proc finish {} {
global ns nf
$ns flush-trace
close $nf
exec nam out.nam &
exit 0
}

# Créaton des noeuds
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

#Création des lignes de commnication
$ns duplex-link $n0 $n2 10Mb 4ms DropTail
$ns duplex-link $n1 $n2 10Mb 4ms DropTail
$ns duplex-link $n2 $n3 10Mb 4ms DropTail
$ns duplex-link $n3 $n4 10Mb 4ms DropTail
$ns duplex-link $n3 $n5 10Mb 4ms DropTail

#Création des agents des noeuds 0 et 1
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0

set tcp1 [new Agent/TCP]
$ns attach-agent $n1 $tcp1

$tcp0 set class_ 1
$tcp0 set class_ 2

$ns color 1 Blue
$ns color 2 Red

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

# agent du noeud 4
set tcpsink0 [new Agent/TCPSink]
$ns attach-agent $n4 $tcpsink0

# agent du noeud 5
set tcpsink1 [new Agent/TCPSink]
$ns attach-agent $n5 $tcpsink1

#Les noeuds 2 et 3
set null2 [new Agent/Null]
$ns attach-agent $n2 $null2
set null3 [new Agent/Null]
$ns attach-agent $n3 $null3

# Lier les agents
$ns connect $tcp0 $tcpsink0
$ns connect $tcp1 $tcpsink1

#Scenario
$ns at 0 "$ftp0 start"
$ns at 1.5 "$ftp1 start"
$ns at 8.5 "$ftp0 stop"
$ns at 9 "$ftp1 stop"
$ns at 10.1 "finish"

# Execution
$ns run
