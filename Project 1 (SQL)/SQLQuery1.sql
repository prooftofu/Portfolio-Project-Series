Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4 

Select *
from PortfolioProject..CovidVaccination
order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 

--DEATH LIKELIHOOD COUNTRYWISE
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--POPULATION V/S CASES
Select location,date,total_cases,population,(total_cases/population)*100 as Case_percentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--HIGHEST INFECTION RATE COUNTY WISE
Select location, population, max(total_cases) as Highest_infection_count, max((total_cases/population))*100 as percent_population_infected
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by percent_population_infected asc

--HIGHEST DEATH RATE COUNTY WISE
Select location, max(cast(total_deaths as int)) as Highest_death_count, max((total_deaths/population))*100 as percent_population_death
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by Highest_death_count desc

--HIGHEST DEATH RATE CONTINENT WISE
Select continent, max(cast(total_deaths as int)) as Highest_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Highest_death_count desc

--GLOBAL NUMBERS
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int)) / sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2;

--TOTAL POPULATION VS VACCINATIONS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeaths dea
join PortfolioProject..CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--CTE
with PopvsVac (continent , loaction , date , population ,New_Vaccinations, rollingpeoplevaccinated )
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeaths dea
join PortfolioProject..CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
)
select * ,(rollingpeoplevaccinated/population)*100
from PopvsVac

--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
loaction  nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeaths dea
join PortfolioProject..CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null

select * ,(rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALS

create view Percent_Population_Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeaths dea
join PortfolioProject..CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  go

  select * 
  from Percent_Population_Vaccinated


 