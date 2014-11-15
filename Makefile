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
	ssh $(SSH_HOST) "sudo find /srv/blog -type d -exec chmod 775 {} \;"
	ssh $(SSH_HOST) "sudo find /srv/blog -type f -exec chmod 664 {} \;"
	ssh $(SSH_HOST) "sudo chown -R www-data:www-data /srv/blog"
