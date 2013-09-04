SSH_HOST=publish.caremad.io
SSH_TARGET_DIR=/var/www/caremad.io


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
	rsync -rz --delete $(CURDIR)/deploy/ $(SSH_HOST):$(SSH_TARGET_DIR)
	ssh -t $(SSH_HOST) 'chgrp -R www-data $(SSH_TARGET_DIR)'
