#!/bin/sh
java -Dspring.profiles.active=confluent-local -jar target/demo-consumer-0.0.1-SNAPSHOT.jar
