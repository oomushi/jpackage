FROM ubuntu
RUN apt-get install openjdk-17-jdk dpkg-dev -y
WORKDIR /tmp
ENTRYPOINT ["jpackage"]
CMD ["-h"]
