FROM apache/hive:4.1.0

# MySQL Connector/J backs the metastore; the S3A jars (hadoop-aws + AWS SDK
# bundle, already version-matched to the bundled Hadoop) ship inside the image
# under hadoop's tools dir but are not on Hive's classpath — link them in.
ARG MYSQL_CONNECTOR_VERSION=9.4.0

USER root

RUN curl -fSL -o /opt/hive/lib/mysql-connector-j-${MYSQL_CONNECTOR_VERSION}.jar \
      https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_CONNECTOR_VERSION}/mysql-connector-j-${MYSQL_CONNECTOR_VERSION}.jar && \
    chown hive:hive /opt/hive/lib/mysql-connector-j-*.jar && \
    ln -s /opt/hadoop/share/hadoop/tools/lib/hadoop-aws-*.jar /opt/hive/lib/ && \
    ln -s /opt/hadoop/share/hadoop/tools/lib/*bundle*.jar /opt/hive/lib/

USER hive
