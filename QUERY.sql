SELECT * 
FROM portfolioproject..CovidDeaths 
ORDER BY 3,4

--select *
--FROM portfolioproject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM portfolioproject..CovidDeaths 
ORDER BY 1,2

--Total cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM portfolioproject..CovidDeaths 
where location like 'Egypt'
ORDER BY date

--Total cases vs population
--To find the percentage of the population who got covid-19
SELECT location, date, population, total_cases , (total_cases/population)*100 AS Cases_Percentage
FROM portfolioproject..CovidDeaths 
where location like 'Egypt'
ORDER BY date

--Countries with highest infection rate comapred to population
SELECT location, population, MAX(total_cases) AS Highest_Infection_Countries, MAX(total_cases/population)*100 AS highest_Cases_Percentage
FROM portfolioproject..CovidDeaths 
GROUP BY location, population
ORDER BY highest_Cases_Percentage desc;

--countries with highest deaths
SELECT location, MAX(cast(total_deaths as int)) AS Deaths_per_Countries
FROM portfolioproject..CovidDeaths 
WHERE continent is not null
GROUP BY location
ORDER BY Deaths_per_Countries desc;

--continent total deaths
SELECT continent, MAX(cast(total_deaths as int)) AS Deaths_per_Countries
FROM portfolioproject..CovidDeaths 
WHERE continent is not null
GROUP BY continent
ORDER BY Deaths_per_Countries desc;

--Global Deathes per day

SELECT  date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as int)) as total_death, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS Death_Percentage
FROM portfolioproject..CovidDeaths 
WHERE continent is not null
GROUP BY date
ORDER BY date

--Global Total number of cases and deaths

SELECT   SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as int)) as total_death, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS Death_Percentage
FROM portfolioproject..CovidDeaths 
WHERE continent is not null

--Total vaccinated population
WITH rollvac (continent, location, date, population, new_vaccinations, Totalvaccinatedperday)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as Totalvaccinatedperday
FROM portfolioproject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (Totalvaccinatedperday/population)*100 as total_percentage_vaccinated_perday
FROM rollvac

--Temp Table
drop table #percentpopulationvaccinated
--As needed per each modifcation
Create Table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert into #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as Totalvaccinatedperday
FROM portfolioproject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null


SELECT *, (Rollingpeoplevaccinated/population)*100 as total_percentage_vaccinated_perday
FROM #percentpopulationvaccinated

--Creating View to store data for visuallization

Create View percentpopulationvaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as Totalvaccinatedperday
FROM portfolioproject..CovidDeaths dea
join portfolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
