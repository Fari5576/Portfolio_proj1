
--Select * from
--Portfolioproject1..CovidDeath$
--Where continent is not null
--order by  1,2

Select Location, date, total_cases, new_cases, total_deaths, population
from Portfolioproject1.dbo.CovidDeath$
order by 1,2

-- We are looking at Total Cases vs Total Death
--Shows likelihood of dying if you contract to COVID-19 in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases ) * 100 as DeathPercentage
From Portfolioproject1.dbo.CovidDeath$
--Where location='Canada'
Order by 1,2

 -- Looking at Total Cases Vs Population
 -- Shows what percentage of population  got Covid-19
 Select Location, date,population, total_cases,  (total_cases/population) * 100 as CasePercentage
From Portfolioproject1.dbo.CovidDeath$
--Where location='Canada'
Order by 1,2

-- Let's find out what country has the highest infection rate
Select Location, population, Max  (total_cases) as HighestInfectionCount ,
                                                   Max((total_cases/population))*100  as PercentPopulationInfected
From Portfolioproject1.dbo.CovidDeath$
where total_cases is not null and population is not null
Group by population, location
Order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per Popilation
Select location, Max(Cast(total_deaths as int)) as TotalDeathsCount
From Portfolioproject1.dbo.CovidDeath$
Where continent is not null
Group by  location
Order by TotalDeathsCount desc

-- LET'S EXPLORE THE DATASET BY CONTINENET
-- Showing continents with the highest death count per population
Select location, Max(Cast(total_deaths as int)) as TotalDeathsCount
From Portfolioproject1.dbo.CovidDeath$
Where continent is null
Group by  location
Order by TotalDeathsCount desc
--------------------------------------------
Select
 continent, Max(Cast(total_deaths as int)) as TotalDeathsCount
From Portfolioproject1.dbo.CovidDeath$
Where continent is not  null
Group by  continent
Order by TotalDeathsCount desc

--- GLOBAL NUMBERS
Select 
                  date,  Sum(new_cases) as TotalCases , Sum(cast(new_deaths as int)) as TotalDeaths,
                        ROUND( Sum(cast(new_deaths as int))/Sum(new_cases) *100,2) as DeathPercentage
From  Portfolioproject1.dbo.CovidDeath$
Where  continent is not null and new_cases is not null and new_deaths is not null
group by date
Order by 1,2 
-----Total Death Percentage 
Select   
                         Sum(new_cases) as TotalCases , Sum(cast(new_deaths as int)) as TotalDeaths,
                 ROUND(  Sum(cast(new_deaths as int))/Sum(new_cases) *100,2) as DeathPercentage
From  Portfolioproject1.dbo.CovidDeath$
Where  continent is not null

--Select COL_NAME(object_id('dbo.CovidVaccination$'),1 )

-- Looking at Total Population vs Total Vaccinations
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From 
Portfolioproject1.dbo.CovidDeath$  dea
Join 
Portfolioproject1.dbo.CovidVaccination$ vac
         On dea.location=vac.location
		   and dea.date=vac.date
		   where dea.continent is not null 
	Order by 2,3
	--Partition by Location------------------------
	Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM( Cast(vac.new_vaccinations as int)) Over (Partition by  dea.location Order by dea.location , dea.Date)
	as RollingVaccinationCount
	--, ( RollingVaccinationCount/dea.population)*100
From 
Portfolioproject1.dbo.CovidDeath$  dea
Join 
Portfolioproject1.dbo.CovidVaccination$ vac
         On dea.location=vac.location
		   and dea.date=vac.date
		   where dea.continent is not null 
	Order by 2,3

 -- Using CTE 
 With  popVsvac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
 as
 (
 Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM( Cast(vac.new_vaccinations as int)) Over (Partition by  dea.location Order by dea.location , dea.Date)
	as RollingVaccinationCount
	--, ( RollingVaccinationCount/dea.population)*100
From 
Portfolioproject1.dbo.CovidDeath$  dea
Join 
Portfolioproject1.dbo.CovidVaccination$ vac
         On dea.location=vac.location
		   and dea.date=vac.date
		   where dea.continent is not null 
	)
Select *, (RollingVaccinationCount/Population)*100
From popVsvac

-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
      ( 
			Continent nvarchar(255),
			Location nvarchar(255),
			Date datetime,
			Population numeric,
			New_Vacccinations numeric,
			RollingVaccinationCount numeric
																					 )
Insert Into #PercentPopulationVaccinated
 Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast( vac.new_vaccinations as numeric) ) Over (Partition by  dea.location Order by dea.location , dea.Date)
	as RollingVaccinationCount
From 
Portfolioproject1.dbo.CovidDeath$  dea
Join 
Portfolioproject1.dbo.CovidVaccination$ vac
         On dea.location=vac.location
		   and dea.date=vac.date
		where dea.continent is not null 
	Select *, (RollingVaccinationCount/Population)*100
                     From  #PercentPopulationVaccinated
--Creating View to Store Data for Later Visualizations
Create View PercentPopulationVaccinated  as
 Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast( vac.new_vaccinations as numeric) ) Over (Partition by  dea.location Order by dea.location , dea.Date)
	as RollingVaccinationCount
From 
Portfolioproject1.dbo.CovidDeath$  dea
Join 
Portfolioproject1.dbo.CovidVaccination$ vac
         On dea.location=vac.location
		   and dea.date=vac.date
		where dea.continent is not null 
	