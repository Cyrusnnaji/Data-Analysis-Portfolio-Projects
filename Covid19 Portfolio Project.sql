-- CovidDeaths Table
select *
from portfolioproject.dbo.CovidDeaths
order by 3,4

-- Looking at Total Cases vs Total Deaths
-- shows the likelihood of dying of covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from portfolioproject..CovidDeaths
-- where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
from portfolioproject..CovidDeaths
-- where location like '%states%'
group by location, population 
order by 4 DESC

-- Looking at Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from portfolioproject..CovidDeaths
where continent is not null
group by location
order by 2 DESC

-- Looking at Continents with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from portfolioproject..CovidDeaths
where continent is null
group by location
order by 2 DESC

-- Global Covid Cases across the World

select *
from portfolioproject..CovidDeaths

select location, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths
from portfolioproject..CovidDeaths
where continent is null
group by location
order by 2 desc

-- Total Global Daily Cases and percentage deaths

select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as percentagedeath
from portfolioproject..CovidDeaths
where continent is not null
group by date
order by 1 asc

-- Global cases

select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as percentagedeath
from portfolioproject..CovidDeaths
where continent is not null
order by 1 asc

-- Total amount of people in the world that were vaccinated and percentage vaccination per population

select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.date, d.location) total_vaccinations_per_day, 
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.date, d.location)/d.population*100 as percentage_vaccinations
from portfolioproject..CovidVaccinations V
join portfolioproject..CovidDeaths D
	on v.location = d.location 
	and v.date = d.date
where d.continent is not null
group by d.continent, d.location, d.date, d.population, v.new_vaccinations
order by 1,2,3

-- Creating a CommonTableExpression for Total Vaccinations Per Day

with TotalVacc (continent, location, date, population, new_vaccinations, total_vaccinations_per_day)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.date, d.location) total_vaccinations_per_day 
--sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.date, d.location)/d.population*100 as percentage_vaccinations
from portfolioproject..CovidVaccinations V
join portfolioproject..CovidDeaths D
	on v.location = d.location 
	and v.date = d.date
where d.continent is not null
group by d.continent, d.location, d.date, d.population, v.new_vaccinations
--order by 1,2,3
)
select *
from TotalVacc

-- Creating a Temporary Table

drop table if exists #MyCovidSQL
create table #MyCovidSQL
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations_per_day numeric
)
insert into #MyCovidSQL
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.date, d.location) total_vaccinations_per_day 
--sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.date, d.location)/d.population*100 as percentage_vaccinations
from portfolioproject..CovidVaccinations V
join portfolioproject..CovidDeaths D
	on v.location = d.location 
	and v.date = d.date
where d.continent is not null
group by d.continent, d.location, d.date, d.population, v.new_vaccinations
--order by 1,2,3

Select *
from #MyCovidSQL
