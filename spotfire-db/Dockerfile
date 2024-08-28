FROM microsoft/mssql-server-windows-developer:2016-sp1

ENV ADMINNAME=sa
ENV ADMINPASSWORD=saPassword123
ENV SERVERDB_NAME=spotfire_server
ENV SERVERDB_USER=spotfire_server
ENV SERVERDB_PASSWORD=SpotfireServer123

COPY install/* install/

CMD .\start -sa_password saPassword123 -ACCEPT_EULA y  -Verbose
