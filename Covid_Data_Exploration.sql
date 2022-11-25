/*
COVID19 Data Exploration Using SQL

Skills Used : Data Conversion, Aggregate Functions, Windows Functions, Temp Tables, Joins, CTE's, Views Creation etc.

*/

SELECT * 
FROM portfolio_projects.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- Selecting data that is going to be used for analysis
SELECT location, date,total_cases,new_cases,total_deaths,population 
FROM portfolio_projects.coviddeaths
ORDER BY 1,2;  

-- Total Cases vs Total Deaths 
-- Shows Likelihood of dying if contracted in my home country 
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 AS death_percentage
FROM portfolio_projects.coviddeaths
WHERE location LIKE '%ghana%'
AND continent IS NOT NULL
ORDER BY 1,2; 

-- Total Cases vs Total Deaths
-- Shows what perecntage of population is infected with COVID 
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS population_percentage_infected
FROM portfolio_projects.coviddeaths
ORDER BY 1,2; 

-- Countries with Highest Infection Rate compared to Population
SELECT location,MAX(total_cases) AS highest_infection_count , population, MAX((total_cases/population)) * 100 AS population_percentage_infected
FROM portfolio_projects.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY population_percentage_infected DESC;

-- Countries with Highest Death Count Per Population
SELECT location, MAX(cast(total_deaths as signed int)) AS total_death_count
FROM portfolio_projects.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;  


-- CONTINENT BREAKDOWN

-- Showing Continents With The Highest Death Count Per Population
SELECT continent, MAX(cast(total_deaths as signed int)) AS total_death_count
FROM portfolio_projects.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;  


-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as signed int)) AS total_deaths, SUM(cast(new_deaths as signed int))/SUM(new_cases) *100 AS death_percentage
FROM portfolio_projects.coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;  

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as signed int)) AS total_deaths, SUM(cast(new_deaths as signed int))/SUM(new_cases) *100 AS death_percentage
FROM portfolio_projects.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;  

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as signed int)) OVER(partition by dea.location, dea.date) AS rolling_people_vaccinated
FROM portfolio_projects.coviddeaths dea
JOIN portfolio_projects.covidvaccinations vac
ON dea.location = vac.location 
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Using CTE to perform Calculation on Partition By in previous query
WITH population_vaccinated (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as signed int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_people_vaccinated
FROM portfolio_projects.coviddeaths dea
JOIN portfolio_projects.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)
SELECT * , (rolling_people_vaccinated/population)*100
From population_vaccinated;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists percentpopulationvaccinated;
CREATE TABLE percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
);

INSERT INTO percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as signed int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS rolling_people_vaccinated
FROM portfolio_projects.coviddeaths dea
JOIN portfolio_projects.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL ;


SELECT * , (rolling_people_vaccinated/population)*100
FROM percentpopulationvaccinated;




-- Creating View to store data for later visualizations

CREATE VIEW percentpopulationvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as signed int)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS rolling_people_vaccinated
FROM portfolio_projects.coviddeaths dea
JOIN portfolio_projects.covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL ;













