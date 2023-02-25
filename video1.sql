select * 
from PORTFOLIOPROJECT..['COVID DEATHS$']
order by 3, 4

------  select *
------  from PORTFOLIOPROJECT..['COVID VACCINATION$']
------  order by 3, 4

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PORTFOLIOPROJECT..['COVID DEATHS$']
order by 1, 2

-- looking at Total cases vs Total deaths

select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PORTFOLIOPROJECT..['COVID DEATHS$']
where location like '%states%'
order by 1, 2

-- looking at Total cases vs population
-- show what percentage of population got covid

select location, date,population, total_cases, (total_cases/population)*100 as percentpopulationinfected
from PORTFOLIOPROJECT..['COVID DEATHS$']
where location like '%states%'
order by 1, 2

-- looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as highestinfectioncount, max(total_cases/population)*100 as percentpopulationinfected
from PORTFOLIOPROJECT..['COVID DEATHS$']
group by location, population
order by percentpopulationinfected desc

--showing countries with highest death count per population

select location, max(cast(total_deaths as int )) as totaldeathcount
from PORTFOLIOPROJECT..['COVID DEATHS$']
where continent is not null
group by location
order by totaldeathcount desc

--- let's break things down by continent
---showing continent with the highest death count per population


select continent, max(cast(total_deaths as int )) as totaldeathcount
from PORTFOLIOPROJECT..['COVID DEATHS$']
where continent is not null
group by continent
order by totaldeathcount desc

----Global number
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PORTFOLIOPROJECT..['COVID DEATHS$']
order by 1,2

-----looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as rollingpeopelevaccinated
-----( rollingpeopelevaccinated/population)*100

from PORTFOLIOPROJECT..['COVID DEATHS$'] dea
join PORTFOLIOPROJECT..['COVID VACCINATION$']  vac
on dea.location = vac.location
and dea.date =vac.date
where dea.continent is not  null
order by 2,3

--use CTE
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeopelevaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as rollingpeopelevaccinated
-----( rollingpeopelevaccinated/population)*100

from PORTFOLIOPROJECT..['COVID DEATHS$'] dea
join PORTFOLIOPROJECT..['COVID VACCINATION$']  vac
on dea.location = vac.location
and dea.date =vac.date
where dea.continent is not  null
---order by 2,3
)
select * , (rollingpeopelevaccinated/population)*100
from popvsvac



----TEMP TABLE
Drop Table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeopelevacinated numeric
)
INSERT INTO #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as rollingpeopelevaccinated
-----( rollingpeopelevaccinated/population)*100

from PORTFOLIOPROJECT..['COVID DEATHS$'] dea
join PORTFOLIOPROJECT..['COVID VACCINATION$']  vac
on dea.location = vac.location
and dea.date =vac.date
--where dea.continent is not  null
---order by 2,3

select * , (rollingpeopelevacinated/population)*100
from #percentpopulationvaccinated

---creating view to store data for later visualization
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as rollingpeopelevaccinated
-----( rollingpeopelevaccinated/population)*100

from PORTFOLIOPROJECT..['COVID DEATHS$'] dea
join PORTFOLIOPROJECT..['COVID VACCINATION$']  vac
on dea.location = vac.location
and dea.date =vac.date
where dea.continent is not  null
--order by 2,3

select * 
from percentpopulationvaccinated
