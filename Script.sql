

-- DEMANDE DE LA DIRECTION

-- 1)liste des films
SELECT title
FROM film

--2) Nombre de films par catégorie

SELECT name,count(name) as nombre_de_films
FROM category
INNER JOIN film_category
ON category.category_id = film_category.category_id 
GROUP BY name

--3)Liste des films dont la durée est supérieure à 120 minutes
SELECT title, length
FROM film 
WHERE length >= 120

--4)Liste des films de catégorie "Action" ou "Comedy"

SELECT title,name 
FROM film 
INNER JOIN film_category 
ON film.film_id = film_category.film_id 
INNER JOIN category 
ON film_category.category_id = category.category_id 
WHERE name = "Action"
OR name ="Comedy"
ORDER BY name ASC;

--5)Nombre total de films (définissez l'alias 'nombre de film' pour la valeur calculée)

SELECT COUNT(title) AS "nombre de film"
FROM film f 

--6)Les notes moyennes par catégorie

SELECT name, ROUND(AVG(rental_rate),2) AS "notes moyennes"
FROM category c 
INNER JOIN film_category fc 
ON c.category_id = fc.category_id 
INNER JOIN film f 
ON f.film_id = fc.film_id 
GROUP BY name

-- DEMANDE DE LA DIRECTION AVEC CONCEPTS ASSOCIES

--1)Liste des 10 films les plus loués. (SELECT, JOIN, GROUP BY, ORDER BY, LIMIT)

SELECT title, COUNT() AS total_location
FROM film f 
INNER JOIN inventory i 
ON f.film_id = i.film_id 
INNER JOIN rental r 
ON i.inventory_id = r.inventory_id 
GROUP BY title 
ORDER BY total_location DESC
LIMIT 10

--2)Acteurs ayant joué dans le plus grand nombre de films. (JOIN, GROUP BY, ORDER BY, LIMIT)

SELECT first_name, last_name,COUNT() AS nombre_tot_films
FROM actor
INNER JOIN film_actor fa 
ON actor.actor_id = fa.actor_id
INNER JOIN film f 
ON f.film_id = fa.film_id 
GROUP BY last_name, first_name 
ORDER BY nombre_tot_films DESC
LIMIT 1

--3)Revenu total généré par mois

SELECT strftime('%Y-%m', payment_date) AS periode,sum(amount) AS tot_CA
FROM payment p 
GROUP BY strftime('%Y-%m', payment_date)
ORDER BY tot_CA DESC 

-- 4)Revenu total généré par chaque magasin par mois pour l'année 2005. (JOIN, SUM, GROUP BY, DATE functions)

SELECT s.store_id,strftime('%Y-%m', payment_date) AS periode, sum(amount) AS tot_CA
FROM store s 
INNER JOIN staff s2 
ON s.store_id = s2.store_id 
INNER JOIN payment p 
ON p.staff_id = s2.staff_id 
GROUP BY s.store_id,periode
HAVING periode NOT LIKE "2006%"

-- 5)Les clients les plus fidèles, basés sur le nombre de locations. (SELECT, COUNT, GROUP BY, ORDER BY)

SELECT first_name, last_name,C.customer_id ,COUNT() AS nombre_locations
FROM customer c 
INNER JOIN payment p 
ON c.customer_id = p.customer_id
GROUP BY first_name, last_name
ORDER BY nombre_locations DESC 

-- 6)Films qui n'ont pas été loués au cours des 6 derniers mois. (LEFT JOIN, WHERE, DATE functions, Sub-query)

  -- (creation d'une table temporaire pour avoir la date 6 mois en arrière) 

WITH table_date AS (
SELECT date(MAX(rental_date), '-6 months') AS date_choisie
FROM rental
),

   -- (Recuperation des films ayant été loués dans les 6 mois)

films_in6months AS (
SELECT title, rental_date
FROM film f 
INNER JOIN inventory i 
ON f.film_id = i.film_id 
INNER JOIN rental r 
ON i.inventory_id = r.inventory_id 
WHERE rental_date > (SELECT  date_choisie FROM table_date)
GROUP BY title 
)

  -- (requête principale)

SELECT f.title 
FROM film f 
LEFT JOIN films_in6months
ON f.title = (SELECT title FROM films_in6months)
GROUP BY f.title


--7)Le revenu total de chaque membre du personnel à partir des locations. (JOIN, GROUP BY, ORDER BY, SUM)

SELECT first_name, last_name, sum(amount) AS CA_total
FROM staff s
INNER JOIN payment p 
ON s.staff_id = p.staff_id 
GROUP BY first_name, last_name

--8) Catégories de films les plus populaires parmi les clients. (JOIN, GROUP BY, ORDER BY, LIMIT)
   -- Commentaires: Je considère que plus il y a de locations dans une catégorie et plus elle sera populaire. 
 
SELECT name, COUNT() AS nbr_loc
FROM category c 
INNER JOIN film_category fc 
ON c.category_id = fc.category_id 
INNER JOIN film f 
ON fc.film_id  = f.film_id
INNER JOIN inventory i 
ON f.film_id  = i.film_id 
INNER JOIN rental r 
ON r.inventory_id = i.inventory_id 
GROUP BY name 
ORDER BY nbr_loc DESC

-- 9)Durée moyenne entre la location d'un film et son retour. (SELECT, AVG, DATE functions)

SELECT FLOOR(AVG(JULIANDAY(return_date)-JULIANDAY(rental_date))) AS moyenne_location
FROM rental r 


--10)Acteurs qui ont joué ensemble dans le plus grand nombre de films. 
--ficher l'acteur 1, l'acteur 2 et le nombre de films en commun
--Trier les résultats par ordre décroissant. Attention aux répétitons. 
--joIN, GROUP BY, ORDER BY, Self-join)



SELECT fa.actor_id AS acteur_1, fa2.actor_id AS acteur_2, fa.film_id,COUNT() AS nombre_de_films
FROM film_actor fa 
INNER JOIN film_actor fa2 
ON fa.film_id  = fa2.film_id 
WHERE fa.actor_id > fa2.actor_id 
GROUP BY acteur_1,acteur_2
ORDER BY nombre_de_films DESC

-- BONUS Clients qui ont loué un film  mais qui n'ont pas fait au moins une location dans les 30J qui suivent

WITH total_interval AS(
SELECT r.rental_date ,r2.rental_date,r2.customer_id,(JULIANDAY(date(r2.rental_date))  - JULIANDAY(date(r.rental_date)))  AS intervalle
FROM rental r 
INNER JOIN rental r2 
ON r.customer_id = r2.customer_id 
WHERE date(r.rental_date) < date(r2.rental_date) 
)
SELECT customer_id ,MIN(intervalle) AS intervalle_min
FROM total_interval
GROUP BY customer_id
HAVING intervalle_min > 30


--Refaite la même question pour un interval de 15 jours pour le mois d'août 2005.

WITH total_interval AS(
SELECT 
FROM rental r 
INNER JOIN rental r2 
ON r.customer_id  = r2.customer_id 
WHERE date(r.rental_date) < date(r2.rental_date)
AND rental.da
)





