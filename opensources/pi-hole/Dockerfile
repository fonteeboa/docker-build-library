FROM pihole/pihole:latest
EXPOSE 53/tcp 53/udp 80/tcp 443/tcp
ENV TZ='America/Sao_Paulo' \
    FTLCONF_dns_listeningMode='all'

RUN rm -rf /var/www/html/admin
COPY . /va/www/html/admin/
VOLUME ["/etc/pihole"]
CMD ["/s6-init"]
