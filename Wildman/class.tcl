bind PUB - !pause pub:pause
bind PUB - !resume pub:resume
bind PUB - !stop pub:stop

proc pub:prestart {nick uhost hand chan arg} {
	global class

	set class(start) 1
	set class(end) 0
	set class(pause) 0
	set class(line) 0
	set class(number) 0
	set class(total) 0

	set of [open class]; while {[gets $of line] ne -1} { incr class(total) }; close $of

	putlog "total: $class(total)"

	class:start $chan $nick
}

proc class:start {chan nick} {
	global class

	if {$class(pause)} { return }
	if {$class(end)} { return }
	if {$class(number) eq $class(total)} { putquick "PRIVMSG $chan :\002::\002 Am terminat.."; return }

	incr class(number)

	set of [open class]

	while {[gets $of line] ne -1} {
		incr class(line)
		if {$class(line) eq $class(number)} {
			putquick "PRIVMSG $chan :$line"
		}
	}

	set class(line) 0
	close $of

	set class(running) [utimer 3 [list class:start $chan $nick]]
}

proc pub:stop {nick uhost hand chan arg} {
	global class

	set class(end) 1

	killutimer $class(running)

	putquick "PRIVMSG $chan :\002::\002 Am oprit cu succes"
}

proc pub:pause {nick uhost hand chan arg} {
	global class

	set class(pause) 1

	killutimer $class(running)

	putquick "PRIVMSG $chan :\002::\002 Am oprit temporar..."
}

proc pub:resume {nick uhost hand chan arg} {
	global class

	set class(pause) 0

	class:start $chan $nick
}
