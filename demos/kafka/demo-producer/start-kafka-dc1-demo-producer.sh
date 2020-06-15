#!/bin/sh
java -Dspring.profiles.active=kafka-dc1 -jar target/demo-producer-0.0.1-SNAPSHOT.jar
