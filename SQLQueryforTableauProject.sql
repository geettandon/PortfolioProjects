/*
	Queries for Tableau Project
*/

-- 1.

SELECT SUM(new_cases) AS total_cases, 
		SUM(CAST(new_deaths AS INT)) AS total_deaths,
		(SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths

-- 2.

Select location, 
		SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location in ('Asia', 'Europe', 'North America', 'South America', 'Oceania', 'Africa')
Group by location
order by TotalDeathCount desc

--3.

Select Location, 
		COALESCE(Population, 0) AS Population, 
		COALESCE(MAX(total_cases), 0) as HighestInfectionCount,  
		COALESCE(Max((total_cases/population))*100, 0) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--4.


Select Location, 
		Population,
		date, 
		COALESCE(MAX(total_cases), 0) as HighestInfectionCount,  
		COALESCE(Max((total_cases/population))*100, 0) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc