use sakila;
-- 1.Write a query to display for each store its store ID, city, and country.
select * from store;
select * from address;
select * from city;
select * from country;

select s.store_id, ci.city, co.country from store as s
join address as a
on s.address_id = a.address_id
join city as ci
on a.city_id = ci.city_id
join country as co
on ci.country_id = co.country_id;

-- 2.Write a query to display how much business, in dollars, each store brought in.
select * from store; -- store_id, manager_staff_id
select * from payment; -- payment_id, amount, staff_id

select s.store_id, sum(payment_id*amount) as total_amount_brought from store as s
join payment as p
on s.manager_staff_id = p.staff_id
group by s.store_id
order by total_amount_brought;

-- 3.Which film categories are longest?
select * from category; -- category_id, name
select * from film_category; -- film_id, category_id
select * from film; -- length, film_id
-- I don't know exactly the requested way at calculate it, anyway all gives back the same result: Action is the longest category.
select c.name, ((f.length*f.film_id)/c.category_id) as lenght_per_category from film as f
join film_category as fc
on f.film_id = fc.film_id
join category as c
on fc.category_id = c.category_id
group by c.name
order by lenght_per_category desc; 

select c.name, sum((f.length*f.film_id)/c.category_id) as lenght_per_category from film as f
join film_category as fc
on f.film_id = fc.film_id
join category as c
on fc.category_id = c.category_id
group by c.name
order by lenght_per_category desc; 

select c.name, avg((f.length*f.film_id)/c.category_id) as lenght_per_category from film as f
join film_category as fc
on f.film_id = fc.film_id
join category as c
on fc.category_id = c.category_id
group by c.name
order by lenght_per_category desc; 

-- 4.Display the most frequently rented movies in descending order.
select * from rental; -- rental_id, customer_id, inventory_id
select * from film; -- film_id, title, rental_duration
select * from inventory;-- inventory_id, film_id

select f.title, count(r.inventory_id) as rentals from film as f
join inventory as i
on f.film_id = i.film_id
join rental as r
on i.inventory_id = r.inventory_id
group by f.film_id
order by rentals desc; 


-- 5.List the top five genres in gross revenue in descending order.
select * from film_category; -- film_id, category_id
select * from category; -- category_id, name
select * from payment; -- amount, customer_id, rental_id
select * from rental; -- rental_id, customer_id, inventory_id
select * from inventory;-- inventory_id, film_id

select c.name, count(p.rental_id*p.amount) as gross_revenue from film_category as fc
join inventory as i
on fc.film_id = i.film_id
join rental as r
on i.inventory_id = r.inventory_id
join payment as p
on r.rental_id = p.rental_id
join category as c
on fc.category_id = c.category_id
group by fc.category_id
order by gross_revenue desc limit 5; 
 

-- 6.Is "Academy Dinosaur" available for rent from Store 1?
select * from film; -- title, film_id
select * from inventory; -- inventory_id, store_id, film_id

select f.title, i.store_id, i.inventory_id from film as f
join inventory as i
on f.film_id = i.film_id
where f.title like "%Academy Dinosaur%" and i.store_id = 1;
-- Yes, there are 4 copies of the film in store 1.

-- 7.Get all pairs of actors that worked together.
select * from actor;
select * from film_actor;

-- This is when we display all the actors that have worked together:
select a.first_name, a.last_name, fa.film_id from film_actor as fa
join actor as a
on fa.actor_id = a.actor_id
order by fa.film_id;

-- These are all the pair of actors that has worked together:
select a1.first_name, a1.last_name, a2.first_name, a2.last_name, f.title from film as f
join film_actor as fa1 on f.film_id = fa1.film_id
join film_actor as fa2 on fa1.film_id = fa2.film_id
join actor as a1 on fa1.actor_id = a1.actor_id
join actor as a2 on fa2.actor_id = a2.actor_id
where a1.actor_id <  a2.actor_id
order by fa1.film_id;


-- 8.Get all pairs of customers that have rented the same film more than 3 times.
select * from rental; -- rental_id, customer_id, inventory_id
select * from film; -- film_id, title, rental_duration
select * from inventory;-- inventory_id, film_id
select * from customer; -- fisrt_name, last_name, customer_id

-- This is the result if we don't use self joins:
select c.first_name, c.last_name, r.customer_id, count(distinct f.film_id = r.customer_id) as times_renting_the_same_film from film as f
join inventory as i
on f.film_id = i.film_id
join rental as r
on i.inventory_id = r.inventory_id
join customer as c
on r.customer_id = c.customer_id
group by r.customer_id
having times_renting_the_same_film > 3 -- if we include this filter it wouldn't appear any
order by times_renting_the_same_film desc;

-- This is the result if we use self join:
select c1.first_name, c1.last_name, c2.first_name, c2.last_name, f.title, COUNT(i.film_id) as times_renting_the_same_film 
from rental as r1
join rental as r2 on r1.inventory_id = r2.inventory_id
join inventory as i on r1.inventory_id = i.inventory_id
join film as f on i.film_id = f.film_id
join customer as c1 on r1.customer_id = c1.customer_id
join customer as c2 on r2.customer_id = c2.customer_id
where c1.customer_id < c2.customer_id
group by i.film_id, c1.customer_id, c2.customer_id
having times_renting_the_same_film > 3;


-- 9.For each film, list actor that has acted in more films.
select * from film; -- film_id, title
select * from film_actor; -- actor_id, film_id
select * from actor; -- actor_id, first_name, last_name


select a.first_name, a.last_name, f.title, count(a.actor_id) as total_films from film as f
join film_actor as fa on f.film_id = fa.film_id
join actor as a on fa.actor_id = a.actor_id 
group by f.film_id, a.actor_id
order by f.film_id, total_films desc;

-- Using subqueries we can get:
select f.title, a.first_name, a.last_name, count(a.actor_id) as total_films from film f
join film_actor fa on f.film_id = fa.film_id
join actor a on fa.actor_id = a.actor_id
group by fa.film_id
having total_films = (select max(total_films) from 
(select count(actor_id) as total_films from film_actor 
group by film_id, actor_id) as t)
order by fa.film_id;

