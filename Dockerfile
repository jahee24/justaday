FROM ubuntu:latest
LABEL authors="hee"

ENTRYPOINT ["top", "-b"]