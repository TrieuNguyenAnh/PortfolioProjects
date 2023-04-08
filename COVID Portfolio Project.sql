--IN VIETNAM
SELECT location, population, MAX(CAST(total_cases AS INT)) AS HighestInfectionCount, MAX((CAST (total_cases AS INT)/population))*100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
WHERE location = 'Vietnam'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC
--BY LOCATION
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC
-- BY CONTINENT
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC
--Total deaths in the world per day
SELECT date, SUM(new_deaths) AS TotalNewDeathPerDay
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY date

--Total Population vs Vaccinations
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
SUM(CONVERT(BIGINT, va.new_vaccinations)) OVER (PARTITION BY de.location ORDER BY de.location, de.date)
AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths AS de
JOIN PortfolioProject..CovidVaccinations AS va
  ON de.date = va.date
  AND de.location = va.location
WHERE de.continent is not null

--using CTE
WITH PopulationVsVaccination(Continent, Location, Date, Population, New_vaccinations, PeopleVaccinated)
AS(
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
SUM(CONVERT(BIGINT, va.new_vaccinations)) OVER (PARTITION BY de.location ORDER BY de.location, de.date)
AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths AS de
JOIN PortfolioProject..CovidVaccinations AS va
  ON de.date = va.date
  AND de.location = va.location
WHERE de.continent is not null
)
SELECT *, (PeopleVaccinated/Population)*100 AS PercentOfVaccinated
FROM PopulationVsVaccination

--Using Temp table
DROP TABLE if exists #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
Continent nvarchar(50),
Location nvarchar(50),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric,
)
INSERT INTO #PercentPeopleVaccinated
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
SUM(CONVERT(BIGINT, va.new_vaccinations)) OVER (PARTITION BY de.location ORDER BY de.location, de.date)
AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths AS de
JOIN PortfolioProject..CovidVaccinations AS va
  ON de.date = va.date
  AND de.location = va.location
WHERE de.continent is not null

SELECT *, (PeopleVaccinated/Population)*100 AS PercentOfVaccinated
FROM #PercentPeopleVaccinated

--Create View to store data
CREATE VIEW PercentPeopleVaccinated AS
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations,
SUM(CONVERT(BIGINT, va.new_vaccinations)) OVER (PARTITION BY de.location ORDER BY de.location, de.date)
AS PeopleVaccinated
FROM PortfolioProject..CovidDeaths AS de
JOIN PortfolioProject..CovidVaccinations AS va
  ON de.date = va.date
  AND de.location = va.location
WHERE de.continent is not null
