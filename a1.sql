--
--  a1.sql
--  Assignment 1
--
--	COMP3311: Database Systems
--
--  Created by IYER, Neel Ram on 20/03/19.
--  zID: z5165452
--


-- Q1. List all the company names (and countries) that are incorporated outside Australia.

create or replace view Q1(Name, Country) as
  
	select name, country
	from company
	where country!='Australia';

;

-- Q2. List all the company codes that have more than five executive members on record (i.e., at least six).

create or replace view Q2(Code) as 

	select code as Code
	from executive
	group by code
	having count(person)>5
	order by code;

;


-- Q3. List all the company names that are in the sector of "Technology"
create or replace view Q3(Name) as 

	select company.name as Name
	from category
	join company on category.code = company.code
	where sector = 'Technology';

;



-- Q4 .Find the number of Industries in each Sector
    
create or replace view Q4(Sector, Number) as 

	select sector as Sector, count(industry) as Number
	from category
	group by sector;

;

-- Q5. Find all the executives (i.e., their names) that are affiliated with companies in the sector of "Technology". If an executive is affiliated with more than one company, he/she is counted if one of these companies is in the sector of "Technology".
create or replace view Q5(Name) as

	select distinct executive.person as Name
	from executive
	join category on executive.code = category.code
	where category.sector = 'Technology';

;


-- Q6. List all the company names in the sector of "Services" that are located in Australia with the first digit of their zip code being 2.
create or replace view Q6(Name) as

	select company.name as Name
	from category
	join company on category.code = company.code
	where substring(company.zip,1,1) = '2' and category.sector = 'Services';

;


-- Q7. Create a database view of the ASX table that contains previous Price, Price change (in amount, can be negative) and Price gain (in percentage, can be negative). (Note that the first trading day should be excluded in your result.) For example, if the PrevPrice is 1.00, Price is 0.85; then Change is -0.15 and Gain is -15.00 (in percentage but you do not need to print out the percentage sign).
create or replace view Q7("Date", Code, Volume, PrevPrice, Price, Change, Gain) as 

	select curr."Date", curr.code, curr.volume, prev.price as prevprice, curr.price as price, (curr.price - prev.price) as change, ((curr.price - prev.price)/prev.price) * 100 as gain

	from asx as curr

	join asx as prev

	on curr.code = prev.code

	join 

		(select "Date" as current_date, lag("Date", 1) over (order by "Date") as previous_date
			from 

				(select distinct asx."Date"

				from asx) as all_dates) as distinct_dates

	on distinct_dates.previous_date = prev."Date" and distinct_dates.current_date = curr."Date"

	order by curr.code, curr."Date";

;



-- Q8. Find the most active trading stock (the one with the maximum trading volume; if more than one, output all of them) on every trading day. Order your output by "Date" and then by Code.
create or replace view Q8("Date", Code, Volume) as

	select max_volume."Date", asx.code, max_volume.volume

	from 

		(select "Date", max(volume) as volume from asx group by "Date" order by 		"Date") as max_volume

		join asx on asx.volume = max_volume.volume;

;


-- Q9. Find the number of companies per Industry. Order your result by Sector and then by Industry.
create or replace view Q9(Sector, Industry, Number) as

	select sector_name.sector as sector, industry_count.industry as industry, industry_count.count as number

	from

		(select industry, count(industry)
		from category
		group by industry
		order by industry) as industry_count

		join

		(select distinct industry, sector from category) as sector_name

		on industry_count.industry = sector_name.industry

	order by sector_name.sector, industry_count.industry;

;


-- Q10. List all the companies (by their Code) that are the only one in their Industry (i.e., no competitors).
create or replace view Q10(Code, Industry) as

	select category.code, category.industry 

	from category

	join

		(select industry, count(code)
		from category
		group by industry
		having count(code)=1) as no_comp

	on category.industry = no_comp.industry;

;

-- Q11. List all sectors ranked by their average ratings in descending order. AvgRating is calculated by finding the average AvgCompanyRating for each sector (where AvgCompanyRating is the average rating of a company).
create or replace view Q11(Sector, AvgRating) as


	select company_ratings.sector as Sector, avg(company_ratings.star) as AvgRating

	from 

		(select rating.star, category.sector

		from rating

		join category on rating.code = category.code) as company_ratings

	group by company_ratings.sector;

;


-- Q12. Output the person names of the executives that are affiliated with more than one company.
create or replace view Q12(Name) as

	select person as name

	from executive

	group by person

	having count(code)>1;

;


-- Q13. Find all the companies with a registered address in Australia, in a Sector where there are no overseas companies in the same Sector. i.e., they are in a Sector that all companies there have local Australia address.
create or replace view Q13(Code, Name, Address, Zip, Sector) as


	select category.code, company.name, company.address, company.zip, category.sector

	from category

	join

		((select distinct category.sector

		from category)

	except

		(select distinct category.sector

		from company

		join category

		on category.code = company.code

		where company.country!='Australia'

		order by category.sector)) as inclusions

	on inclusions.sector = category.sector

	join company on company.code = category.code;


--checking
/*
select company.code, company.name, category.sector, company.country
from category
join company
on company.code = category.code
*/
;


-- Q14. Calculate stock gains based on their prices of the first trading day and last trading day (i.e., the oldest "Date" and the most recent "Date" of the records stored in the ASX table). Order your result by Gain in descending order and then by Code in ascending order.
create or replace view Q14(Code, BeginPrice, EndPrice, Change, Gain) as


	select 	begin_price.code, begin_price.beginprice, end_price.endprice,

	(end_price.endprice - begin_price.beginprice) as change, 

	((end_price.endprice - begin_price.beginprice)/begin_price.beginprice)*100 as 		gain
	
	from 

		(select asx.code, asx.price as beginprice

		from asx
	
		join

			(select min("Date"), code
	
			from asx

			group by code) as min_date

		on min_date.min = asx."Date" and min_date.code = asx.code

		order by asx.code) as begin_price

	join

		(select asx.code, asx.price as endprice

		from asx
	
		join

			(select max("Date"), code
	
			from asx

			group by code) as max_date

		on max_date.max = asx."Date" and max_date.code = asx.code

		order by asx.code) as end_price

	on begin_price.code = end_price.code

	order by gain desc, begin_price.code;
	
;


-- Q15. For all the trading records in the ASX table, produce the following statistics as a database view (where Gain is measured in percentage). AvgDayGain is defined as the summation of all the daily gains (in percentage) then divided by the number of trading days (as noted above, the total number of days here should exclude the first trading day).
create or replace view Q15(Code, MinPrice, AvgPrice, MaxPrice, MinDayGain, AvgDayGain, MaxDayGain) as

	select total_duration.code, total_duration.minprice, total_duration.avgprice, total_duration.maxprice, intraday.min as mindaygain, intraday.avg as avgdaygain, intraday.max as maxdaygain

	from

		(select asx.code, min(asx.price) as minprice, avg(asx.price) as avgprice, max(asx.price) as maxprice

		from asx

		group by asx.code) as total_duration


	join 

		(select daily_gains.code, min(daily_gains.gain), max(daily_gains.gain), 		avg(daily_gains.gain)

		from
	
			(select ((curr.price - prev.price)/prev.price)*100 as gain, curr.code, curr."Date" as current, prev."Date" as previous

			from asx as curr

			join asx as prev on prev.code = curr.code

			join 

				(select "Date" as current_date, lag("Date", 1) over (order by "Date") as previous_date

				from 
					(select distinct asx."Date"

					from asx) as all_dates) as distinct_dates 

			on distinct_dates.previous_date = prev."Date" and 		 distinct_dates.current_date = curr."Date") as daily_gains

		group by daily_gains.code) as intraday

	on total_duration.code = intraday.code

;

-- Q16. Create a trigger on the Executive table, to check and disallow any insert or update of a Person in the Executive table to be an executive of more than one company. 

	--create function
	create or replace function check_executive() returns trigger as $$

	begin

			if((select count(code) from executive where person = new.person)>1)
			then
				raise exception 'Invalid:  % already an executive for a company',new.person;
			end if;

	return new;

	end;

	$$ language plpgsql;


	--create trigger
	create trigger Q16 

	after insert or update

	on executive for each row 

	execute procedure check_executive();
	

-- Q17. Suppose more stock trading data are incoming into the ASX table. Create a trigger to increase the stock's rating (as Star's) to 5 when the stock has made a maximum daily price gain (when compared with the price on the previous trading day) in percentage within its sector. For example, for a given day and a given sector, if Stock A has the maximum price gain in the sector, its rating should then be updated to 5. If it happens to have more than one stock with the same maximum price gain, update all these stocks' ratings to 5. Otherwise, decrease the stock's rating to 1 when the stock has performed the worst in the sector in terms of daily percentage price gain. If there are more than one record of rating for a given stock that need to be updated, update (not insert) all these records. You may assume that there are at least two trading records for each stock in the existing ASX table, and do not worry about the case that when the ASX table is initially empty. 

--update rating = 5 if max daily gain in sector
--update rating = 1 if min daily gain in sector

	--create view
	create or replace view gains_by_sector as
		select "Date", Q7.code, category.sector as sector, Q7.gain
		from Q7
		join category
		on Q7.code = category.code
	;

	--create function
	create or replace function check_daily_gain() returns trigger as $$

	declare

		max_gain float;
		min_gain float;
		new_gain float;
		sector varchar;

	begin

		--calculate daily gain for stock inserted/updated
		new_gain := gain 

					from gains_by_sector 

					where gains_by_sector.code = new.code and "Date" = new."Date";

		--calculate max gain for sector
		max_gain := max(gain) 

					from gains_by_sector 

					where gains_by_sector.sector = 

						(select distinct gains_by_sector.sector
 
						from gains_by_sector 

						where gains_by_sector.code = new.code);

		--calculate min gain for sector
		min_gain := min(gain) 

					from gains_by_sector

					where gains_by_sector.sector = 

						(select distinct gains_by_sector.sector 

						from gains_by_sector 

						where gains_by_sector.code = new.code);

		--if daily gain is greater than max gain->rating is 5
		if (new_gain > max_gain) then 

			update rating set star = 5

			where code = new.code;

		end if;

		--if daily gain is less than min gain->rating is 1
		if (new_gain < min_gain) then 

			update rating set star = 1

			where code = new.code;

		end if;

		--if daily gain is equal to max gain
		if(new_gain  = max_gain) then
 
			update rating set star = 5

			where 
			
				code = (select distinct code 

					from gains_by_sector 

					where gain = (select distinct gain from gains_by_sector where gains_by_sector."Date" = new."Date" and code = new.code)) 

				and 

				sector = (select distinct gains_by_sector.sector 

					from gains_by_sector 

					where gains_by_sector.code = new.code);

		end if;	

		--if daily gain is equal to min gain
		if(new_gain  = min_gain) then
 
			update rating set star = 1

			where 
			
				code = (select distinct code 

					from gains_by_sector 

					where gain = (select distinct gain from gains_by_sector where gains_by_sector."Date" = new."Date" and code = new.code)) 

				and 

				sector = (select distinct gains_by_sector.sector 

					from gains_by_sector 

					where gains_by_sector.code = new.code);

		end if;	

	return new;
	end;
	$$ language plpgsql;


	--create trigger

	create trigger Q17

	after update or insert 

	on asx for each row

	execute procedure check_daily_gain();



-- Q18. Stock price and trading volume data are usually incoming data and seldom involve updating existing data. However, updates are allowed in order to correct data errors. All such updates (instead of data insertion) are logged and stored in the ASXLog table. Create a trigger to log any updates on Price and/or Voume in the ASX table and log these updates (only for update, not inserts) into the ASXLog table. Here we assume that Date and Code cannot be corrected and will be the same as their original, old values. Timestamp is the date and time that the correction takes place. Note that it is also possible that a record is corrected more than once, i.e., same Date and Code but different Timestamp.

	--function
	create or replace function insert_asxlog() returns trigger as $$

	begin

		insert into asxlog values(now(), old."Date", old.code, old.volume, old.price);

	return new;

	end;

	$$ language plpgsql;


	--trigger

	create trigger Q18

	after update on asx
	
	for each row
	
	execute procedure insert_asxlog();

