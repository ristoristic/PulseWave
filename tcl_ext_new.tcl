#
# Usage note
# at nrcmd prompt paste the following lines:
#
# nrcmd> extension name-the-client create tcl tcl_ext_new.tcl name-the-client
# nrcmd> extension encode-the-client create tcl tcl_ext_new.tcl encode-the-client
#
# nrcmd> dhcp attachExtension pre-client-lookup name-the-client
# nrcmd> dhcp attachExtension pre-packet-encode encode-the-client

# after that type the following:
#
# nrcmd> save
# nrcmd> dhcp reload
#

proc name-the-client { request response environ } {

	$environ log LOG_INFO "==== Naming the client start"

	set option82 [ $request get relay-agent-info ]
	set option82 [ string tolower $option82 ]
	
	set circuitid [ $request get relay-agent-circuit-id-data ]
	set circuitid [ string tolower $circuitid ]
	
	set uzmiposlednjikarakter [string range $circuitid [expr {[string length $circuitid] - 2}] end]
	proc hex2dec {largeHex} {
		set res 0
		foreach hexDigit [split $largeHex {}] {
			set new 0x$hexDigit
			set res [expr {16*$res + $new}]
		}
		return $res
	}
	set hextodecimal [ hex2dec $uzmiposlednjikarakter]
	set decimalukarater [format %c $hextodecimal]

	if {$decimalukarater==";"} {
		set samovlan [string range $circuitid [expr {[string length $circuitid] - 11}] [expr {[string length $circuitid] - 4}]]
	} else {
		set samovlan [string range $circuitid [expr {[string length $circuitid] - 8}] end]
	}
	
	
	
	
	set option53 [$request get dhcp-message-type]
	set option53 [string tolower $option53]
	
	set remoteid [ $request get chaddr ]
	set remoteid [ string tolower $remoteid ]
	
	set clientname [ $environ get chaddr ]
	
	set classname [ $request get giaddr ]
    set classname [ string range $classname 0 5 ]
	set classname [ string tolower $classname ]
	
	set option43_9 [ $request get vendor-encapsulated-options ]
	set option43_9 [ string tolower $option43_9 ] 
	
	
	if {$option53==1} {
		if {$samovlan!="34:31:30" && $samovlan!="34:31:35" && $samovlan!="34:32:30" && $samovlan!="34:33:30"} {
			if { $classname == "10.70." } {
				set nameprefix "mng_"
				set clientname $nameprefix$remoteid
			} elseif {$classname == "10.90."} {
				set nameprefix "sip_"
				set clientname $nameprefix$remoteid
			} else {
				set nameprefix "int_"
				set clientname $nameprefix$remoteid
			}
		}
	}
	
	
	
	
	$environ log LOG_INFO "================================="
	$environ log LOG_INFO "==== option-43 sub 9:"
	$environ log LOG_INFO $option43_9

	$environ log LOG_INFO "================================="	
	$environ log LOG_INFO "==== current name: $clientname"
	$environ log LOG_INFO "==== Option 82: $option82"
	$environ log LOG_INFO "==== Circuit ID: $circuitid"
	$environ log LOG_INFO "==== Remote ID: $remoteid"
	$environ log LOG_INFO "==== vendor-class: $classname"
	$environ log LOG_INFO "================================="
	
	$environ log LOG_INFO "==== new client name: $clientname"
	$environ put client-specifier $clientname
	$environ log LOG_INFO "==== naming end"
}

proc encode-the-client { request response environ } {

	$environ log LOG_INFO "==============pre-packet-encode start"
	
	
	#IZVLACENJE REMOTE ID
	set remoteid [$request get relay-agent-remote-id-data]
	set remoteid $remoteid
	
	#IZVLACENJE VLAN IZ STRINGA  (POTREBNO JE IZVRSITI PROVJERU POCKET FRONT-A)
	set circuitid [ $request get relay-agent-circuit-id-data ]
	set circuitid [ string tolower $circuitid ]
	set uzmiposlednjikarakter [string range $circuitid [expr {[string length $circuitid] - 2}] end]
	proc hex2dec {largeHex} {
		set res 0
		foreach hexDigit [split $largeHex {}] {
			set new 0x$hexDigit
			set res [expr {16*$res + $new}]
		}
		return $res
	}
	set hextodecimal [ hex2dec $uzmiposlednjikarakter]
	set decimalukarater [format %c $hextodecimal]

	if {$decimalukarater==";"} {
		set samovlan [string range $circuitid [expr {[string length $circuitid] - 11}] [expr {[string length $circuitid] - 4}]]
	} else {
		set samovlan [string range $circuitid [expr {[string length $circuitid] - 8}] end]
	}
	
	
	#PARSIRANJE CLASS IDENTIFIER RADI RASPOZNAVANJA TIPA FTTH UREDJAJA
		#DIO ZA GENEXIS
		set cigenexisocg [$request get dhcp-class-identifier]
		set cigenexisocg [string range $cigenexisocg 0 6]
		set cigenexisocg [string tolower $cigenexisocg]
	
		#DIO ZA DRGOS
		set cigenexishibrid [$request get dhcp-class-identifier]
		set cigenexishibrid [string range $cigenexishibrid 0 4]
		set cigenexishibrid [string tolower $cigenexishibrid]
	
	#PARSIRANJE TIPA PORUKE SA KOJOM JE UREDJAJ DOSAO
	set option53 [$request get dhcp-message-type]
	set option53 [string tolower $option53]
	
	if {$samovlan!="34:31:30" && $samovlan!="34:31:35" && $samovlan!="34:32:30" && $samovlan!="34:33:30"} {
		$response putOption 01:24:68:74:74:70:3a:2f:2f:31:30:2e:37:30:2e:30:2e:33:3a:38:30:38:30:2f:50:72:6f:76:6a:65:72:61:54:52:30:36:39:2f option 43 
		$response putOption 18c0a8000a46000118c0a80a0a46000110ac100a5a0001100a320a5a0001100afc0a5a0001 option 121
	} else {
		if {$option53==1 || $option53==3} {
			if {$cigenexisocg=="genexis"} {
				if {$samovlan=="34:33:30"} {
					$response putOption 73:3d:31:39:32:2e:31:36:38:2e:31:30:2e:31:33:39:3b:76:3d:34:31:30:3b option 43
					#dodali smo 01 + DUZINU na opciju 125
					$response putOption 01:22:6d:3d:30:3b:76:3d:34:31:30:3b:73:3d:31:39:32:2e:31:36:38:2e:31:30:2e:31:33:39:3b:63:3d:6b:65:6b:65:63 option 125 enterprise 25167
				} elseif {$samovlan=="34:31:30"} {
	
					set prvidio "76:3d:34:31:30:3b:73:3d:31:39:32:2e:31:36:38:2e:31:30:2e:31:33:39:3b:63:3d:"
					set drugidio $remoteid
			
					$response putOption $prvidio$drugidio option 43
				}
			} elseif {$cigenexishibrid=="drgos"} {
				if {$samovlan=="34:33:30"} {
					$response putOption 73:3d:31:39:32:2e:31:36:38:2e:31:30:2e:31:33:39:3b:76:3d:34:31:30:3b option 43
					#dodali smo 01 + DUZINU na opciju 125
					$response putOption 01:22:6d:3d:30:3b:76:3d:34:31:30:3b:73:3d:31:39:32:2e:31:36:38:2e:31:30:2e:31:33:39:3b:63:3d:6b:65:6b:65:63 option 125 enterprise 25167
				} elseif {$samovlan=="34:31:30"} {
			
					
					set prvidio "76:3d:34:31:30:3b:73:3d:31:39:32:2e:31:36:38:2e:31:30:2e:31:33:39:3b:63:3d:"
					set drugidio $remoteid
					
					set duzinazaprovjeru $prvidio$drugidio
					set duzinazaprovjerubezdvotacki [string map {: ""} $duzinazaprovjeru]
					set duzinazaprovjerubezdvotackiudecimalipravogstringa [expr {[string length $duzinazaprovjerubezdvotacki] / 2}]
					set inhexduzinu [format %x $duzinazaprovjerubezdvotackiudecimalipravogstringa]
					set prefixkojisedodaje "01:"
					set dvotacka ":"
					
					#dodali smo 01 + DUZINU na opciju 125
					$response putOption $prefixkojisedodaje$inhexduzinu$dvotacka$prvidio$drugidio option 125 enterprise 25167
				}
			}
		}
	}
	
	$environ log LOG_INFO "==============pre-packet-encode end"
	
	#set option60 [$request get chaddr]
	#set option43 ""

	#$environ log LOG_INFO "==== MAC za opciju 60: $option60"	

	#switch -glob -- $option60 {
	#	64:6e:ea* {
	#		set option43 01:14:68:74:74:70:73:3a:2f:2f:35:2e:35:2e:35:2e:35:2f:70:65:72:6f 		}

	#	default { set option121 18:c0:a8:0a:0a:4d:00:01}
	#}

	#$environ log LOG_INFO "==== vendor-option-string: $option43"
	
	
	#set opcijazaRaisecom [$request get host-name]
	#set option121 ""

	#$environ log LOG_INFO "==== Host name za opciju 121: $opcijazaRaisecom"	

	#switch -glob -- $opcijazaRaisecom {
	#	RTK_GW {
	#		set option121 18:c0:a8:0a:0a:4d:00:01 		}

	#	#default { set option121 18:c0:a8:0a:0a:4d:00:01}
	#}

	#$environ log LOG_INFO "==== Opcija 121: $option121"

}
