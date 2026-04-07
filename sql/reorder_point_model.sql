WITH reorder_point_model AS (
    SELECT
        i.sku,
        i.current_inventory,
        SUM(s.quantity) / 360.0 AS avg_daily_demand,
        STDDEV_SAMP(s.quantity) AS demand_stddev,
        MIN(sup.lead_time_days) AS lead_time_days,
        (SUM(s.quantity) / 360.0 * MIN(sup.lead_time_days)) AS demand_during_lead_time,
        (STDDEV_SAMP(s.quantity) * SQRT(MIN(sup.lead_time_days))) AS safety_stock,
        (
            (SUM(s.quantity) / 360.0 * MIN(sup.lead_time_days))
            + (STDDEV_SAMP(s.quantity) * SQRT(MIN(sup.lead_time_days)))
        ) AS reorder_point,
        (i.current_inventory / NULLIF(SUM(s.quantity) / 360.0, 0)) AS days_supply
    FROM inventory i
    JOIN sales s
        ON s.sku = i.sku
    JOIN suppliers sup
        ON sup.sku = i.sku
    GROUP BY i.sku, i.current_inventory
)
SELECT
    sku,
    current_inventory,
    ROUND(avg_daily_demand::numeric, 2) AS avg_daily_demand,
    ROUND(demand_stddev::numeric, 2) AS demand_stddev,
    lead_time_days,
    ROUND(demand_during_lead_time::numeric, 2) AS demand_during_lead_time,
    ROUND(safety_stock::numeric, 2) AS safety_stock,
    ROUND(reorder_point::numeric, 2) AS reorder_point,
    ROUND(days_supply::numeric, 2) AS days_supply,
    ROUND((current_inventory - reorder_point)::numeric, 2) AS inventory_gap,
    CASE
        WHEN current_inventory <= reorder_point THEN 'REORDER'
        WHEN days_supply > 90 THEN 'REDUCE'
        ELSE 'MONITOR'
    END AS action
FROM reorder_point_model
ORDER BY sku;
