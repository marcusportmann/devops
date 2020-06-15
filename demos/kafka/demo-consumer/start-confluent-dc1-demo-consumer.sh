#!/bin/sh
java -Dspring.profiles.active=confluent-dc1 -jar target/demo-consumer-0.0.1-SNAPSHOT.jar
