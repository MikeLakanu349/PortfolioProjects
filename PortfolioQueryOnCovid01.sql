select *
from PortfolioProjectCovid..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProjectCovid..CovidVaccinations
--order by 3,4


select location,date, total_cases, new_cases, total_deaths,population
from PortfolioProjectCovid..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- This shows the likelihood of dying if you contract covid in the UK
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjectCovid..CovidDeaths
where location like '%kingdom%'
order by 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got covid in the UK
select location,date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
from PortfolioProjectCovid..CovidDeaths
where location like '%kingdom%'
order by 1,2


-- Looking at Countries with highest infection rate compared to population
-- Shows Cyprus has the Highest PercentPopulationInfected
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProjectCovid..CovidDeaths
--where location like '%kingdom%'
Group by location, population
order by PercentPopulationInfected desc


-- Looking at Countries with highest TotalDeathCount
-- Had to use Cast function to correct datatype 
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectCovid..CovidDeaths
--where location like '%kingdom%'
Group by location
order by TotalDeathCount desc

--Noticed continents and other unwanted data in location column
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectCovid..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc


-- Breaking it down by continent
-- Showing the continents with the highest death count
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectCovid..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Looking at Continents with highest infection rate compared to population
-- Shows Cyprus has the Highest PercentPopulationInfected
select continent, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProjectCovid..CovidDeaths
--where location like '%kingdom%'
where continent is not null
Group by continent, population
order by PercentPopulationInfected desc

-- Looks like data is still separated by countries
-- Did something to add countries to total continents??




-- Global Numbers

select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProjectCovid..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Joining tables on date and location columns

select *
from PortfolioProjectCovid..CovidDeaths dea
join PortfolioProjectCovid..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


-- Looking at Total Population vs Vaccinations
-- Used convert data type to bigint to solve overflow error
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjectCovid..CovidDeaths dea
join PortfolioProjectCovid..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjectCovid..CovidDeaths dea
join PortfolioProjectCovid..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as RollingPercentage
from PopvsVac




-- Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjectCovid..CovidDeaths dea
join PortfolioProjectCovid..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


select *, (RollingPeopleVaccinated/population)*100 as RollingPercentage
from #PercentPopulationVaccinated




-- Creating View to store data for later visualisations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjectCovid..CovidDeaths dea
join PortfolioProjectCovid..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null




-- Queries for Tableu Project



Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2