FROM centos
MAINTAINER Gokul
RUN yum -y install java
RUN java -version
RUN yum -y install tomcat

WORKDIR /opt/tomcat/webapps
CMD 'git clone https://github.com/rishi154/helloworld'

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]