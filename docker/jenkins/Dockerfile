FROM jenkins:2.46.3

COPY plugins.txt /tmp/plugins.txt

RUN /usr/local/bin/install-plugins.sh $(cat /tmp/plugins.txt) \
	&& git config --global user.email "${user}@localhost.local" \
  && git config --global user.name "${user}" \
	&& curl -L -o /usr/share/jenkins/ref/insecure_vagrant_key \
  https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant

COPY ./ref /usr/share/jenkins/ref
