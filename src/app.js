'use strict';
// Sample webhook showing what a hasura auth webhook looks like

// init project
const fastify = require('fastify')({ logger: true })
const jwt = require('jsonwebtoken');

const PORT = 3000;
const JWT_SECRET = 'myjwtsecret';

/* A simple sample
   Flow:
   1) Extracts token
   2) Fetches userInfo in a mock function
   3) Return hasura variables
*/
function fetchUserInfo (token, cb) {
  // This function takes a token and then makes an async
  // call to the session-cache or database to fetch
  // data that is needed for Hasura's access control rules

  // todo: jwt.verify should be used instead
  const decoded = token && jwt.decode(token);

  if (decoded?.role && decoded?.user_id) {
    return cb(decoded);
  }

  cb();
}

fastify.get('/', (req, res) => {
  res.send('Webhooks are running');
});

fastify.post('/auth', async (req, res) => {
  const { arg1 } = req.body.input;

  // run some business logic

  /*
  // In case of errors:
  return res.code(400).send({
    message: "error happened"
  })
  */

  // success
  return res.send({
    accessToken: jwt.sign(arg1, JWT_SECRET),
  });

});

fastify.get('/webhook', (req, res) => {
  // Extract token from request
  const authorization = req.headers.authorization || '';
  const token = authorization.split(/^Bearer /)[1];

  // Fetch user_id that is associated with this token
  fetchUserInfo(token, (result) => {

    // Return appropriate response to Hasura
    const hasuraVariables = result
      ? {
        'X-Hasura-Role': result.role,
        'X-Hasura-User-Id': result.user_id,
      } : {
        'X-Hasura-Role': 'anonymous',
      };
    
    res.send(hasuraVariables);
  });
});

// listen for requests :)
fastify.listen({ port: PORT }, (err) => {
  if (err) {
    fastify.log.error(err);
    process.exit(1);
  }
})
