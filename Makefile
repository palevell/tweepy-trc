# Makefile v1.1.31 - Tuesday, September 5, 2017

SHELL		:= /usr/bin/env bash
PROJECT		:= $(shell basename ${PWD})
ROOT		:= $$(dirname $${PWD} |sed s,$${HOME}/,,)
TIMESTAMP	:= $(shell date +%s)
SUFFIX		:= $(shell date +\~.%s)
BAKDIR		:= local/backups
BACKUPS		:= --suffix='~.$(TIMESTAMP)' --backup-dir=$(BAKDIR) 
EXCLUDES	:= {'.DS_Store','*~*','.idea','__pycache__','flask','*.db','db_repository*','local','tmp/*'}
ROPTS		:= -Cabhuve 'ssh -Aq' --exclude=$(EXCLUDES) $(BACKUPS) --delete

.PHONY: help

help:
	@cat Makefile-help.txt

dryget:
	@rsync $(ROPTS) --dry-run btcdev:$(ROOT)/$(PROJECT)/ ~/$(ROOT)/$(PROJECT)

get:
	@rsync $(ROPTS) btcdev:$(ROOT)/$(PROJECT)/ ~/$(ROOT)/$(PROJECT)

drygethq:
	@rsync --dry-run $(ROPTS) hq:$(ROOT)/$(PROJECT)/ ~/$(ROOT)/$(PROJECT)

gethq:
	@rsync $(ROPTS) hq:$(ROOT)/$(PROJECT)/ ~/$(ROOT)/$(PROJECT)

dryputhq:
	@rsync --dry-run $(ROPTS) ~/$(ROOT)/$(PROJECT)/ hq:$(ROOT)/$(PROJECT)

puthq:
	@rsync $(ROPTS) ~/$(ROOT)/$(PROJECT)/ hq:$(ROOT)/$(PROJECT)

dryput:
	@rsync --dry-run $(ROPTS) ~/$(ROOT)/$(PROJECT)/ btcdev:$(ROOT)/$(PROJECT)

put:
	@rsync $(ROPTS) ~/$(ROOT)/$(PROJECT)/ btcdev:$(ROOT)/$(PROJECT)

drysync: dryget dryput

sync: get put

testpypi:
	@echo $(PROJECT)
	pip3 install 'twine>=1.5.0' >/dev/null
	python3 setup.py sdist bdist_wheel
	twine upload --repository testpypi dist/*
	rm -fr build/* dist/* *.egg-info

publish:
	pip3 install 'twine>=1.5.0'
	python3 setup.py sdist bdist_wheel
	twine upload dist/*
	rm -fr build/* dist/*  *.egg-info

clean-dist:
	rm -fr build/* dist/*  *.egg-info

docs:
	cd docs && make html
	@echo "\033[95m\n\nBuild successful! View the docs homepage at docs/_build/html/index.html.\n\033[0m"
