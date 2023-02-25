select * from PortfolioProject..CovidDeaths
--where continent is not null
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total Cases vs Total Deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

select Location, date, total_cases,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


select Location, date, total_cases,population,(total_cases/population)*100 as PopulationInfected
from PortfolioProject..CovidDeaths
order by 1,2

select Location,Population, max(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PopulationInfected
from PortfolioProject..CovidDeaths
group by location,population
order by PopulationInfected desc

select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--By continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

select date,sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(nullif(new_cases,0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
group by date
order by 1,2

select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(nullif(new_cases,0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--group by date
order by 1,2

select *
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date

--total population vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--How many percent people are vaccinated?
--So use CTE

with PopvsVac(Continent,Location,Date,Population,New_Vaccination,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3
)
select *,(RollingPeopleVaccinated/Population)*100 from PopvsVac

--Temp table
drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinated numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null
--order by 1,2,3

select *,(RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated

--creating a view for visualization

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3


select *
from PercentPopulationVaccinated