-- neighborhood group with the highest average price for private rooms

SELECT 
    a.neighbourhood_group,
    a.room_type,
    AVG(a.price) AS avg_price
FROM 
    singapore_airbnb_dataset AS a
JOIN (
    SELECT 
        neighbourhood_group,
        room_type,
        AVG(price) AS avg_price
    FROM 
        singapore_airbnb_dataset
    WHERE
        price > 0  -- Exclude rows with zero price
    GROUP BY 
        neighbourhood_group,
        room_type
) AS subquery
ON 
    a.neighbourhood_group = subquery.neighbourhood_group
    AND a.room_type = subquery.room_type
GROUP BY 
    a.neighbourhood_group,
    a.room_type;

-- average price difference between private rooms and entire homes/apartments in each neighborhood

SELECT 
       neighbourhood, 
                   AVG(CASE WHEN room_type = 'Private room' THEN price ELSE 0 END) AS avg_private_room_price,
                   AVG(CASE WHEN room_type = 'Entire home/apt' THEN price ELSE 0 END) AS avg_entire_home_price,
                   AVG(CASE WHEN room_type = 'Entire home/apt' THEN price ELSE 0 END) - AVG(CASE WHEN room_type = 'Private room' THEN price ELSE 0 END) AS price_difference
FROM singapore_airbnb_dataset
GROUP BY neighbourhood;


--  the top 5 hosts with the most listings in each neighborhood group

WITH ranked_hosts AS (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY neighbourhood_group 
           ORDER BY calculated_host_listings_count DESC) AS row_num
    FROM singapore_airbnb_dataset
)
SELECT *
FROM ranked_hosts
WHERE row_num <= 5;


-- hosts that have all their listings with availability more than 180 days

SELECT id
FROM (
    SELECT id, 
           COUNT(*) AS total_listings,
           SUM(CASE WHEN availability_365 > 180 THEN 1 ELSE 0 END) AS long_term_avail_listings
    FROM singapore_airbnb_dataset
    GROUP BY id
) AS availability_counts
WHERE total_listings = long_term_avail_listings;


-- the average price for each room type in each neighborhood group

SELECT neighbourhood_group,
       room_type,
       AVG(price) AS aveg_price
FROM singapore_airbnb_dataset
GROUP BY neighbourhood_group, room_type;       


-- hosts in three categories based on the number of listings they have: 'Small' if less than 5, 'Medium' if between 5 and 20, and 'Large' if more than 20. we then, count the number of hosts in each category.

SELECT 
	CASE 
        WHEN calculated_host_listings_count < 5 THEN 'Small'
		WHEN calculated_host_listings_count BETWEEN 5 AND 20 THEN 'Medium'
        ELSE 'Large'
    END AS host_category,
    COUNT(*) AS num_hosts
FROM singapore_airbnb_dataset
GROUP BY host_category;    


-- percentage of reviews each listing receives compared to the total reviews in its neighborhood group

SELECT id,
       number_of_reviews,
       100 * number_of_reviews / SUM(number_of_reviews) OVER(PARTITION BY neighbourhood_group) AS review_percentage
FROM singapore_airbnb_dataset;       






    
        






