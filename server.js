'use strict';
/**************************************************************************************************
 * This sample demonstrates the most simplistic usage of Swagger Server.
 * It simply creates a new instance of Swagger Server and starts it.
 * All functionality is provided automatically by Swagger Server's mocks.
 * Validate and Parse the API yaml/json before starting
 **************************************************************************************************/

// Set the DEBUG environment variable to enable debug output
process.env.DEBUG = 'swagger:*';

// Create a Swagger Server app from the PetStore.yaml file
var swaggerServer = require('swagger-server');
var SwaggerParser = require('swagger-parser');

var myAPI = 'HelloWorld.yaml';
var port = 8080;

var app = swaggerServer(myAPI);

// Validate it first
SwaggerParser.validate(myAPI)
    .then(function(api) {
      console.log("API name: %s, Version: %s", api.info.title, api.info.version);

      // Start listening on port 8000
      app.listen(port, function() {
          console.log('HelloWorld is now running at http://localhost:' + port);
      });
    })
    .catch(function(err) {
      console.error(err);
    });

