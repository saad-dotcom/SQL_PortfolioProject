
Select *
from SQLProject..CovidDeaths
order by 3,4

--Select *
--from CovidVaccinations


Select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


-- Total cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
from CovidDeaths
--where location like 'United States'

-- Total cases vs Total Population
Select Location, date, total_cases, Population, (total_cases/Population)*100 as PositiveRate
from CovidDeaths
where location like 'United States'

-- Countries with highest infection rate
Select Location, Max(total_cases) as highestinfectioncount, Population, Max((total_cases/Population))*100 as infectionrate
from CovidDeaths
group by Location, Population
order by 4 desc

-- Countries with highest death rate
Select Location, Max(cast (total_deaths as int)) as highestdeathcount, Population, Max((total_deaths/Population))*100 as deathrate
from CovidDeaths
where continent is not null
group by Location, Population
order by 4 desc

-- Break things by continent
Select location, Max(cast (total_deaths as int)) as highestdeathcount, Max((total_deaths/Population))*100 as deathrate
from CovidDeaths
where continent is null
group by location
order by 3 desc

-- Global Analysis by every day
Select  distinct date, 
	MAX(total_cases) over (partition by date) as Total_Cases, 
	MAX(new_cases) over (partition by date) as New_Cases, 
	MAX(cast (total_deaths as int)) over (partition by date) as Total_Deaths,
	AVG(((cast (total_deaths as int))/(Total_Cases))*100) over (partition by date) as deathrate
from CovidDeaths
order by 1


-- Total Global Analysis
Select  
	MAX(total_cases)  as Total_Cases, 
	--MAX(new_cases)  as New_Cases, 
	MAX(cast (total_deaths as int))  as TotalDeaths,
	(MAX(cast (total_deaths as int))/MAX(total_cases))*100 as DeathRate
from CovidDeaths
--order by 1


-- Joining Deaths and Vaccination tables and looking at vaccination data

Select a.continent, a.location, a.date, a.population, b.new_vaccinations,
sum(cast(b.new_vaccinations as int)) over (partition by a.location order by a.location, a.date) as RollingPeopleVaccinated
from CovidDeaths a
join CovidVaccinations b
on a.location=b.location
where a.continent is not null --and b.new_vaccinations is not null
and a.date=b.date
order by 2

-- Using CTE
With PopVSVacc(Continent, Location, Date, Population, New_vaccinations,RollingPeopleVaccinated)
as
(
Select a.continent, a.location, a.date, a.population, b.new_vaccinations,
sum(cast(b.new_vaccinations as int)) over (partition by a.location order by a.location, a.date) as RollingPeopleVaccinated
from CovidDeaths a
join CovidVaccinations b
on a.location=b.location
where a.continent is not null --and b.new_vaccinations is not null
and a.date=b.date
--order by 2
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPplVacc
from PopVSVacc

--Creating View for later
--1)

Create View PercentPopulationVaccinated as
Select a.continent, a.location, a.date, a.population, b.new_vaccinations,
sum(cast(b.new_vaccinations as int)) over (partition by a.location order by a.location, a.date) as RollingPeopleVaccinated
from CovidDeaths a
join CovidVaccinations b
on a.location=b.location and a.date=b.date
where a.continent is not null and b.new_vaccinations is not null
--order by 2

Select *
from PercentPopulationVaccinated


--2)
Create View Deathspercountry as
Select Location, Max(cast (total_deaths as int)) as highestdeathcount, Population, Max((total_deaths/Population))*100 as deathrate
from CovidDeaths
where continent is not null
group by Location, Population
--order by 4 desc

--3)
Create View infectionRate as
Select Location, Max(total_cases) as highestinfectioncount, Population, Max((total_cases/Population))*100 as infectionrate
from CovidDeaths
group by Location, Population
--order by 4 desc

--4)
Create View infectionRolling as
Select a.continent, a.location, a.date, a.population, a.new_cases,
sum(cast(a.new_cases as int)) over (partition by a.location order by a.location, a.date) as RollingCases
from CovidDeaths a
where a.continent is not null
--order by 2

