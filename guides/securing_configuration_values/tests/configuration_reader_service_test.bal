package securing_configuration_values;

import ballerina/test;
import ballerina/http;
import ballerina/file;
import ballerina/io;

@test:BeforeSuite
function beforeFunc() {
    file:Path filePath = new("secret.txt");
    boolean fileCreated = check file:createFile(filePath);
    if (fileCreated) {
        var openFileResult = io:openFile("secret.txt", "w");
        match (openFileResult) {
            io:ByteChannel byteChannel => {
                var createCharacterChannelResult = check io:createCharacterChannel(byteChannel, "ASCII");
                match (createCharacterChannelResult) {
                    io:CharacterChannel characterChannel => {
                        var writeCharactersResult = characterChannel.writeCharacters("ballerina", 0);
                        match (writeCharactersResult) {
                            int length => {
                                // Start the 'configuration_reader' service before running the test.
                                _ = test:startServices("securing_configuration_values");
                            }
                            io:IOError error => { return; }
                        }
                    }
                }
            }
        }

    }
}

endpoint http:Client clientEPUnauthenticated {
    targets:[{url:"http://localhost:9090/configs"}]
};

@test:Config
// Function to test GET resource 'readAPIKey'.
function testReadAPIKey() {
    // Initialize the empty http request.
    http:Request request;
    // Send 'GET' request and obtain the response.
    http:Response response = check clientEPUnauthenticated -> get("/readAPIKey", request);
    // Expected response code is 200.
    test:assertEquals(response.statusCode, 200,
        msg = "readAPIKey resource did not respond with expected response code!");
    // Check whether the response is as expected.
    string resPayload = check response.getStringPayload();
    test:assertEquals(resPayload, "secret-api-key-value", msg = "Response mismatch!");
}

@test:AfterSuite
function afterFunc() {
    // Stop the 'configuration_reader' service after running the test.
    test:stopServices("securing_configuration_values");
}
