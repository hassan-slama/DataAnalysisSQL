  #       DATA CLEANING
  
  
  
  SELECT *
  FROM layoffs;
  
  
  # 1. REMOVE DUPLICATES
  # 2. STANDARDIZE THE DATA
  # 3. NULL & BLANK VALUES
  # 4. REMOVE UNNECESSARY COLUMNS
  
  
  CREATE TABLE layoffs_stages
	like layoffs;
  
  
  select * 
  from layoffs_stages;
  
  
  insert layoffs_stages
  select *
  from layoffs;
  
  
  
  
  with duplicate_cte as
  (
		select *,row_number() over(
        partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
        from layoffs_stages
  )
  select *
  from duplicate_cte
  where row_num >1;
  
  
  select *
  from layoffs_stages
  where company = 'Yahoo';
  
  
  
  
  
  CREATE TABLE `layoffs_stages2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



select *
from layoffs_stages2;

insert into layoffs_stages2
select *,row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num

from layoffs_stages;


select * 
from layoffs_stages2
where row_num>1;



delete
from layoffs_stages2
where row_num>1;