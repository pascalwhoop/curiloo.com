
article:
	hugo new content/blog/$(folder)/index.md

serve:
	hugo server --buildDrafts --disableFastRender

build:
	docker run -v $(shell pwd):/app -w /app hugomods/hugo:exts-0.119.0 build
