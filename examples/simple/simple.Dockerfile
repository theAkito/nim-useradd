FROM nimlang/nim:alpine AS build

LABEL testuseradd=true

COPY . /useradd

WORKDIR /useradd

RUN nimble dbuild


FROM akito13/alpine

LABEL testuseradd=true

COPY --from=build /useradd/useradd_debug /useradd
COPY examples/simple/example_simple_docker-entrypoint.sh /docker-entrypoint.sh

## https://www.reddit.com/r/gitlab/comments/mcwp8l/comment/gs5w742/
RUN chmod 4755 /bin/su

ENTRYPOINT [ "/bin/ash" ]
CMD [ "/docker-entrypoint.sh" ]