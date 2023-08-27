Feature: “As a frequent flyer, I want to programmatically find the current coldest US State using a metadata input file
        1. Import states.csv as JSON array/table, parse the table to get all US/state_code
        2. Import cities_all.csv as JSON array/table, parse the table to get city IDs in each state/US
        3. GET a group of observations by cities' ID list => /current?cities={cities}
        4. Query the weather result list, get the lowest temp value of the city in a state/US
        5. Compare the 51 states's lowest temp to get the lowest city name, state name. 

Background: Set up the Weather API endpoints
    * callonce read('classpath:utils/query.feature')
    * call read('classpath:utils/utils.js')
    * def allCitiesJsonFromCsv = read('classpath:metadata/cities_all.csv')
    * def allStatesJsonFromCsv = read('classpath:metadata/states.csv')
    * print 'allCitiesJsonFromCsv.length = ', allCitiesJsonFromCsv.length
    * print 'allStatesJsonFromCsv.length = ', allStatesJsonFromCsv.length
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
Scenario Outline: #1.<no> Happy path: Basic positive tests, <Protocol> Get current coldest city, state in USA
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    * def usaCountryCode = 'US'
    * def usaStateList = getStateCodeListByCountryCode(allStatesJsonFromCsv, usaCountryCode)
    * print 'usaStateList = ', usaStateList
    # * def usaStateList = ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]
    
    # * def auCapitalCityNameList = ["Sydney", "Melbourne", "Brisbane", "Perth", "Adelaide", "Hobart", "Canberra", "Darwin"]
    # * def citiesIDList = getCityIdListByKVListAndCountryCode(allCitiesJsonFromCsv, "city_name", auCapitalCityNameList, australiaCountryCode)
    # * print 'citiesIDList =', citiesIDList
    # And param cities = citiesIDList
    # And method get
    # Then status 200
    # And assert responseTime < maxResponseTimeinMs
    # And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    # And match karate.response.header('keep-alive') == "timeout=5"
    # And match response == getWeatherByCityResponseSchema
    # And match response.count == 8

    # * def capitalCityWeatherTable = response.data
    # * def dbQueryResult = queryJsonTableMaxValueByKey(capitalCityWeatherTable, "temp")
    # * def currentWarmestCapitalCityName = dbQueryResult.city_name
    # * print `currentWarmestCapitalCityName is`, currentWarmestCapitalCityName, ', tempeture is: ', dbQueryResult.temp
    Examples:
    | no | Protocol  | 
    | 1  | http://   |
    # | 2  | https://  |