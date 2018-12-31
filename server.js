'use strict';
const express = require('express');
const createMiddleware = require('swagger-express-middleware');

/**************************************************************************************************
 * This sample demonstrates the most simplistic usage of Swagger Server.
 * It simply creates a new instance of Swagger Server and starts it.
 * All functionality is provided automatically by Swagger Server's mocks.
 * Validate and Parse the API yaml/json before starting
 **************************************************************************************************/

var port = 8080;
let app = express();

createMiddleware('HelloWorld.yaml', app, function (err, middleware) {
  // Add all the Swagger Express Middleware, or just the ones you need.
  // NOTE: Some of these accept optional options (omitted here for brevity)
  app.use(
    middleware.metadata(),
    middleware.CORS(),
    middleware.files(),
    middleware.parseRequest(),
    middleware.validateRequest(),
    middleware.mock()
  );

  app.listen(port, function () {
    console.log('HelloWorld is now running at http://localhost:' + port);
  });

});
