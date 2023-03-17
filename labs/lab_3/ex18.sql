--ex 18
with "2021" as (
	select district_id, count(*) 
	from ((select object_id from sales where extract (year from sales.date) = 2021) as "a"
join 
(select objects.id, objects.district_id from objects) as "b"
on "a".object_id = "b".id)
group by district_id),
"2022" as (select district_id, count(*) from
((select object_id from sales where extract (year from sales.date) = 2022) as "a"
join 
(select objects.id, objects.district_id from objects) as "b"
on "a".object_id = "b".id)
group by district_id)

select districts.name, "2021".count,"2022".count, round((("2022".count - "2021".count)/"2022".count::decimal)*100) as delta 

from "2021","2022",districts where
districts.id = "2021".district_id and districts.id = "2022".district_id
