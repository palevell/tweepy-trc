# -*- coding: utf-8 -*-

from os.path import expanduser, join

import tweepy
from munch import *

from .config import Config
from .utils import yaml_load

class TrcFile(Munch):
	"""
	This returns a collection of Tweepy api objects
	(one for each account in the .trc or .twurlrc file.)
	"""
	def __init__(self):
		self.__filename = join(expanduser('~'), Config.TRCFILENAME)
		self.__data = Munch.fromDict(yaml_load(self.__filename))
		self.configuration = self.__data.configuration
		self.__profiles = self.__data.profiles
		self.active_profile = self.configuration.default_profile
		self.active_consumer_key = self.__profiles[self.active_profile[0]][self.active_profile[1]]['consumer_key']
		self.active_consumer_secret = self.__profiles[self.active_profile[0]][self.active_profile[1]]['consumer_secret']
		self.active_token = self.__profiles[self.active_profile[0]][self.active_profile[1]]['token']
		self.active_secret = self.__profiles[self.active_profile[0]][self.active_profile[1]]['secret']
		# taccts
		self.usernames = list(self.__profiles.keys())
		self.__oauth_keys = {}
		for profile in self.__profiles:
			for appID in self.__profiles[profile]:
				self.__oauth_keys[profile] = [
					self.__profiles[profile][appID]['username'],
					self.__profiles[profile][appID]['consumer_key'],
					self.__profiles[profile][appID]['consumer_secret'],
					self.__profiles[profile][appID]['token'],
					self.__profiles[profile][appID]['secret'], ]
		self.__auths = {}
		self.apis = {}
		for key in self.__oauth_keys.keys():
			username, consumer_key, consumer_secret, token, secret = self.__oauth_keys[key]
			self.__auths[key] = tweepy.OAuthHandler(consumer_key, consumer_secret)
			self.__auths[key].set_access_token(token, secret)
			self.apis[key] = tweepy.API(self.__auths[key],
			                            wait_on_rate_limit=True,
			                            wait_on_rate_limit_notify=True,
			                            proxy=None)
		self.api = self.apis[self.active_profile[0]]
		self.me = self.api.me()
