@ignore
Feature: Not real feature, just a container to collect utils functions

  Scenario:

    * def isRecordFoundInDB =
    """
    function(table, key, value) {
        var i, found = false, queryResult = {};
        if(database[table] !== undefined) {
            for (i = 0; i < database[table].length; i++) {
                if (value == database[table][i][key]) {
                    karate.log(value, 'is found in database[', table, '][', ~~i, ']');
                    found = true;
                    queryResult = database[table][i];
                    karate.log("DB query result ==>\n", queryResult);
                    break;
                }
            }
        }
        karate.log(key, value, found? ': is found' : ': is not found');
        return found;
    }
    """

    * def getCityIdListByKVListAndCountryCode =
    """
    function(table, key, valueList, countryCode) {
        // e.g. key = "city_name", valueList = auCapitalCityList
        // or   key = "state_code", valueList = usaStateList
        var i, queryResult, cityListString = '';
        for (i = 0; i < valueList.length; i++) {
            queryResult = queryTable(table, key, valueList[i], "country_code", countryCode);
            if(i < valueList.length -1) {
                cityListString += queryResult.city_id + ',';
            }
            else {
                cityListString += queryResult.city_id;
            }
        }
        karate.log("cityListString = ", cityListString);
        return cityListString;
    }
    """

    * def getStateCodeListByCountryCode =
    """
    function(stateTable, countryCode) {
        var i, stateList = [];
        for (i = 0; i < stateTable.length; i++) {
            if(stateTable[i].country_code == countryCode) {
                stateList.push(stateTable[i].state_code);
            }
        }
        karate.log("stateList = ", stateList);
        return stateList;
    }
    """

    * def queryTable =
    """
    function(table, key1, value1, key2, value2) {
        var i, found = false, queryResult = {};
        for (i = 0; i < table.length; i++) {
            if ((value1 === table[i][key1]) && (value2 === table[i][key2])) {
                karate.log(value1, value2, 'is found in table[', ~~i, ']');
                found = true;
                queryResult = table[i];
                karate.log("DB query result ==>\n", queryResult);
                break;
            }
        }
        return queryResult;
    }
    """
    # WIP...
    # * def queryJsonTableMinValueByKey =
    # """
    # function(table, key, valueList, countryCode) {
    #     // key = "state_code", valueList = usaStateList
    #     var cityIDWithSameUsaStateCode = getCityIdListByKVListAndCountryCode(table, key, valueList, countryCode);        

    # }
    # """

    * def queryJsonTableMaxValueByKey =
    """
    function(table, key) {
        var i, maxIndex, value = Number.MIN_VALUE, queryResult = {};
        karate.log(`Go through the table...`);
        for (i = 0; i < table.length; i++) {
            if (table[i][key] >= value) {
                value = table[i][key];
                maxIndex = i;
            }
        }
        karate.log(table[maxIndex][key], 'is found in table[', ~~maxIndex, ']');
        queryResult = table[maxIndex];
        karate.log("DB query result ==>\n", queryResult);
        return queryResult;
    }
    """

    * def queryListDB =
    """
    function(table, key, value) {
        var i, found = false, queryResult = [];
        var keyContainsChildkey = (key.indexOf('.') > -1) ? true : false;
        try {
            if ( keyContainsChildkey ) {
                // Only deal with 2 level keys, seperated by DOT(.)
                var keys = key.split('.');
                var parentKey = keys[0], childKey = keys[1];
                karate.log('parentKey =', parentKey, "childKey =", childKey);
            }
            if(database[table] !== undefined && !keyContainsChildkey) {
                for (i = 0; i < database[table].length; i++) {
                    if (value == database[table][i][key] || value == '*') {
                        karate.log(value.toLowerCase(), 'is found in database[', table, '][', ~~i, ']');
                        found = true;
                        queryResult.push(database[table][i]);
                    }
                }
            } else if (database[table] !== undefined && keyContainsChildkey) {
                for (i = 0; i < database[table].length; i++) {
                    if (database[table][i][parentKey] != null && database[table][i][parentKey] != undefined
                        && database[table][i][parentKey][childKey] != null && database[table][i][parentKey][childKey] != undefined
                        && (value == database[table][i][parentKey][childKey] || value == '*')) {
                        karate.log(value.toLowerCase(), 'is found in database[', table, '][', ~~i, ']');
                        found = true;
                        queryResult.push(database[table][i]);
                    } else if (database[table][i][parentKey] == null || database[table][i][parentKey] == undefined) {
                        karate.log('parentKey:{', parentKey, '} is NOT found in database[', table, '][', ~~i, ']', database[table][i]);
                        continue;
                    } else if (database[table][i][parentKey][childKey] == null || database[table][i][parentKey][childKey] == undefined) {
                        karate.log('childKey:{', childKey, '} is NOT found in database[', table, '][', ~~i, ']', database[table][i]);
                        continue;
                    }
                }
            }
            karate.log("DB query result ==>\n", queryResult);
        } catch (err) {
            karate.log('Exception: \n', 'err.stack ==> \n',  err.stack);
        } finally {
            return queryResult;
        }
    }
    """

    * def getDBQueryResultByPK =
    """
    function(schema, table, pk, value) {
        var i, found = false, queryResult = {}, getQuery = {};
        var query = "SELECT * FROM " + schema + "." + table + " WHERE \"" + pk + "\" = '" + value + "';";
        var queryResult = runPostgreSQL(query, postgreSQL, schema);
        if(queryResult.length == 1) {
            karate.log(pk, ':',  value, 'is found in PG schema:', schema, ', table :', table);
            found = true;
            getQuery.result = queryResult[0];
            karate.log("DB query result ==>\n", queryResult);
        }
        getQuery.found = found;
        
        return getQuery;
    }
    """

    * def getQueryListByKeyValue =
    """
    function(schema, table, key, value) {
        var i, found = false, queryResult = {}, getQuery = {};
        var query = "SELECT * FROM " + schema + "." + table + " WHERE \"" + key + "\" = '" + value + "';";
        var queryResult = runPostgreSQL(query, postgreSQL, schema);
        if(queryResult.length >= 1) {
            karate.log(key, ':',  value, 'is found in PG schema:', schema, ', table :', table);
            found = true;
            getQuery.result = queryResult;
            karate.log("DB query result ==>\n", queryResult);
        }
        getQuery.found = found;
        
        return getQuery;
    }
    """

    * def getQueryListByColumn =
    """
    function(schema, table, column) {
        var i, found = false, queryResult = {}, getQuery = {};
        var query = "SELECT \"" + column + "\" FROM " + schema + "." + table;
        var queryResult = runPostgreSQL(query, postgreSQL, schema);
        if(queryResult.length >= 1) {
            karate.log(column, 'is found in PG schema:', schema, ', table :', table);
            found = true;
            getQuery.result = queryResult;
            karate.log("DB query result ==>\n", queryResult);
        }
        getQuery.found = found;
        
        return getQuery;
    }
    """

    * def isRecordInTable =
    """
    function(table, key, value) {
        var i, found = false;
        if(table !== undefined && table.length > 0) {
            for (i = 0; i < table.length; i++) {
                if (value.toLowerCase() == table[i][key].toLowerCase()) {
                    karate.log(value.toLowerCase(), 'is found in table: ', table, ' , index = ', ~~i);
                    found = true;
                    break;
                }
            }
        }
        return found;
    }
    """

    * def readTableFromJSONFile =
    """
    function(tableName) {
        karate.log("Read " + env + " JSON table :  [" + tableName + "]...");
        try {
            return karate.read('classpath:DADB/' + env + '/' + tableName + '.json');
        } catch (err) {
            karate.log('Exception: \n', 'err.stack ==> \n',  err.stack);
        }
    }
    """



