FROM opensuse/tumbleweed
RUN zypper in -y java-17-openjdk-devel rpm-build
RUN ln -s /usr/lib64/jvm/java-17-openjdk/bin/jpackage /etc/alternatives/jpackage; \
ln -s /etc/alternatives/jpackage /usr/bin/jpackage
WORKDIR /tmp
ENTRYPOINT ["jpackage"]
CMD ["-h"]
