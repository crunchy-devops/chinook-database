# use_case_sql / ca_total.sql

## Objectif de la requête

La requête [ca_total.sql](cci:7://file:///D:/crunchydevops/chinook-database/use_case_sql/ca_total.sql:0:0-0:0) calcule, pour chaque genre musical :

- **nb_ventes** : le nombre de lignes de facture (ventes) associées au genre.
- **ca_total** : le chiffre d'affaires total (`UnitPrice * Quantity`) pour ce genre.
avec les noms d'origine des tables/colonnes :

```sql
SELECT g."Name" AS genre,
       COUNT(il."InvoiceLineId")  AS nb_ventes,
       SUM(il."UnitPrice" * il."Quantity") AS ca_total
FROM   "InvoiceLine" il
JOIN   "Track"  t  USING ("TrackId")
JOIN   "Genre"  g  USING ("GenreId")
GROUP BY g."Name"
ORDER BY ca_total DESC;

Pour cette requête spécifique sur la base de données Chinook, voici une
analyse détaillée des pistes d'optimisation par rapport aux concepts que
vous avez mentionnés.
Étant donné que votre requête n'a pas de clause WHERE, elle effectue
une agrégation totale sur l'ensemble de la table invoice_line.
1. Seq Scan vs Index Scan / Joins (Hash, Merge, Nested Loop)
Puisque vous lisez toutes les lignes de la table invoice_line
(pour calculer le total global), le planificateur (planner)
 de PostgreSQL va très probablement opter pour :

•
Seq Scan (Balayage séquentiel) sur invoice_line et track. C'est normal et
 souvent plus rapide que de faire un Index
Scan sur chaque ligne, car le Seq Scan limite les lectures aléatoires sur
 le disque.
•
Hash Join ou Merge Join. Le planificateur va charger les tables genre et
track en mémoire (car elles sont petites) et les hacher pour les joindre avec
le flux de invoice_line.
•
Nested Loop : À éviter ici. Un Nested Loop serait très inefficace sur une
 table complète, car il parcourrait la table interne pour chaque ligne de
 invoice_line.

Action sur les index : Assurez-vous d'avoir des index sur les clés étrangères,
même si PostgreSQL pourrait préférer un Seq Scan pour cette requête globale.
Ils sont vitaux si vous rajoutez un filtre plus tard (ex: WHERE date > ...).


2. Optimisation avec une CTE (Common Table Expression)
Une CTE (WITH ... AS) est souvent utilisée pour la lisibilité,
mais ne va généralement pas accélérer cette requête (le planificateur
 Postgres va simplement l'inliner). Cependant, on pourrait théoriquement
  pré-agréger au niveau des pistes (track_id) avant de joindre la table
  genre pour réduire le volume de données transitant dans les jointures.
   Mais avec la base Chinook (assez petite), le gain sera négligeable et le
 moteur sait souvent le déduire lui-même :

3. La solution ultime : Materialized View (Vue matérialisée)
Puisqu'il s'agit d'une requête analytique (calcul de CA global) qui
parcourt beaucoup d'historique (les anciennes factures ne changent pas),
 l'utilisation d'une Vue Matérialisée est l'optimisation la plus radicale
 et la plus adaptée.
Plutôt que de recalculer à chaque fois, vous stockez le résultat "en dur" :


L'inconvénient : Il faudra la rafraîchir manuellement (ou via une tâche cron/trigger) quand de
 nouvelles ventes sont ajoutées avec la commande : REFRESH MATERIALIZED VIEW CONCURRENTLY mv_ca_par_genre;
En résumé pour cette requête :
1.
Sans filtrage (pas de WHERE) : Ne touchez pas à la requête initiale, un Seq Scan + Hash Join est
 le comportement le plus sain pour PostgreSQL sur ce volume.
2.
Pour des performances de type Dashboard (zéro latence) : Mettez en place la Materialized View