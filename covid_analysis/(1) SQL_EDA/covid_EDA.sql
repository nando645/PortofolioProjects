select TOP 10 * 
from [[Portofolio]]-CovidDeaths]..covid_deaths$ as cd
where cd.continent is not null;

-- Covid total_infected and total_death_counts per country
select  
	cd.location, 
    max(cast(cd.population as float)) as total_populations,
	max(cast(cd.total_cases as float)) as total_infected,
	max(cast(cd.total_deaths as float)) as total_death_counts
from [[Portofolio]]-CovidDeaths]..covid_deaths$ as cd
where cd.continent is not null
group by cd.location
order by cd.location ASC;

-- Country with highest infection rate per population (total_infected to total_populations ratio)
select  
	cd.location, 
    max(cast(cd.population as float)) as total_populations, 
    max(cast(cd.total_cases as float)) as total_infected,
	ROUND(max(cast(cd.total_cases as float)) / max(cast(cd.population as float)) * 100, 3) as infection_rate
from [[Portofolio]]-CovidDeaths]..covid_deaths$ as cd
where cd.continent is not null
group by cd.location
order by infection_rate DESC;

-- Country with highest deaths per population (total_death_counts to total_populations ratio) 
select  
	cd.location, 
    max(cast(cd.population as float)) as total_populations, 
    max(cast(cd.total_deaths as float)) as total_death_counts,
    ROUND(max(cast(cd.total_deaths as float)) / max(cast(cd.population as float)) * 100, 3) as death_rate
from [[Portofolio]]-CovidDeaths]..covid_deaths$ as cd
where cd.continent is not null
group by cd.location
order by death_rate DESC;

-- Country with highest fatality rate (total_death_counts to total_infected ratio) 
select  
	cd.location, 
    max(cast(cd.population as float)) as total_populations, 
    max(cast(cd.total_cases as float)) as total_infected,
	max(cast(cd.total_deaths as float)) as total_death_counts,
	ROUND(max(cast(cd.total_cases as float)) / max(cast(cd.population as float)) * 100, 3) as infection_rate,
    ROUND(max(cast(cd.total_deaths as float)) / max(cast(cd.population as float)) * 100, 3) as death_rate,
    ROUND(MAX(cast(cd.total_deaths as float)) / MAX(cast(cd.total_cases as float)) * 100, 3) as fatality_rate
from [[Portofolio]]-CovidDeaths]..covid_deaths$ as cd
where cd.continent is not null
group by cd.location
order by fatality_rate DESC;

--Data summary for each continent
select
	cd.continent, 
    max(cast(cd.population as float)) as total_populations, 
    max(cast(cd.total_cases as float)) as total_infected,
	ROUND(max(cast(cd.total_cases as float)) / max(cast(cd.population as float)) * 100, 3) as infection_rate,
    max(cast(cd.total_deaths as float)) as total_death_counts,
    ROUND(max(cast(cd.total_deaths as float)) / max(cast(cd.population as float)) * 100, 3) as death_rate,
    CONCAT(ROUND(MAX(cast(cd.total_deaths as float)) / MAX(cast(cd.total_cases as float)) * 100, 3), '%') as fatality_rate
from [[Portofolio]]-CovidDeaths]..covid_deaths$ as cd
where cd.continent is not null
group by cd.continent

-- Daily global total_infected & deaths since beginning
SELECT 
    cd.location,
    cd.date,
    CAST(cd.population AS FLOAT) AS total_populations,
	cast(cd.new_cases as float) as daily_infected,
	SUM(convert(float, cd.new_cases)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as cum_daily_infected,
	cast(cd.new_deaths as float) as daily_death_counts,
	SUM(convert(float, cd.new_deaths)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as cum_daily_death_counts
FROM [[Portofolio]]-CovidDeaths]..covid_deaths$ AS cd
WHERE cd.location ='World'
order by cd.location, cd.date asc

-- Global total_infected and deaths
select
	cast(cd.population as float),
	sum(cast(cd.new_cases as float)) as total_infected,
	sum(cast(cd.new_deaths as float)) as total_death_counts,
	ROUND(SUM(CAST(cd.new_deaths AS FLOAT)) / SUM(CAST(cd.new_cases AS FLOAT)) * 100, 2) as fatality_rate
from [[Portofolio]]-CovidDeaths]..covid_deaths$ as cd
where cd.location='World'
group by cd.population

-- Daily country all vaccinations vs population rate
SELECT 
    cd.location,
    cd.date,
    CAST(cd.population AS FLOAT) AS total_populations,
	cast(cv.new_vaccinations as float) as daily_vaccinated,
	SUM(convert(float, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as cum_vaccinated, 
	round(SUM(convert(float, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)/cast(cd.population as float)*100,3) as vaccination_rate
FROM [[Portofolio]]-CovidDeaths]..covid_deaths$ AS cd
JOIN [[Portofolio]]-CovidDeaths]..covid_vaccinations$ AS cv
    ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
order by cd.location, cd.date asc

-- Country full vaccinated vs population rate
select
	cd.location,
	max(cast(cd.population as float)) as total_populations,
	max(cast(cv.people_fully_vaccinated as float)) as fully_vaccinated,
	round(max(cast(cv.people_fully_vaccinated as float))/max(cast(cd.population as float)) *100,3) as fully_vaccination_rate
FROM [[Portofolio]]-CovidDeaths]..covid_deaths$ AS cd
JOIN [[Portofolio]]-CovidDeaths]..covid_vaccinations$ AS cv
    ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
group by cd.location
order by fully_vaccination_rate desc

-- Relation of deaths, cardiovasc_death_rate, and diabetes
select
	cd.location,
	max(cast(cd.population as float)) as total_populations,
	max(cast(cd.total_deaths as float)) as total_death_counts,
	max(cast(cv.cardiovasc_death_rate as float)) as cdr,
	max(cast(cv.diabetes_prevalence as float)) as diabetes
FROM [[Portofolio]]-CovidDeaths]..covid_deaths$ AS cd
JOIN [[Portofolio]]-CovidDeaths]..covid_vaccinations$ AS cv
    ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
group by cd.location
order by total_death_counts desc


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT 
    cd.location,
    cd.date,
    CAST(cd.population AS FLOAT) AS total_populations,
	cast(cv.new_vaccinations as float) as daily_vaccinated,
	SUM(convert(float, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as cum_vaccinated, 
	round(SUM(convert(float, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)/cast(cd.population as float)*100,3) as vaccination_rate
FROM [[Portofolio]]-CovidDeaths]..covid_deaths$ AS cd
JOIN [[Portofolio]]-CovidDeaths]..covid_vaccinations$ AS cv
    ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL