mob/proc
	score_Add(score, val = 1)
		if(!client || !client.player) return
		var/player/P = client.player
		if(P && ("score_[score]" in P.vars))
			P.vars["score_[score]"]  += val
			spawn P.UpdateScore() //branch this off to avoid problems (e.x., double king bug)
	score_Rem(score, val = 1) return score_Add(score, -val)
	medal_Award(medal)
		if(!client || !client.player) return
		var/player/P = client.player
		return P.AwardMedal(medal)
	medal_Remove(medal)
		if(!client || !client.player) return
		var/player/P = client.player
		return P.RemoveMedal(medal)
	medal_Report(medal, additional)
		if(!client || !client.player) return
		var/player/P = client.player
		return P.ReportMedal(medal, additional)

proc
	medal2text(medal)
		var/type = medal2type(medal)
		switch(type)
			if(1) return "<font color=\"#3232CC\">[medal]</font>"
			if(2) return "<font color=\"#CC3232\">[medal]</font>"
			if(3) return "<font color=\"#D2A232\">[medal]</font>"
			else return "<font color=\"#32AA32\">[medal]</font>"
	medal2type(medal)
		var/list
			special = list("The Data's Brow Award", "Contributor", "Vanity Rules", "Vigilante")
			heavy = list()
			medium = list("Saint")
			light = list("Apprentice", "Member Of The Bovinia Book Club",
			"Woodcutter", "Chef de cuisine", "Overthrown", "Vertigo", "The Unfunny Man", "Good Morning", "Painter")
		if(medal in special) return 1
		else if(medal in heavy) return 2
		else if(medal in medium) return 3
		else if(medal in light) return 4
		return 1
	ScoreDenied()
		return dd_file2list("data/deny_score.txt", "\n")
	MedalDenied()
		return dd_file2list("data/deny_medal.txt", "\n")