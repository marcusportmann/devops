package com.example.demoproducer;

import java.util.HashMap;
import java.util.Map;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.boot.autoconfigure.kafka.KafkaProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;

@Configuration
public class DemoProducerConfiguration {

  private final KafkaProperties kafkaProperties;

  public DemoProducerConfiguration(KafkaProperties kafkaProperties) {
    this.kafkaProperties = kafkaProperties;
  }

  private Map<String, Object> demoProducerConfigs() {
    Map<String, Object> props = new HashMap<>(kafkaProperties.buildProducerProperties());
    props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
    props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
    props.put(ProducerConfig.ACKS_CONFIG, "1");
    return props;
  }

  private ProducerFactory<String, String> demoProducerFactory() {
    return new DefaultKafkaProducerFactory<>(demoProducerConfigs());
  }

  @Bean
  public KafkaTemplate<String, String> demoProducerKafkaTemplate() {
    return new KafkaTemplate<>(demoProducerFactory());
  }
}
