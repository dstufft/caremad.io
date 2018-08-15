HOST="shitbird.caremad.io"

serve:
	hugo serve -b http://localhost/ --buildDrafts --buildFuture

clean:
	rm -rf $(CURDIR)/deploy/

build: clean
	hugo --destination=deploy/ --buildDrafts
	find deploy -name '*.html' -exec sh -c 'gzip -9 -c "{}" > "{}.gz"' \;
	find deploy -name '*.xml' -exec sh -c 'gzip -9 -c "{}" > "{}.gz"' \;
	find deploy -name '*.css' -exec sh -c 'gzip -9 -c "{}" > "{}.gz"' \;
	find deploy -name '*.js' -exec sh -c 'gzip -9 -c "{}" > "{}.gz"' \;

upload: build
	rsync -rz --delete --no-perms $(CURDIR)/deploy/ $(HOST):/var/www/caremad.io/
