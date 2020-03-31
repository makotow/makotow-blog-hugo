# bumpup version here.
VERSION := 1.0
CURDIR := $(shell pwd)
HUGO := hugo
REMOTE := origin
BRANCH := master

## Shortcuts

po: post
p: preview
d: deploy
u: update-theme

## Commands

# base_url can be assigned by make parameter.
.PHONY: preview
preview:
	hack/preview.sh ${base_url} 

.PHONY: post
post:
ifdef title
	hack/new-post.sh ${title}
else
	@echo "Please specify post title.\n"
	@echo "   Example: make post title=your_article_title"
endif

.PHONY: deploy
deploy:
	git push $(REMOTE) $(BRANCH)

.PHONY: update-theme
update-theme:
	git submodule update --rebase --remote
