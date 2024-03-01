SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4


-- Select Data that we are going to be using

SELECT location, CAST(date AS DATE) AS date,total_cases, TRY_CAST(total_cases AS numeric),  new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE ISNUMERIC(total_cases) = 0
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths 
--Show likelihood of dyning if you contract Covid in your Country

SELECT location, CAST(date AS DATE) AS date, total_cases, total_deaths,  CASE WHEN
	total_cases ='' OR total_deaths =''  THEN  NULL
	WHEN TRY_CAST(total_cases AS numeric) IS NOT NULL AND TRY_CAST(total_deaths AS numeric) IS NOT NULL AND 
             TRY_CAST(total_cases AS numeric) != 0 THEN 
            TRY_CAST(total_deaths AS numeric) / TRY_CAST(total_cases AS numeric) * 100
        ELSE NULL
	END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%france%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Show what percentage of population get Covid

SELECT location, CAST(date AS DATE) AS date, total_cases, population,  CASE WHEN
	total_cases ='' OR population =''  THEN  NULL
	WHEN TRY_CAST(total_cases AS numeric) IS NOT NULL AND TRY_CAST(population AS numeric) IS NOT NULL AND 
             TRY_CAST(total_cases AS numeric) != 0 THEN 
            TRY_CAST(total_cases AS numeric) / TRY_CAST(population AS numeric) * 100
        ELSE NULL
	END AS CovidPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%france%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(CovidPercentage) AS CovidPercentage
FROM (SELECT location, population, total_cases, CASE WHEN
	total_cases ='' OR population =''  THEN  NULL
	WHEN TRY_CAST(total_cases AS numeric) IS NOT NULL AND TRY_CAST(population AS numeric) IS NOT NULL AND 
             TRY_CAST(total_cases AS numeric) != 0 THEN 
            TRY_CAST(total_cases AS numeric) / TRY_CAST(population AS numeric) * 100
        ELSE NULL
	END AS CovidPercentage
FROM PortfolioProject..CovidDeaths) a
--WHERE location LIKE '%france%'
Group by Location, Population
ORDER BY CovidPercentage DESC



-- Showing Countries with Highest Death count per Population

SELECT location, MAX(TRY_CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%france%'
WHERE CONTINENT = ''
Group by Location
ORDER BY TotalDeathCount DESC

SELECT distinct continent
FROM  PortfolioProject..CovidDeaths


-- GLOBAL NUMBERS

SELECT --CAST(date AS DATE) AS date,
SUM(TRY_CAST(new_cases AS numeric)) AS Total_New_cases, SUM(TRY_CAST(new_deaths AS numeric)) AS Total_deaths , CASE WHEN SUM(TRY_CAST(New_cases AS numeric)) !=0 THEN (SUM(TRY_CAST(new_deaths AS numeric))/SUM(TRY_CAST(New_cases AS numeric)))*100 ELSE 0 END AS DeathPercentage
	--total_cases ='' OR total_deaths =''  THEN  NULL
	--WHEN TRY_CAST(total_cases AS numeric) IS NOT NULL AND TRY_CAST(total_deaths AS numeric) IS NOT NULL AND 
 --            TRY_CAST(total_cases AS numeric) != 0 THEN 
 --           TRY_CAST(total_deaths AS numeric) / TRY_CAST(total_cases AS numeric) * 100
 --       ELSE NULL
	--END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%france%'
WHERE continent != '' 
--ORDER BY new_cases
--GROUP BY date
ORDER BY DeathPercentage DESC
 

 SELECT  TRY_CAST(new_cases AS numeric),new_cases
 FROM PortfolioProject..CovidDeaths
 ORDER BY TRY_CAST(new_cases AS numeric)


 -- Looking at Total Population vs Vaccinations

 -- USE CTE 

 WITH PopvsVac(Continent, location, date, population, new_vaccinations, total_vaccinations) 
 AS (
 SELECT  dea.continent, dea.location, CAST(dea.date AS date) AS date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location)  AS total_vaccinations
 FROM PortfolioProject..CovidDeaths AS dea
 JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
--ORDER by total_vaccinations DESC 
)
SELECT  *,  CASE WHEN population !=0 THEN (total_vaccinations/population)*100 ELSE 0 END 
FROM  PopvsVac



-- Temp table


 SELECT   dea.continent, dea.location, CAST(dea.date AS date) AS date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location)  AS total_vaccinations
 INTO #PercentPopulationVaccinated
 FROM PortfolioProject..CovidDeaths AS dea
 JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''
--ORDER by total_vaccinations DESC 


SELECT *
FROM #PercentPopulationVaccinated


--Creating View to store data

CREATE VIEW PercentPopulationVaccinated AS 
 SELECT   dea.continent, dea.location, CAST(dea.date AS date) AS date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location)  AS total_vaccinations
 FROM PortfolioProject..CovidDeaths AS dea
 JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent != ''


SELECT * 
FROM PercentPopulationVaccinated
