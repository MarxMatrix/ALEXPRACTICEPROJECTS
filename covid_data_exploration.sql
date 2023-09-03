USE potfolioproject;
SELECT *
FROM coviddeaths;


-- selecting data i will be using
SELECT location, date, population, total_cases, new_cases, total_deaths
FROM coviddeaths
ORDER BY 1, 2;
-- Looking the deathrate percentage by location 

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM coviddeaths
WHERE location LIKE '%rwanda%'
ORDER BY 1, 2;

-- Looking the survival rate by location
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/population)*100 AS survivalpercentage
FROM coviddeaths
WHERE location LIKE '%rwanda%'
ORDER BY 1, 2;

-- countries with highest rate of infection

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/population)*100 AS infectedpopulationpercentage
FROM coviddeaths
WHERE location LIKE '%rwanda%'
ORDER BY 1, 2;

-- maximum infection peak by country
SELECT location, MAX(total_cases) AS highest_infection_count,MAX( (total_cases/population)*100 )AS infectedpopulationpercentage
FROM coviddeaths
GROUP BY location
ORDER BY  highest_infection_count DESC;

-- maximum deaths in every country

SELECT location, MAX(cast(total_deaths AS UNSIGNED)) AS highest_death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY  highest_death_count DESC;

-- maximum deaths in every continent
SELECT continent, MAX(cast(total_deaths AS UNSIGNED)) AS highest_death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  highest_death_count DESC;

-- sum of new death and cases by dates

SELECT date,SUM(CAST(new_cases AS UNSIGNED)) AS total_new_cases,SUM(CAST(new_deaths AS UNSIGNED)) AS total_new_deaths,SUM(CAST(new_cases AS UNSIGNED))/ SUM(CAST(new_deaths AS UNSIGNED))*100 AS percentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

-- sum of new death and cases
SELECT SUM(CAST(new_cases AS UNSIGNED)) AS total_new_cases,SUM(CAST(new_deaths AS UNSIGNED)) AS total_new_deaths,SUM(CAST(new_cases AS UNSIGNED))/ SUM(CAST(new_deaths AS UNSIGNED))*100 AS percentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Joinning covid deaths and covidvaccinatoins
SELECT *
FROM coviddeaths c
JOIN covidvaccinations cv
ON c.date = cv.date
AND c.location = cv.location;

-- sum of vaccinated people

SELECT SUM(CAST(people_fully_vaccinated as UNSIGNED)) AS sum_of_vaccinated_people
FROM coviddeaths c
JOIN covidvaccinations cv
ON c.date = cv.date
AND c.location = cv.location;

-- sum of fully vaccinated people in every continent

SELECT cv.continent, SUM(CAST(people_fully_vaccinated as UNSIGNED)) AS sum_of_vaccinated_people
FROM coviddeaths c
JOIN covidvaccinations cv
ON c.date = cv.date
AND c.location = cv.location
WHERE cv.continent IS NOT NULL
GROUP BY continent;

-- looking at numbers of  newly vaccinated people and percentage
-- WITH create a new table out of the existing subquery allowing one to operate on the newly generated table
WITH popVSvacc (continent, location, date, population, new_vaccinations, additional_vaccinated)
AS
( 
SELECT cv.continent, c.location, c.date, c.population, cv.new_vaccinations, SUM(CAST(new_vaccinations as UNSIGNED)) OVER (PARTITION BY c.location ORDER BY c.location, c.date) AS additional_vaccinated
FROM coviddeaths c
JOIN covidvaccinations cv
ON c.date = cv.date
AND c.location = cv.location
WHERE cv.continent IS NOT NULL
)

-- using the newly generated table popVSvacc

SELECT *, (additional_vaccinated/population)*100 AS vaccinated_percentage
FROM popVSvacc;


-- creating views for visualization 

CREATE VIEW popVSvacc AS
SELECT cv.continent, c.location, c.date, c.population, cv.new_vaccinations, SUM(CAST(new_vaccinations as UNSIGNED)) OVER (PARTITION BY c.location ORDER BY c.location, c.date) AS additional_vaccinated
FROM coviddeaths c
JOIN covidvaccinations cv
ON c.date = cv.date
AND c.location = cv.location
WHERE cv.continent IS NOT NULL;


CREATE VIEW ALL_VAC_PER_CONTINENT AS
SELECT cv.continent, SUM(CAST(people_fully_vaccinated as UNSIGNED)) AS sum_of_vaccinated_people
FROM coviddeaths c
JOIN covidvaccinations cv
ON c.date = cv.date
AND c.location = cv.location
WHERE cv.continent IS NOT NULL
GROUP BY continent;

 