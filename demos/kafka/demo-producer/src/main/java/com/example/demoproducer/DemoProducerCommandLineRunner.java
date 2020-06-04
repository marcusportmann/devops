package com.example.demoproducer;

import java.util.Date;
import java.util.UUID;
import org.springframework.boot.CommandLineRunner;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
public class DemoProducerCommandLineRunner implements CommandLineRunner {

  private KafkaTemplate<String, String> demoProducerKafkaTemplate;

  public DemoProducerCommandLineRunner(KafkaTemplate<String, String> demoProducerKafkaTemplate) {
    this.demoProducerKafkaTemplate = demoProducerKafkaTemplate;
  }

  @Override
  public void run(String... args) throws Exception {
    try {
      demoProducerKafkaTemplate.send(
          "test", UUID.randomUUID().toString(), "Test message sent at " + new Date().toString());

      demoProducerKafkaTemplate.flush();
    } catch (Throwable e) {
      System.out.println("[ERROR] " + e.getMessage());
      e.printStackTrace(System.out);
    }
  }
}
