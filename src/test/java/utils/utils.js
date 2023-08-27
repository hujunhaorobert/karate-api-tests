//just a workaround JS utility to collect common functions for Karate
function utils() {
  return {
    createUUID: () => java.util.UUID.randomUUID(),

    randomIndexInArray: array => new java.util.Random().nextInt(array.length),

    sleep: seconds => {
      karate.log(`sleeping for ${seconds} s`);
      for(let i = 0; i < seconds; i++, karate.log(`zzz... ${i} s`))
      {
        java.lang.Thread.sleep(1*1000);
      }
    },

    command: cli => {
      const proc = karate.fork({ redirectErrorStream: false, useShell: true, line: cli });
      proc.waitSync();
      karate.set('sysOut', proc.sysOut);
      karate.set('sysErr', proc.sysErr);
      karate.set('exitCode', proc.exitCode);
    },

    triggerLambda: lambdaARN => command(`aws lambda invoke --function-name ${lambdaARN} --invocation-type Event --cli-binary-format raw-in-base64-out --payload '{"name": "Bob"}' target/awscli-response.json`),

  }
}