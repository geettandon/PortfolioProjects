/*
	Covid-19 Data Exploration
	Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Looking at CovidDeaths table

SELECT *
FROM PortfolioProject..CovidDeaths

-- Looking at CovidVaccinations table

SELECT *
FROM PortfolioProject..CovidVaccinations

-- Exploring columns in CovidDeaths table

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Total Cases vs Total Deaths
-- Shows the likelihood of a death if someone is diagnosed with covid in India

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
AND continent IS NOT NULL
ORDER BY 1, 2

-- Total Cases vs Populations
-- Shows percentage of people that contracted covid in India

SELECT location, date, population, total_cases, (total_cases / population) * 100 AS Infected_Percentage_Population
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate as compared to Populations

SELECT location, population, MAX(total_cases) AS Highest_Infected, 
		MAX((total_cases / population)) * 100 AS Infected_Percentage_Population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Looking at Contries with Highest Death Count

SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Looking at Contries with Highest Population Death Percentage

SELECT location, population, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count,
		MAX(CAST(total_deaths AS INT)) / population * 100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- BREAKING THINGS DOWN BY CONTINENTS

-- Total Cases vs Total Deaths
-- Shows the likelihood of an event of death in Continents

SELECT location, SUM(total_cases) AS total_cases, SUM(CAST(total_deaths AS INT)) AS total_deaths,
		SUM(CAST(total_deaths AS INT)) / SUM(total_cases) * 100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is null
AND location IN ('Asia', 'Europe', 'North America', 'South America', 'Oceania', 'Africa')
GROUP BY location
ORDER BY 4 DESC

-- Total Cases vs Population
-- Shows percentage of Population diagnosed with covid

SELECT location, population, MAX(total_cases) AS Total_Cases,
		MAX(total_cases) / population * 100 AS Infected_Population_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is null
AND location IN ('Asia', 'Europe', 'North America', 'South America', 'Oceania', 'Africa')
GROUP BY location, population
ORDER BY 4 DESC

-- Death Count by Continents

SELECT location, population, MAX(CAST(total_deaths AS INT)) AS Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is null
AND location IN ('Asia', 'Europe', 'North America', 'South America', 'Oceania', 'Africa')
GROUP BY location, population
ORDER BY 3 DESC

-- Population Death Percentage by Continents

SELECT location, population, MAX(CAST(total_deaths AS INT)) AS Death_Count,
		MAX(CAST(total_deaths AS INT)) / population * 100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is null
AND location IN ('Asia', 'Europe', 'North America', 'South America', 'Oceania', 'Africa')
GROUP BY location, population
ORDER BY 4 DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, 
		SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

-- Total Population vs Total Vaccinations
-- Shows the count of people received at least one dose of vaccine in each country

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- Shows the count of people in India that has recieved at least on dose of vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
	AND dea.location = 'India'
ORDER BY 2, 3

-- Showing the Percentage of People Vaccinated in each Country

-- Using CTE

WITH PopvsVac AS (
				SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
						SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
				FROM PortfolioProject..CovidDeaths AS dea
				JOIN PortfolioProject..CovidVaccinations AS vac
					ON dea.location = vac.location
					AND dea.date = vac.date
				WHERE dea.continent IS NOT NULL
				)

SELECT *,
		(Rolling_People_Vaccinated / population) * 100 AS Vaccinated_Percentage
FROM PopvsVac

-- Using TEMP TABLE

DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date DATETIME,
population NUMERIC,
New_Vaccinations NUMERIC,
Rolling_People_Vaccinated NUMERIC
)

INSERT INTO #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *,
		(Rolling_People_Vaccinated / population) * 100 AS Vaccinated_Percentage
FROM #Percent_Population_Vaccinated

-- Showing the Percentage of People Fully Vaccinated in India

SELECT dea.continent, dea.location, dea.population, 
		MAX(CAST(vac.total_vaccinations AS BIGINT)) AS total_vaccinations, 
		MAX(vac.people_fully_vaccinated) AS fully_vaccinated_population,
		MAX(vac.people_fully_vaccinated) / dea.population * 100  AS fully_vaccinated_pop_percentage
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
	AND dea.location = 'India'
GROUP BY dea.continent, dea.location, dea.population

-- Creating VIEW to store data for visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

