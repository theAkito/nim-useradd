FROM nimlang/nim:alpine AS build

COPY . /useradd

WORKDIR /useradd

RUN nim c --forceBuild:on --debuginfo:on --out:custom_salt examples/custom_salt/custom_salt.nim

FROM akito13/alpine

LABEL testuseradd=true

COPY --from=build /useradd/custom_salt /custom_salt
COPY examples/custom_salt/example_custom-salt_docker-entrypoint.sh /docker-entrypoint.sh

## https://www.reddit.com/r/gitlab/comments/mcwp8l/comment/gs5w742/
RUN chmod 4755 /bin/su

ENTRYPOINT [ "/bin/ash" ]
CMD [ "/docker-entrypoint.sh" ]