on run {input, parameters}
	
	tell application "System Events" to tell dock preferences
		if screen edge is bottom then
			set screen edge to left
            set autohide to false

		else if screen edge is left then
			set screen edge to bottom
			set dock size to 16
            set autohide to true

		end if
	end tell
	
	return input
end run
