FROM dind-java-base-image

# Prepare Devbox Environment
RUN apk add --no-cache \
    bash-completion \
    emacs \
    docker-bash-completion \
    gnupg \
    nano \
    rng-tools \
    ttyd \
    vim

# Tune the TTYD terminal Windows to avoid loosing last line when scrolling
# RUN curl -L -o /index.html \
#     https://raw.githubusercontent.com/tsl0922/ttyd/master/src/index.html \
#   && sed -i 's/height:100%;/height:98%;/g' /index.html

RUN git config --global user.email "${user}@localhost.local" \
  && git config --global user.name "${user}"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 7681

ENTRYPOINT ["/sbin/tini","-g","--","bash"]
CMD ["/usr/local/bin/entrypoint.sh"]
