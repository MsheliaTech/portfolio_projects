-- Exploratory Data Analysis

-- Finding Trends and Patterns or any Outliers


SELECT *
FROM world_layoffs.layoffs_staging2;


-- Highest Total Layoffs and Highest Percentage of Layoffs

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM world_layoffs.layoffs_staging2;


-- Companies that Laid off 100 Percent of the Company

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;


-- Funds Raised by Companies that Laid off 100 Percent of the Company 

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1 AND funds_raised_millions IS NOT NULL AND funds_raised_millions <> 0
ORDER BY funds_raised_millions DESC;


-- Start Date and End Date of Layoffs

SELECT MIN(`date`), MAX(`date`)
FROM world_layoffs.layoffs_staging2;


-- Total Layoffs by Company

SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
HAVING SUM(total_laid_off) IS NOT NULL
ORDER BY 2 DESC;


-- Total Layoffs by Industry 

SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY 2 DESC;


-- Total Layoffs by Country

SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
HAVING SUM(total_laid_off) IS NOT NULL
ORDER BY 2 DESC;


-- Total Layoffs by Year

SELECT YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;


-- Total Layoffs by Stage

SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE stage IS NOT NULL
GROUP BY stage
ORDER BY 2 DESC;


-- Average Percentage of Layoffs by Company

SELECT company, AVG(percentage_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
HAVING AVG(percentage_laid_off)
ORDER BY 2 DESC;


-- Rolling Total of Layoffs by Month

SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH rolling_total_cte AS 
(
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM world_layoffs.layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER (ORDER BY `MONTH`) AS rolling_total
FROM rolling_total_cte;

SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
HAVING SUM(total_laid_off) IS NOT NULL
ORDER BY 2 DESC;


-- Ranking Companies with the Highest Layoffs by Year

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company, YEAR(`date`)
HAVING SUM(total_laid_off) IS NOT NULL
ORDER BY 3 DESC;

WITH company_year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company, YEAR(`date`)
HAVING SUM(total_laid_off) IS NOT NULL
), company_year_rank AS 
(
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking 
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;