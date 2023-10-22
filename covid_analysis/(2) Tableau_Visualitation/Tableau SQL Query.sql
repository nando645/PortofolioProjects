-- Infection & Death Related
SELECT 
	*
FROM [[Portofolio]]-CovidDeaths]..covid_deaths$ as cd
JOIN [[Portofolio]]-CovidDeaths]..covid_vaccinations$ as cv
	ON cd.location=cv.location and cd.date=cv.date
WHERE cd.location = 'Indonesia'
ORDER BY cd.date DESC

SELECT 
	cd.continent, 
	cd.location, 
	cd.date,
	CAST(cd.population AS FLOAT) AS total_populations,
	CAST(cd.total_cases AS FLOAT) AS total_infected,
	CAST(cd.new_cases AS FLOAT) AS daily_infected,
	CAST(cd.total_deaths AS FLOAT) AS total_death_counts,
	CAST(cd.new_deaths AS FLOAT) AS daily_death_counts,
	CAST(cv.total_vaccinations AS FLOAT) AS total_vaccinations,
	CAST(cv.people_vaccinated AS FLOAT) AS partially_vaccinated,
	CAST(cv.people_fully_vaccinated AS FLOAT) AS fully_vaccinated,
	CAST(cv.population_density AS FLOAT) AS population_density,
	CAST(cv.median_age AS FLOAT) AS median_age,
	CAST(cv.extreme_poverty AS FLOAT) AS poverty,
	CAST(cv.cardiovasc_death_rate AS FLOAT) as cardiovasc_rate,
	CAST(cv.diabetes_prevalence AS FLOAT) AS diabetes_prevalence
FROM [[Portofolio]]-CovidDeaths]..covid_deaths$ AS cd
JOIN [[Portofolio]]-CovidDeaths]..covid_vaccinations$ AS cv
	ON cd.location=cv.location and cd.date=cv.date
ORDER BY cv.diabetes_prevalence ASC

SELECT
	max(cast(cd.total_deaths as float))
from [[Portofolio]]-CovidDeaths]..covid_deaths$ as cd
where cd.continent is not null

select count(cd.date)
from [[Portofolio]]-CovidDeaths]..covid_deaths$ as cd
where cd.continent is not null