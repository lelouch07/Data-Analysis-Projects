select * 
from dbo.covidDeaths$
order by 3,4


select * 
from dbo.covidVaccination$
order by 3,4


--Select data that we are starting with


select location,date,total_cases,new_cases,total_deaths,population
from dbo.covidDeaths$
where continent is not null
order by 1,2
 

 --Total cases vs Total Deaths Percentage

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from dbo.covidDeaths$
where continent is not null 
and location='India'
order by 1,2

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from dbo.covidDeaths$
where continent is not null 
order by 1,2


--Total cases vs Population ,population infected by covid


select location,date,total_cases,population,(total_cases/population)*100  as PopulationInfected
from dbo.covidDeaths$
where continent is not null 
order by 1,2



select location,date,total_cases,population,(total_cases/population)*100  as PopulationInfected
from dbo.covidDeaths$
where continent is not null
and location='India'
order by 1,2


--Countries with Highest Infection rate  and death count compared to population

select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100)  as PercentagePopulationInfected
from dbo.covidDeaths$
where continent is not null 
group by location,population
order by PercentagePopulationInfected desc

select location,population,MAX(cast(total_deaths as int)) as Totaldeathcount,MAX((total_deaths/population)*100)  as PercentageDeathPerPopulation
from dbo.covidDeaths$
where continent is not null 
group by location,population
order by Totaldeathcount desc

--Breaking things down by content

select location,MAX(cast(total_deaths as int)) as Totaldeathcount
from dbo.covidDeaths$
where continent is null
group by location
order by Totaldeathcount desc

--Global numbers

select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as deathpercentage
from dbo.covidDeaths$
where continent is not null
group by date
order by 1,2

-- Total Population vs Vaccinations

select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
sum(cast(vaccine.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location,death.date) as RollingPeopleVaccinated
from covidDeaths$ death
JOIN covidVaccination$ vaccine
 on death.location=vaccine.location
	and death.date=vaccine.date
where death.continent is not null
order by 2,3


select death.location,death.date,vaccine.new_vaccinations,vaccine.total_vaccinations,death.population
from covidDeaths$ death
JOIN covidVaccination$ vaccine
 on death.location=vaccine.location
	and death.date=vaccine.date
where death.continent is not null
 and death.location='India'
 order by 3

--with CTE 
WITH popvsvac(continent,location,date,population,New_Vaccinations,RollingPeopleVaccinated)
AS
(
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
sum(cast(vaccine.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location,death.date) as RollingPeopleVaccinated
from covidDeaths$ death
JOIN covidVaccination$ vaccine
 on death.location=vaccine.location
	and death.date=vaccine.date
where death.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100
from popvsvac