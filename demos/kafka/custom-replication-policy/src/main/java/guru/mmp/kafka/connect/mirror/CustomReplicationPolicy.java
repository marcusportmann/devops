package guru.mmp.kafka.connect.mirror;

import java.util.Map;
import java.util.regex.Pattern;
import org.apache.kafka.common.Configurable;
import org.apache.kafka.connect.mirror.MirrorClientConfig;
import org.apache.kafka.connect.mirror.MirrorConnectorConfig;
import org.apache.kafka.connect.mirror.ReplicationPolicy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CustomReplicationPolicy implements ReplicationPolicy, Configurable {

  private static final Logger logger = LoggerFactory.getLogger(CustomReplicationPolicy.class);

  // In order to work with various metrics stores, we allow custom separators.
  public static final String SEPARATOR_CONFIG = MirrorClientConfig.REPLICATION_POLICY_SEPARATOR;
  public static final String SEPARATOR_DEFAULT = ".";

  private String separator = SEPARATOR_DEFAULT;
  private Pattern separatorPattern = Pattern.compile(Pattern.quote(SEPARATOR_DEFAULT));

  private String sourceClusterAlias;
  private String targetClusterAlias;

  @Override
  public void configure(Map<String, ?> props) {
    if (props.containsKey(SEPARATOR_CONFIG)) {
      separator = (String) props.get(SEPARATOR_CONFIG);
      logger.info("Using custom remote topic separator: '{}'", separator);
      separatorPattern = Pattern.compile(Pattern.quote(separator));
    }

    sourceClusterAlias = (String) props.get(MirrorConnectorConfig.SOURCE_CLUSTER_ALIAS);
    if (sourceClusterAlias == null) {
      String logMessage =
          String.format("Property %s not found", MirrorConnectorConfig.SOURCE_CLUSTER_ALIAS);
      logger.error(logMessage);
      throw new RuntimeException(logMessage);
    } else {
      logger.info("Using source cluster alias: " + sourceClusterAlias);
    }

    targetClusterAlias = (String) props.get(MirrorConnectorConfig.TARGET_CLUSTER_ALIAS);
    if (targetClusterAlias == null) {
      String logMessage =
          String.format("Property %s not found", MirrorConnectorConfig.TARGET_CLUSTER_ALIAS);
      logger.error(logMessage);
      throw new RuntimeException(logMessage);
    } else {
      logger.info("Using target cluster alias: " + targetClusterAlias);
    }
  }

  @Override
  public String formatRemoteTopic(String sourceClusterAlias, String topic) {
    String remoteTopic = sourceClusterAlias + separator + topic;

    logger.info("[formatRemoteTopic] remote topic = " + remoteTopic);
    return remoteTopic;
  }

  @Override
  public String topicSource(String topic) {

    logger.info("[topicSource] topic = " + topic);

    String[] parts = separatorPattern.split(topic);
    if (parts.length < 2) {
      // this is not a remote topic
      return null;
    } else {
      return parts[0];
    }
  }

  @Override
  public String upstreamTopic(String topic) {
    logger.info("[upstreamTopic] topic = " + topic);

    String source = topicSource(topic);
    if (source == null) {
      return null;
    } else {
      return topic.substring(source.length() + separator.length());
    }
  }
}
