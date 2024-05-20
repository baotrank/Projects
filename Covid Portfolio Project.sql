select * from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4;

--select * from PortfolioProject..CovidVaccinations$
--order by 3,4;

-- Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
order by 1,2;

-- Looking at the Total Cases vs The Population
-- Shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/ population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
order by 1,2;

--Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/ population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
group by location, population
--where location like '%states%'
where continent is not null
order by PercentPopulationInfected desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT
select continent, max(cast(total_deaths as int)) as MaxTotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by MaxTotalDeathCount desc;


-- Showing Countries with the Highest Death Count per Population
select location, max(cast(total_deaths as int)) as MaxTotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by MaxTotalDeathCount desc;

-- Showing continents with the Highest Death Counts per Population
select continent, max(cast(total_deaths as int)) as MaxTotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by MaxTotalDeathCount desc;


-- Global Numbers 
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, round(sum(cast(new_deaths as int))/ sum(new_cases)*100,2) as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2;

--Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,dea.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- USE CTE
with PopvsVac 
(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,dea.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3 -- this cannot be used in CTEs
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac;

-- TEMP TABLE 
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,dea.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,dea.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated;