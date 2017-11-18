FROM dind-java-base-image

# Tune SSH Server for Jenkins Usage + sending logs on stdout
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
  && sed -i 's/#RSAAuthentication.*/RSAAuthentication yes/' /etc/ssh/sshd_config \
  && sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
  && sed -i 's/#SyslogFacility.*/SyslogFacility AUTH/' /etc/ssh/sshd_config \
  && sed -i 's/#LogLevel.*/LogLevel INFO/' /etc/ssh/sshd_config \
  && mkdir /var/run/sshd \
  && rm -f /var/log/auth.log \
  && ln -s /dev/stdout /var/log/auth.log

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 22

# Overwrite parent execution
ENTRYPOINT ["/sbin/tini","-g","--","bash"]
CMD ["/usr/local/bin/entrypoint.sh"]
