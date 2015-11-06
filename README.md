# swagger node hello world

see https://www.npmjs.com/package/swagger-server
see https://github.com/swagger-api/swagger-codegen

# generate JAX-RS stubs
npm start
java -jar ~/git/swagger-codegen/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar generate \
  -i http://localhost:8080/api-docs/ \
  -l jaxrs \
  -o samples/jaxrs \
  -c swagger-generate-java-config.json

