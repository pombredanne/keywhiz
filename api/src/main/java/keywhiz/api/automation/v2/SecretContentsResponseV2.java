package keywhiz.api.automation.v2;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.auto.value.AutoValue;
import com.google.common.collect.ImmutableMap;
import java.util.Map;

@AutoValue public abstract class SecretContentsResponseV2 {
  SecretContentsResponseV2() {} // prevent sub-classing


  public static Builder builder() {
    return new AutoValue_SecretContentsResponseV2.Builder()
        .successSecrets(ImmutableMap.of())
        .errorSecrets(ImmutableMap.of());
  }

  @AutoValue.Builder public abstract static class Builder {
    // intended to be package-private
    abstract SecretContentsResponseV2.Builder successSecrets(ImmutableMap<String, String> successSecrets);
    abstract SecretContentsResponseV2.Builder errorSecrets(ImmutableMap<String, String> errorSecrets);


    public SecretContentsResponseV2.Builder successSecrets(Map<String, String> successSecrets) {
      return successSecrets(ImmutableMap.copyOf(successSecrets));
    }
    public SecretContentsResponseV2.Builder errorSecrets(Map<String, String> errorSecrets) {
      return errorSecrets(ImmutableMap.copyOf(errorSecrets));
    }

    public abstract SecretContentsResponseV2 build();
  }

  /**
   * Static factory method used by Jackson for deserialization
   */
  @SuppressWarnings("unused")
  @JsonCreator public static SecretContentsResponseV2 fromParts(
      @JsonProperty("successSecrets") ImmutableMap<String, String> successSecrets,
      @JsonProperty("errorSecrets") ImmutableMap<String, String> errorSecrets) {
    return builder().successSecrets(successSecrets).errorSecrets(errorSecrets).build();
  }

  @JsonProperty("successSecrets") public abstract ImmutableMap<String, String> successSecrets();
  @JsonProperty("errorSecrets") public abstract ImmutableMap<String, String> errorSecrets();
}
