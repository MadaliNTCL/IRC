bind PUBM - * public

proc public {nick uhost hand chan arg} {
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
		add {
			set fbid [lindex [split $arg] 0]

			set facebook([string tolower $nick]) $fbid
			facebook:save

			putquick "PRIVMSG $chan :Added Facebook ID for you nickname to: \00312$fbid"
		}
		del {
			if {[info exists facebook([string tolower $nick])]} {
				unset -nocomplain facebook([string tolower $nick])
				facebook:save

				putquick "PRIVMSG $chan :Your facebook ID has been deleted"
			}
		}
		find {
			set target [lindex [split $arg] 0]

			foreach n [array names facebook] {
				if {[string match -nocase $n $target]} {
					putquick "PRIVMSG $chan :Found facebook id \00304$facebook([string tolower $target])\003 matching nickname \00303$target"
				}
			}
		}
	}
}

proc facebook:save {} {
	global facebook

	set nfw [open facebook w]
	puts $nfw "array set top [list [array get facebook]]"
	close $nfw
}

catch {source facebook}
