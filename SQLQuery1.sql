SELECT *
FROM [Portfolio Project]..CovidDeaths
where continent is not null
ORDER BY 3,4

SELECT *
FROM [Portfolio Project]..CovidVaccinations
where continent is not null
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
where continent is not null
ORDER BY 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
where continent is not null
WHERE location like '%kingdom%'
ORDER BY 1,2


-- Looking at total cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PERCENTPopulationInfected
FROM [Portfolio Project]..CovidDeaths
where continent is not null
WHERE location like '%kingdom%'
ORDER BY 1,2



-- Looking at countries with higest infection rate vs population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%states%'
where continent is not null
group by location, population
ORDER BY PercentPopulationInfected desc


-- Showingcountries with highest death count per population

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
where continent is not null
--WHERE location like '%states%'
group by location, population
ORDER BY TotalDeathCount desc



-- Showing the continents with the highest death count

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
where continent is not null
--WHERE location like '%states%'
group by continent
ORDER BY TotalDeathCount desc




-- Global stats by day

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
where continent is not null
Group by date
ORDER BY 1,2



-- Looking at total population vs Vaccinations per day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) Over (partition by dea.location ORDER BY dea.date) as RollingTotalVac
From [Portfolio Project]..CovidVaccinations vac
Join [Portfolio Project]..CovidDeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE, UK edit

WITH PopvsVac (Continent, location, date, population, New_Vaccinations, RollingTotalVac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) Over (partition by dea.location ORDER BY dea.date) as RollingTotalVac
From [Portfolio Project]..CovidVaccinations vac
Join [Portfolio Project]..CovidDeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingTotalVac/population)*100 as rollingPercentage
From PopvsVac
where location like '%kingdom%'


-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingTotalVac numeric,
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) Over (partition by dea.location ORDER BY dea.date) as RollingTotalVac
From [Portfolio Project]..CovidVaccinations vac
Join [Portfolio Project]..CovidDeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingTotalVac/population)*100 as rollingPercentage
From #PercentPopulationVaccinated


-- Creating View to store data for later Visualisations 
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) Over (partition by dea.location ORDER BY dea.date) as RollingTotalVac
From [Portfolio Project]..CovidVaccinations vac
Join [Portfolio Project]..CovidDeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3



Select *
From PercentPopulationVaccinated