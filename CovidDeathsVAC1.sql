-- Columns needed   
SELECT location, date, total_cases, new_cases,total_deaths,population
FROM covidproject.coviddeaths2
where location is not null
ORDER BY 1,2;

-- Total_cases vs Total_death
-- Percentage of Death
SELECT location, date, total_cases, population, (total_cases/population)*100 
as CasesPerPopulation 
FROM covidproject.coviddeaths2

ORDER BY 1,2;
-- Percentage of a population that got covid (Total_cases VS Population) 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 
as DeathPercentage 
FROM covidproject.coviddeaths2
ORDER BY 1,2;

-- countries with highest covid rate
SELECT location, population, max(total_cases), max((total_cases/population))*100 
as MaxCase 
FROM covidproject.coviddeaths2
group by population,location
ORDER BY MaxCase desc;

-- Showing countries with highest death count per population
SELECT location, max(cast(total_deaths as UNSIGNED) )  as highest_death_count
FROM covidproject.coviddeaths2
where location is not null
group by population
ORDER BY highest_death_count desc;

-- Breakdown by continent
SELECT continent, max(cast(total_deaths as UNSIGNED) )  as highest_death_count
FROM covidproject.coviddeaths2
where location  is  not null
group by continent
ORDER BY highest_death_count desc;

-- Global numbers
SELECT  sum(new_cases) as total_cases, sum(new_deaths) as total_death, 
( sum(new_deaths)/sum(new_cases))*100
as DeathPercentage 
FROM covidproject.coviddeaths2
where continent is not null
-- group by date 
ORDER BY 1,2 ;

-- Total po;ulation vs vacination
select det.continent, det.location, det.date, det.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by det.location order by det.location,det.date)
as RollOver_Count
 from coviddeaths2 det
join
covidvaccinations vac
on
det.location = vac.location
and 
det.date = vac.date
order by 2,3;

-- use CTE
with popvsvac  (continent,  location, date, population, new_vaccinations, RollOver_Count)
as
(select det.continent, det.location, det.date, det.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by det.location order by det.location,det.date)
as RollOver_Count
 from coviddeaths2 det
join covidvaccinations vac
on det.location = vac.location
and det.date = vac.date
-- order by 2,3
)
select *, ( RollOver_Count/population)*100
from popvsvac;

-- Temp Table
drop table if exists percentPopulationVaccinanted;
create TEMPORARY TABLE percentPopulationVaccinanted (
continent nvarchar(255),
location nvarchar(255),
date text ,
population numeric,
new_vaccinations text,
RollOver_Count numeric);

insert into percentPopulationVaccinanted
select det.continent, det.location, det.date, det.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by det.location order by det.location,det.date)
as RollOver_Count
 from coviddeaths2 det
join covidvaccinations vac
on det.location = vac.location
and det.date = vac.date
-- order by 2,3
;

select *, ( RollOver_Count/population)*100
from percentPopulationVaccinanted;

-- Creating View to store data for later visualization

create view  percentPopulationVaccinanted as 
select det.continent, det.location, det.date, det.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by det.location order by det.location,det.date)
as RollOver_Count
 from coviddeaths2 det
join covidvaccinations vac
on det.location = vac.location
and det.date = vac.date




