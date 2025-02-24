CREATE VIEW cleaned_customer AS
WITH cohort_data AS (
    SELECT 
        s.customerkey,
        c.countryfull, 
        c.age,
        c.givenname,
        c.surname,
        MIN(s.orderdate) OVER (PARTITION BY s.customerkey) AS first_purchase_date,
        EXTRACT(YEAR FROM MIN(s.orderdate) OVER (PARTITION BY s.customerkey)) AS cohort_year,
        s.orderdate,
        COUNT(s.orderkey) AS num_orders,
        SUM(s.quantity* s.netprice * s.exchangerate) AS total_net_revenue
    FROM sales s
    LEFT JOIN customer c ON c.customerkey = s.customerkey
    GROUP BY 
        s.customerkey, 
        c.countryfull, 
        c.age, 
        c.givenname, 
        c.surname,
        s.orderdate
)

SELECT
    cd.customerkey, 
    cd.cohort_year,
    CONCAT(TRIM(cd.givenname), ' ', TRIM(cd.surname)) AS cleaned_name, 
    COALESCE(cd.num_orders, 0) AS num_orders,
    COALESCE(cd.total_net_revenue, 0) AS net_revenue
    cd.countryfull,
    cd.age,
    cd.first_purchase_date,
    cd.orderdate
FROM cohort_data cd;