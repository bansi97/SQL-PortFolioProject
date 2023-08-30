/*Project: Data Exploration*/
    /*Covid Dataset*/

select * 
from CovidDeaths$
where continent is not Null
order by 3,4;

--select * 
--from CovidVaccinations$
--order by 3,4;

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
where continent is not Null
order by 1,2;

--Looking at total Cases Vs Total Deaths
--shows  likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location like '%pakistan%'
and continent is not Null
order by 1,2;

--Looking at Total Cases vs Population
--shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths$
--where location like '%pakistan%'
order by 1,2;

--looking at Countries with Highest Infection Rate compared to Population
Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected 
from CovidDeaths$
--where location like '%pakistan%'
Group by location, population
order by PercentPopulationInfected desc


--showing Countries with Highest Death Count per Population

Select location, Max(cast(total_cases as int)) as TotalDeathCount
From CovidDeaths$
--where location like '%pakistan%'
where continent is not Null
Group by location
order by TotalDeathCount desc



--Lets Break things Down by continent

--Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--where location like '%pakistan%'
where continent is not Null
Group by continent
order by TotalDeathCount desc



--Global Numbers

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast
   (new_deaths as int))/Sum(New_Cases)*100 as DeathPercentage
from CovidDeaths$
--where location like '%pakistan%'
where continent is not null
--Group By date 
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE

with popvsVac (Continent,location,date,population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
from PopvsVac



--Temp Table

Drop Table if exists #PecentPopulationVaccinated
Create table #PecentPopulationVaccinated
(
  Continent nvarchar(255),
  location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccination numeric,
  RollingPeopleVaccinated numeric
)

Insert into #PecentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PecentPopulationVaccinated



--Creating View to store data for later Visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths$ dea
join CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated

