# bumpup version here.
VERSION := 1.0
CURDIR := $(shell pwd)
HUGO := hugo
REMOTE := origin
BRANCH := master

## Shortcuts

p: preview
d: deploy
u: update-theme

## Commands

.PHONY: preview
preview:
	$(HUGO) server --disableFastRender --gc --debug

.PHONY: deploy
deploy:
	git push $(REMOTE) $(BRANCH)

.PHONY: update-theme
update-theme:
	git submodule update --rebase --remote
