# Be careful: not tag-versioned, behavior may change

## To uncomment when released
#FROM tsl0922/ttyd:alpine

FROM alpine:edge
LABEL maintainer "Shuanglei Tao - tsl0922@gmail.com" \
    maintainer "Damien Duportal - damien.duportal@gmail.com"

RUN apk add --update --no-cache \
    bash \
    ttyd

EXPOSE 7681

ENTRYPOINT ["ttyd"]

CMD ["bash"]

# Prepare Dev Env
RUN apk add --update --no-cache openjdk8 maven git
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
VOLUME /workspace
WORKDIR /workspace

# Tune the TTYD terminal Windows to avoid loosing last line
# RUN curl -L -o /index.html \
#         https://raw.githubusercontent.com/tsl0922/ttyd/master/src/index.html \
#     && sed -i 's/height:100%;/height:98%;/g' /index.html
#
# CMD ["-I","/index.html","bash"]
