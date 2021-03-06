bind PUB - !start pub:prestart
bind PUB - !pause pub:pause
bind PUB - !resume pub:resume
bind PUB - !stop pub:stop

bind MSGM - * class:msgm

set class(path) "database/"

setudef flag class

proc class:msgm {nick uhost hand arg} {
	global class
	
	switch -exact -- [lindex [split $arg] 0] {
		class {
			if {![file exists $class(path)[lindex [split $arg] 1]]} { putquick "PRIVMSG $nick :\002$nick\002 - Fisierul nu exista"; return }

			set class(chan) [lindex [split $arg] 2]
			set class(delay) [lindex [split $arg] 3]	
			set class(file) [lindex [split $arg] 1]
			set class(start) 1
			set class(end) 0
			set class(pause) 0
			set class(line) 0
			set class(number) 0
			set class(total) 0

			if {$class(file) eq "" } { putquick "PRIVMSG $nick :\002::\002 Nu ai specificat \00304fisierul\003 pe care trebuie sa il rulez"; return }			
			if {$class(chan) eq "" } { putquick "PRIVMSG $nick :\002::\002 Nu ai specificat \00304canalul\003 pe care sa rulez"; return }
			if {$class(delay) eq "" } { putquick "PRIVMSG $nick :\002::\002 Nu ai specificat \00304timpul"; return }
			
			set of [open $class(path)$class(file)]; while {[gets $of line] ne -1} { incr class(total) }; close $of

			putlog "Total linii: \00312$class(total)"

			foreach c [channels] { if {[channel get $c class]} { set chan $c } }

			putquick "PRIVMSG $nick :\002$nick\002 - Pornesc fisierul \00303$class(file)\003 pe canalul \00304$class(chan)\003 cu un delay de \00312$class(delay)\003 secunde"
			class:start $chan $nick $class(delay) $class(file)
		}
		chanset {
			channel set [lindex [split $arg] 1] [lindex [split $arg] 2]

			putquick "PRIVMSG $nick :\002$nick\002 - Am setat cu succes \00304[lindex [split $arg] 2]\003 pentru \00312[lindex [split $arg] 1]"
		}
		stop {
			set class(end) 1

			putquick "PRIVMSG $nick :\002::\002 Am oprit cu succes"
			
			catch {killutimer $class(running)}
		}
		pause {
			set class(pause) 1

			putquick "PRIVMSG $nick :\002::\002 Am oprit temporar..."
			
			catch {killutimer $class(running)}
		}
		resume {
			set class(pause) 0

			class:start $class(chan) $nick $class(delay) $class(file)
			
			putquick "PRIVMSG $nick :\002::\002 Pornim de unde am ramas..."
		}
	}
}

proc class:start {chan nick delay file} {
	global class

	putlog "$chan $nick $delay ($class(path)$file)"
	
	if {$class(pause)} { putlog "gasit pauza"; return }
	if {$class(end)} { putlog "gasit oprit"; return }
	if {$class(number) eq $class(total)} { putquick "PRIVMSG $chan :\002::\002 Am terminat.."; return }

	incr class(number)

	set of [open $class(path)$file]

	while {[gets $of line] ne -1} {
		incr class(line)
		if {$class(line) eq $class(number)} {
			putquick "PRIVMSG $chan :$line"
		}
	}

	set class(line) 0
	close $of

	set class(running) [utimer $delay [list class:start $chan $nick $class(delay) $file]]
}
