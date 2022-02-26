var/list/settings
proc/LoadSettings()
	settings = new/list()
	settings["use_mysql"] = 1
	if(!fexists("Cowed.cfg")) return

	var
		contents = dd_file2list("Cowed.cfg", "\n")
		i = 1
	for(var/line in contents)
		if(!line || text2ascii(line, 1) == 35) continue //ignore #comments
		var/pos = findtext(line, "=")
		if(!pos)
			world.log << "Warning: Syntax error in Cowed.cfg, line [i]."
			continue
		var
			setting = trimAll(copytext(line, 1, pos))
			value = trimAll(copytext(line, pos + 1))

		if(text2ascii(value, 1) == 34 && text2ascii(value, length(value)) == 34) //"string"
			value = copytext(value, 2, length(value))
		else if(IsNum(value))
			value = text2num(value)
		else
			world.log << "Warning: Syntax error in Cowed.cfg, line [i]."
			continue

		if(setting in settings)
			world.log << "Warning: Redefinition of setting [setting] in Cowed.cfg, line [i]."

		settings[setting] = value

		i++
	/*world.log << "DEBUG: The following settings were loaded:"
	for(var/setting in settings)
		world.log << "DEBUG: [setting] = [settings[setting]]"*/