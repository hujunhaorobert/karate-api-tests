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
    4. Bear in mind that if increasing the parallel worker number, it will increase API concurrency and the load to server, as a consequence, the API response time will be longer than usual.
       Tipically it will be 500ms if n=1; when set n=10, response time will be >2000ms, which causes responseTime assertion failure, as maxResponseTimeinMs is set to 2000ms in karate-config.js.

## How to open Cucumber HTML report
    Under target > cucumber-html-report, open file overview-features.html in any browser
   
## Roadmap for future development and enhancement
    To be improved:
        1. Weather api key is a sensitive data, for quick demo purpose, it has been stored in karate-conf.js, while the best practice would be upload the api key to cloud, e.g. AWS Secrete Manager, and retrieve it when needed.  An alternative could be put to .env.
        2. API key in log should be masked as ****, to avoid secret leakage in log, e.g. Cucumber HTML report. Currently there is api key marsking solution by Karate Framework, but not fully ready yet. Please refer to link:https://github.com/karatelabs/karate#log-masking
        3. Could utilize or import 3rd party Database/Table management package or tools, and import the csv table meta data into DB, so that DB/Table query will be easier and more efficient.
        4. Feature Background set up, these seems to be common steps, so it could be put into a common feature file. Some common validation steps, e.g. validate response header, etc, could be refactored to a common feature file as well.
    
    For future development:
        1. Given time is limited, the AC4 job is on the half way to finish, basically the design solution is similar as AC3, and the high level implementation steps are documented at the Feature file header part, which need time to be fully tested/implemented.
        8. CI/CD could be enabled, e.g. CircleCI, add slack and SMS notification(e.g. https://github.com/hujunhaorobert/playwright-automation)

## Bug list to be reported and triaged with DEV team
    1. Schema validation failed for lat/lon, becauses api.weatherbit.io/v2.0/current?cities=<cityIDs> response lat/lon as string(X), in other endpoints, it respones as number(as expected), better to keep the data type consistent. Detail failure as below:
         $.data[0].lat | not a number (STRING:STRING)
        '42.43603'
        '#number'
    2. GET http://api.weatherbit.io/v2.0/current?cities=NaN&key=<apiKey> returns 500, ideally if GET API cannot retrieve/find the weather data by cityID, it would be better to return RC=400, rather than 500
