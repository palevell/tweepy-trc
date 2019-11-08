from tweepy_trc import TrcFile

trc = TrcFile()
for key in trc.apis:
	api = trc.apis[key]
	me = api.me()
	print(me.screen_name, me.status.text)
