bind PUB - !facebooker cmdfacebook

proc cmdfacebook {nick uhost hand chan arg} {
	global cmdfacebook
	putserv "PRIVMSG $nick :Premi�re chose � savoir, notre canal � pour but de ramener les gens sur IRC. Donc, mes commandes de base sert � faire un certain lien avec FaceBook! Le canal commence, donc d'autres fonctionnalit�s seront rajout�es en cours de route!"
	putserv "PRIVMSG $nick :Nous avons cr�er un annuaire facebook. Pour rechercher quelqu'un dans ma base de donn�e tape !faceboook find <nick>"
	putserv "PRIVMSG $nick :Pour t'ajouter � notre base de donn�e: tape !facebook addme <url-facebbok> (ex:!facebook addme http://fb.me/FaceBooKer) Les autres utilisateurs pourront te rechercher."
	putserv "PRIVMSG $nick :Sache que tu peux te d�sabonner ou changer ton lien facebook � tout moment avec la commande !facebook removeme"
	putserv "PRIVMSG $nick :Nous avons aussi un syst�me de recherche si vous ne trouvez pas la personne que vous rechercher sur le canal. Vous pouvez taper !seen <nick>"
}

bind MSG * !facebook facebookcmd
bind PUB * !facebook finding

proc finding {nick uhost hand chan arg} {
	global temp facebook

	if {[string index $arg 0] in {! . `}} {
		set temp(cmd) [string range $arg 1 end]
		set temp(cmd) [lindex [split $temp(cmd)] 0]
		set arg [join [lrange [split $arg] 1 end]]
	} elseif {[isbotnick [lindex [split $arg] 0]]} {
		set temp(cmd) [lindex [split $arg] 1]
		set arg [join [lrange [split $arg] 2 end]]
	} else {
		set temp(cmd) [lindex [split $arg] 0]
	}

	switch -nocase -- $temp(cmd) {
		find {
			set target [lindex [split $arg] 0]

			foreach n [array names facebook] {
				if {[string match -nocase $n $target]} {
					putquick "PRIVMSG $nick :Facebook ID: \00304$facebook([string tolower $target])\003 est associ� au nickname: \00303$target"
				}
				else {
					putquick "PRIVMSG $nick :D�sol�, \00303$target\003 n'est \00304pas\003 associ� � un Facebook ID."
				}
			}
		}
	}
}


proc facebookcmd {nick uhost hand arg} {
	global temp facebook

	if {[string index $arg 0] in {! . `}} {
		set temp(cmd) [string range $arg 1 end]
		set temp(cmd) [lindex [split $temp(cmd)] 0]
		set arg [join [lrange [split $arg] 1 end]]
	} elseif {[isbotnick [lindex [split $arg] 0]]} {
		set temp(cmd) [lindex [split $arg] 1]
		set arg [join [lrange [split $arg] 2 end]]
	} else {
		set temp(cmd) [lindex [split $arg] 0]
	}

	switch -nocase -- $temp(cmd) {

		removeme {

			if {[info exists facebook([string tolower $nick])]} {
				unset -nocomplain facebook([string tolower $nick])
				facebook:save

				putquick "PRIVMSG $nick :Votre facebook ID n'est plus dans notre annuaire."

			}
		}
		find {
			set target [lindex [split $arg] 1]

			foreach n [array names facebook] {
				if {[string match -nocase $n $target]} {
					putquick "PRIVMSG $nick :Facebook ID: \00304$facebook([string tolower $target])\003 est associ� au nickname: \00303$target"
				} else {
					putquick "PRIVMSG $nick :D�sol�, \00303$target\003 n'est \00304pas\003 associ� � un Facebook ID."
				}
			}
		}

		addme {
			set fbid [lindex [split $arg] 1]

			set facebook([string tolower $nick]) $fbid
			facebook:save

			putquick "PRIVMSG $nick :Ce Facebook ID (\00312$fbid\003) a �t� ajout� pour votre nickname. Les gens pourront vous retrouver � l'aide de la fonction\00303 !facebook find $nick"

		}
	}
}
proc facebook:save {} {
	global facebook

	set nfw [open facebook w]
	puts $nfw "array set facebook [list [array get facebook]]"
	close $nfw
}

putlog "Facebook pour FacebooKer"

catch {source facebook}
