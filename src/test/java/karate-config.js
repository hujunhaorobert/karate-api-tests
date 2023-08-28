function fn() {
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var config = {
    env: env,
    apiKey: 'fbe08dca4320471c942aed0113c55892',
    weatherbitBaseUrl: 'api.weatherbit.io/v2.0/',
    maxResponseTimeinMs: 2000
  }
  if (env == 'dev') {
    // customize
    // e.g. config.foo = 'bar';
  } else if (env == 'e2e') {
    // customize
  }
  karate.configure('logPrettyResponse', true);
  return config;
}