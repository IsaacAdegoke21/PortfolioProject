SELECT *
FROM PortfoiloProject..CovidDeath
ORDER BY 3,4

--SELECT *
--FROM PortfoiloProject..CovidVaccination
--ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM PortfoiloProject..CovidDeath
ORDER BY 1,2

--Looking at the Total cases vs Total Deaths

--Select Location, date, total_cases, total_deaths, ((total_deaths/total_cases)
--From PortfoiloProject..CovidDeath	(ERROR)


SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DEATHPERCENTAGE
FROM PortfoiloProject..CovidDeath
ORDER BY 1,2;


--LOOKING AT TOTAL CASES VS POPULATION

SELECT Location, date, population, total_cases, (CAST(total_cases AS float)/CAST(population AS float))*100 AS POPULATION_PERCENTAGE
FROM PortfoiloProject..CovidDeath
ORDER BY 1,2;

--LOOKING  AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED

SELECT Location, population, MAX(total_cases) AS HIGHESTINFECTIONCOUNT, MAX(CAST(total_cases AS float)/CAST(population AS float))*100 AS PERCENTPOPULATIONINFECTECD
FROM PortfoiloProject..CovidDeath
GROUP BY location, population
ORDER BY PERCENTPOPULATIONINFECTECD DESC

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT Location, MAX(total_deaths) AS TOTALDEATHCOUNT
FROM PortfoiloProject..CovidDeath
GROUP BY location
ORDER BY TOTALDEATHCOUNT DESC;

-- Showing continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) AS TOTALDEATHCOUNT
FROM PortfoiloProject..CovidDeath
WHERE continent is not null
GROUP BY continent
ORDER BY TOTALDEATHCOUNT DESC;

--Global Numbers

SELECT date, SUM(new_cases) as total_case, SUM(new_deaths) as total_deaths, CASE WHEN SUM(new_cases) = 0 THEN NULL ELSE SUM(CAST(new_deaths as int))/SUM(CAST(new_cases as int))*100 END AS DEATHPERCENTAGE
FROM PortfoiloProject..CovidDeath
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RolloingPeoplevaccinated
FROM PortfoiloProject..CovidDeath dea
JOIN PortfoiloProject..CovidVaccination vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


--USE CTE

With PopvsVac (Continent, location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RolloingPeoplevaccinated
--, (RollingPeopleVaccinated/population\*100)
FROM PortfoiloProject..CovidDeath dea
JOIN PortfoiloProject..CovidVaccination vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF exists #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PERCENTPOPULATIONVACCINATED
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RolloingPeoplevaccinated
FROM PortfoiloProject..CovidDeath dea
JOIN PortfoiloProject..CovidVaccination vac
ON dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 1,2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PERCENTPOPULATIONVACCINATED


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PERCENTPOPULATIONVACCINATED AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RolloingPeoplevaccinated
FROM PortfoiloProject..CovidDeath dea
JOIN PortfoiloProject..CovidVaccination vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3

SELECT *
FROM PERCENTPOPULATIONVACCINATED