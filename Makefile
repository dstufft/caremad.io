SSH_HOST=shitbird.caremad.io
SSH_TARGET_DIR=/srv/blog


serve:
	hugo serve --watch --buildDrafts --theme=caremad

clean:
	rm -rf $(CURDIR)/public/
