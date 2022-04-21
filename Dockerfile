FROM ubuntu
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install openjdk-17-jdk dpkg-dev -y
WORKDIR /tmp
ENTRYPOINT ["jpackage"]
CMD ["-h"]
