-- 1.Nombre total d’appartements vendus au 1er semestre 2020.

SELECT Type_local, COUNT(ID_vente) AS Nombre_de_ventes FROM vente
JOIN bien ON vente.id_bien=bien.id_bien
WHERE Type_local='Appartement' AND "2020-01-01" <= Date_mutation AND Date_mutation <= "2020-06-30";


-- 2.Le nombre de ventes d’appartement par région pour le 1er semestre 2020.

SELECT nom_region, type_local, COUNT(DISTINCT id_vente) AS Nombre_de_ventes FROM vente
LEFT JOIN bien ON vente.id_bien=bien.id_bien
LEFT JOIN commune ON bien.Id_commune=commune.Id_commune
LEFT JOIN region ON commune.Code_region=region.Code_region
WHERE Type_local='Appartement' AND "2020-01-01" <= Date_mutation AND Date_mutation <= "2020-06-30"
GROUP BY nom_region;

  
-- 3.Proportion des ventes d’appartements par le nombre de pièces.

SELECT  Total_piece, COUNT(Id_vente) AS Nombre_de_ventes, CONCAT(ROUND((COUNT(Id_vente)/(
SELECT COUNT(Id_vente) FROM vente LEFT JOIN bien ON vente.id_bien=bien.id_bien WHERE Type_local='Appartement')*100),3), "%") as Proportion 
FROM vente
LEFT JOIN bien ON vente.id_bien=bien.id_bien
WHERE Type_local='Appartement'
GROUP BY Total_piece
ORDER BY Total_piece;

-- 4.Liste des 10 départements où le prix du mètre carré est le plus élevé.

SELECT Nom_departement, ROUND(AVG(Valeur/Surface_carrez)) AS Prix_au_m²_€ FROM vente
LEFT JOIN bien ON vente.id_bien=bien.id_bien
LEFT JOIN commune ON bien.Id_commune=commune.Id_commune
GROUP BY Nom_Departement
ORDER BY Prix_au_m²_€ DESC
LIMIT 10;
  
-- 5.Prix moyen du mètre carré d’une maison en Île-de-France.

SELECT Nom_region, Type_local, ROUND(AVG(Valeur/Surface_carrez)) AS Prix_moyen_au_m²_€ FROM vente
LEFT JOIN bien ON vente.id_bien=bien.id_bien
LEFT JOIN commune ON bien.Id_commune=commune.Id_commune
LEFT JOIN region ON commune.Code_region=region.Code_region
WHERE Type_local='Maison' AND Nom_Region='Île-de-France';

-- 6.Liste des 10 appartements les plus chers avec la région et le nombre de mètres carrés.

SELECT  bien.id_bien, Nom_region, Valeur as Valeur_€, CONCAT(Surface_carrez, " m²") AS Surface_Carrez  FROM vente
LEFT JOIN bien ON vente.id_bien=bien.id_bien
LEFT JOIN commune ON bien.Id_commune=commune.Id_commune
LEFT JOIN region ON commune.Code_region=region.Code_region
WHERE Type_local='Appartement' 
ORDER BY Valeur DESC
LIMIT 10;

-- 7.Taux d’évolution du nombre de ventes entre le premier et le second trimestre de 2020

WITH 
Premier_trimestre AS (
SELECT COUNT(Id_vente) AS Premier_trimestre FROM vente
WHERE  date_mutation BETWEEN "2020-01-01" AND "2020-03-31" ),

Second_trimestre AS (
SELECT COUNT(Id_vente) AS Second_trimestre FROM vente
WHERE  date_mutation BETWEEN "2020-04-01" AND "2020-06-30")

SELECT Premier_trimestre AS Nb_vente_1er_Trimestre, Second_trimestre AS Nb_vente_2eme_Trimestre, CONCAT(ROUND(((Second_trimestre-Premier_trimestre)/Premier_trimestre*100),2), " %") AS evolution 
FROM Premier_trimestre, Second_trimestre;


-- 8.Le classement des régions par rapport au prix au mètre carré des appartement de plus de 4 pièces.

SELECT ROW_NUMBER() OVER (ORDER BY AVG(Valeur/Surface_carrez) DESC) AS Classement, Nom_region, ROUND((AVG(Valeur/Surface_carrez))) AS Prix_moyen_au_m²_€  FROM vente
LEFT JOIN bien ON vente.id_bien=bien.id_bien
LEFT JOIN commune ON bien.Id_commune=commune.Id_commune
LEFT JOIN region ON commune.Code_region=region.Code_region
WHERE Type_local='Appartement' AND Total_piece > 4
GROUP BY Nom_region
ORDER BY Prix_moyen_au_m²_€ DESC;

-- 9.Liste des communes ayant eu au moins 50 ventes au 1er trimestre

SELECT Nom_commune, COUNT(id_vente) AS Nombre_de_ventes FROM vente
LEFT JOIN bien ON vente.id_bien=bien.id_bien
LEFT JOIN commune ON bien.Id_commune=commune.Id_commune
WHERE Date_mutation >= "2020-01-01" AND Date_mutation <= "2020-03-31"
GROUP BY Nom_commune
HAVING COUNT(id_vente) >= 50
ORDER BY COUNT(id_vente) DESC;

-- 10.Différence en pourcentage du prix au mètre carré entre un appartement de 2 pièces et un appartement de 3 pièces.

WITH 

prix_au_m2_t2 AS (
SELECT AVG(Valeur/surface_carrez) AS pt2 FROM vente
LEFT JOIN bien ON vente.id_bien=bien.id_bien
WHERE Total_piece=2),

prix_au_m2_t3 AS (
SELECT AVG(Valeur/surface_carrez) AS pt3 FROM vente
LEFT JOIN bien ON vente.id_bien=bien.id_bien
WHERE Total_piece=3)

SELECT CONCAT(ROUND(pt2), " €") AS Prix_moyen_m²_t2, CONCAT(ROUND(pt3), " €") AS Prix_moyen_m²_t3, CONCAT(ROUND(((pt3-pt2)/pt2*100),2), " %") AS Ecart_prix
FROM prix_au_m2_t2, prix_au_m2_t3;

-- 11.Les moyennes de valeurs foncières pour le top 3 des communes des départements 6, 13, 33, 59 et 69

WITH Ordre 

AS ( 
SELECT Code_departement, Nom_commune, ROUND(AVG(valeur)) AS Valeur_foncière_moyenne_€, ROW_NUMBER() OVER (PARTITION BY Code_departement ORDER BY AVG(Valeur) DESC) AS Classement
FROM vente
LEFT JOIN bien ON vente.id_bien=bien.id_bien
LEFT JOIN commune ON bien.Id_commune=commune.Id_commune
WHERE Code_departement IN (6, 13, 33, 59, 69)
GROUP BY Nom_commune
ORDER BY Code_departement)

SELECT*FROM Ordre WHERE Classement <= 3 ;

