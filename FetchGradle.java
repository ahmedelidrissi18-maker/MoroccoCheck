import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class FetchGradle {
  public static void main(String[] args) throws Exception {
    HttpClient client = HttpClient.newBuilder().build();
    HttpRequest request = HttpRequest.newBuilder()
      .uri(URI.create("https://plugins.gradle.org/m2/org/jetbrains/kotlin/kotlin-gradle-plugin/2.0.21/kotlin-gradle-plugin-2.0.21-gradle85.jar"))
      .GET()
      .build();
    HttpResponse<Void> response = client.send(request, HttpResponse.BodyHandlers.discarding());
    System.out.println(response.statusCode());
  }
}
