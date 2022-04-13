FROM openjdk:17.0.2-jdk-slim
WORKDIR /tmp
ENTRYPOINT ["jpackage"]
CMD ["-h"]
