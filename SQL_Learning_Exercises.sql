/*The database scheme consists of four tables:
Product(maker, model, type)
PC(code, model, speed, ram, hd, cd, price)
Laptop(code, model, speed, ram, hd, screen, price)
Printer(code, model, color, type, price)
The Product table contains data on the maker, model number, and type of product ('PC', 'Laptop', or 'Printer'). 
It is assumed that model numbers in the Product table are unique for all makers and product types. Each personal computer in the PC table is unambiguously identified by a unique code, and is additionally characterized by its model (foreign key referring to the Product table), processor speed (in MHz) – speed field, RAM capacity (in Mb) - ram, hard disk drive capacity (in Gb) – hd, CD-ROM speed (e.g, '4x') - cd, and its price. The Laptop table is similar to the PC table, except that instead of the CD-ROM speed, it contains the screen size (in inches) – screen. For each printer model in the Printer table, its output type (‘y’ for color and ‘n’ for monochrome) – color field, printing technology ('Laser', 'Jet', or 'Matrix') – type, and price are specified.
*/

-- 1. Find the model number, speed and hard drive capacity for all the PCs with prices below $500. Result set: model, speed, hd.
SELECT model,speed,hd
FROM PC
WHERE price<500;

-- 2. List all printer makers. Result set: maker.
SELECT distinct maker
FROM PRODUCT
WHERE type='PRINTER';

-- 3.Find the model number, RAM and screen size of the laptops with prices over $1000.
SELECT model,ram,screen
FROM laptop
WHERE price >1000;

-- 4. Find all records from the Printer table containing data about color printers.
SELECT * FROM PRINTER WHERE color='y';

-- 5. Find the model number, speed and hard drive capacity of PCs cheaper than $600 having a 12x or a 24x CD drive.
SELECT model,speed,hd
FROM PC
WHERE cd in ('12x','24x');

-- 6. For each maker producing laptops with a hard drive capacity of 10 Gb or higher, find the speed of such laptops. Result set: maker, speed.
SELECT distinct p.maker, l.speed
from Product p, Laptop l
where l.hd >=10 and p.model = l.model;

-- 7. Get the models and prices for all commercially available products (of any type) produced by maker B.
Select p.model,pc.price
from product p,pc
where p.model = pc.model
and p.maker='B'

UNION

Select p.model,l.price
from product p,laptop l
where p.model = l.model 
and p.maker='B'

UNION

Select p.model,pr.price
from product p,printer pr
where p.model = pr.model 
and p.maker='B'
and price <600;


-- 8. Find the makers producing PCs but not laptops.
SELECT maker 
FROM Product
WHERE TYPE IN ('PC')
EXCEPT
SELECT maker 
FROM Product 
WHERE TYPE IN ('Laptop');


SELECT DISTINCT maker
FROM Product
WHERE TYPE = 'PC'
AND maker NOT IN (
	SELECT DISTINCT maker
	FROM Product
	WHERE TYPE = 'Laptop'
);

-- 9. Find the makers of PCs with a processor speed of 450 MHz or more. Result set: maker.
Select distinct p.maker
from product p,PC
where p.model=pc.model and speed >=450;

-- 10. Find the printer models having the highest price. Result set: model, price.
SELECT model, price 
FROM Printer pr, (SELECT MAX(price) AS maxprice  
                  FROM Printer
                  ) AS mp 
WHERE price = mp.maxprice;

-- 11. Find out the average speed of PCs.
Select AVG(speed)
from pc;

-- 12. Find out the average speed of the laptops priced over $1000.
Select AVG(speed)
from laptop
where price >1000

-- 13.Find out the average speed of the PCs produced by maker A.
Select AVG(pc.speed)
from pc,product p
where p.model=pc.model and p.maker='A';

-- 14. For the ships in the Ships table that have at least 10 guns, get the class, name, and country.
SELECT s.class,s.name,c.country 
FROM CLASSES C, Ships s
where c.class=s.class and c.numGuns >=10;

-- 15.Get hard drive capacities that are identical for two or more PCs. Result set: hd.
SELECT distinct hd
from PC
Group by hd
having count(hd)>=2;

-- 16. Get pairs of PC models with identical speeds and the same RAM capacity. Each resulting pair should be displayed only once, i.e. (i, j) but not (j, i). Result set: model with the bigger number, model with the smaller number, speed, and RAM.
SELECT DISTINCT pc1.model, pc2.model, pc1.speed, pc1.ram
FROM PC pc1 JOIN PC pc2
ON pc1.speed = pc2.speed 
AND pc1.ram = pc2.ram
WHERE pc1.model > pc2.model;

-- 17. Get the laptop models that have a speed smaller than the speed of any PC. Result set: type, model, speed.
SELECT DISTINCT type, Laptop.model, speed
FROM Laptop, Product
WHERE Product.model = Laptop.model AND
      Laptop.speed < (SELECT MIN(speed) FROM PC);
      
-- 18. Find the makers of the cheapest color printers. Result set: maker, price.
select p.maker,MIN(price)
from product p, printer pr
where p.model = pr.model and price =(select MIN(pr.price)
from printer pr
where pr.color='y') and pr.color='y'
group by p.maker;

-- 19.For each maker having models in the Laptop table, find out the average screen size of the laptops he produces. Result set: maker, average screen size.
select p.maker,AVG(screen)
from product p,Laptop l
where p.model = l.model 
group by p.maker;

-- 20. Find the makers producing at least three distinct models of PCs. Result set: maker, number of PC models.
SELECT maker, COUNT(model)
FROM Product
WHERE TYPE = 'PC'
GROUP BY maker
HAVING COUNT(model) >= 3;

-- 21.Find out the maximum PC price for each maker having models in the PC table. Result set: maker, maximum price.
Select p.maker, MAX(pc.price) 
from product p, Pc
where p.model = pc.model
group by p.maker;

-- 22. For each value of PC speed that exceeds 600 MHz, find out the average price of PCs with identical speeds. Result set: speed, average price.
Select speed, AVG(price)
from pc
where speed >600
group by speed;

-- 23. Get the makers producing both PCs having a speed of 750 MHz or higher and laptops with a speed of 750 MHz or higher. Result set: maker
SELECT DISTINCT maker
FROM Product
WHERE maker IN (
SELECT distinct p.maker
from Product p,PC 
where p.model = pc.model and pc.speed>=750)
and maker IN(

SELECT distinct p.maker
from Product p, Laptop l
where p.model =l.model and l.speed>=750
);

-- 24. List the models of any type having the highest price of all products present in the database.
WITH MAX
AS (
	SELECT model, price FROM PC
	UNION 
	SELECT model, price FROM Laptop
	UNION 
	SELECT model, price FROM printer
)

SELECT model FROM MAX
WHERE price = (
	SELECT MAX(price) 
	FROM MAX
)


-- 25.  Find the printer makers also producing PCs with the lowest RAM capacity and the highest processor speed of all PCs having the lowest RAM capacity. Result set: maker.
SELECT DISTINCT maker
FROM Product JOIN PC
ON Product.model = PC.model
WHERE ram = (
	SELECT MIN(ram)
	FROM PC
)
AND speed = (
	SELECT MAX(speed)
	FROM PC
	WHERE ram = (
		SELECT MIN(ram)
		FROM PC)
	)
AND maker IN (
	SELECT maker
	FROM Product
	WHERE TYPE='Printer'
);

-- 26. Find out the average price of PCs and laptops produced by maker A. Result set: one overall average price for all items.

SELECT AVG(price)
FROM (
	SELECT price
	FROM Product JOIN PC
	ON Product.model = PC.model
	WHERE maker = 'A'
	UNION ALL
	SELECT price
	FROM Product JOIN Laptop
	ON Product.model = Laptop.model
	WHERE maker='A'
) AS AVG_price;

-- 27. Find out the average hard disk drive capacity of PCs produced by makers who also manufacture printers. Result set: maker, average HDD capacity.
Select p.maker,AVG(hd)
from pc, product p
where p.model=pc.model and p.maker in (SELECT DISTINCT maker
	FROM Product
	WHERE TYPE='Printer')
group by p.maker;

-- 28. Using Product table, find out the number of makers who produce only one model.
WITH total_count
AS (
	SELECT maker
	FROM product 
	GROUP BY maker 
	HAVING COUNT(model) = 1
)

SELECT COUNT(maker)
FROM total_count;

-- 29. Under the assumption that receipts of money (inc) and payouts (out) are registered not more than once a day for each collection point [i.e. the primary key consists of (point, date)], write a query displaying cash flow data (point, date, income, expense). Use Income_o and Outcome_o tables.
SELECT i.point, i.date, i.inc, o.out
FROM Income_o i LEFT JOIN Outcome_o o
ON i.point = o.point
AND i.date = o.date

UNION
SELECT o.point, o.date, i.inc, o.out
FROM Outcome_o o LEFT JOIN Income_o i
ON o.point = i.point
AND o.date = i.date ;

-- 30. Under the assumption that receipts of money (inc) and payouts (out) can be registered any number of times a day for each collection point [i.e. the code column is the primary key], display a table with one corresponding row for each operating date of each collection point. Result set: point, date, total payout per day (out), total money intake per day (inc). Missing values are considered to be NULL.
SELECT i.point, i.date, o.out, i.inc
FROM (
	SELECT point, date, sum(inc) AS inc
	FROM Income
	GROUP BY point, date
) AS i
LEFT JOIN (
	SELECT point, date, sum(out) AS out
	FROM Outcome
	GROUP BY point, date
) AS o
ON i.point = o.point
AND i.date = o.date

UNION
SELECT o.point, o.date, o.out, i.inc
FROM (
	SELECT point, date, sum(out) AS out
	FROM Outcome
	GROUP BY point, date
) AS o
LEFT JOIN (
	SELECT point, date, sum(inc) AS inc
	FROM Income
	GROUP BY point, date
) AS i
ON o.point = i.point
AND o.date = i.date ;

-- 31. For ship classes with a gun caliber of 16 in. or more, display the class and the country.
SELECT class, country
FROM Classes
WHERE bore >= 16.0


-- 32. One of the characteristics of a ship is one-half the cube of the calibre of its main guns (mw). Determine the average ship mw with an accuracy of two decimal places for each country having ships in the database.

WITH result
AS (
	SELECT country, bore, name
	FROM Classes, Ships
	where Classes.class = Ships.class
	
	UNION
	SELECT country, bore, ship
	FROM Classes ,Outcomes
	where Classes.class = Outcomes.ship
)

SELECT country, cast(round(AVG(power(bore,3)*0.5),2) AS numeric(10,2)) AS weight 
FROM result
GROUP BY country;

-- 33. Get the ships sunk in the North Atlantic battle. Result set: ship.
Select ship
from outcomes
where battle = 'North Atlantic' and result='sunk'


-- 34. In accordance with the Washington Naval Treaty concluded in the beginning of 1922, it was prohibited to build battle ships with a displacement of more than 35 thousand tons. Get the ships violating this treaty (only consider ships for which the year of launch is known). List the names of the ships.
select  distinct s.name
from classes c, Ships s 
where c.class = s.class and c.displacement >35000 and s.launched >=1922 and
 c.TYPE = 'bb';
 
 -- 35. Find models in the Product table consisting either of digits only or Latin letters (A-Z, case insensitive) only. Result set: model, type.
SELECT model, TYPE
FROM Product
WHERE model NOT LIKE '%[^0-9]%' OR model NOT LIKE '%[^a-z]%'
OR model NOT LIKE '%[^A-Z]%'; 

-- 36. List the names of lead ships in the database (including the Outcomes table).
Select s.name 
from ships s, classes c
where s.name=c.class
union
Select b.name 
from Battles b, classes c
where b.name=c.class
union
Select o.ship 
from outcomes o, classes c
where o.ship=c.class;

-- 37. Find classes for which only one ship exists in the database (including the Outcomes table).
WITH total_ship
AS (Select c.class, s.name
from classes c, ships s
where c.class = s.class
union

Select c.class, o.ship as name
from outcomes o, classes c
where o.ship = c.class
)
SELECT class 
FROM total_ship 
GROUP BY class 
HAVING COUNT(class) = 1;

-- 38. Find countries that ever had classes of both battleships (‘bb’) and cruisers (‘bc’).
Select DISTINCT country
from classes
where type='bb' and country in
(Select DISTINCT country
from classes
where type='bc');

-- 39. Find the ships that `survived for future battles`; that is, after being damaged in a battle, they participated in another one, which occurred later.
SELECT DISTINCT o2.ship 
FROM (
	SELECT ship, battle, result, date
	FROM Outcomes,Battles
	where Outcomes.battle = Battles.name
	and result='damaged'
) AS o1 
JOIN (
	SELECT ship, battle, result, date
	FROM Outcomes, Battles
	where Outcomes.battle = Battles.name
) AS o2
ON o1.ship = o2.ship
WHERE o1.date < o2.date;

-- 40. Get the makers who produce only one product type and more than one model. Output: maker, type.
Select distinct maker,MAX(type) as type
from product 
group by maker
having count(DISTINCT type) = 1
and count(model)> 1;

-- 41.For each maker who has models at least in one of the tables PC, Laptop, or Printer, determine the maximum price for his products. Output: maker; if there are NULL values among the prices for the products of a given maker, display NULL for this maker, otherwise, the maximum price.

SELECT maker,
  CASE 
    WHEN sum(CASE 
                WHEN price IS NULL THEN 1 
                ELSE 0 
             END) > 0 THEN NULL
    ELSE max(price) 
  END AS price
FROM(SELECT p.maker,pc.price
FROM product p, pc
WHERE p.model = pc.model
UNION ALL
SELECT p.maker,l.price
FROM product p, laptop l
WHERE p.model = l.model
UNION ALL
SELECT p.maker,pr.price
FROM product p, Printer pr
WHERE p.model = pr.model
) res

Group by maker;


-- 42. Find the names of ships sunk at battles, along with the names of the corresponding battles.
select ship,battle
 from outcomes
where result='sunk';

-- 43. Get the battles that occurred in years when no ships were launched into water.
SELECT name
FROM Battles
WHERE year(date)
NOT IN (
	SELECT launched
	FROM Ships
	WHERE launched IS NOT NULL
);

-- 44.Find all ship names beginning with the letter R.
SELECT name
FROM Ships
WHERE name LIKE 'R%'
UNION
SELECT ship
FROM Outcomes
WHERE ship LIKE 'R%';

-- 45. Find all ship names consisting of three or more words (e.g., King George V). Consider the words in ship names to be separated by single spaces, and the ship names to have no leading or trailing spaces.
SELECT name
FROM Ships
WHERE name LIKE '% % %'
UNION
SELECT ship
FROM Outcomes
WHERE ship LIKE '% % %';

-- 46. For each ship that participated in the Battle of Guadalcanal, get its name, displacement, and the number of guns.
SELECT DISTINCT ship, displacement, numguns
FROM Classes LEFT JOIN Ships
ON classes.class = ships.class
RIGHT JOIN Outcomes
ON Classes.class = ship
OR ships.name = ship
WHERE battle = 'Guadalcanal'


-- 47. Find the countries that have lost all their ships in battles.

WITH boat_count AS 
(SELECT country, COUNT(*) AS cnt
FROM 
(SELECT s.name AS name, 
c.country AS country
FROM classes c, ships s 
WHERE c.class = s.class
UNION
SELECT o.ship AS name, c.country
FROM classes c, outcomes o
WHERE o.ship = c.class
) res3
GROUP BY country)

SELECT res2.country
FROM
(SELECT country, COUNT(*) AS sunk_count
FROM 
(SELECT s.name, c.country
FROM classes c, ships s 
WHERE c.class = s.class
UNION 
SELECT o.ship, c.country
FROM classes c, Outcomes o
WHERE c.class= o.ship
) res1,outcomes o
WHERE o.ship = res1.name and result ='sunk'
GROUP BY country
) res2
,boat_count bct
WHERE bct.country = res2.country AND bct.cnt = res2.sunk_count

-- 48. Find the ship classes having at least one ship sunk in battles.

select c.class
from Outcomes o, classes c
where o.result='sunk' and c.class = o.ship
UNION

select distinct c.class
from Ships s, Classes c,Outcomes o
where o.result='sunk' and s.name = o.ship and c.class = s.class;

-- 49. Find the names of the ships having a gun caliber of 16 inches (including ships in the Outcomes table).
select s.name
from Ships s, classes c
where c.class = s.class and bore=16
UNION
select o.ship
from Outcomes o, Classes c
where c.class = o.ship and bore =16;

-- 50. Find the battles in which Kongo-class ships from the Ships table were engaged.
select distinct o.battle
from ships s,Outcomes o
where s.name= o.ship and s.class='Kongo';




