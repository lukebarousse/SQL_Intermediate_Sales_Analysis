WITH customer_ltv AS (
    SELECT
        customerkey,
        SUM(total_net_revenue) AS total_ltv
    FROM cleaned_customer
    GROUP BY customerkey
),

customer_segments AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS percentile_25th,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS percentile_75th
    FROM customer_ltv
),

-- Put previous main query into a CTE
segement_values AS (
    SELECT
        c.customerkey,
        c.total_ltv,
        CASE
            WHEN c.total_ltv > percentile_75th THEN 'High-Value'
            WHEN c.total_ltv BETWEEN percentile_25th AND percentile_75th THEN 'Mid-Value'
            ELSE 'Low-Value'
        END AS customer_segment
    FROM customer_ltv c,
    customer_segments cs
)

SELECT
    customer_segment,
    SUM(total_ltv) AS total_ltv,
    COUNT(customerkey) AS customer_count
FROM segement_values
GROUP BY customer_segment
ORDER BY total_ltv DESC
;