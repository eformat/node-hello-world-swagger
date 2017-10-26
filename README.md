# Swagger Node Hello World

[Swagger node server using mocks] (https://www.npmjs.com/package/swagger-server)

[Swagger codegen] (https://github.com/swagger-api/swagger-codegen)

## Run locally

    npm install
    npm start

[Browse to here to test] (http://localhost:8080)


## Run in OSEv3

    oc project helloworld-dev
    oc new-app https://github.com/eformat/node-hello-world-swagger.git --name=helloworld --strategy=sti
    oc expose service helloworld --name=helloworld --hostname=helloworld-dev.apps.example.com

## Generate JAX-RS stubs (or any other code stubs - see codegen link)

https://github.com/swagger-api/swagger-codegen/wiki/Server-stub-generator-HOWTO#java-jax-rs-apache-cxf-framework-on-java-ee-server-supporting-cdi

    npm start

    java -jar ~/git/swagger-codegen/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar generate \
    -i http://localhost:8080/api-docs/ \
    -l jaxrs \
    -o samples/jaxrs \
    -c swagger-generate-java-config.json

    java -jar ~/git/swagger-codegen/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar generate \
    -i http://localhost:8080/api-docs/ \
    -l jaxrs-cxf-cdi \
    -o samples/jaxrs-cxf-cdi \
    -c swagger-generate-java-config.json

    java -jar ~/git/swagger-codegen/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar generate \
    -i http://localhost:8080/api-docs/ \
    -l spring \
    -o samples/springboot \
    -c swagger-generate-java-config.json


## java errors

Incorrect imports (remove)

    import io.swagger.model.Object;