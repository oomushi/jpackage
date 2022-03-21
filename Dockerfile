FROM openjdk:17.0.2-windowsservercore
RUN powershell Set-Service -Name wuauserv -StartupType "Manual"
RUN powershell Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All -NoRestart -WarningAction SilentlyContinue
WORKDIR c:/
COPY ./files/ .
RUN ["wix311.exe", "/install", "/quiet", "/norestart"]
RUN del wix311.exe
WORKDIR c:/tmp
ENTRYPOINT ["jpackage"]
CMD ["-h"]
