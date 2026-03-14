SELECT g.name AS genre,
       COUNT(il.invoice_line_id)  AS nb_ventes,
       SUM(il.unit_price * il.quantity) AS ca_total
FROM   invoice_line il
           JOIN   track t USING ("track_id")
           JOIN   genre  g  USING (genre_id)
GROUP BY g.name
ORDER BY ca_total DESC;

---

WITH track_sales AS (
    SELECT track_id,
           COUNT(invoice_line_id) AS nb_ventes,
           SUM(unit_price * quantity) AS track_ca
    FROM invoice_line
    GROUP BY track_id
)
SELECT g.name AS genre,
       SUM(ts.nb_ventes) AS nb_ventes,
       SUM(ts.track_ca) AS ca_total
FROM track_sales ts
         JOIN track t USING (track_id)
         JOIN genre g USING (genre_id)
GROUP BY g.name
ORDER BY ca_total DESC;


---
-- 1. Création de la vue matérialisée
CREATE MATERIALIZED VIEW mv_ca_par_genre AS
SELECT g.name AS genre,
       COUNT(il.invoice_line_id) AS nb_ventes,
       SUM(il.unit_price * il.quantity) AS ca_total
FROM invoice_line il
         JOIN track t USING (track_id)
         JOIN genre g USING (genre_id)
GROUP BY g.name;

-- 2. Création d'un index sur la vue pour accélérer le tri
CREATE UNIQUE INDEX idx_mv_ca_par_genre_name ON mv_ca_par_genre(genre);

-- 3. Utilisation très rapide (Index Only Scan potentiellement)
SELECT * FROM mv_ca_par_genre ORDER BY ca_total DESC;