
article:
	hugo new content/blog/$(folder)/index.md

serve:
	hugo server --buildDrafts --disableFastRender
build:
	hugo --minify