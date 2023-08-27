Feature: “As a frequent flyer, I want to programmatically find the current warmest capital city in Australia
        1. Import cities_all.csv as JSON array/table, parse the table to get capital city IDs
        2. GET a group of observations by cities' ID list => /current?cities={cities}
        3. Query the weather result list, get the highest temp value of the campital city

Background: Set up the Weather API endpoints
    * callonce read('classpath:utils/query.feature')
    * call read('classpath:utils/utils.js')
    * def allCitiesJsonFromCsv = read('classpath:metadata/cities_all.csv')
    * print 'allCitiesJsonFromCsv[0] = ', allCitiesJsonFromCsv[0]
    * print 'allCitiesJsonFromCsv.length = ', allCitiesJsonFromCsv.length
    * def weatherSchema = {code: '#number', icon: '#string', description: '#string'}
    * def minutelySchema = {precip: '#number', snow: '#number', temp: '#number', ts: '#number', timestamp_utc: '#string', timestamp_local: '#string'}
    * def weatherDataSchema = read('classpath:schemas/weatherDataSchema.json')
    * def getWeatherByCityResponseSchema =
    """
    {
        alerts: '##[]',
        count: '#number', 
        data: '#[] #(weatherDataSchema)',
        minutely: '##[_ == 60] #(minutelySchema)'
    }
    """
Scenario Outline: #1.<no> Happy path: Basic positive tests, <Protocol> Get current warmest capital city in Australia
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    * def auCapitalCityNameList = ["Sydney", "Melbourne", "Brisbane", "Perth", "Adelaide", "Hobart", "Canberra", "Darwin"]
    * def australiaCountryCode = 'AU'
    * def citiesIDList = getCityIdListByKVListAndCountryCode(allCitiesJsonFromCsv, "city_name", auCapitalCityNameList, australiaCountryCode)
    * print 'citiesIDList =', citiesIDList
    And param cities = citiesIDList
    And method get
    Then status 200
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    # And match response == getWeatherByCityResponseSchema
    And match response.count == 8

    * def capitalCityWeatherTable = response.data
    * def dbQueryResult = queryJsonTableMaxValueByKey(capitalCityWeatherTable, "temp")
    * def currentWarmestCapitalCityName = dbQueryResult.city_name
    * print `currentWarmestCapitalCityName is`, currentWarmestCapitalCityName, ', tempeture is: ', dbQueryResult.temp
    Examples:
    | no | Protocol  | 
    | 1  | http://   |
    | 2  | https://  |