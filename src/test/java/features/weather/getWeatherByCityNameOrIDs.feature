Feature: “As a frequent flyer, I want to get current weather data for multiple cities in the world 
        Basically 2 Current Weather API endpoints could fulill the request: 
        1. GET a current observation by city name => /current?city={city}&country={country} 
        2. GET a group of observations by cities' ID list => /current?cities={cities}” 

Background: Set up the Weather API endpoints
    * call read('classpath:utils/utils.js')
    * def langList = ["en", "ar", "az", "be", "bg", "bs", "ca", "cz", "da", "de", "fi", "fr", "el", "et", "hr", "hu", "id", "it", "is", "kw", "nb", "nl", "pl", "pt", "ro", "ru", "sk", "sl", "sr", "sv", "tr", "uk", "zh", "zh-tw"]
    * def allCitiesJsonFromCsv = read('classpath:metadata/cities_all.csv')
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

Scenario Outline: #1.<no> Happy path: Basic positive tests, <Protocol> Get current weather by city name & country code, n=1, RC=200
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    * def cityRowIndex = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityName = allCitiesJsonFromCsv[cityRowIndex].city_name
    * def countryCode = allCitiesJsonFromCsv[cityRowIndex].country_code
    And param city = cityName
    And param country = countryCode
    And method get
    Then status 200
    And assert responseTime < maxResponseTimeinMs
    And match response == getWeatherByCityResponseSchema
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response.count == 1
    And match response.data[0].city_name == cityName
    And match response.data[0].country_code == countryCode
    
    Examples:
        | no | Protocol  |
        | 1  | http://   |
        | 2  | https://  |

Scenario Outline: #2.<no> Negative test: Missing Api Key, <Protocol> Get current weather by city name, n=1, RC=403 
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    * def cityRowIndex = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityName = allCitiesJsonFromCsv[cityRowIndex].city_name
    * def countryCode = allCitiesJsonFromCsv[cityRowIndex].country_code
    And param city = cityName
    And param country = countryCode
    And method get
    Then status 403
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response == {"error": "API key is required." }
    Examples:
    | no | Protocol  | 
    | 1  | http://   |
    | 2  | https://  |

Scenario Outline: #3.<no> Happy path: Positive + optional parameters, w/o callbackFunction, <Protocol> Get current weather by city name & country code, n=1, RC=200
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    * def cityRowIndex = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityName = allCitiesJsonFromCsv[cityRowIndex].city_name
    * def countryCode = allCitiesJsonFromCsv[cityRowIndex].country_code
    * def randomLang = langList[randomIndexInArray(langList)]
    And param city = cityName
    And param country = countryCode

    # Below are optional parameters
    And param lang = randomLang
    And param include = '<Include>'
    And param units = '<Unit>'
    # And param callback = 'myCallbackFunction'

    And method get
    Then status 200
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response == getWeatherByCityResponseSchema
    And match response.count == 1
    And match response.data[0].city_name == cityName
    And match response.data[0].country_code == countryCode
    Examples:
        | no | Protocol  | Include         | Unit |
        | 1  | http://   | minutely,alerts |  M   |
        | 2  | https://  | hourly,alert    |  S   |
        | 3  | https://  | minutely,alerts |  I   |
Scenario Outline: #4.<no> Happy path: Positive + optional + callbackFunction, <Protocol> Get current weather by city name & country code, and all optional parameters, n=1, RC=200
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    * def cityRowIndex = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityName = allCitiesJsonFromCsv[cityRowIndex].city_name
    * def countryCode = allCitiesJsonFromCsv[cityRowIndex].country_code
    * def randomLang = langList[randomIndexInArray(langList)]
    And param city = cityName
    And param country = countryCode

    # Below are optional parameters
    And param lang = randomLang
    And param include = '<Include>'
    And param units = '<Unit>'
    And param callback = 'myCallbackFunction'

    And method get
    Then status 200
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response contains `myCallbackFunction(`
    Examples:
        | no | Protocol  | Include         | Unit |
        | 1  | http://   | minutely,alerts |  M   |
        | 2  | https://  | hourly,alert    |  S   |
        | 3  | https://  | minutely,alerts |  I   |

Scenario Outline: #5.<no> Happy path: Basic positive tests, <Protocol> Get current weather for multiple cities by CityID List, n=1, RC=200
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    * def cityRowIndex1 = randomIndexInArray(allCitiesJsonFromCsv)
    And def randomCityId1 = allCitiesJsonFromCsv[cityRowIndex1].city_id
    * print 'randomCityId1 = ', randomCityId1
    And def citiesList =  `${randomCityId1}`
    * print 'citiesList =', citiesList
    And param cities = citiesList
    And method get
    Then status 200
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response == getWeatherByCityResponseSchema
    And match response.count == 1
    # And match response.data[0].city_name == cityName
    # And match response.data[0].country_code == countryCode
    And match response.data[0].city_name == allCitiesJsonFromCsv[cityRowIndex1].city_name
    And match response.data[0].country_code == allCitiesJsonFromCsv[cityRowIndex1].country_code
    Examples:
    | no | Protocol  | 
    | 1  | http://   |
    | 2  | https://  |
Scenario Outline: #6.<no> Happy path: Basic positive tests, <Protocol> Get current weather data for multiple cities by CityID List, n=3, RC=200
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    # * def randomLang = langList[randomIndexInArray(langList)]
    # * print 'randomLang =', randomLang
    # And param lang = randomLang
    * def cityRowIndex1 = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityRowIndex2 = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityRowIndex3 = randomIndexInArray(allCitiesJsonFromCsv)
    And def randomCityId1 = allCitiesJsonFromCsv[cityRowIndex1].city_id
    And def randomCityId2 = allCitiesJsonFromCsv[cityRowIndex2].city_id
    And def randomCityId3 = allCitiesJsonFromCsv[cityRowIndex3].city_id
    * print 'randomCityId1 = ', randomCityId1
    * print 'randomCityId2 = ', randomCityId2
    * print 'randomCityId3 = ', randomCityId3
    And def citiesList =  `${randomCityId1}, ${randomCityId2}, ${randomCityId3}`
    * print 'citiesList =', citiesList
    And param cities = citiesList
    And method get
    Then status 200
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response == getWeatherByCityResponseSchema
    And match response.count == 3
    # validate response body value, city_name, country
    # And match response.data[*].city_name contains [allCitiesJsonFromCsv[cityRowIndex1].city_name, allCitiesJsonFromCsv[cityRowIndex2].city_name, allCitiesJsonFromCsv[cityRowIndex3].city_name]
    # And match response.data[0].country_code == allCitiesJsonFromCsv[cityRowIndex1].country_code
    Examples:
    | no | Protocol  | 
    | 1  | http://   |
    | 2  | https://  |

Scenario Outline: #7.<no> Negative test: missing api key, <Protocol> Get current weather for multiple cities by CityID List n=3, RC=403 
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'

    # * def randomLang = langList[randomIndexInArray(langList)]
    # * print 'randomLang =', randomLang
    # And param lang = randomLang
    * def cityRowIndex1 = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityRowIndex2 = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityRowIndex3 = randomIndexInArray(allCitiesJsonFromCsv)
    And def randomCityId1 = allCitiesJsonFromCsv[cityRowIndex1].city_id
    And def randomCityId2 = allCitiesJsonFromCsv[cityRowIndex2].city_id
    And def randomCityId3 = allCitiesJsonFromCsv[cityRowIndex3].city_id
    * print 'randomCityId1 = ', randomCityId1
    * print 'randomCityId2 = ', randomCityId2
    * print 'randomCityId3 = ', randomCityId3
    And def citiesList =  `${randomCityId1}, ${randomCityId2}, ${randomCityId3}`
    * print 'citiesList =', citiesList
    And param cities = citiesList
    And method get
    Then status 403
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response == {"error": "API key is required." }
    Examples:
    | no | Protocol  | 
    | 1  | http://   |
    | 2  | https://  |

Scenario Outline: #8.<no> Negative test: missing cities key, <Protocol> Get current weather data for multiple cities by CityID List, RC=400, 
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    And method get
    Then status 400
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response == {"error": "Invalid Parameters supplied." }
    Examples:
    | no | Protocol  | 
    | 1  | http://   |
    | 2  | https://  |
Scenario Outline: #9.<no> Negative test: cities key is set to empty, <Protocol> Get current weather data for multiple cities by CityID List, n=0, RC=400
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    # * def cityRowIndex1 = randomIndexInArray(allCitiesJsonFromCsv)
    # * def cityRowIndex2 = randomIndexInArray(allCitiesJsonFromCsv)
    # * def cityRowIndex3 = randomIndexInArray(allCitiesJsonFromCsv)
    # And def randomCityId1 = allCitiesJsonFromCsv[cityRowIndex1].city_id
    # And def randomCityId2 = allCitiesJsonFromCsv[cityRowIndex2].city_id
    # And def randomCityId3 = allCitiesJsonFromCsv[cityRowIndex3].city_id
    # * print 'randomCityId1 = ', randomCityId1
    # * print 'randomCityId2 = ', randomCityId2
    # * print 'randomCityId3 = ', randomCityId3
    # And def citiesList =  `${randomCityId1}, ${randomCityId2}, ${randomCityId3}`
    # * print 'citiesList =', citiesList
    And param cities = ''
    And method get
    Then status 400
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response == {"error": "Invalid Parameters supplied." }
    Examples:
    | no | Protocol  | 
    | 1  | http://   |
    | 2  | https://  |

Scenario Outline: #10.<no> Negative test: cities key is set to invalid e.g. non-existing ID, <Protocol> Get current weather for multiple cities (n=0) by CityID List, n=1, RC=204
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    And param cities = '12345'
    And method get
    Then status 204
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == null
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response == ''
    Examples:
    | no | Protocol  | 
    | 1  | http://   |
    | 2  | https://  |

Scenario Outline: #11.<no> Negative test: cities key is set to invalid e.g. NaN, <Protocol> Get current weather for multiple cities (n=0) by CityID List, n=1, RC=400
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    And param cities = 'NaN'
    And method get
    Then status 400
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == null
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response == ''
    Examples:
    | no | Protocol  | 
    | 1  | http://   |
    | 2  | https://  |

Scenario Outline: #12.<no> Happy path: Positive + optional parameters w/o callbackFunction, <Protocol> Get current weather for multiple cities by cityID List, n=3, RC=200
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey

    * def cityRowIndex1 = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityRowIndex2 = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityRowIndex3 = randomIndexInArray(allCitiesJsonFromCsv)
    And def randomCityId1 = allCitiesJsonFromCsv[cityRowIndex1].city_id
    And def randomCityId2 = allCitiesJsonFromCsv[cityRowIndex2].city_id
    And def randomCityId3 = allCitiesJsonFromCsv[cityRowIndex3].city_id
    * print 'randomCityId1 = ', randomCityId1
    * print 'randomCityId2 = ', randomCityId2
    * print 'randomCityId3 = ', randomCityId3
    And def citiesList =  `${randomCityId1}, ${randomCityId2}, ${randomCityId3}`
    * print 'citiesList =', citiesList
    And param cities = citiesList

    # Below are optional parameters
    * def randomLang = langList[randomIndexInArray(langList)]
    * print 'randomLang =', randomLang
    And param lang = randomLang
    And param include = '<Include>'
    And param units = '<Unit>'
    And method get
    Then status 200
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response == getWeatherByCityResponseSchema
    And match response.count == 3
    Examples:
        | no | Protocol  | Include         | Unit |
        | 1  | http://   | minutely,alerts |  M   |
        | 2  | https://  | hourly,alert    |  S   |
        | 3  | https://  | minutely,alerts |  I   |

Scenario Outline: #13.<no> Happy path: Positive + optional parameters + callbackFunction, <Protocol> Get current weather for multiple cities by cityID List, n=3, RC=200
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey

    * def cityRowIndex1 = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityRowIndex2 = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityRowIndex3 = randomIndexInArray(allCitiesJsonFromCsv)
    And def randomCityId1 = allCitiesJsonFromCsv[cityRowIndex1].city_id
    And def randomCityId2 = allCitiesJsonFromCsv[cityRowIndex2].city_id
    And def randomCityId3 = allCitiesJsonFromCsv[cityRowIndex3].city_id
    * print 'randomCityId1 = ', randomCityId1
    * print 'randomCityId2 = ', randomCityId2
    * print 'randomCityId3 = ', randomCityId3
    And def citiesList =  `${randomCityId1}, ${randomCityId2}, ${randomCityId3}`
    * print 'citiesList =', citiesList
    And param cities = citiesList

    # Below are optional parameters
    * def randomLang = langList[randomIndexInArray(langList)]
    * print 'randomLang =', randomLang
    And param lang = randomLang
    And param include = '<Include>'
    And param units = '<Unit>'
    And param callback = 'myCallbackFunction'
    And method get
    Then status 200
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response contains `myCallbackFunction(`
    Examples:
        | no | Protocol  | Include         | Unit |
        | 1  | http://   | minutely,alerts |  M   |
        | 2  | https://  | hourly,alert    |  S   |
        | 3  | https://  | minutely,alerts |  I   |

Scenario Outline: #14.<no> Happy path: Positive + optional parameters + callbackFunction + extra_query_param, <Protocol> Get current weather for multiple cities by cityID List, n=3, RC=200
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey

    * def cityRowIndex1 = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityRowIndex2 = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityRowIndex3 = randomIndexInArray(allCitiesJsonFromCsv)
    And def randomCityId1 = allCitiesJsonFromCsv[cityRowIndex1].city_id
    And def randomCityId2 = allCitiesJsonFromCsv[cityRowIndex2].city_id
    And def randomCityId3 = allCitiesJsonFromCsv[cityRowIndex3].city_id
    * print 'randomCityId1 = ', randomCityId1
    * print 'randomCityId2 = ', randomCityId2
    * print 'randomCityId3 = ', randomCityId3
    And def citiesList =  `${randomCityId1}, ${randomCityId2}, ${randomCityId3}`
    * print 'citiesList =', citiesList
    And param cities = citiesList

    # Below are optional parameters
    * def randomLang = langList[randomIndexInArray(langList)]
    * print 'randomLang =', randomLang
    And param lang = randomLang
    And param include = '<Include>'
    And param units = '<Unit>'
    And param callback = 'myCallbackFunction'
    And param extra_query_param = 'InjectRedundentString'
    And method get
    Then status 200
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response contains `myCallbackFunction(`
    Examples:
        | no | Protocol  | Include         | Unit |
        | 1  | http://   | minutely,alerts |  M   |
        | 2  | https://  | hourly,alert    |  S   |
        | 3  | https://  | minutely,alerts |  I   |

Scenario Outline: #15.<no> Nagative test: Invalid key + optional parameters + callbackFunction, <Protocol> Get current weather for multiple cities by cityID List, n=3, RC=403
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = "InvalidHeader"+ apiKey + "InvalidTail"

    * def cityRowIndex1 = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityRowIndex2 = randomIndexInArray(allCitiesJsonFromCsv)
    * def cityRowIndex3 = randomIndexInArray(allCitiesJsonFromCsv)
    And def randomCityId1 = allCitiesJsonFromCsv[cityRowIndex1].city_id
    And def randomCityId2 = allCitiesJsonFromCsv[cityRowIndex2].city_id
    And def randomCityId3 = allCitiesJsonFromCsv[cityRowIndex3].city_id
    * print 'randomCityId1 = ', randomCityId1
    * print 'randomCityId2 = ', randomCityId2
    * print 'randomCityId3 = ', randomCityId3
    And def citiesList =  `${randomCityId1}, ${randomCityId2}, ${randomCityId3}`
    * print 'citiesList =', citiesList
    And param cities = citiesList

    # Below are optional parameters
    * def randomLang = langList[randomIndexInArray(langList)]
    * print 'randomLang =', randomLang
    And param lang = randomLang
    And param include = '<Include>'
    And param units = '<Unit>'
    And param callback = 'myCallbackFunction'
    And method get
    Then status 403
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response == {"error": "API key not valid, or not yet activated. If you recently signed up for an account or created this key, please allow up to 30 minutes for key to activate."}
    Examples:
        | no | Protocol  | Include         | Unit |
        | 1  | http://   | minutely,alerts |  M   |
        | 2  | https://  | hourly,alert    |  S   |
