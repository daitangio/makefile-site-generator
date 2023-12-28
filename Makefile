# GG Taken from
# https://itnext.io/glorious-makefile-building-your-static-website-4e7cdc32d985
SRC_DIR = src
DST_DIR = build
TEMPLATE_DIR=template
BASE_URL="https://daitangio.github.io/makefile-site-generator"

TEMPLATE = $(TEMPLATE_DIR)/main_template.html


CSS_DIR = $(DST_DIR)/css
SCSS_DIR = $(SRC_DIR)/scss
SCSS_INCLUDES_DIR = $(SCSS_DIR)/includes

SCSS_FILES = $(wildcard $(SCSS_DIR)/*.scss)
CSS_FILES=$(patsubst $(SCSS_DIR)/%.scss, $(CSS_DIR)/%.css, $(SCSS_FILES))

JS_DIR=$(DST_DIR)/js
SRC_STATIC_FILES=$(wildcard $(SRC_DIR)/*.html) $(wildcard $(SRC_DIR)/css/*.css)  $(wildcard $(SRC_DIR)/js/*.js)
STATIC_FILES=$(subst $(SRC_DIR), $(DST_DIR), $(SRC_STATIC_FILES))

MD_FILES = $(shell find $(SRC_DIR) -type f -name '*.md')
HTML_FILES = $(patsubst $(SRC_DIR)/%.md, $(DST_DIR)/%.html, $(MD_FILES))

ALL_GENERATED_CONTENT=$(HTML_FILES) $(STATIC_FILES) $(DST_DIR)/sitemap.xml $(DST_DIR)/robots.txt


.PHONY: all
all: html css static $(DST_DIR)/robots.txt $(DST_DIR)/sitemap.xml  ## Build the whole website



#
# HTML
#

.PHONY: html
html: $(HTML_FILES) ## Build all HTML files from SLIM files (even nested)

# $(DST_DIR)/%.html: $(SRC_DIR)/%.md
# 	pandoc --from markdown --to html --standalone $< -o $@

$(DST_DIR)/%.html: $(SRC_DIR)/%.md $(TEMPLATE)
	@pandoc \
	--from markdown_github+smart+yaml_metadata_block+auto_identifiers \
	--to html \
	--template $(TEMPLATE) \
	--variable today="$$(date)" \
	--variable baseroot="${BASE_URL}" \
	-o $@ $<

#
# CSS
#

.PHONY: css
css: $(CSS_FILES) ## Build all CSS files from SCSS


$(CSS_DIR):
	mkdir -p $@

$(JS_DIR):
	mkdir -p $@

# Dependencies after a pipe symbol means the dependency only needs to exist
# GG This line must be revied
#$(CSS_DIR)/%.css: $(SCSS_DIR)/%.scss $(SCSS_INCLUDES_DIR)/_*.scss | $(CSS_DIR)
# $(CSS_DIR)/%.css: $(SCSS_DIR)/%.scss | $(CSS_DIR)
# 	sass --load-path=$(SCSS_INCLUDES_DIR) --style=compressed  $< $@

# Static mngmnt
static: $(STATIC_FILES)

$(DST_DIR)/%.html: $(SRC_DIR)/%.html
	cp $< $@

$(DST_DIR)/css/%.css: $(SRC_DIR)/css/%.css  | $(CSS_DIR)
	cp $< $@
$(DST_DIR)/js/%.js: $(SRC_DIR)/js/%.js  | $(JS_DIR)
	cp $< $@
#
# Robots.txt
#

$(DST_DIR)/robots.txt:
	@echo "User-agent: *" > $@
	@echo "Allow: *" >> $@
	@echo "Sitemap: $(BASE_URL)/sitemap.xml" >> $@

#
# Sitemap.xml
#

$(DST_DIR)/sitemap.xml: $(HTML_FILES)
	@echo '<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' > $@
	for f in $^; do echo "<url><loc>$(BASE_URL)$${f#$(DST_DIR)}<loc></url>" >> $@ ; done
	@echo '</urlset>' >> $@

#
# Helpers
#


.PHONY: clean
clean: $(ALL_GENERATED_CONTENT)  ## Delete eveything
	rm  $^
	# List of auto-managed directories
	rmdir $(DST_DIR)/css $(DST_DIR)/js


.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[34m%-15s\033[0m %s\n", $$1, $$2}'
# $(info SCSS_FILES=${SCSS_FILES})
# $(info CSS_FILES=${CSS_FILES})
# $(info CSS_DIR=${CSS_DIR})

# Extra features taken from https://www.karl.berlin/static-site.html
serve: ## Serve the site on port 8000
	python3 -m http.server -d build

# entr: Run arbitrary commands when files change
watch: ## Modify and rebuild locally
	find src  Makefile | entr make BASE_URL="http://localhost:8000/" 

install: ## Install software needed
	sudo apt install entr pandoc
	npm install -g sass

# Deploy to gh-pages branch according to
# https://sangsoonam.github.io/2019/02/08/using-git-worktree-to-deploy-github-pages.html
deploy: all ## Deploy gh-pages
	echo Deploying
	git worktree add public_html gh-pages
	cp -rf build/* public_html
	cd public_html && \
	  git add --all && \
	  git commit -m "Deploy to github pages" && \
	  git push origin gh-pages
	git worktree remove public_html