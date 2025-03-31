
article:
	hugo new content/blog/$(folder)/index.md

serve:
	# using docker to run hugo server
	docker run \
		-p 1313:1313 \
		-v $(shell pwd):/app \
		-w /app \
		hugomods/hugo:exts-0.119.0 \
		hugo server \
		--buildDrafts \
		--bind=0.0.0.0 \
		--disableFastRender

build:
	docker run -v $(shell pwd):/app -w /app hugomods/hugo:exts-0.119.0 build
