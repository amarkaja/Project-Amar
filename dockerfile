FROM tomcat:9
ADD ABCtechnologies-1.0.war /usr/local/tomcat/webapps
EXPOSE 8080
CMD ["catalina.sh", "run"]
