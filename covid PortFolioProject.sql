SELECT *
FROM PortfolioProject2..coviddeaths
ORDER BY 3,4

----SELECT *
----FROM PortfolioProject2..Covidvaccinations
----ORDER BY 3,4

--SELECT location,date, total_cases, new_cases,total_deaths,population 
--from  PortfolioProject2..coviddeaths

SELECT location,date, total_cases,total_deaths,(cast(total_deaths as float)/cast (total_cases as float))*100 as DeathPercentage
from  PortfolioProject2..coviddeaths
where total_cases > 0



SELECT location,date, total_cases,total_deaths,(cast(total_deaths as float)/cast (total_cases as float))*100 as DeathPercentage
from  PortfolioProject2..coviddeaths
where location like '%Nigeria%'
AND total_cases > 0

SELECT location,date, total_cases, population, (cast(total_cases as float)/cast (population as float))*100 as PercentPopulationInfected
from  PortfolioProject2..coviddeaths
where location like '%Nigeria%'
AND total_cases > 0


SELECT location, population, max(total_cases) as highestInfectionCount, max((cast(total_cases as float) /cast (population as float)))*100 as PercentPopulationInfected
from  PortfolioProject2..coviddeaths
where total_cases > 0
group by location, population
order by PercentPopulationInfected desc


SELECT location, max ( cast(total_deaths as int)) as TotalDeathCount
from  PortfolioProject2..coviddeaths
group by location
order by TotalDeathCount desc

SELECT continent, max ( cast(total_deaths as int)) as TotalDeathCount
from  PortfolioProject2..coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc

select date, SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast (new_deaths as float))/SUM(cast(new_cases as float))* 100 as DeathPercentage
from PortfolioProject2..coviddeaths
WHERE new_cases > 0
GROUP BY date

select  SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast (new_deaths as float))/SUM(cast(new_cases as float))* 100 as DeathPercentage
from PortfolioProject2..coviddeaths
WHERE new_cases > 0
--GROUP BY date


select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
from PortfolioProject2..coviddeaths dea
JOIN PortfolioProject2..Covidvaccinations vac
	ON dea.location= vac.location
	and dea.date = vac.date

select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM (CONVERT(float,vac.new_vaccinations )) OVER (Partition by dea.location)
from PortfolioProject2..coviddeaths dea
JOIN PortfolioProject2..Covidvaccinations vac
	ON dea.location= vac.location
	and dea.date = vac.date


select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM (CONVERT(float,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject2..coviddeaths dea
JOIN PortfolioProject2..Covidvaccinations vac
	ON dea.location= vac.location
	and dea.date = vac.date


with popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM (CONVERT(float,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated / population)*100
from PortfolioProject2..coviddeaths dea
JOIN PortfolioProject2..Covidvaccinations vac
	ON dea.location= vac.location
	and dea.date = vac.date
)
select * , (RollingPeopleVaccinated/population)* 100
from popvsvac

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
New_Vaccinations float,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM (CONVERT(float,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated / population)*100
from PortfolioProject2..coviddeaths dea
JOIN PortfolioProject2..Covidvaccinations vac
	ON dea.location= vac.location
	and dea.date = vac.date

select * , (RollingPeopleVaccinated/population)* 100
from #PercentPopulationVaccinated


create view  PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM (CONVERT(float,vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated / population)*100
from PortfolioProject2..coviddeaths dea
JOIN PortfolioProject2..Covidvaccinations vac
	ON dea.location= vac.location
	and dea.date = vac.date

select *
from PercentPopulationVaccinated