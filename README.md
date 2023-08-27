# Karate API Tests Framework

This repo has referred to the [Getting Started Guide](https://github.com/karatelabs/karate/wiki/Get-Started:-Maven-and-Gradle#github-template).


## Project Structure
The project is structured as follows:

```bash
📦 karate-api-tests
├─ .gitignore
├─ LICENSE
├─ README.md
├─ pom.xml
└─ src
   ├─ test
   │  └─ java
   │     ├─ features
   │     │  ├─ weather
   │     │  │  ├─ getAuWarmestCapitalCity.feature   -> AC3 solution
   │     │  │  ├─ getUsaColdestState.feature        -> AC4 solution 
   │     │  │  ├─ getWeatherByCityNameOrIDs.feature -> AC1 solution
   │     │  │  ├─ getWeatherByLatitudeLongitude.feature -> AC2 solution
   │     │  │  └─ WeatherRunner.java
   │     │  └─ WeatherTest.java
   │     ├─ metadata
   │     │   ├─ cities_all.csv
   │     │   └─ states.csv
   │     │─ schemas
   │     │      └─  weatherDataSchema.json
   │     ├─ utils
   │     │  ├─ query.feature
   │     │  └─ utils.js
   │     ├─ karate-config.js
   │     └─ logback-test.xml

```
## How to setup the automation test
    1. Git clone the repo
    2. Install JAVA and/or latest JDK, e.g. openjdk version "11.0.15"
    3. Install Apache Maven e.g., 3.9.3
   
## How to run the test
    1. Go to the project root folder: cd karate-api-tests
    2. Run cli: mvn clean test
    3. API Tests has been set to run in parallel with workers num=10, could be increased, e.g. to 20 or even bigger to speed up the testing. 

## How to open Cucumber HTML report
    Under target > cucumber-html-report, open file overview-features.html in any browser
   
## Roadmap for future development and enhancement
    To be improved:
        1. weather api key is a sensitive data, for quick and easy demo purpose, it has been put in karate-conf.js, while best practice is to upload the api key to AWS Secrete Manager, and fetch from it when needed.  An alternative could be put to .env.
        2. api key log should be masked as **** , to avoid secret leakage in Cucumber HTML report. Currently there will be api key marking solution by Karate Framework on roadmap, but not fully ready yet. 
        3. Feature Background set up, could be put into a common feature file. 
        4. Could utilize or import 3rd party Database/Table management software or tools, so that DB/Table operation will be more efficient.
        5. Some common validation steps, e.g. validate response header, etc, could be refactored to a common feature file
    
    For future development:
        1. Given time is limited, the AC4 job is on the half way to finish, basically the design solution is similar as AC3, and the details is documented at the Feature header part, which need time to be fully tested/implemented.

## Bug list to be reported and triaged with DEV team
    1. Schema validation failed for lat/lon, becauses api.weatherbit.io/v2.0/current?cities=<cityIDs> response lat/lon as string(X), in other endpoints, it respones as number(as expected), we need keep the data type agligned. Detail failure as below:
         $.data[0].lat | not a number (STRING:STRING)
        '42.43603'
        '#number'
    2. GET http://api.weatherbit.io/v2.0/current?cities=NaN&key=<apiKey> returns 500, ideally if GET API cannot retrieve the weather data by cityID, it would be better to return RC=400, rather than 500
