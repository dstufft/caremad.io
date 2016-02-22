FROM alpine:latest

RUN apk --no-cache add openssh rsync

ADD sshd_config /etc/ssh/sshd_config
ADD authorized_keys /root/.ssh/authorized_keys

RUN chmod -R 600 /root/.ssh/

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
