package features.weather;

import com.intuit.karate.junit5.Karate;

class WeatherRunner {
    
    @Karate.Test
    Karate testWeather() {
        return Karate.run("weather").relativeTo(getClass());
    }    

}
