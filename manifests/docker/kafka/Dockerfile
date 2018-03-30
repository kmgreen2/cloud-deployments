FROM openjdk:8-jre-alpine

# Install bash
RUN echo http://nl.alpinelinux.org/alpine/v3.5/main > /etc/apk/repositories; \
    echo http://nl.alpinelinux.org/alpine/v3.5/community >> /etc/apk/repositories
RUN apk update
RUN /bin/sh -c "apk add --no-cache bash"
RUN /bin/sh -c "apk add --no-cache bind-tools"

ENV SCALA_VERSION 2.11
ENV KAFKA_VERSION 0.10.2.1

RUN mkdir /opt

RUN  wget -q -O - http://www.eu.apache.org/dist/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz | tar -xzf - -C /opt \
       && mv /opt/kafka_$SCALA_VERSION-$KAFKA_VERSION /opt/kafka

ENV PATH /opt/kafka/bin:$PATH

COPY /service/kafka/kafka-docker-entrypoint.sh /kafka-docker-entrypoint.sh

COPY ./config/kafka/conf /opt/kafka/config
VOLUME ["/opt/kafka/config"]

EXPOSE 9092
