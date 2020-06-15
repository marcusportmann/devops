#!/bin/sh
java -Dspring.profiles.active=confluent-dc2 -jar target/demo-consumer-0.0.1-SNAPSHOT.jar
