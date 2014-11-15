SSH_HOST=caremad.io
SSH_TARGET_DIR=/srv/blog


serve:
	hugo serve --watch --buildDrafts --buildFuture --theme=caremad

clean:
	rm -rf $(CURDIR)/deploy/

build: clean
	hugo --theme=caremad --destination=deploy/

upload: build
	rsync -rz --delete --no-perms $(CURDIR)/deploy/ $(SSH_HOST):$(SSH_TARGET_DIR)
