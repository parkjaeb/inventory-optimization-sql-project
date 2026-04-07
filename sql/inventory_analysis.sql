
SELECT 
    i.sku,
    i.current_inventory,
    ROUND(SUM(s.quantity) / 365.0,2) AS avg_daily_demand,
    ROUND(i.current_inventory / (SUM(s.quantity) / 365.0),2) AS days_of_supply
FROM inventory i
JOIN sales s ON i.sku = s.sku
GROUP BY i.sku, i.current_inventory
ORDER BY days_of_supply ASC;

select
	i.sku,
	i.current_inventory,
	avg(s.price) as avg_price,
	round(i.current_inventory * avg(s.price),2) as inventory_value
from inventory i 
join sales s on i.sku = s.sku
group by i.sku, i.current_inventory 
order by current_inventory desc;

select 
	i.sku,
	i.current_inventory,
	round(sum(s.quantity)/365,2) as avg_daily_demand,
	round(i.current_inventory/(sum(s.quantity)/365),2) as days_supply,
	round(i.current_inventory * avg(s.price),2) as inventory_value
from inventory i 
join sales s on i.sku = s.sku
group by i.sku, i.current_inventory 
order by inventory_value desc;
	
