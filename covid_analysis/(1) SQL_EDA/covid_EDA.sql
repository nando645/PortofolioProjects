select TOP 10 * 
from [[Portofolio]]-CovidDeaths]..covid_deaths$ as cd
where cd.continent is not null;

-- Covid total_infected and total_death_counts per country
select  
	cd.location, 
    max(cast(cd.population as float)) as total_populations,
	case
		when max(cast(cd.total_cases as float)) is null then 0
		else max(cast(cd.total_cases as float))
	end as total_infected,
	case
		when max(cast(cd.total_deaths as float)) is null then 0
		else max(cast(cd.total_deaths as float)) 
	end as total_death_counts
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
    max(cast(cd.total_deaths as float)) as deaths,
    ROUND(max(cast(cd.total_deaths as float)) / max(cast(cd.population as float)) * 100, 3) as death_rate,
    CONCAT(ROUND(MAX(cast(cd.total_deaths as float)) / MAX(cast(cd.total_cases as float)) * 100, 3), '%') as fatality_rate
from [[Portofolio]]-CovidDeaths]..covid_deaths$ as cd
where cd.continent is not null
group by cd.continent

-- Daily global total_infected & deaths since beginning
select
	cd.date,
	sum(cast(cd.new_cases as float)) as daily_total_cases,
	sum(cast(cd.new_deaths as float)) as daily_total_deaths,
	CASE
        WHEN SUM(CAST(cd.new_cases AS FLOAT)) = 0 THEN 0
        ELSE ROUND(SUM(CAST(cd.new_deaths AS FLOAT)) / SUM(CAST(cd.new_cases AS FLOAT)) * 100, 2)
    END AS fatality_rate
from [[Portofolio]]-CovidDeaths]..covid_deaths$ as cd
where cd.location='World' and cd.new_cases is not null
group by cd.date
order by 1,2

-- Global total_infected and deaths
select
	--cd.date,
	sum(cast(cd.new_cases as float)) as total_cases,
	sum(cast(cd.new_deaths as float)) as total_deaths,
	CASE
        WHEN SUM(CAST(cd.new_cases AS FLOAT)) = 0 THEN 0
        ELSE ROUND(SUM(CAST(cd.new_deaths AS FLOAT)) / SUM(CAST(cd.new_cases AS FLOAT)) * 100, 2)
    END AS fatality_rate
from [[Portofolio]]-CovidDeaths]..covid_deaths$ as cd
where cd.location='World' and cd.new_cases is not null
--group by cd.date
order by 1,2;

-- Daily country all vaccinations vs population rate
SELECT 
    cd.location,
    cd.date,
    CAST(cd.population AS FLOAT) AS total_populations,
	cast(cv.new_vaccinations as float) as daily_vaccinations,
	SUM(convert(float, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as cum_vaccinated, 
	case 
		when SUM(convert(float, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) is null then null
		else round(SUM(convert(float, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)/cast(cd.population as float)*100,3)
	end as vaccination_rate
FROM [[Portofolio]]-CovidDeaths]..covid_deaths$ AS cd
JOIN [[Portofolio]]-CovidDeaths]..covid_vaccinations$ AS cv
    ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL and cd.location ='Indonesia'
order by cd.location, cd.date asc

-- Country full vaccinated vs population rate
select
	cd.location,
	max(cast(cd.population as float)) as populations,
	max(cast(cv.people_fully_vaccinated as float)) as fully_vaccinated,
	case
		when max(cast(cv.people_fully_vaccinated as float)) is null then null
		else round(max(cast(cv.people_fully_vaccinated as float))/max(cast(cd.population as float)) *100,3)
	end as fully_vaccination_rate
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
	max(cast(cd.population as float)) as populations,
	max(cast(cd.total_deaths as float)) as total_death,
	max(cast(cv.cardiovasc_death_rate as float)) as cdr,
	max(cast(cv.diabetes_prevalence as float)) as diabetes
FROM [[Portofolio]]-CovidDeaths]..covid_deaths$ AS cd
JOIN [[Portofolio]]-CovidDeaths]..covid_vaccinations$ AS cv
    ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
group by cd.location
order by total_death desc


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT 
    cd.location,
    cd.date,
    CAST(cd.population AS FLOAT) AS total_populations,
	cast(cv.new_vaccinations as float) as daily_vaccinations,
	SUM(convert(float, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as cum_vaccinated, 
	case 
		when SUM(convert(float, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) is null then null
		else round(SUM(convert(float, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)/cast(cd.population as float)*100,3)
	end as vaccination_rate
FROM [[Portofolio]]-CovidDeaths]..covid_deaths$ AS cd
JOIN [[Portofolio]]-CovidDeaths]..covid_vaccinations$ AS cv
    ON cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent IS NOT NULL