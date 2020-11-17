CREATE procedure [AppAdmin].[ti_RFM_Object_sp] as
select objectid,objectname, last_access_date, accessedby,
case when recency = 4 and frequency = 4 then
	'most used'
	when recency = 1 and frequency = 1 then
	'least used'
	else
	'medium use'
end as usage
from
(
	select objectid,objectname, last_access_date, accessedby,
		ntile(4) over (order by most_recent_accessed) recency,
		ntile(4)  over (order by your_most_accessed) frequency,
		ntile(4) over ( order by your_recent_accessed) your_recency ,
		ntile(4)  over (order by most_accessed) your_frequency,
		most_recent_accessed,
		your_most_accessed,
		your_recent_accessed,
		most_accessed

	from (
			select objectid,objectname, last_access_date, accessedby,
			row_number() over (partition by accessedby order by last_access_date desc) your_recent_accessed,
			row_number() over (order by last_access_date desc) most_recent_accessed,

			count(accessedby) over (partition by objectid) most_accessed,
			count(*) over (partition by accessedby,objectid) your_most_accessed

			from 
				   (select objectid, objectname, accessedby,
				   max(accessdate) as last_access_date,
				   count(*) as count_accessed 
					from sandbox.objectaccesslog
					group by objectid,objectname,accessedby)
					as a
		) b
) c