
-- 1.Retrieve the avg population by year
SELECT Year, round(AVG(Population),2) AS Avg_Population
FROM schema1.population_data
GROUP BY Year;

-- 2.Growth of Population for each country
SELECT Year,
       Country_name,
       Population_Growth
FROM (
    SELECT Year,
           Country_name,
           Population - LAG(Population, 1) OVER (PARTITION BY Country_name ORDER BY Year) AS Population_Growth
    FROM schema1.population_data
) AS subquery
where population_growth is not null
ORDER BY Country_name, Year
;


-- 3.Age group with the highest populace country-wise decade-wise
WITH Age_Group_Populations AS (
    SELECT 
        FLOOR(Year / 10) * 10 AS Decade,
        Country_name,
        Population_aged_1_to_4_years,
        Population_aged_5_to_9_years,
        Population_aged_10_to_14_years,
        Population_aged_15_to_19_years,
        Population_aged_20_to_29_years,
        Population_aged_30_to_39_years,
        Population_aged_40_to_49_years,
        Population_aged_50_to_59_years,
        Population_aged_60_to_69_years,
        Population_aged_70_to_79_years,
        Population_aged_80_to_89_years,
        Population_aged_90_to_99_years,
        GREATEST(
            Population_aged_1_to_4_years,
            Population_aged_5_to_9_years,
            Population_aged_10_to_14_years,
            Population_aged_15_to_19_years,
            Population_aged_20_to_29_years,
            Population_aged_30_to_39_years,
            Population_aged_40_to_49_years,
            Population_aged_50_to_59_years,
            Population_aged_60_to_69_years,
            Population_aged_70_to_79_years,
            Population_aged_80_to_89_years,
            Population_aged_90_to_99_years
        ) AS Greatest_Age
    FROM schema1.population_data
)
SELECT 
    Country_name,
    MAX(CASE WHEN Decade = 1950 THEN Most_Populated_Age_Group ELSE NULL END) AS `1950`,
    MAX(CASE WHEN Decade = 1960 THEN Most_Populated_Age_Group ELSE NULL END) AS `1960`,
    MAX(CASE WHEN Decade = 1970 THEN Most_Populated_Age_Group ELSE NULL END) AS `1970`,
    MAX(CASE WHEN Decade = 1980 THEN Most_Populated_Age_Group ELSE NULL END) AS `1980`,
    MAX(CASE WHEN Decade = 1990 THEN Most_Populated_Age_Group ELSE NULL END) AS `1990`,
    MAX(CASE WHEN Decade = 2000 THEN Most_Populated_Age_Group ELSE NULL END) AS `2000`,
    MAX(CASE WHEN Decade = 2010 THEN Most_Populated_Age_Group ELSE NULL END) AS `2010`,
    MAX(CASE WHEN Decade = 2020 THEN Most_Populated_Age_Group ELSE NULL END) AS `2020`
FROM (
    SELECT 
        Decade,
        Country_name,
        CASE 
            WHEN Greatest_Age = Population_aged_1_to_4_years THEN '1-4 Years'
            WHEN Greatest_Age = Population_aged_5_to_9_years THEN '5-9 Years'
            WHEN Greatest_Age = Population_aged_10_to_14_years THEN '10-14 Years'
            WHEN Greatest_Age = Population_aged_15_to_19_years THEN '15-19 Years'
            WHEN Greatest_Age = Population_aged_20_to_29_years THEN '20-29 Years'
            WHEN Greatest_Age = Population_aged_30_to_39_years THEN '30-39 Years'
            WHEN Greatest_Age = Population_aged_40_to_49_years THEN '40-49 Years'
            WHEN Greatest_Age = Population_aged_50_to_59_years THEN '50-59 Years'
            WHEN Greatest_Age = Population_aged_60_to_69_years THEN '60-69 Years'
            WHEN Greatest_Age = Population_aged_70_to_79_years THEN '70-79 Years'
            WHEN Greatest_Age = Population_aged_80_to_89_years THEN '80-89 Years'
            WHEN Greatest_Age = Population_aged_90_to_99_years THEN '90-99 Years'
            ELSE 'Unknown'
        END AS Most_Populated_Age_Group
    FROM Age_Group_Populations
    GROUP BY Decade, Country_name, Most_Populated_Age_Group
) AS Age_Groups
GROUP BY Country_name;



-- 4.Average age of population(weighted average)
SELECT Country_name,FLOOR(Year / 10) * 10 AS Decade, 
       (SUM(Population_at_age_1 * 1 + Population_aged_1_to_4_years * 3 + Population_aged_5_to_9_years * 7 + Population_aged_10_to_14_years * 12 + Population_aged_15_to_19_years * 17 +
       Population_aged_20_to_29_years * 24 + Population_aged_30_to_39_years * 34 + Population_aged_40_to_49_years * 44 + Population_aged_50_to_59_years * 54 +
       Population_aged_60_to_69_years * 64 + Population_aged_70_to_79_years * 74 + Population_aged_80_to_89_years * 84 + Population_aged_90_to_99_years * 94 +
       Population_older_than_100_years * 100)) / SUM(Population) AS Avg_Age
FROM schema1.population_data
GROUP BY Country_name,FLOOR(Year / 10) * 10;

#5. Top 5 Countries with the highest population growth rate (Population change from year to year):
SELECT DISTINCT p1.Country_name, p1.year,
       (p2.Population - p1.Population) / p1.Population * 100 AS Population_Growth_Rate
FROM schema1.population_data p1
JOIN schema1.population_data p2 ON p1.Country_name = p2.Country_name AND p1.Year = p2.Year - 1
WHERE p1.year = 2020
ORDER BY Population_Growth_Rate DESC LIMIT 5;


#6.Top 5 Countries with the lowest population growth rate (Population change from year to year):
SELECT DISTINCT p1.Country_name, p1.year,
       (p2.Population - p1.Population) / p1.Population * 100 AS Population_Growth_Rate
FROM schema1.population_data p1
JOIN schema1.population_data p2 ON p1.Country_name = p2.Country_name AND p1.Year = p2.Year - 1
WHERE p1.year = 2020
ORDER BY Population_Growth_Rate ASC LIMIT 5;


# 7. Birth rate by country
SELECT 
    Country_name,
    SUM(CASE WHEN Year BETWEEN 1950 AND 1959 THEN Population_at_age_1 ELSE 0 END) / SUM(CASE WHEN Year BETWEEN 1950 AND 1959 THEN Population ELSE 0 END) AS '1950-1959',
    SUM(CASE WHEN Year BETWEEN 1960 AND 1969 THEN Population_at_age_1 ELSE 0 END) / SUM(CASE WHEN Year BETWEEN 1960 AND 1969 THEN Population ELSE 0 END) AS '1960-1969',
    SUM(CASE WHEN Year BETWEEN 1970 AND 1979 THEN Population_at_age_1 ELSE 0 END) / SUM(CASE WHEN Year BETWEEN 1970 AND 1979 THEN Population ELSE 0 END) AS '1970-1979',
    SUM(CASE WHEN Year BETWEEN 1980 AND 1989 THEN Population_at_age_1 ELSE 0 END) / SUM(CASE WHEN Year BETWEEN 1980 AND 1989 THEN Population ELSE 0 END) AS '1980-1989',
    SUM(CASE WHEN Year BETWEEN 1990 AND 1999 THEN Population_at_age_1 ELSE 0 END) / SUM(CASE WHEN Year BETWEEN 1990 AND 1999 THEN Population ELSE 0 END) AS '1990-1999',
    SUM(CASE WHEN Year BETWEEN 2000 AND 2009 THEN Population_at_age_1 ELSE 0 END) / SUM(CASE WHEN Year BETWEEN 2000 AND 2009 THEN Population ELSE 0 END) AS '2000-2009',
    SUM(CASE WHEN Year BETWEEN 2010 AND 2019 THEN Population_at_age_1 ELSE 0 END) / SUM(CASE WHEN Year BETWEEN 2010 AND 2019 THEN Population ELSE 0 END) AS '2010-2019'
FROM 
    schema1.population_data
GROUP BY 
    Country_name;



    
    
#8. Dependency Ratio by Country (Ratio of Dependents to Working Population):
SELECT Country_name, 
       (SUM(Population_of_children_under_the_age_of_15) + SUM(Population_aged_60_to_69_years) + SUM(Population_aged_70_to_79_years) + SUM(Population_aged_80_to_89_years) + SUM(Population_aged_90_to_99_years) + SUM(Population_older_than_100_years)) / SUM(Population_aged_15_to_64_years) AS Dependency_Ratio
FROM schema1.population_data
WHERE year>=2000
GROUP BY Country_name;


#9. Life Expectancy of each country decade wise (An Estimate)
SELECT 
    Country_name,
    SUM(CASE WHEN Year BETWEEN 1950 AND 1959 THEN Life_Expectancy ELSE 0 END) AS Life_Expectancy_1950s,
    SUM(CASE WHEN Year BETWEEN 1960 AND 1969 THEN Life_Expectancy ELSE 0 END) AS Life_Expectancy_1960s,
    SUM(CASE WHEN Year BETWEEN 1970 AND 1979 THEN Life_Expectancy ELSE 0 END) AS Life_Expectancy_1970s,
    SUM(CASE WHEN Year BETWEEN 1980 AND 1989 THEN Life_Expectancy ELSE 0 END) AS Life_Expectancy_1980s,
    SUM(CASE WHEN Year BETWEEN 1990 AND 1999 THEN Life_Expectancy ELSE 0 END) AS Life_Expectancy_1990s,
    SUM(CASE WHEN Year BETWEEN 2000 AND 2009 THEN Life_Expectancy ELSE 0 END) AS Life_Expectancy_2000s,
    SUM(CASE WHEN Year BETWEEN 2010 AND 2019 THEN Life_Expectancy ELSE 0 END) AS Life_Expectancy_2010s
    ##SUM(CASE WHEN Year BETWEEN 2020 AND 2021 THEN Life_Expectancy ELSE 0 END) AS Life_Expectancy_2020s
FROM (
    SELECT 
        Country_name,
        Year,
        SUM(Population_aged_60_to_69_years * 65 + Population_aged_70_to_79_years * 75 + Population_aged_80_to_89_years * 85 + Population_aged_90_to_99_years * 95 + Population_older_than_100_years * 105) / SUM(Population_older_than_15_years) AS Life_Expectancy
    FROM 
        schema1.population_data
    GROUP BY 
        Country_name, Year
) AS subquery
GROUP BY 
    Country_name;
    
    
#10. Changes in age distribution for each year & previous year country wise
SELECT 
    p1.Country_name,
    p1.Year AS Current_Year,
    p2.Year AS Previous_Year,
    p1.Population AS Current_Population,
    p2.Population AS Previous_Population,
    (p1.Population_of_children_under_the_age_of_15) / p1.Population AS Current_Percent_Children,
    (p2.Population_of_children_under_the_age_of_15) / p2.Population AS Previous_Percent_Children,
    p1.Population_under_the_age_of_25 / p1.Population AS Current_Percent_Under_25,
	p2.Population_under_the_age_of_25 / p2.Population AS Previous_Percent_Under_25,
    p1.Population_aged_15_to_64_years / p1.Population AS Current_Percent_15_to_64,
	p2.Population_aged_15_to_64_years / p2.Population AS Previous_Percent_15_to_64,
    p1.Population_older_than_15_years / p1.Population AS Current_Percent_Over_15,
    p2.Population_older_than_15_years / p2.Population AS Previous_Percent_Over_15
FROM 
    schema1.population_data p1
JOIN 
    schema1.population_data p2 ON p1.Country_name = p2.Country_name
    AND p1.Year = p2.Year + 1;