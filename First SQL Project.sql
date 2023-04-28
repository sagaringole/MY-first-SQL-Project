-- Database: Music_Database

-- DROP DATABASE IF EXISTS "Music_Database";

CREATE DATABASE "Music_Database"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_India.1252'
    LC_CTYPE = 'English_India.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
	
	Who is the senior most employee;
	
	select * from employee
	order by levels desc 
	limit 1;
	
	
	Q2: Countries have most invoices;
	
	select * from invoice;
	
	select COUNT(*) as c, billing_country
	from invoice
	group by billing_country
	order by c desc
	
	Q3: Total invoice
	
	select total from invoice
	order by total desc
	limit 3
	
	Q4:Best coustomer in the city name and total;
	
	Select sum(total) as invoice_total, billing_city
     from invoice
	group by billing_city
	order by invoice_total desc
	
	Q5: The customer who has send more money;
	
	select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice ON Customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1


 Q6: Return your list ordered alphabetically by email starting with A;
 
 SELECT DISTINCT email,first_name, last_name
   FROM customer
   JOIN invoice ON customer.customer_id = invoice.customer_id
   JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
    WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;
 
 Q7: Write a query that returns the Artist name and total track count of the top 10 rock bands.
 
 
 Select * from artist;
 
     SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
     FROM track
     JOIN album ON album.album_id = track.album_id
     JOIN artist ON artist.artist_id = album.artist_id
      JOIN genre ON genre.genre_id = track.genre_id
      WHERE genre.name LIKE 'Rock'
     GROUP BY artist.artist_id
      ORDER BY number_of_songs DESC
LIMIT 10;


Q8: Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

    SELECT name,milliseconds
    FROM track
     WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;      


Q9: find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist.

WITH best_selling_artist AS (
SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
FROM invoice_line
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

Q10 We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. 

   WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
  SELECT * FROM popular_genre WHERE RowNo <= 1
  
  
  Recursive Method to solve the problem
  
  
  WITH RECURSIVE
  sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;


Q11 - Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount.
   
   WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1



