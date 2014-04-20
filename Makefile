SSH_HOST=shitbird.caremad.io
SSH_TARGET_DIR=/srv/blog


install:
	pip install -r requirements.txt

serve:
	liquidluck server -d

clean:
	rm -rf $(CURDIR)/deploy/

build: clean
	liquidluck build -v
	find deploy -name '*.html' -exec sh -c 'gzip -c "{}" > "{}.gz"' \;
	find deploy -name '*.xml' -exec sh -c 'gzip -c "{}" > "{}.gz"' \;
	find deploy -name '*.css' -exec sh -c 'gzip -c "{}" > "{}.gz"' \;

upload: build
	rsync -rz --delete --no-perms $(CURDIR)/deploy/ $(SSH_HOST):$(SSH_TARGET_DIR)
	ssh -t $(SSH_HOST) 'chgrp -R nginx $(SSH_TARGET_DIR)'
