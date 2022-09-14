-- Data Gathering/Data Entry
-- creating the database for the dataset
CREATE DATABASE IF NOT EXISTS data_science_jobs_salaries;


-- Selecting the active database
USE data_science_jobs_salaries;


-- creating the table for the dataset if you cant load the data directly
CREATE TABLE IF NOT EXISTS ds_salaries (
	MyUnknownColumn INT,
    work_year YEAR,
    experience_level CHAR(2),
    employment_type CHAR(2),
    job_title VARCHAR(255),
    salary INT,
    salary_currency CHAR(3),
    salary_in_usd INT,
    employee_residence CHAR(2),
    remote_ratio NUMERIC,
    company_location CHAR(2),
    company_size CHAR(1)
    );
    
-- To check if it worked
SHOW TABLES;

-- checking the table description
DESCRIBE ds_salaries;

-- to load the data into the table
LOAD DATA LOCAL INFILE 'ds_salaries.csv' -- file path location
	INTO TABLE ds_salaries
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES;
    
-- Data Inspection
USE data_science_jobs;
-- number of rows
SELECT count(*) 
FROM data_science_jobs.ds_salaries;
-- 607 rows

-- number of columns
SELECT COUNT(*)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'ds_salaries';
-- 12 columns

-- Data Cleaning
-- Overview of the data
SELECT * 
FROM ds_salaries;

DESCRIBE ds_salaries;

-- changing the name of the first column 
ALTER TABLE ds_salaries
CHANGE COLUMN  MyUnknownColumn row_num numeric;

-- changing the numbering of the first column
UPDATE ds_salaries
SET row_num = row_num + 1;

-- to check if the row number was numbered correctly 
WITH ds_salaries_cte as 
(
SELECT *,
	ROW_NUMBER() OVER() AS row_num_two
FROM ds_salaries
)
SELECT *
FROM ds_salaries_cte
WHERE row_num <> row_num_two;

-- No rows returned so the row_num column is accurate

-- to change the data type of the work year column
ALTER TABLE ds_salaries
MODIFY COLUMN work_year YEAR;

-- to change the elements of employment type 
UPDATE ds_salaries
SET employment_type = CASE WHEN employment_type = 'PT' THEN 'Part-time'
		WHEN employment_type = 'FT' THEN 'Full-time'
        WHEN employment_type = 'FL' THEN 'Freelance'
        WHEN employment_type = 'CT' THEN 'Contract'
        ELSE employment_type
        END;
        
-- checking if it worked
SELECT employment_type
FROM ds_salaries
GROUP BY employment_type;


-- to change the elements of experience level 
UPDATE ds_salaries
SET experience_level = CASE WHEN experience_level = 'EN' THEN 'Entry'
		WHEN experience_level = 'MI' THEN 'Mid'
        WHEN experience_level = 'SE' THEN 'Senior'
        WHEN experience_level = 'EX' THEN 'Executive'
        ELSE experience_level
        END;
        
-- checking if it worked
SELECT experience_level
FROM ds_salaries
GROUP BY experience_level;


-- to change the elements of company size
UPDATE ds_salaries
SET company_size = CASE WHEN company_size = 'L' THEN 'Large'
		WHEN company_size = 'M' THEN 'Medium'
        WHEN company_size = 'S' THEN 'Small'
        ELSE company_size
        END;
        
-- checking if it worked
SELECT company_size
FROM ds_salaries
GROUP BY company_size;

-- ML Engineer and Machine Learning Engineer are the same thing
UPDATE ds_salaries
SET job_title = "ML Engineer"
	WHERE job_title = "Machine Learning Engineer";
    
-- checking if it worked
SELECT job_title
FROM ds_salaries
WHERE job_title = 'Machine Learning Engineer';
------------------------------------------------------------------------------------------------------------------------------------
-- Data Exploration/ Data Analysis 

-- Overall Average salary in USD
SELECT AVG(salary_in_usd)
FROM ds_salaries;

-- Trend for Average paid salary per data science jobs per year
SELECT work_year, 
	AVG(salary_in_usd) as average_salary_per_job
FROM ds_salaries
GROUP BY work_year
ORDER BY average_salary_per_job;

-- the average paid salary per year for different experience level
SELECT experience_level, 
	AVG(CASE WHEN work_year = '2020' THEN salary_in_usd END) AS avg_salary_2020,
    AVG(CASE WHEN work_year = '2021' THEN salary_in_usd END) AS avg_salary_2021,
    AVG(CASE WHEN work_year = '2022' THEN salary_in_usd END) AS avg_salary_2022
FROM ds_salaries
GROUP BY experience_level
ORDER BY 4;

-- the average paid salary per year for different employment type 
SELECT employment_type, 
	AVG(CASE WHEN work_year = '2020' THEN salary_in_usd END) AS avg_salary_2020,
    AVG(CASE WHEN work_year = '2021' THEN salary_in_usd END) AS avg_salary_2021,
    AVG(CASE WHEN work_year = '2022' THEN salary_in_usd END) AS avg_salary_2022
FROM ds_salaries
GROUP BY employment_type
ORDER BY 4 DESC;

-- count of data science jobs per year for several employment type
SELECT employment_type, 
	COUNT(CASE WHEN work_year = '2020' THEN salary_in_usd ELSE NULL END) AS jobs_count_2020,
    COUNT(CASE WHEN work_year = '2021' THEN salary_in_usd ELSE NULL END) AS jobs_count_2021,
    COUNT(CASE WHEN work_year = '2022' THEN salary_in_usd ELSE NULL END) AS jobs_count_2022
FROM ds_salaries
GROUP BY employment_type
ORDER BY 4 DESC;

-- count of data science jobs and the average salary per year for several experience level and employment type
SELECT experience_level, 
	employment_type, 
	COUNT(CASE WHEN work_year = '2020' THEN salary_in_usd ELSE NULL END) AS jobs_count_2020,
    AVG(CASE WHEN work_year = '2020' THEN salary_in_usd END) AS avg_salary_2020,
    COUNT(CASE WHEN work_year = '2021' THEN salary_in_usd ELSE NULL END) AS jobs_count_2021,
    AVG(CASE WHEN work_year = '2021' THEN salary_in_usd END) AS avg_salary_2021,
    COUNT(CASE WHEN work_year = '2022' THEN salary_in_usd ELSE NULL END) AS jobs_count_2022,
    AVG(CASE WHEN work_year = '2022' THEN salary_in_usd END) AS avg_salary_2022
FROM ds_salaries
GROUP BY experience_level, employment_type
ORDER BY 8 DESC;


SELECT * 
FROM ds_salaries;

-- Average Salary per job title 
SELECT job_title,
	ROUND(AVG(CASE WHEN work_year = '2020' THEN salary_in_usd END), 2) AS avg_salary_2020,
    ROUND(AVG(CASE WHEN work_year = '2021' THEN salary_in_usd END), 2) AS avg_salary_2021,
    ROUND(AVG(CASE WHEN work_year = '2022' THEN salary_in_usd END), 2) AS avg_salary_2022
FROM ds_salaries
GROUP BY job_title
ORDER BY 4 DESC, 
		3 DESC, 
        2 DESC;


-- Top 10 payiong jobs in 2022
SELECT job_title,
	employment_type,
    experience_level,
    remote_ratio,
    company_size,
    salary_in_usd
FROM ds_salaries
WHERE work_year = '2022'
ORDER BY salary_in_usd DESC
LIMIT 10;

-- Top 10 payiong jobs in 2021
SELECT job_title,
	employment_type,
    experience_level,
    remote_ratio,
    company_size,
    salary_in_usd
FROM ds_salaries
WHERE work_year = '2021'
ORDER BY salary_in_usd DESC
LIMIT 10;

-- Top 10 payiong jobs in 2020
SELECT job_title,
	employment_type,
    experience_level,
    remote_ratio,
    company_size,
    salary_in_usd
FROM ds_salaries
WHERE work_year = '2020'
ORDER BY salary_in_usd DESC
LIMIT 10;

-- percentage of jobs earning above 100,000 usd for 2020, 2021, 2022
SELECT 
	COUNT(CASE WHEN salary_in_usd > 100000 THEN salary_in_usd ELSE NULL END)/ COUNT(*) AS perc_job_salary_above_100k,
    COUNT(CASE WHEN salary_in_usd <= 100000 THEN salary_in_usd ELSE NULL END)/ COUNT(*) AS perc_job_salary_below_100k
FROM ds_salaries
WHERE work_year = '2020';

SELECT 
	COUNT(CASE WHEN salary_in_usd > 100000 THEN salary_in_usd ELSE NULL END)/ COUNT(*) AS perc_job_salary_above_100k,
    COUNT(CASE WHEN salary_in_usd <= 100000 THEN salary_in_usd ELSE NULL END)/ COUNT(*) AS perc_job_salary_below_100k
FROM ds_salaries
WHERE work_year = '2021';

SELECT 
	COUNT(CASE WHEN salary_in_usd > 100000 THEN salary_in_usd ELSE NULL END)/ COUNT(*) AS perc_job_salary_above_100k,
    COUNT(CASE WHEN salary_in_usd <= 100000 THEN salary_in_usd ELSE NULL END)/ COUNT(*) AS perc_job_salary_below_100k
FROM ds_salaries
WHERE work_year = '2022';


-- creating temp tables for 2020, 2021, 2022
CREATE TEMPORARY TABLE IF NOT EXISTS ds_salaries_2020 AS
(
	SELECT *
    FROM ds_salaries
    WHERE work_year = '2020'
);

CREATE TEMPORARY TABLE IF NOT EXISTS ds_salaries_2021 AS
(
	SELECT *
    FROM ds_salaries
    WHERE work_year = '2021'
);

CREATE TEMPORARY TABLE IF NOT EXISTS ds_salaries_2022 AS
(
	SELECT *
    FROM ds_salaries
    WHERE work_year = '2022'
);

-- For each temp table, check the top 5 paying jobs per experience level per company location

-- For Entry Level/ Junior roles

-- For year 2020
SELECT  job_title, 
	company_location,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2020
WHERE experience_level = "EN"
GROUP BY job_title, 
	company_location
ORDER BY 3 DESC
LIMIT 5;

-- For year 2021
SELECT  job_title, 
	company_location,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2021
WHERE experience_level = "EN"
GROUP BY job_title, 
	company_location
ORDER BY 3 DESC
LIMIT 5;

-- For year 2022
SELECT  job_title, 
	company_location,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2022
WHERE experience_level = "EN"
GROUP BY job_title, 
	company_location
ORDER BY 3 DESC
LIMIT 5;


-- For Mid Level/ Intermediate roles "MI"

-- For year 2020
SELECT  job_title, 
	company_location,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2020
WHERE experience_level = "MI"
GROUP BY job_title, 
	company_location
ORDER BY 3 DESC
LIMIT 5;

-- For year 2021
SELECT  job_title, 
	company_location,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2021
WHERE experience_level = "MI"
GROUP BY job_title, 
	company_location
ORDER BY 3 DESC
LIMIT 5;

-- For year 2022
SELECT  job_title, 
	company_location,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2022
WHERE experience_level = "MI"
GROUP BY job_title, 
	company_location
ORDER BY 3 DESC
LIMIT 5;


-- For Senior Level/ Expert roles "SE"

-- For year 2020
SELECT  job_title, 
	company_location,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2020
WHERE experience_level = "SE"
GROUP BY job_title, 
	company_location
ORDER BY 3 DESC
LIMIT 5;

-- For year 2021
SELECT  job_title, 
	company_location,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2021
WHERE experience_level = "SE"
GROUP BY job_title, 
	company_location
ORDER BY 3 DESC
LIMIT 5;

-- For year 2022
SELECT  job_title, 
	company_location,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2022
WHERE experience_level = "SE"
GROUP BY job_title, 
	company_location
ORDER BY 3 DESC
LIMIT 5;

-- For Executive Level/ Director roles "EX"

-- For year 2020
SELECT  job_title, 
	company_location,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2020
WHERE experience_level = "EX"
GROUP BY job_title, 
	company_location
ORDER BY 3 DESC
LIMIT 5;

-- For year 2021
SELECT  job_title, 
	company_location,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2021
WHERE experience_level = "EX"
GROUP BY job_title, 
	company_location
ORDER BY 3 DESC
LIMIT 5;

-- For year 2022
SELECT  job_title, 
	company_location,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2022
WHERE experience_level = "EX"
GROUP BY job_title, 
	company_location
ORDER BY 3 DESC
LIMIT 5;


-- Number of Jobs and Average Salaries Each Country are Paying per Data Science Jobs

-- For 2020
SELECT company_location,
	COUNT(*) AS Number_of_Jobs,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2020
GROUP BY company_location
-- HAVING AVG(salary_in_usd) > 50000
ORDER BY 3 DESC;

-- For 2021
SELECT company_location,
	COUNT(*) AS Number_of_Jobs,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2021
GROUP BY company_location
-- HAVING AVG(salary_in_usd) > 50000
ORDER BY 3 DESC;

-- For 2022
SELECT company_location,
	COUNT(*) AS Number_of_Jobs,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2022
GROUP BY company_location
-- HAVING AVG(salary_in_usd) > 50000
ORDER BY 3 DESC;


-- Number of Jobs and Average Salaries Each Country are Paying per Data Science 
-- Jobs and Grouping them by Company size

-- For 2020
SELECT company_size, 
	company_location,
	COUNT(*) AS Number_of_Jobs,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2020
GROUP BY company_size, 
	company_location
-- HAVING AVG(salary_in_usd) > 50000
ORDER BY 4 DESC;

-- For 2021
SELECT company_size, 
	company_location,
	COUNT(*) AS Number_of_Jobs,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2021
GROUP BY company_size, 
	company_location
-- HAVING AVG(salary_in_usd) > 50000
ORDER BY 4 DESC;

-- For 2022
SELECT company_size, 
	company_location,
	COUNT(*) AS Number_of_Jobs,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2022
GROUP BY company_size, 
	company_location
-- HAVING AVG(salary_in_usd) > 50000
ORDER BY 4 DESC;


-- Average salaries per country per remote ratio

-- For 2020
SELECT company_location,
	remote_ratio,
	COUNT(*) AS Number_of_Jobs,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2020
GROUP BY company_location,
	remote_ratio
-- HAVING AVG(salary_in_usd) > 50000
ORDER BY 4 DESC;

-- For 2021
SELECT company_location,
	remote_ratio,
	COUNT(*) AS Number_of_Jobs,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2021
GROUP BY company_location,
	remote_ratio
-- HAVING AVG(salary_in_usd) > 50000
ORDER BY 4 DESC;

-- For 2022
SELECT company_location,
	remote_ratio,
	COUNT(*) AS Number_of_Jobs,
    AVG(salary_in_usd) AS average_salary
FROM ds_salaries_2022
GROUP BY company_location,
	remote_ratio
-- HAVING AVG(salary_in_usd) > 50000
ORDER BY 4 DESC;  


-- Creating a stored Procedure to show top rated Job per country per year
DROP PROCEDURE IF EXISTS job_per_country_per_year;
DELIMITER //
CREATE PROCEDURE job_per_country_per_year(IN country CHAR(2), IN years INT)
BEGIN
	SELECT job_title,
		employment_type,
        experience_level,
        remote_ratio,
        company_size,
        salary_in_usd
	FROM ds_salaries
    WHERE company_location = country
		AND work_year = years
	ORDER BY salary_in_usd DESC;
END //
DELIMITER ;

-- To test the procedure
CALL job_per_country_per_year('FR', 2021)