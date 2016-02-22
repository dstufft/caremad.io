CONTAINER_NAME=caremad_uploader

include .secret/Carina.mk

.secret/docker/docker.env:
	carina credentials --path=$(CURDIR)/.secret/docker $(CARINA_CLUSTER)

serve:
	hugo server --watch -b http://localhost/ --buildDrafts --buildFuture --theme=caremad

clean:
	rm -rf $(CURDIR)/deploy/

build: clean
	hugo --theme=caremad --destination=deploy/
	find deploy -name '*.html' -exec sh -c 'gzip -9 -c "{}" > "{}.gz"' \;
	find deploy -name '*.xml' -exec sh -c 'gzip -9 -c "{}" > "{}.gz"' \;
	find deploy -name '*.css' -exec sh -c 'gzip -9 -c "{}" > "{}.gz"' \;
	find deploy -name '*.js' -exec sh -c 'gzip -9 -c "{}" > "{}.gz"' \;

upload: .secret/docker/docker.env build
	$(eval HOST := $(shell bin/docker-env docker inspect --format '{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostIp}}' $(CONTAINER_NAME)))
	$(eval PORT := $(shell bin/docker-env docker inspect --format '{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostPort}}' $(CONTAINER_NAME)))

	rsync -rz --delete --no-perms -e "ssh -p $(PORT)" $(CURDIR)/deploy/ root@$(HOST):/srv/blog

bootstrap: .secret/docker/docker.env
	bin/docker-env docker-compose build --pull
	bin/docker-env docker-compose up -d
	bin/docker-env docker-compose run uploader sh -c 'ssh-keygen -A && mv /etc/ssh/*_host_* /etc/ssh/host-keys/'
	bin/docker-env docker-compose up -d
	bin/docker-env docker-compose restart

rebuild: .secret/docker/docker.env
	bin/docker-env docker-compose build --pull
	bin/docker-env docker-compose stop -t 3
	bin/docker-env docker-compose rm -f web uploader lets-encrypt
	bin/docker-env docker-compose up -d

shell: .secret/docker/docker.env
	bin/docker-env docker-compose run web sh

ps: .secret/docker/docker.env
	bin/docker-env docker-compose ps
