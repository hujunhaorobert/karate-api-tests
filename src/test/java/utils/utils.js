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
    }
  }
}