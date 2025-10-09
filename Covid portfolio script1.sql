select * 
from PortfolioProject2..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject2.dbo.CovidVaccinations
--order by 3,4

--select the data that we are going to be using 

select Location,date, total_cases,new_cases,total_deaths,population
from PortfolioProject2..CovidDeaths
where continent is not null
order by 1,2

--looking at Total cases vs Total Deaths 
--shows likelihood of dying if you contract covid in your country

select Location,date, total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject2..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2


--Looking at total cases vs population 
--shows what percentage of population got covid 

select Location, date, total_cases,new_cases,population,(total_cases/population)*100 as CasesPercentage
from PortfolioProject2..CovidDeaths
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population 

select Location, population, Max(total_cases) as highestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject2..CovidDeaths
--where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- the total number of COVID-19 deaths per country, ranked from highest to lowest.

select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject2..CovidDeaths
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--showing countries with highest death count per population 

select Location, population, Max(cast(total_deaths as int)) as highestDeathCount,MAX((total_deaths/population))*100 as PercentPopulationDead
from PortfolioProject2..CovidDeaths
--where location like '%states%'
Group by Location, Population
order by PercentPopulationDead desc
 

--showing the continents with hightest death count per population

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject2..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers

-- Showing the total worldwide numbers for the pandemic (including all countries and all dates).

select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
from PortfolioProject2..CovidDeaths
where continent is not null
--group by date 
order by 1,2

--------------------------------
-- looking table covidvaccinations
select *
from PortfolioProject2..CovidVaccinations

-- loking at total population vs vaccinations 

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) over
(partition by dea.location order by dea.location,dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject2..CovidDeaths dea
join PortfolioProject2..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE (common table expression : expression de table commune , sert a créer une
--table temporaire ou une vue temporaire a utiliser juste dans la requete actuelle

with PopvsVac(Continent, Location, Date, Population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) over
(partition by dea.location order by dea.location,dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject2..CovidDeaths dea
join PortfolioProject2..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
)
select*,(RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Temp Table 

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) over
(partition by dea.location order by dea.location,dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject2..CovidDeaths dea
join PortfolioProject2..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
--where dea.continent is not null
         
select*,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

DROP VIEW IF EXISTS PercentPopulationVaccinated
USE PortfolioProject2;
GO
create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) over
(partition by dea.location order by dea.location,dea.date ) as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths dea
join PortfolioProject2..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated;