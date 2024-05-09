-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022






SELECT * 
FROM world_layoffs.layoffs;



CREATE TABLE world_layoffs.layoffs_stages 
LIKE world_layoffs.layoffs;

INSERT layoffs_stages 
SELECT * FROM world_layoffs.layoffs;


-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways



-- 1. Remove Duplicates




SELECT *
FROM world_layoffs.layoffs_stages
;

SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`) AS row_num
	FROM 
		world_layoffs.layoffs_stages;



SELECT *
FROM (
	SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`
			) AS row_num
	FROM 
		world_layoffs.layoffs_stages
) duplicates
WHERE 
	row_num > 1;
    
-- let's just look at oda to confirm
SELECT *
FROM world_layoffs.layoffs_stages
WHERE company = 'Oda'
;

SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_stages
) duplicates
WHERE 
	row_num > 1;

-- these are the ones we want to delete where the row number is > 1 or 2or greater essentially

-- now you may want to write it like this:
WITH DELETE_CTE AS 
(
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_stages
) duplicates
WHERE 
	row_num > 1
)
DELETE
FROM DELETE_CTE
;


WITH DELETE_CTE AS (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM world_layoffs.layoffs_stages
)
DELETE FROM world_layoffs.layoffs_stages
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
	FROM DELETE_CTE
) AND row_num > 1;



ALTER TABLE world_layoffs.layoffs_stages ADD row_num INT;


SELECT *
FROM world_layoffs.layoffs_stages
;

CREATE TABLE `world_layoffs`.`layoffs_stages2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);

INSERT INTO `world_layoffs`.`layoffs_stages2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_stages;


DELETE FROM world_layoffs.layoffs_stages2
WHERE row_num >= 2;







-- 2. Standardize Data

SELECT * 
FROM world_layoffs.layoffs_stages2;

-- if we look at industry it looks like we have some null and empty rows, let's take a look at these
SELECT DISTINCT industry
FROM world_layoffs.layoffs_stages2
ORDER BY industry;

SELECT *
FROM world_layoffs.layoffs_stages2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- let's take a look at these
SELECT *
FROM world_layoffs.layoffs_stages2
WHERE company LIKE 'Bally%';
-- nothing wrong here
SELECT *
FROM world_layoffs.layoffs_stages2
WHERE company LIKE 'airbnb%';



UPDATE world_layoffs.layoffs_stages2
SET industry = NULL
WHERE industry = '';


SELECT *
FROM world_layoffs.layoffs_stages2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;


UPDATE layoffs_stages2 t1
JOIN layoffs_stages2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM world_layoffs.layoffs_stages2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- ---------------------------------------------------

SELECT DISTINCT industry
FROM world_layoffs.layoffs_stages2
ORDER BY industry;

UPDATE layoffs_stages2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- now that's taken care of:
SELECT DISTINCT industry
FROM world_layoffs.layoffs_stages2
ORDER BY industry;

-- --------------------------------------------------


SELECT *
FROM world_layoffs.layoffs_stages2;

SELECT DISTINCT country
FROM world_layoffs.layoffs_stages2
ORDER BY country;

UPDATE layoffs_stages2
SET country = TRIM(TRAILING '.' FROM country);

SELECT DISTINCT country
FROM world_layoffs.layoffs_stages2
ORDER BY country;


-- Let's also fix the date columns:
SELECT *
FROM world_layoffs.layoffs_stages2;

-- we can use str to date to update this field
UPDATE layoffs_stages2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- now we can convert the data type properly
ALTER TABLE layoffs_stages2
MODIFY COLUMN `date` DATE;


SELECT *
FROM world_layoffs.layoffs_stages2;





-- 3. Look at Null Values

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values




-- 4. remove any columns and rows we need to

SELECT *
FROM world_layoffs.layoffs_stages2
WHERE total_laid_off IS NULL;


SELECT *
FROM world_layoffs.layoffs_stages2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use
DELETE FROM world_layoffs.layoffs_stages2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM world_layoffs.layoffs_stages2;

ALTER TABLE layoffs_stages2
DROP COLUMN row_num;


SELECT * 
FROM world_layoffs.layoffs_stages2;	
