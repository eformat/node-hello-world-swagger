# Swagger Node Hello World

[Swagger node server using mocks] (https://www.npmjs.com/package/swagger-server)

[Swagger codegen] (https://github.com/swagger-api/swagger-codegen)

## Run

```npm install```
`` npm start```

[Browse to here to test] (http://localhost:8080)

## Generate JAX-RS stubs

```npm start```

```java -jar ~/git/swagger-codegen/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar generate \
  -i http://localhost:8080/api-docs/ \
  -l jaxrs \
  -o samples/jaxrs \
  -c swagger-generate-java-config.json```

