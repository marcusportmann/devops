package com.example.democonsumer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class DemoConsumerListener {

  private final Logger logger = LoggerFactory.getLogger(DemoConsumerListener.class);

  @KafkaListener(
      topicPattern = "(.*\\.test|test)",
      groupId = "demo-consumer",
      containerFactory = "demoKafkaListenerContainerFactory")
  public void consumer(String message) {
    logger.info(String.format("$$ -> Consumed Message -> %s", message));
  }
}
