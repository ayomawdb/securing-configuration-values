# Securing Configuration Values

The following are the sections available in this guide.

- [What you'll build](#what-youll-build)
- [Prerequisites](#prerequisites)
- [Developing the service](#developing-the-service)
- [Testing](#testing)

## What you’ll build
Ballerina Config API can be used to read configuration values from external sources such as program arguments, environment variables, and configuration files. There are certain situations where you might need to store and consume security sensitive configuration value. Passwords and client secrets used to access external services is one such example. In this guide, you will build a Ballerina program that uses configuration encryption mechanism to securely store and access security sensitive values, encrypted with AES/CBC/PKCS5Padding.  

## Prerequisites

- JDK 1.8 or later
- [Ballerina Distribution](https://github.com/ballerina-lang/ballerina/blob/master/docs/quick-tour.md)
- A Text Editor or an IDE

### Optional requirements
- Ballerina IDE plugins ([IntelliJ IDEA](https://plugins.jetbrains.com/plugin/9520-ballerina), [VSCode](https://marketplace.visualstudio.com/items?itemName=WSO2.Ballerina), [Atom](https://atom.io/packages/language-ballerina))
- [Docker](https://docs.docker.com/engine/installation/)

## Developing the service and encrypting configuration

- Although the language allows you to have any package structure, use the following package structure for this project to follow this guide.

```
secure-restful-service
  └── src
      ├── ballerina.conf
      └── securing_configuration_values
          ├── configuration_reader_service.bal
          └── test
              └── configuration_reader_service_test.bal          
```

- Once you created your package structure, go to the sample src directory and run the following command to initialize your Ballerina project.

```bash
   $ballerina init
```

  The above command will initialize the project with a `Ballerina.toml` file and `.ballerina` implementation directory that contain a list of packages in the current directory.

- Add the following content to your Ballerina service, which is simply reading the configuration value with the key "api.key" and print that in the response.

##### secure_order_mgt_service.bal
```ballerina
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

```

- In this guide we will use a configuration value stored in the configuration file. To add sample configuration value for initial testing, add following content to ballerina.conf file.

##### ballerina.conf
```
api.key="secret-api-key-value"

```

- With that we've completed creating a service that reads a configuration value. However, the "api.key" is still in plain-text. In order to encrypt the plain-text value, run the following command:

```
$ballerina encrypt
```

- A separate prompt will request you to enter the plain-text value to be encrypted, followed by the request for the encryption key. In this guide, we will use "secret-api-key-value" as the plain-text value and "ballerina" as the encryption key. The command will print the encrypted configuration value to be used.

```
ballerina encrypt
Enter value: secret-api-key-value

Enter secret: ballerina

Re-enter secret to verify: ballerina

Add the following to the runtime config:
@encrypted:{YqEP28mD/6JlIyI3RXs5uPqY2pVgWaRUymOuASVgJn8+tcFxcQMUyLrO/wKPV036}

Or add to the runtime command line:
-e<param>=@encrypted:{YqEP28mD/6JlIyI3RXs5uPqY2pVgWaRUymOuASVgJn8+tcFxcQMUyLrO/wKPV036}
```

- Change the ballerina.conf file to contain the encrypted configuration value.
##### ballerina.conf
```
api.key="@encrypted:{YqEP28mD/6JlIyI3RXs5uPqY2pVgWaRUymOuASVgJn8+tcFxcQMUyLrO/wKPV036}"

```

- With that we've completed securing the secret configuration value, while retaining the ability of reading the decrypted value from a Ballerina program.

## Testing

### Starting and invoking the service

You can run the service that you developed above, in your local environment. You need to have the Ballerina installation in you local machine and simply point to the <ballerina>/bin/ballerina binary to execute all the following steps.  

1. As the first step you can build a Ballerina executable archive (.balx) of the service that we developed above, using the following command. It points to the directory in which the service we developed above located and it will create an executable binary out of that. Navigate to the `<SAMPLE_ROOT>/src/` folder and run the following command.

```
$ballerina build securing_configuration_values
```

2. Once the securing_configuration_values.balx is created inside the target folder, you can run that with the following command.

```
$ballerina run target/securing_configuration_values.balx
```

3. Ballerina will now prompt for the encryption key, since you have an encrypted configuration value. Enter the encryption key. The encryption key we used in the previous step was "ballerina".

```
ballerina: enter secret for config value decryption:

```

3. The successful execution of the service should show us the following output.

```
$ ballerina run target/securing_configuration_values.balx

ballerina: enter secret for config value decryption:

ballerina: deploying service(s) in 'target/securing_configuration_values.balx'
ballerina: started HTTP/WS server connector 0.0.0.0:9090
```

4. You can test that Ballerina program could internally decrypt the configuration value by sending a HTTP request using 'curl'.

```
curl -v  http://localhost:9090/configs/readAPIKey

Output :  
< HTTP/1.1 200 OK
< content-type: text/plain
< content-length: 20
< server: ballerina/0.970.0-beta1-SNAPSHOT
< date: Wed, 18 Apr 2018 15:15:55 +0530
<
secret-api-key-value
```

### Writing unit tests

In Ballerina, the unit test cases should be in the same package inside a folder named as 'test'. The naming convention should be as follows,

* Test functions should contain test prefix.
  * e.g.: testReadAPIKey()

This guide contains unit test cases for each resource available in the 'configuration_reader_service.bal'.

To run the unit tests, go to the sample src directory and run the following command.
```bash
   $ballerina test
```

To check the implementation of the test file, refer to the [secure_order_mgt_service_test.bal](https://github.com/ballerina-guides/securing-configuration-values/blob/master/src/guides/securing_configuration_values/tests/configuration_reader_service_test.bal).
