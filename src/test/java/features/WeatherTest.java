package weather;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;

import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import org.apache.commons.io.FileUtils;
import com.intuit.karate.KarateOptions;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

class WeatherTest {

    @Test
    void testParallel() {
        Results results = Runner.path("classpath:features/*")
                .outputCucumberJson(true)
                .parallel(5);
        generateReports(results.getReportDir());
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

    public static void generateReports(String karateOutputPath) {
        Collection<File> jsonFiles = FileUtils.listFiles(new File(karateOutputPath), new String[] {"json"}, true);
        List<String> jsonPaths = new ArrayList(jsonFiles.size());
        jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
        Configuration config = new Configuration(new File("target"), "Qantas Weather API Automation Test Report");
        config.addClassifications("Branch", "develop/latest");
        ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
        reportBuilder.generateReports();
    }
}