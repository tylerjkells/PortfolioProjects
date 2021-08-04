/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/



Select *
From CovidPortfolioProject..[Covid Deaths]
Where continent is not null
Order By 3,4

Select *
From CovidPortfolioProject..[Covid Vaccinations]
order by 3,4



--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidPortfolioProject..[Covid Deaths]
Where continent is not null
Order By 1, 2



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortfolioProject..[Covid Deaths]
Where location like '%states%'
And continent is not null
Order By 1, 2



-- Total Cases vs Population
-- Shows what percentage of the population has contracted covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidPortfolioProject..[Covid Deaths]
Where continent is not null
And location like '%states%'
Order By 1, 2



-- Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidPortfolioProject..[Covid Deaths]
Where continent is not null
Group By location
Order By PercentPopulationInfected desc



-- Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..[Covid Deaths]
Where continent is not null
Group By location, population
Order By TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT


-- Continents with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..[Covid Deaths]
Where continent is null
Group By location
Order By TotalDeathCount desc



-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidPortfolioProject..[Covid Deaths]
Where continent is not null
Group By date
Order By 1, 2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From CovidPortfolioProject..[Covid Deaths] dea
Join CovidPortfolioProject..[Covid Vaccinations] vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
Order By 2, 3



-- Using CTE to perform Calculation on Partition By in previous entry

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From CovidPortfolioProject..[Covid Deaths] dea
Join CovidPortfolioProject..[Covid Vaccinations] vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous entry

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From CovidPortfolioProject..[Covid Deaths] dea
Join CovidPortfolioProject..[Covid Vaccinations] vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From CovidPortfolioProject..[Covid Deaths] dea
Join CovidPortfolioProject..[Covid Vaccinations] vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated