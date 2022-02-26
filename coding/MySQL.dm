var/MySQL/MySQL = new
MySQL
	var
		DBConnection/handle
	proc
		IsOpen() return (handle && handle.IsConnected())
		Open()
			if(!IsOpen())
				handle = new()

				var
					host = settings["db_host"]
					port = 3306
					pos = findtext(host, ":")
				if(pos)
					port = text2num(copytext(host, pos + 1))
					host = copytext(host, 1, pos)
				return handle.Connect("dbi:mysql:[settings["db_name"]]:[host]:[port]",settings["db_user"],settings["db_pass"])
			return -1
		Close()
			if(IsOpen())
				handle.Disconnect()
				handle = null
		Query(sql)
			if(!handle) return
			var/DBQuery/qry = handle.NewQuery(sql)
			if(!qry.Execute())
				world.log << "SQL Error<br>Query: [sql]<br>Error: [qry.ErrorMsg()]"
			return qry
		Escape(string)
			if(!string) return "''"
			return handle.Quote(string)