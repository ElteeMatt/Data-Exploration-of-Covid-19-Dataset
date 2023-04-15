

use PortfolioProject

select *
from PortfolioProject..CovidDeaths
order by 3,4

select * 
from PortfolioProject..CovidVaccination
order by 3,4



----Looking at the data we are going to be using--

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 3,4


---Looking at total Cases vs Total Deaths
---Showing what percentage of population got Covid


select location, date, population total_cases,total_deaths, (total_deaths/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Zimbabwe%'
order by 1,2


--- Looking at Countries with Highest Infection Rate compared to Population 


select location, population, Max(total_cases) as HighestInfectionCount, Max(total_deaths/population)*100 
	as PercentagePopulationInfected
	from PortfolioProject..CovidDeaths
	--where location like '%Zimbabwe%'
	Group by location, Population
	order by PercentagePopulationInfected


----Countries with the Highest Death Count per population

select location, Max(cast(total_deaths as int)) as TotalDeathCount
	from PortfolioProject..CovidDeaths
	---where location like '%Zimbabwe%'
	where continent is not null
	Group by location
	order by TotalDeathCount desc


----Let's break things down by continent

----Showing continents with the highest death count per population

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
	from PortfolioProject..CovidDeaths
	---where location like '%Zimbabwe%'
	where continent is not null
	Group by continent
	order by TotalDeathCount desc




	---GLOBAL NUMBERS OF TOTAL DEATHS & TOTAL CASES

select Sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100
as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%Zimbabwe%'
where continent is not null
--Group By date
order by 1,2



----Looking at Total Population vs Vaccination

select *
from PortfolioProject..CovidDeaths CovD
join PortfolioProject..CovidVaccination CovVac
	on CovD.location = CovVac.location
	and CovD.date = CovVac.date
	order by CovD.location desc


	select CovD.continent, CovD.location, CovD.continent, CovD.population, CovVac.new_vaccinations
	,SUM(CONVERT(bigint,CovVac.new_vaccinations)) OVER (Partition by CovD.location Order by CovD.location,
	CovD.date) as RollingPeopleVaccinated
	from PortfolioProject..CovidDeaths CovD
join PortfolioProject..CovidVaccination CovVac
	on CovD.location = CovVac.location
	and CovD.date = CovVac.date
	where CovD.continent is not null  
	order by 2,3

	---USE CTE---

With PopvsVac (Continent, Location, Date, Population, new_vaccination, RollingPeopleVaccinated)
as
(
select CovD.continent, CovD.location, CovD.continent, CovD.population, CovVac.new_vaccinations
	,SUM(CONVERT(bigint,CovVac.new_vaccinations)) OVER (Partition by CovD.location Order by CovD.location,
	CovD.date) as RollingPeopleVaccinated
	from PortfolioProject..CovidDeaths CovD
join PortfolioProject..CovidVaccination CovVac
	on CovD.location = CovVac.location
	and CovD.date = CovVac.date
	where CovD.continent is not null 
	---order by 2,3
	)
	Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPopulation
	From PopvsVac
	Order by VaccinatedPopulation desc



	---TEMP TABLE--

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
	
INSERT INTO #PercentPopulationVaccinated
select CovD.continent, CovD.location, CovD.date, CovD.population, CovVac.new_vaccinations
	,SUM(CONVERT(bigint,CovVac.new_vaccinations)) OVER (Partition by CovD.location Order by CovD.location,
	CovD.date) as RollingPeopleVaccinated
	from PortfolioProject..CovidDeaths CovD
join PortfolioProject..CovidVaccination CovVac
	on CovD.location = CovVac.location
	and CovD.date = CovVac.date
	where CovD.continent is not null 
	---order by 2,3

	SELECT * FROM #PercentPopulationVaccinated