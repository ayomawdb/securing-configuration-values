package securing_configuration_values;

import ballerina/http;
import ballerina/config;

endpoint http:Listener listener {
    port:9090
};

service<http:Service> configs bind listener {

    readAPIKey(endpoint client, http:Request req) {
        // Find the requested order from the map and retrieve it in JSON format.
        string apiKey = config:getAsString("api.key");
        http:Response response;

        // Set the JSON payload in the outgoing response message.
        response.setStringPayload(apiKey);

        // Send response to the client.
        _ = client -> respond(response);
    }

}
