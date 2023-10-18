-- Dataset (initial view)

SELECT *
FROM [Project 2 - Covid Data].[dbo].[CovidData]


-- Filtering columns that I'm going to be using for cases/deaths 

Select Location, date, total_cases, new_cases, total_deaths, population
From [Project 2 - Covid Data]..[CovidData]
Order by Location, date


-- Looking at Total cases vs Total deaths change over time around the world, and in Spain

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deaths_percentage
From [Project 2 - Covid Data]..[CovidData]
Where continent IS NOT NULL and location <> 'European Union'
Order by date, Deaths_percentage desc

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deaths_percentage
From [Project 2 - Covid Data]..[CovidData]
Where location='Spain'
Order by date


-- Selecting Total cases vs Population to check the percentage of infected individuals over time around the world, and in Spain
-- Note: total_cases was multiplied by "1." to transform the data from integer to numeric

Select Location, date, total_cases, Population, (total_cases*1./Population)*100 as Infected_percentage
From [Project 2 - Covid Data]..[CovidData]
Where continent IS NOT NULL and location <> 'European Union'
Order by date, Infected_percentage desc

Select Location, date, total_cases, Population, (total_cases*1./Population) as Infected_percentage
From [Project 2 - Covid Data]..[CovidData]
Where location='Spain'
Order by date

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases*1./Population)*100) 
	   as HighestInfected_percentage
From [Project 2 - Covid Data]..[CovidData]
Where continent IS NOT NULL and location <> 'European Union'
Group by Location, Population
Order by HighestInfected_percentage desc


-- Countries with Highest Deaths Count

Select Location, MAX(total_deaths) as HighestDeathCount
From [Project 2 - Covid Data]..[CovidData]
Where continent IS NOT NULL and location <> 'European Union'
Group by Location
Order by HighestDeathCount desc
	
-- Breaking down the Highest Deaths Count by Continent/Worldwide
	
Select continent, MAX(total_deaths) as HighestDeathCount
From [Project 2 - Covid Data]..[CovidData]
Where continent IS NOT NULL
Group by continent
Order by HighestDeathCount desc


-- Global daily cases and deaths
-- Note: total_cases was multiplied by "1." to transform the data from integer to numeric

Select date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, 
	  (SUM(new_deaths*1.)/SUM(new_cases))*100 as DeathRate
From [Project 2 - Covid Data]..[CovidData]
Where continent IS NOT NULL and location <> 'European Union'
Group by date
Order by date, TotalCases
	
-- Worldwide summary of Total cases and deaths 
Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, 
	  (SUM(new_deaths*1.)/SUM(new_cases))*100 as DeathRate
From [Project 2 - Covid Data]..[CovidData]
Where continent IS NOT NULL and location <> 'European Union'


-- Looking at worldwide Vaccination vs Population over time, and in Spain
	
Select continent, location, date, population, new_vaccinations, 
       SUM(new_vaccinations) OVER (PARTITION BY location order by location, date) as RollingPeopleVaccinated
From [Project 2 - Covid Data].[dbo].[CovidData]
Where continent IS NOT NULL and location <> 'European Union'
Order by location, date
	
-- Adding Vaccination Rate column and checking worldwide and Spain data
with CTE_PopVsVac as (
Select continent, location, date, population, new_vaccinations, 
       SUM(new_vaccinations) OVER (PARTITION BY location order by location, date) as RollingPeopleVaccinated
From [Project 2 - Covid Data].[dbo].[CovidData]
Where continent IS NOT NULL and location <> 'European Union'
)
Select *, (RollingPeopleVaccinated*1./population)*100 as VaccinationRate
From CTE_PopVsVac
Order by location, date

with CTE_PopVsVac as (
Select continent, location, date, population, new_vaccinations, 
       SUM(new_vaccinations) OVER (PARTITION BY location order by location, date) as RollingPeopleVaccinated
From [Project 2 - Covid Data].[dbo].[CovidData]
Where continent IS NOT NULL and location <> 'European Union'
)
Select *, (RollingPeopleVaccinated*1./population)*100 as VaccinationRate
From CTE_PopVsVac
Where location='Spain'
Order by date


-- Creating a TEMP table for the previous query

CREATE TABLE #PeopleVaccinations (
	continent nvarchar(50), 
	location nvarchar(50), 
	date date, 
	population bigint, 
	new_vaccinations int, 
	RollingPeopleVaccinated numeric(8,2) , 
	)

INSERT INTO #PeopleVaccinations
Select continent, location, date, population, new_vaccinations, 
       SUM(new_vaccinations) OVER (PARTITION BY location order by location, date) as RollingPeopleVaccinated
From [Project 2 - Covid Data].[dbo].[CovidData]
Where continent IS NOT NULL and location <> 'European Union'

Select *, (RollingPeopleVaccinated*1./population)*100 as VaccinationRate
From #PeopleVaccinations
Order by location, date


-- Countries with Highest Vaccination Rate using TEMP table #PeopleVaccinations

Select location, MAX(RollingPeopleVaccinated) AS RollingPeopleVaccinated, 
	   MAX((RollingPeopleVaccinated*1./population)*100) as VaccinationRate
From #PeopleVaccinations
Group by location
Order by VaccinationRate desc


-- Global Total Vaccinations
	
Select SUM(new_vaccinations) as TotalVaccinations
fROM #PeopleVaccinations
