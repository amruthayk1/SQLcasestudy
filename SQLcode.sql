USE casestudy;

-- Creation of Investment table
CREATE TABLE investment (
company_permalink varchar(250),
funding_round_permalink varchar(250),
funding_round_type varchar(50),
funding_round_code	varchar(50),
funded_at varchar(50),
raised_amount_usd bigint
);

-- Creation of companies table
CREATE TABLE companies (
permalink varchar(1000),
name varchar(1000),
homepage_url varchar(1000),
category_list varchar(1000),
status varchar(1000),
country_code varchar(100),
state_code varchar(100),
region varchar(100),
city varchar(100),
founded_at varchar(100)
);

-- Creation of mapping table
CREATE TABLE mappings (
category_list	varchar(50),
AutomotiveSports int,	
Blanks int,
CleantechSemiconductors	int,
Entertainment int,
Health int,
Manufacturing int,
NewsSearchMessaging	int,
others	int,
SocialFinanceAnalyticsAdvertising int
);

-- Importing data to the companies table from companies.txt from path

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.txt' 
INTO TABLE companies 
CHARACTER SET latin1
FIELDS TERMINATED BY '\t' ENCLOSED BY '"'  IGNORE 1 LINES 
(
permalink,
name,
homepage_url,
category_list,
status,
country_code,
state_code,
region,
city,
founded_at
);

-- Importing data to the investment table from investmentdatanew.txt 
-- from path after converting CSV file to txt

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/InvestmentDatanew.txt' 
INTO TABLE investment
CHARACTER SET latin1
FIELDS TERMINATED BY ',' ENCLOSED BY '"'  IGNORE 1 LINES 
(
company_permalink,
funding_round_permalink,
funding_round_type,
funding_round_code,
funded_at,
raised_amount_usd
);

-- Mappings table loaded directly from MySQL Workbench
-- Data cleaned to replace 0 with na

UPDATE mappings
SET category_list = REPLACE(category_list,'0','na');

/**
 * @desc View investment_with_constraints created with Constraints 1 and 2. 
 * Join performed with investment and companies tables on company_permalink and permalink columns
 * Constraint 1: Spark Funds wants to invest between 5 to 15 million USD per round of investment
 * Constraint 2: Invest only in English-speaking countries if English is one of the official languages. 
 * From the country list, filter includes ( 'IND', 'USA', 'CAN', 'GBR','NZL', 'AUS' )
 */
 
CREATE OR replace VIEW investment_with_constraints
AS
  SELECT i.*,
         c.country_code,
         c.category_list
  FROM   investment i
         join companies c
           ON Lower(i.company_permalink) = Lower(c.permalink)
  WHERE  i.raised_amount_usd > 5000000
         AND i.raised_amount_usd < 15000000
         AND country_code IN ( 'IND', 'USA', 'CAN', 'GBR',
                               'NZL', 'AUS' ); 

/**
 * @desc Applying the constraints, the most suitable funding is queried by Avg() function on USD raised
 * on the investment_with_constraints view, grouped by funding type 
 * @returns Most suitable funding = 'post_ipo_equity'
 */

SELECT funding_round_type,
       Avg(raised_amount_usd) avg_funding
FROM   investment_with_constraints
GROUP  BY funding_round_type
ORDER  BY avg_funding DESC; 
 
 /**
 * @desc Top countries to witness the most funding is queried by Sum() function on USD raised 
 * and performed on investment_with_constraints with best funding type 'post_ipo_equity'
 * as a filter and grouped by country code
 * @returns Top 2 countries are USA and CAN
 */

SELECT Sum(raised_amount_usd) total_raised,
       country_code
FROM   investment_with_constraints
WHERE  funding_round_type = 'post_ipo_equity'
GROUP  BY country_code
ORDER  BY total_raised DESC; 
 
 /**
 * @desc This query finds the sectors that have performed the best in the chosen funding type and top countries
 * Subquery: turns the mappings table columns into respective sectors for categoried using UNION ALL
 * Main query takes subquery to look up categories in mapping with categories occuring in the view to obtain
 * USD raised based on each sector, filtered by funding type =  'post_ipo_equity' & countries 'USA' 'CAN'
 * @returns Sectors performing the best are Others and 'Social, Finance, Analytics, Advertising'
 */
 
SELECT Sum(raised_amount_usd) AS amount_raised,
       sector
FROM   (SELECT category_list,
               'Automotive_Sports' AS sector
        FROM   mappings
        WHERE  automotivesports = 1
        UNION ALL
        SELECT category_list,
               'Blanks' AS sector
        FROM   mappings
        WHERE  blanks = 1
        UNION ALL
        SELECT category_list,
               'CleantechSemiconductors' AS sector
        FROM   mappings
        WHERE  cleantechsemiconductors = 1
        UNION ALL
        SELECT category_list,
               'Entertainment' AS sector
        FROM   mappings
        WHERE  entertainment = 1
        UNION ALL
        SELECT category_list,
               'Health' AS sector
        FROM   mappings
        WHERE  health = 1
        UNION ALL
        SELECT category_list,
               'NewsSearchMessaging' AS sector
        FROM   mappings
        WHERE  newssearchmessaging = 1
        UNION ALL
        SELECT category_list,
               'Manufacturing' AS sector
        FROM   mappings
        WHERE  manufacturing = 1
        UNION ALL
        SELECT category_list,
               'others' AS sector
        FROM   mappings
        WHERE  others = 1
        UNION ALL
        SELECT category_list,
               'SocialFinanceAnalyticsAdvertising' AS sector
        FROM   mappings
        WHERE  socialfinanceanalyticsadvertising = 1) AS b,
       investment_with_constraints iwc
WHERE  b.category_list IS NOT NULL
       AND Concat('%|', iwc.category_list, '|%') LIKE
           Concat('%|', b.category_list, '|%')
       AND iwc.funding_round_type = 'post_ipo_equity'
       AND iwc.country_code = 'USA'
        OR iwc.country_code = 'CAN'
GROUP  BY b.sector
ORDER  BY amount_raised DESC; 

CREATE INDEX index_investment ON investment (funding_round_type);
CREATE INDEX index_companies ON companies (category_list(200));
DROP INDEX index_companies ON companies;