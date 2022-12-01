SELECT * 
FROM CovidDeaths
where continent is not null
order by 3,4


--SELECT * 
--FROM CovidVaccinations
--where continent is not null
--order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihoof of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
--where location like 'Belgium'
-- and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
--where location like 'Belgium'
order by 1,2


-- Looking at countries with Highest Infection Rate compared to Population


Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--where location like 'Belgium'
group by location, population
order by PercentPopulationInfected desc


-- Showing countries with Highest Death Count per population
-- There are problems with the data type, so 


Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like 'Belgium'
where continent is not null
group by location
order by TotalDeathCount desc


-- By continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like 'Belgium'
where continent is not null
group by continent
order by TotalDeathCount desc

-- The following query gives more precise data than the previous one
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like 'Belgium'
where continent is null
group by location
order by TotalDeathCount desc


-- Showing continents with the highest death count per population
-- create a view
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like 'Belgium'
where continent is not null
group by continent
order by TotalDeathCount desc


-- global numbers (create a view on this one)

Select 
	--date, 
	SUM(new_cases) as globalnewcases, 
	SUM(cast(new_deaths as int)) as globalnewdeaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as globaldeathpercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
--where location like 'Belgium'
where continent is not null
--group by date
order by 1,2


-- Join our 2 tables

-- looking at Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
--,(RollingPeopleVaccination/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100 as RateVaccinatedPopulation
from PopvsVac


-- USE TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/population)*100 as RateVaccinatedPopulation
from #PercentPopulationVaccinated



-- example of creating view to store data for later visualizations

Create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated

CREATE view TotalDeaths as
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like 'Belgium'
where continent is null
group by location
--order by TotalDeathCount desc

Select * 
From TotalDeaths

Create View globalnumbers as
Select 
	--date, 
	SUM(new_cases) as globalnewcases, 
	SUM(cast(new_deaths as int)) as globalnewdeaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as globaldeathpercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
--where location like 'Belgium'
where continent is not null
--group by date
--order by 1,2

Select * 
From globalnumbers