# SQLcasestudy

 <br />On the given dataset, the constraints are:
 <br />Constraint 1: Spark Funds wants to invest between 5 to 15 million USD per round of investment
 <br />Constraint 2: Invest only in English-speaking countries if English is one of the official languages. 
 <br />From the country list, filter includes ( 'IND', 'USA', 'CAN', 'GBR','NZL', 'AUS' )

 <br />Task 1:
 <br /> <br />•	Given the constraints, which funding type is the most suitable?
 <br />o	‘post_ipo_equity’
 <br /> <br />•	In the chosen funding type, which countries have witnessed the most funding?
 <br />o	Top 2 countries are ‘USA’ and ‘CAN’
 <br /> <br />•	In the chosen funding type and top countries, which sectors have performed the best? 
 <br />o	Sectors performing the best are ‘Others’ and 'Social, Finance, Analytics, Advertising'


 <br />Task 2:

 <br />o	Indexing was performed for performance tuning. 
 <br />o	Index ‘index_companies’ created on table ‘companies’ on column ‘country_code’
 <br />o	Index ‘index_investment’ created on table ‘investment’ on column ‘funding_round_type’
 <br />o	Since the columns ‘country_code’ in companies and ‘funding_round_type’ in investment are used for constraints, joins, sub queries, filters, and group by in tasks 1, creating an index on the respective columns help retrieve data faster. This can be seen in the execution plan Query Cost before and after indexing.
 <br />Query cost before index	
 <br />Task 1a	84,005,361.24	
 <br />Task 1b	8,418,921.6	
 <br />Task 1c	10,323,784,047.5	

 <br />Query cost after index
 <br />Task 1a	93,842,568.16
 <br />Task 1b	533,499.19
 <br />Task 1c 52,960,814,289.06

 <br />Since the indexing helped task 1b but increased query cost of task 1a and 1c, the ‘index_companies’ created on table ‘companies’ on column ‘country_code’ was removed to bring back the pre index performance. But the ‘index_investment’ was kept to help task 1b. 



 <br />Task 3:
 <br />Also capture the execution plan is part of the repository

