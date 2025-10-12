-- Query Analysis
-- Total Matches, Wins, and Top 10s
select 
	sum(matches_played) as total_matches, 
	sum(wins) as total_wins, 
	sum(top_10_count)as Top_10s 
from season_stats

-- avg win ratio per map
select
	map_name m,
	round(avg(win_ratio),2) as win_ratio_per_map
from season_stats as ss
join maps as m on ss.map_id = m.map_id
group by map_name

-- average kd by device and server
select 
	device_name d, server_name s,
	round(avg(kd),2) as avg_kd
from season_stats as ss
join devices as d on ss.device_id = d.device_id
join servers as s on ss.server_id = s.server_id
group by device_name, server_name
order by avg_kd desc

-- highest accuracy & headshot by device
select 
	max(accuracy) as accuracy, max(headshots) as headshots, device_name d
from season_stats as ss
join devices as d on ss.device_id = d.device_id
group by device_name
order by device_name

-- best performing server is middleeast
-- most popular map

-- Season Over Season Improvement (Wins Growth %)
with season_summary as (
	select 
		season_label,
		season_date,
		sum(wins) as total_wins
	from season_stats
	group by season_label, season_date
 --because date is in cronological order
)
select
	season_label,
	total_wins,
	case 
		when lag(total_wins) over (order by season_date) >0 then
			round(
          		(total_wins - lag(total_wins) over (order by season_date)) 
           		/ lag(total_wins) over (order by season_date):: decimal * 100, 
           		2
            )
		when lag(total_wins) over (order by season_date) = 0 and total_wins > 0 then
            100.00  -- from 0 to positive = 100% growth
        when lag(total_wins) over (order by season_date) = 0 and total_wins = 0 then
            0.00    -- stayed at 0 = 0% growth
		else null
	end as win_growth_percentage
from season_summary
