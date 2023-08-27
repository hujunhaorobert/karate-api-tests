Feature: “As a frequent flyer, I want to get current weather data for the city at a specific Latitude/Longitude
         GET a current observation by lat/lon => /current?lat={lat}&lon={lon}


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

Scenario Outline: #1.<no> Happy path: Basic positive tests, <Protocol> Get current weather by lat/lon, RC=200
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    And param lat = -33.865143
    And param lon = 151.209900
    And method get
    Then status 200
    And assert responseTime < maxResponseTimeinMs
    And match response == getWeatherByCityResponseSchema
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response.count == 1
    And match response.data[0].city_name == "Sydney"
    And match response.data[0].country_code == "AU"
    
    Examples:
        | no | Protocol  |
        | 1  | http://   |
        | 2  | https://  |

Scenario Outline: #2.<no> Happy path: lat:<latitude>/lon:<longitude> boundary tests, <Protocol> Get current weather by lat/lon, RC=200
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    And param lat = <latitude>
    And param lon = <longitude>
    And method get
    Then status 200
    And assert responseTime < maxResponseTimeinMs
    And match response == getWeatherByCityResponseSchema
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response.count == 1
    Examples:
        | no | Protocol  | latitude |longitude|
        | 1  | http://   | -90      |  -180   |
        | 2  | https://  | -90      |  180    |
        | 3  | http://   | 90       |  -180   |
        | 4  | https://  | 90       |  180    |
        | 5  | http://   | 0        |  0      |
        | 6  | https://  | -0       |  -0     |

Scenario Outline: #3.<no> Happy path: Basic positive tests + optional paramaters w/o callback, <Protocol> Get current weather by lat/lon, RC=200
    * url '<Protocol>' + weatherbitBaseUrl   
    * def randomLang = langList[randomIndexInArray(langList)] 
    When path 'current'
    And param key = apiKey
    And param lat = -33.865143
    And param lon = 151.209900
    And param include = '<Include>'
    And param marine = 't'
    And param units = '<Unit>'
    And param lang = randomLang
    And method get
    Then status 200
    And assert responseTime < maxResponseTimeinMs
    And match response == getWeatherByCityResponseSchema
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response.count == 1
    And match response.data[0].city_name == "Sydney"
    And match response.data[0].country_code == "AU"
    
    Examples:
        | no | Protocol  |      Include       | Unit |
        | 1  | http://   |    minutely,alerts |  M   | 
        | 2  | https://  |    hourly,alert    |  S   |
        | 2  | https://  |   minutely,alerts  |  I   |

Scenario Outline: #31.<no> Happy path: Positive tests + all optional paramaters + callback, <Protocol> Get current weather by lat/lon, RC=200
    * url '<Protocol>' + weatherbitBaseUrl   
    * def randomLang = langList[randomIndexInArray(langList)] 
    When path 'current'
    And param key = apiKey
    And param lat = -33.865143
    And param lon = 151.209900
    And param include = '<Include>'
    And param marine = ''
    And param units = '<Unit>'
    And param lang = randomLang
    And param callback = 'myCallbackFunction'
    And method get
    Then status 200
    And assert responseTime < maxResponseTimeinMs
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response contains `myCallbackFunction(`
    Examples:
        | no | Protocol  |      Include       | Unit |
        | 1  | http://   |    minutely,alerts |  M   | 
        | 2  | https://  |    hourly,alert    |  S   |
        | 2  | https://  |   minutely,alerts  |  I   |
        
Scenario Outline: #4.<no> Negative test: missing required parameter lat, <Protocol> Get current weather by lat/lon, RC=400
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    # And param lat = -33.865143
    And param lon = 151.209900
    And param include = 'minutely'
    And method get
    Then status 400
    And assert responseTime < maxResponseTimeinMs
    And match response == {"error": "Invalid Parameters supplied." }
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    Examples:
        | no | Protocol  |
        | 1  | http://   |
        | 2  | https://  |

Scenario Outline: #5.<no> Negative test: missing required parameter lon, <Protocol> Get current weather by lat/lon, RC=400
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    And param lat = -33.865143
    # And param lon = 151.209900
    And param include = 'minutely'
    And method get
    Then status 400
    And assert responseTime < maxResponseTimeinMs
    And match response == {"error": "Invalid Parameters supplied." }
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    Examples:
        | no | Protocol  |
        | 1  | http://   |
        | 2  | https://  |

Scenario Outline: #6.<no> Negative test: missing api key <Protocol> Get current weather by lat/lon, RC=403
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    # And param key = apiKey
    And param lat = -33.865143
    And param lon = 151.209900
    And param include = 'minutely'
    And method get
    Then status 403
    And assert responseTime < maxResponseTimeinMs
    And match response == {"error": "API key is required." }
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    Examples:
        | no | Protocol  |
        | 1  | http://   |
        | 2  | https://  |

Scenario Outline: #7.<no> Negative test: required parameter lat/lon is invalid, <Protocol> Get current weather by lat/lon, RC=400
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    And param lat = '<latitude>'
    And param lon = '<longitude>'
    And param include = 'minutely'
    And method get
    Then status 400
    And assert responseTime < maxResponseTimeinMs
    And match response == {"error": "Invalid lat/lon supplied."}
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    Examples:
        | no | Protocol  |  latitude | longitude |
        | 1  | http://   | abc.123   |  _$a.123  |
        | 2  | https://  |  *&^%$    |  ?/@#~    |

Scenario Outline: #8.<no> Negative test: required parameter lat:<latitude> is out of boundry[-90,+90], <Protocol> Get current weather by lat/lon, RC=400
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    And param lat = <latitude>
    And param lon = <longitude>
    And param include = 'minutely'
    And method get
    Then status 400
    And assert responseTime < maxResponseTimeinMs
    And match response == {"error": "Invalid lat supplied. Must be between -90 and +90"}
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    Examples:
        | no | Protocol  | latitude | longitude |
        | 1  | http://   | -90.1    |  179.9    |
        | 2  | https://  |  90.1    |  -179.9   |

Scenario Outline: #9.<no> Negative test: required parameter lon:<longitude> is out of boundry[-180,+180], <Protocol> Get current weather by lat/lon, RC=400
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    And param lat = -33.865143
    And param lon = 181.000001
    And param include = 'minutely'
    And method get
    Then status 400
    And assert responseTime < maxResponseTimeinMs
    And match response == {"error": "Invalid lon supplied. Must be between -180 and +180"}
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    Examples:
        | no | Protocol  | latitude | longitude |
        | 1  | http://   |  -89.9   |  -180.1   |
        | 2  | https://  |  89.9    |  180.1    |

Scenario Outline: #10.<no> Positive test: append extra_query_param, set <Protocol> Get current weather by lat/lon, RC=200
    * url '<Protocol>' + weatherbitBaseUrl    
    When path 'current'
    And param key = apiKey
    And param lat = -33.865143
    And param extra_query_param = 'InjectRedundentString'
    And param lon = 151.209900
    And param include = 'minutely'
    And method get
    Then status 200
    And assert responseTime < maxResponseTimeinMs
    And match response == getWeatherByCityResponseSchema
    And match karate.response.header('content-type') == 'application/json; charset=utf-8'
    And match karate.response.header('keep-alive') == "timeout=5"
    And match response.count == 1
    And match response.data[0].city_name == "Sydney"
    And match response.data[0].country_code == "AU"
    Examples:
        | no | Protocol  |
        | 1  | http://   |
        | 2  | https://  |