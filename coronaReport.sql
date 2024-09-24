select DISTINCT *
from PortfolioProject1 ..CovidDeaths
order by 3,4


--select *
--from PortfolioProject1 ..CovidVaccinations
--order by 3,4

--Select data that we r going to worked on

select location,date, total_cases,new_cases,total_deaths,population
from PortfolioProject1..CovidDeaths
order by 1,2

--TOTAL CASES vs TOTAL DEATHS

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as TotalPercentage
from PortfolioProject1..CovidDeaths 
where continent is not null
order by 1,2

-- Check by perticular area

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as TotalPercentage
from PortfolioProject1..CovidDeaths 
where location like '%india%' and  continent is not null
order by 1,2


--FINDING TOTAL CASES vs TOTAL POPULATION

select location,date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject1 ..CovidDeaths
--where location like '%ind%' and  continent is not null
order by 1,2

--Looking at countries with Highest infection rate compared to Population

select location, population, MAX(total_cases) as HighestInfected , MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths
where continent is not null
group by location,population
order by  PercentPopulationInfected desc


--TO CHECK SPECIFIC COUNTRY RANK IN INFECTED 
WITH RankedCountries AS (
    SELECT 
        location, 
        population, 
        MAX(total_cases) AS HighestInfected, 
        MAX(total_cases * 1.0 / NULLIF(population, 0)) * 100 AS PercentPopulationInfected,
        ROW_NUMBER() OVER (ORDER BY MAX(total_cases * 1.0 / NULLIF(population, 0)) * 100 DESC) AS Rank
    FROM PortfolioProject1..CovidDeaths
    WHERE population IS NOT NULL AND population > 0
    GROUP BY location, population
)
SELECT * 
FROM RankedCountries
WHERE location = 'INDIA';


--Showing Countries with Highest death Count per population 

select location, MAX(CAST(total_deaths as int )) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is not null
group by location 
order by TotalDeathCount desc


--Check by continent wise
/* THIS IS THE CORRECT QUERY FOR CONT BUT OUTPUT WRONG AND DOWN QUERY OUTPUT IS CORRECT
select continent, MAX(CAST(total_deaths as int )) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is null
group by continent 
order by TotalDeathCount desc */

select location, MAX(CAST(total_deaths as int )) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is null
group by location 
order by TotalDeathCount desc


-- Global Number By date (convert and cast is same for convert data type )

SELECT date, SUM(new_cases) as Totalcases, SUM(convert(int,new_deaths )) as TotalDeaths, SUM(convert(int,new_deaths ))/SUM(new_cases)*100 DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null 
group by date
order by 1 ,2

SELECT  SUM(new_cases) as Totalcases, SUM(convert(int,new_deaths )) as TotalDeaths, SUM(convert(int,new_deaths ))/SUM(new_cases)*100 DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null 
--group by date
order by 1 ,2


--VACCINATIONS TABLE------------------------------

--LOOKING AT TOTAL POPULATIONS VS TOTAL VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from PortfolioProject1..CovidDeaths as dea  
join PortfolioProject1..CovidVaccinations as vac
ON dea.location = vac.location 
and 
dea.date = vac.date
where dea.continent is not null
order by 2,3



----- USE CTE -------------

With PopsvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from PortfolioProject1..CovidDeaths as dea  
join PortfolioProject1..CovidVaccinations as vac
ON dea.location = vac.location 
and 
dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/Population)*100 as percentage
from PopsvsVac




-----------TEMP TABLE---------------


DROP TABLE IF EXISTS #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Pupulation numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from PortfolioProject1..CovidDeaths as dea  
join PortfolioProject1..CovidVaccinations as vac
ON dea.location = vac.location 
and 
dea.date = vac.date
-- where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/Pupulation)*100 as percentage
from #PercentagePopulationVaccinated

--- Creating view to store data for later visualizations 

create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
from PortfolioProject1..CovidDeaths as dea  
join PortfolioProject1..CovidVaccinations as vac
ON dea.location = vac.location 
and 
dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentagePopulationVaccinated