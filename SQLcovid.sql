Select *
From [PortfolioProject ]..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From [PortfolioProject ]..CovidVaccination$
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From [PortfolioProject ]..CovidDeaths$
where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [PortfolioProject ]..CovidDeaths$
Where location like '%states%' and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Show what percentage of population got covid
Select location, date, population, total_cases,(total_cases/population)*100 as CovidcasePercentage
From [PortfolioProject ]..CovidDeaths$
--Where location like '%states%'
where continent is not null
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population
Select location, population, max(total_cases) as hightestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
From [PortfolioProject ]..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From [PortfolioProject ]..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


-- LET'S EAK THINGS DOWN BY CONTINENT

-- Showing continents wwith the highest death count per popluation
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From [PortfolioProject ]..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS 
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_dealths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [PortfolioProject ]..CovidDeaths$
--Where location like '%states%' 
where continent is not null
--group by date 
order by 1,2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (partition by vac.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [PortfolioProject ]..CovidDeaths$ dea
join [PortfolioProject ]..CovidVaccination$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (partition by vac.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [PortfolioProject ]..CovidDeaths$ dea
join [PortfolioProject ]..CovidVaccination$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinnated
Create table #PercentPopulationVaccinnated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinnated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (partition by vac.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [PortfolioProject ]..CovidDeaths$ dea
join [PortfolioProject ]..CovidVaccination$ vac
on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinnated

--Creating View to store data for later visualizations
Create view PercentPopulationVaccinnated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) OVER (partition by vac.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [PortfolioProject ]..CovidDeaths$ dea
join [PortfolioProject ]..CovidVaccination$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *
From PercentPopulationVaccinnated
