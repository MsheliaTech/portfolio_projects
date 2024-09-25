--Covid 19 Data Exploration

--Used: Aggregate Functions, Converting Data Types, Joins, Windows Functions, CTE's, Temp Tables, Creating Views

Select *
From portfolio_project..covid_deaths
Where continent is not null
Order by 3,4


Select * 
From portfolio_project..covid_vaccinations
Where continent is not null
Order by 3,4


--Data that we are going to be using 

Select location, date, population, total_cases, new_cases, total_deaths 
From portfolio_project..covid_deaths
Where continent is not null
Order by 1,2


--Total Cases Versus Total Deaths 

--Likelihood of Dying if you are Infected with Covid in your Country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From portfolio_project..covid_deaths
Where location like '%Nigeria%' and continent is not null
Order by 1,2


--Total Cases Versus Population 

--Percentage of Population Infected with Covid

Select location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
From portfolio_project..covid_deaths
--Where location like '%Nigeria%'
Order by 1,2


--Countries Highest Infection Rate Compared to Population 

Select location, population, Max(total_cases) as highest_infection_count, Max(total_cases/population)*100 as percent_population_infected
From portfolio_project..covid_deaths
--Where location like '%Nigeria%'
Where continent is not null
Group by location, population
Order by percent_population_infected desc


--Countries Highest Death Count per Population 

Select location, population, Max(cast(total_deaths as int)) as total_death_count
From portfolio_project..covid_deaths
--Where location like '%Nigeria%'
Where continent is not null
Group by location, population 
Order by total_death_count desc


--Breaking Data down by Continent

--Continents Highest Death Count per Population 

Select continent,  Max(cast(total_deaths as int)) as total_death_count
From portfolio_project..covid_deaths
--Where location like '%Nigeria%'
Where continent is not null
Group by continent
Order by total_death_count desc


--Continents Highest Infection Count 

Select continent,  Max(total_cases) as total_infected_count
From portfolio_project..covid_deaths
--Where location like '%Nigeria%'
Where continent is not null
Group by continent
Order by total_infected_count desc


--World Numbers

--Total Percentage of new Deaths 

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, 
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as new_death_percentage
From portfolio_project..covid_deaths
--Where location like '%Nigeria%'
Where continent is not null
--Group by date
Order by 1,2


--Percentage of Daily new Deaths

Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, 
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as new_death_percentage
From portfolio_project..covid_deaths
--Where location like '%Nigeria%'
Where continent is not null
Group by date
Order by 1,2


--Total Population Versus Vaccinations

--Percentage of Population that have Received Covid Vaccine 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(new_vaccinations as Bigint))
Over (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
From portfolio_project..covid_deaths dea
Join portfolio_project..covid_vaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null -- and new_vaccinations is not null
Order by 2,3


--CTE to Perform Calculation on Partition By in the Previous Query

With pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(new_vaccinations as Bigint)) 
Over (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
From portfolio_project..covid_deaths dea
Join portfolio_project..covid_vaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (rolling_people_vaccinated/population)*100
From pop_vs_vac


--Temp Table to Perform Calculation on Partition By in the Previous Query

Drop Table if exists #percent_population_vaccinated
Create Table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric,
)

Insert into #percent_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(new_vaccinations as Bigint)) 
Over (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
From portfolio_project..covid_deaths dea
Join portfolio_project..covid_vaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (rolling_people_vaccinated/population)*100
From #percent_population_vaccinated


--View to Store Data for later Visualizations

Create View percent_population_vaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(new_vaccinations as Bigint)) 
Over (Partition by dea.location Order by dea.location, dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
From portfolio_project..covid_deaths dea
Join portfolio_project..covid_vaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From percent_population_vaccinated

