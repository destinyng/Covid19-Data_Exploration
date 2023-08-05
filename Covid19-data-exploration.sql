/*
This Project is about Covid 19 Data Exploration 

Skills that I used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Showing countries with highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount 
FROM "covid_deaths"
WHERE continent != ''
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing global numbers, total cases, total deaths and percentage
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, CAST(SUM(cast(new_deaths as decimal(38,5)))/SUM(cast(New_Cases as decimal(38,2)))*100 AS decimal(38,2)) as DeathPercentage
FROM "covid_deaths"
WHERE continent != ''
ORDER BY 1,2


-- Total deaths per continent
SELECT continent, MAX(total_deaths) AS TotalDeathCount 
FROM "covid_deaths"
WHERE continent != ''
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Showing countries with the highest total cases compare with population by calculating percentage population infected based on total cases
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS decimal(38,4))/CAST(population AS decimal(38,4)))*100 )AS PercentPopulationInfected
FROM "covid_deaths"
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- USE cte 
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccination vac
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent != ''
)

SELECT *, (CAST(RollingPeopleVaccinated AS decimal(38,4)))/ (CAST(Population AS decimal(38,4))) *100 AS Vaccination_percentage 
FROM PopvsVac
ORDER BY Vaccination_percentage DESC

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM covid_deaths dea
JOIN covid_vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--where dea.continent is not null 
--order by 2,3



-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, 
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM covid_deaths dea
JOIN covid_vaccination vac
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE dea.continent != ''

