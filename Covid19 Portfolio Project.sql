SELECT * FROM dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * FROM dbo.CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE location like 'Indo%'
AND continent is not null
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
--WHERE location like 'Indo%'
ORDER BY 1,2


--Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
--WHERE location like 'Indo%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Showing the countries with the Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location like 'Indo%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing the continent with the Highest Death Count per Population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location like 'Indo%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
--WHERE location like 'Indo%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2



--Looking at Total Population vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths d
JOIN dbo.CovidVaccinations v ON d.location = v.location AND d.date = v.date
WHERE d.continent is not null
ORDER BY 2,3


--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths d
JOIN dbo.CovidVaccinations v ON d.location = v.location AND d.date = v.date
WHERE d.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 FROM PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths d
JOIN dbo.CovidVaccinations v ON d.location = v.location AND d.date = v.date
--WHERE d.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 FROM #PercentPopulationVaccinated



--Creating View to store data for later Visualizations

Create view PercentPopulationVaccinated as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths d
JOIN dbo.CovidVaccinations v ON d.location = v.location AND d.date = v.date
WHERE d.continent is not null
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated