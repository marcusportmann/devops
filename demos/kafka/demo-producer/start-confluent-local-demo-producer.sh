#!/bin/sh
java -Dspring.profiles.active=confluent-local -jar target/demo-producer-0.0.1-SNAPSHOT.jar
