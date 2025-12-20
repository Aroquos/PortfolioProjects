select*
From covid..CovidDeaths
Where continent is not null 
order by 3,4
--select*
--From covid..CovidVacc
--order by 3,4

-- Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From covid..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelyhood of dying if you contact covid in your country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From covid..CovidDeaths
Where location like '%ecuador%'
order by 1,2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got covid 
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulation
From covid..CovidDeaths
Where location like '%ecuador%'
order by 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population 
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected 
From covid..CovidDeaths
--Where location like '%states%'
Group by Location, Population 
order by PercentagePopulationInfected desc

-- Showing Countries with Highest Death Count per Population 
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From covid..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--Let's Break Things Down by Continent 

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From covid..CovidDeaths
--Where location like '%states%'
Where continent is null 
Group by location 
order by TotalDeathCount desc

-- Showing Continent With The Highest Death Count per Population

Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From covid..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent  
order by TotalDeathCount desc

-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From covid..CovidDeaths
--Where location like '%ecuador%'
Where continent is not null
Group by date
order by 1,2

--Looking at Total Populations Vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid..CovidDeaths dea
Join covid..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- USE CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid..CovidDeaths dea
Join covid..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid..CovidDeaths dea
Join covid..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to Store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid..CovidDeaths dea
Join covid..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select* 
From PercentPopulationVaccinated