-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : lun. 20 nov. 2023 à 18:20
-- Version du serveur : 10.4.22-MariaDB
-- Version de PHP : 8.0.13

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `verdibu`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `adAllvideo` (IN `uuid` VARCHAR(50), IN `st` INT, IN `lm` INT)  SELECT 
    v.*,
    ca.Nom AS Cat,
    p.ID AS Channel,
    p.uniid AS Uuid,
    p.PageName,
    p.Photo,
    p.Cover,
    p.Categorie AS Category,
    p.Created_at AS PageCreated,
    c.Nom AS CatPage,
    u.Mail,
    COUNT(DISTINCT vw.ID) AS Views,
    COUNT(DISTINCT l.ID) AS Likes
    
FROM posts v
LEFT JOIN pages p ON v.User = p.ID
LEFT JOIN pagecat c ON p.Categorie = c.ID
LEFT JOIN users u ON p.user_id = u.ID
LEFT JOIN views vw ON v.ID = vw.Post
LEFT JOIN likes l ON v.ID = l.Post
LEFT JOIN categories ca ON ca.ID = v.Categorie
WHERE (p.user_id IS NOT NULL OR p.ID IN (SELECT Subscriber FROM subscribes WHERE User = u.ID))
  AND v.uniid <> uuid
GROUP BY v.Created_at DESC
         LIMIT st,lm$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `adduser` (IN `uniid` VARCHAR(100), IN `pageName` VARCHAR(50), IN `Mail` VARCHAR(50), IN `password` VARCHAR(250))  BEGIN
    DECLARE user_id INT;
    SELECT users.ID INTO user_id FROM users ORDER BY 	users.ID DESC LIMIT 1;
    INSERT INTO pages(user_id,uniid,PageName) VALUES(user_id+1,uniid,pageName);
INSERT INTO users(ID,Mail,Password) VALUES(user_id+1,Mail,password);
SELECT * FROM pages ORDER BY pages.ID DESC LIMIT 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addview` (IN `post` INT, IN `user` INT)  BEGIN
    DECLARE today DATE;
    DECLARE existing_views INT;

    SET today = CURDATE();

    -- Vérifier si une vue existe déjà pour la vidéo et l'utilisateur spécifiés aujourd'hui
    SELECT COUNT(*) INTO existing_views
    FROM views
    WHERE views.Post = post AND views.User = user
    AND DATE(views.Created_at) = today;

    -- Insérer une nouvelle vue si aucune vue n'a été enregistrée aujourd'hui
    IF existing_views = 0 THEN
        INSERT INTO views (post, user)
        VALUES (post, user);
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `adLastvideo` ()  SELECT 
    v.*,
    ca.Nom AS Cat,
    p.ID AS Channel,
    p.uniid AS Uuid,
    p.PageName,
    p.Photo,
    p.Cover,
    p.Categorie AS Category,
    p.Created_at AS PageCreated,
    c.Nom AS CatPage,
    u.Mail,
    COUNT(DISTINCT vw.ID) AS Views,
    COUNT(DISTINCT l.ID) AS Likes
    
FROM posts v
LEFT JOIN pages p ON v.User = p.ID
LEFT JOIN pagecat c ON p.Categorie = c.ID
LEFT JOIN users u ON p.user_id = u.ID
LEFT JOIN views vw ON v.ID = vw.Post
LEFT JOIN likes l ON v.ID = l.Post
LEFT JOIN categories ca ON ca.ID = v.Categorie
WHERE (p.user_id IS NOT NULL OR p.ID IN (SELECT Subscriber FROM subscribes WHERE User = u.ID))
GROUP BY v.ID
ORDER BY v.Created_at DESC LIMIT 1$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `allsms` ()  SELECT m.*, p.uniid, p.user_id, p.PageName, p.Photo
FROM pages p
INNER JOIN messages m ON p.ID = m.User
INNER JOIN (
    SELECT User, MAX(Create_at) AS max_create_at
    FROM messages
    GROUP BY User
) m2 ON m.User = m2.User AND m.Create_at = m2.max_create_at
ORDER BY m.Create_at DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `allVideos` (IN `uuid` VARCHAR(50), IN `st` INT, IN `lm` INT)  SELECT 
        v.*,
        ca.Nom AS Cat,
        p.ID AS Channel,p.user_id,p.uniid Uuid,p.PageName,p.Photo,p.Cover,p.Categorie AS PageCat,p.Created_at AS PageCreated,
        c.Nom AS CatP,
        u.Mail AS Mail,
        COUNT(DISTINCT vw.ID) AS Views,
        COUNT(DISTINCT l.ID) AS Likes
    FROM posts v
    LEFT JOIN pages p ON v.User = p.ID
    LEFT JOIN pagecat c ON p.Categorie = c.ID
    LEFT JOIN users u ON p.user_id = u.ID
    LEFT JOIN views vw ON v.ID = vw.Post
    LEFT JOIN likes l ON v.ID = l.Post
    LEFT JOIN categories ca ON ca.ID = v.Categorie
    WHERE v.User  = (SELECT pages.ID FROM pages WHERE pages.uniid=uuid)
    GROUP BY v.ID
    ORDER BY v.Created_at
    LIMIT st,lm$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `blocs` ()  SELECT (SELECT COUNT(*) FROM posts) AS Posts,(SELECT COUNT(*) FROM messages) AS Messages,(SELECT COUNT(*) FROM users) AS Users,
(SELECT COUNT(*) FROM pages) AS Pages$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `byCat` (IN `cat` VARCHAR(50), IN `st` INT, IN `lm` INT)  SELECT 
        v.*,
        ca.Nom AS Cat,
        p.ID AS Channel,p.user_id,p.uniid Uuid,p.PageName,p.Photo,p.Cover,p.Categorie AS PageCat,p.Created_at AS PageCreated,
        c.Nom AS CatP,
        u.Mail AS Mail,
        COUNT(DISTINCT vw.ID) AS Views,
        COUNT(DISTINCT l.ID) AS Likes
    FROM posts v
    LEFT JOIN pages p ON v.User = p.ID
    LEFT JOIN pagecat c ON p.Categorie = c.ID
    LEFT JOIN users u ON p.user_id = u.ID
    LEFT JOIN views vw ON v.ID = vw.Post
    LEFT JOIN likes l ON v.ID = l.Post
    LEFT JOIN categories ca ON ca.ID = v.Categorie
    WHERE ca.Nom = cat
    GROUP BY v.ID
    ORDER BY v.Created_at DESC
    LIMIT st,lm$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `bySub` (IN `cat` INT, IN `st` INT, IN `lm` INT)  SELECT 
    pages.*, pagecat.Nom AS Category,
    COUNT(*) AS Posts, 
    (SELECT COUNT(*) FROM subscribes WHERE Subscriber = pages.ID) AS Abonnes, 
    SUM((SELECT COUNT(*) FROM likes WHERE Post = posts.ID)) AS Likes, 
    SUM((SELECT COUNT(*) FROM views WHERE Post = posts.ID)) AS Views
FROM 
    posts
INNER JOIN 
    pages ON posts.User = pages.ID
    INNER JOIN pagecat ON pages.Categorie = pagecat.ID
WHERE 
    pages.Categorie = cat
GROUP BY 
    pages.ID
ORDER BY 
    pages.Created_at DESC 
LIMIT st,lm$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `catStatic` (IN `uuid` VARCHAR(50))  BEGIN
DECLARE video_id INT;

-- Sélectionner l'ID de la vidéo actuelle
SELECT posts.ID INTO video_id FROM posts WHERE posts.uniid = uuid;
SELECT pc.Nom AS Category, COALESCE(SUM(h.Number), 0) AS hour_count
FROM pagecat pc
LEFT JOIN pages p ON p.Categorie = pc.ID
LEFT JOIN hours h ON p.ID = h.User AND h.Post = video_id
GROUP BY pc.ID;

SELECT pc.Nom AS Category, COALESCE(COUNT(*), 0) AS view_count
FROM pagecat pc
LEFT JOIN pages p ON pc.ID = p.Categorie
LEFT JOIN views v ON p.ID = v.User AND v.Post = video_id
GROUP BY pc.ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `catSubStat` (IN `user` INT)  BEGIN
SELECT COUNT(s.Subscriber) AS SubCount FROM subscribes s WHERE s.User = user;
SELECT 
    pc.Nom AS Category,
    COUNT(s.Subscriber) AS SubscriberCount
FROM 
    pagecat pc
LEFT JOIN 
    pages p ON pc.ID = p.Categorie
LEFT JOIN 
    subscribes s ON p.ID = s.User AND s.User = user
GROUP BY 
    pc.Nom;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `commentaire` (IN `uuid` VARCHAR(50))  SELECT comments.*,pages.PageName,pages.Photo FROM comments,pages WHERE comments.Post = (SELECT posts.ID FROM posts WHERE posts.uniid = uuid ) AND pages.ID=comments.User$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createChannel` (IN `uniid` VARCHAR(500), IN `id` INT(50), IN `page` VARCHAR(50), IN `description` TEXT, IN `photo` VARCHAR(50), IN `category` VARCHAR(50))  BEGIN
INSERT INTO pages(uniid,user_id,PageName,Description,Photo,Categorie) VALUES(uniid,id,page,description,photo,category);
SELECT pages.ID AS pageId,pages.uniid,pages.PageName,pages.Photo,pages.Description,pages.Categorie,users.ID,users.Mail,users.Password,users.Actif,users.Admin FROM pages,users WHERE pages.user_id=users.ID AND pages.uniid=uniid ORDER BY pages.ID DESC LIMIT 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `dashCatStat` ()  BEGIN
SELECT
    DATE_FORMAT(p.Created_at, '%Y-%m') AS MoisCreation,
    c.Nom AS Category,
    COUNT(*) AS NombrePosts
FROM
    posts p
    INNER JOIN categories c ON p.Categorie = c.ID
    CROSS JOIN (SELECT COUNT(*) AS Total FROM posts) AS total_posts
GROUP BY
    MoisCreation,
    Categorie;
    
    SELECT
    DATE_FORMAT(p.Created_at, '%Y-%m') AS MoisCreation,
    c.Nom AS Category,
    COUNT(*) AS NombrePages
FROM
    pages p
    INNER JOIN pagecat c ON p.Categorie = c.ID
    CROSS JOIN (SELECT COUNT(*) AS Total FROM pages) AS total_pages
GROUP BY
    MoisCreation,
    Categorie;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `dashStat` ()  BEGIN
SELECT COUNT(*) AS Users
FROM users
WHERE MONTH(users.Create_at) = MONTH(CURRENT_DATE()) AND YEAR(users.Create_at) = YEAR(CURRENT_DATE());
SELECT DATE_FORMAT(Created_at, '%Y-%m') AS MoisCreation, COUNT(*) AS CountPosts
FROM posts
GROUP BY MoisCreation;
SELECT DATE_FORMAT(users.Create_at, '%Y-%m') AS MoisCreation, COUNT(*) AS CountUsers
FROM users
GROUP BY MoisCreation;
SELECT DATE_FORMAT(pages.Created_at, '%Y-%m') AS MoisCreation, COUNT(*) AS CountPages
FROM pages
GROUP BY MoisCreation;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `displayLastVideo` (IN `uuid` VARCHAR(100))  SELECT 
    v.*,
    ca.Nom AS Cat,
    p.ID AS Channel,
    p.uniid AS Uuid,
    p.PageName,
    p.Photo,
    p.Cover,
    p.Categorie AS Category,
    p.Created_at AS PageCreated,
    c.Nom AS CatPage,
    u.Mail,
    COUNT(DISTINCT vw.ID) AS Views,
    COUNT(DISTINCT l.ID) AS Likes
    
FROM posts v
LEFT JOIN pages p ON v.User = p.ID
LEFT JOIN pagecat c ON p.Categorie = c.ID
LEFT JOIN users u ON p.user_id = u.ID
LEFT JOIN views vw ON v.ID = vw.Post
LEFT JOIN likes l ON v.ID = l.Post
LEFT JOIN categories ca ON ca.ID = v.Categorie
WHERE (p.user_id IS NOT NULL OR p.ID IN (SELECT Subscriber FROM subscribes WHERE User = u.ID))
  AND v.uniid=uuid$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `displayUser` (IN `id` INT)  BEGIN
DECLARE user_id INT;
SELECT pages.user_id INTO user_id FROM pages WHERE pages.ID = id;

SELECT * FROM users,pages WHERE 
pages.ID = id AND users.ID = user_id ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `editChannel` (IN `id` INT(50), IN `pageId` INT(50), IN `page` VARCHAR(50), IN `description` TEXT, IN `photo` VARCHAR(50), IN `category` VARCHAR(50))  BEGIN
UPDATE pages SET pages.PageName=page,pages.Description=description,pages.Photo=photo,pages.Categorie=category
WHERE pages.ID=pageId AND pages.user_id=id;
SELECT pages.ID AS pageId,pages.uniid,pages.PageName,pages.Photo,pages.Description,pages.Categorie,users.ID,users.Mail,users.Password,users.Actif,users.Admin FROM pages,users WHERE pages.user_id=id AND pages.ID=pageId ORDER BY pages.ID DESC LIMIT 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getInfos` (IN `userId` INT(50), IN `pageId` INT(50))  SELECT 
  IFNULL(pages.ID,NULL) AS ID, 
  IFNULL(pages.user_id,NULL) AS User,
  IFNULL(pages.PageName,NULL) AS PageName,
  IFNULL(pages.Description,NULL) AS Description,
  IFNULL(pages.Photo,NULL) AS Photo,
  IFNULL(pages.Categorie,NULL) AS Categorie,
  IFNULL(pages.Created_at,NULL) AS Created_at,
  IFNULL(pages.uniid, NULL) AS Uniid, 
  IFNULL(users.Mail, NULL) AS Mail, 
  IFNULL(users.Admin, NULL) AS Admin, 
  IFNULL(users.Actif, NULL) AS Actif
FROM users,pages 
WHERE users.ID = userId AND pages.ID=pageId$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Hist` (IN `visitor` INT)  BEGIN
	SELECT video.*,visite.Create_at AS View_at FROM video,visite WHERE video.ID = visite.IdFilm AND visite.IdUsers = visitor AND video.Visible=true ORDER BY View_at ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `histories` (IN `visitor` INT, IN `st` INT, IN `lm` INT)  SELECT 
    v.*,
    ca.Nom AS Cat,
    p.ID AS Channel,
    p.uniid AS Uuid,
    p.PageName,
    p.Photo,
    p.Cover,
    p.Categorie AS Category,
    p.Created_at AS PageCreated,
    c.Nom AS CatPage,
    u.Mail,
    u.ID AS UserId,
    COUNT(DISTINCT l.ID) AS Likes,
    COUNT(DISTINCT vw.ID) AS Views,
    h.ID AS Hour,
    h.Created_at DateView
FROM hours h 
LEFT JOIN posts v ON v.ID = h.Post
LEFT JOIN pages p ON p.ID = v.User
LEFT JOIN pagecat c ON c.ID = p.Categorie
LEFT JOIN users u ON u.ID = p.user_id
LEFT JOIN likes l ON l.Post = v.ID
LEFT JOIN views vw ON vw.Post = v.ID
LEFT JOIN categories ca ON ca.ID = v.Categorie
WHERE v.Visible = 1 AND h.User = visitor
GROUP BY h.ID
ORDER BY h.ID DESC
LIMIT st,lm$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `login` (IN `email` VARCHAR(50))  SELECT users.*,pages.ID AS Page, pages.uniid AS uniid, pages.PageName,pages.Photo,pages.Description,pages.Cover,pages.Categorie FROM users,pages WHERE Mail = email AND pages.user_id = users.ID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mostViwed` (IN `user` INT)  SELECT * FROM users WHERE users.ID=user$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `myInfos` (IN `uuid` VARCHAR(50))  SELECT 
    pages.*,
    pc.Nom AS Cat,
    COUNT(posts.ID) AS Posts,
    COUNT(subscribes.Subscriber) AS Abonnes,
    SUM((SELECT COUNT(*) FROM likes WHERE Post = posts.ID)) AS Likes,
    SUM((SELECT COUNT(*) FROM views WHERE Post = posts.ID)) AS Views,
    COALESCE(
        (SELECT SUM(hours.Number) FROM hours WHERE hours.Post IN (SELECT posts.ID FROM posts WHERE posts.User = pages.ID)),
        0
    ) AS Hours
FROM 
    pages
LEFT JOIN 
    posts ON posts.User = pages.ID
LEFT JOIN 
    subscribes ON subscribes.Subscriber = pages.ID
LEFT JOIN 
    pagecat pc ON pc.ID = pages.Categorie
WHERE 
    pages.uniid = uuid
GROUP BY 
    pages.ID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `myPosts` (IN `user` INT, IN `st` INT, IN `lm` INT)  SELECT 
        v.*,
        ca.Nom AS Cat,
        p.ID AS Channel,p.user_id,p.uniid Uuid,p.PageName,p.Photo,p.Cover,p.Categorie AS PageCat,p.Created_at AS PageCreated,
        c.Nom AS CatP,
        u.Mail AS Mail,
        COUNT(DISTINCT vw.ID) AS Views,
        COUNT(DISTINCT l.ID) AS Likes
    FROM posts v
    LEFT JOIN pages p ON v.User = p.ID
    LEFT JOIN pagecat c ON p.Categorie = c.ID
    LEFT JOIN users u ON p.user_id = u.ID
    LEFT JOIN views vw ON v.ID = vw.Post
    LEFT JOIN likes l ON v.ID = l.Post
    LEFT JOIN categories ca ON ca.ID = v.Categorie
    WHERE v.User  = user
    GROUP BY v.ID
    ORDER BY v.Created_at DESC
    LIMIT st,lm$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `myShort` (IN `visitor` INT, IN `st` INT, IN `lm` INT)  SELECT 
    v.*,
    ca.Nom AS Cat,
    p.ID AS Channel,
    p.uniid AS Uuid,
    p.PageName,
    p.Photo,
    p.Cover,
    p.Categorie AS Category,
    p.Created_at AS PageCreated,
    c.Nom AS CatPage,
    u.Mail,
    u.ID AS UserId,
    COUNT(DISTINCT vw.ID) AS Views,
    COUNT(DISTINCT l.ID) AS Likes,
    (
        CASE WHEN (SELECT MAX(w.Created_at) FROM views w WHERE w.Post = v.ID AND w.User = p.user_id AND w.Created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)) IS NOT NULL THEN 5 ELSE 0 END
        + CASE WHEN (SELECT COUNT(*) FROM likes w WHERE w.Post = v.ID AND w.User = p.user_id) > 0 THEN 4 ELSE 0 END
        + CASE WHEN (SELECT MAX(w.Created_at) FROM pages w WHERE w.ID = v.User AND w.user_id = p.user_id AND w.ID IN (SELECT Subscriber FROM subscribes WHERE User = p.user_id)) IS NOT NULL THEN 3 ELSE 0 END
        + CASE WHEN (SELECT MAX(w.Created_at) FROM pages w WHERE w.ID = v.User AND w.user_id <> p.user_id AND w.ID IN (SELECT User FROM likes WHERE User = p.user_id)) IS NOT NULL THEN 2 ELSE 0 END
        + CASE WHEN (SELECT MAX(w.Created_at) FROM pages w WHERE w.ID = v.User AND w.Created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)) IS NOT NULL THEN 1 ELSE 0 END
    ) AS Score
FROM posts v
LEFT JOIN pages p ON v.User = p.ID
LEFT JOIN pagecat c ON p.Categorie = c.ID
LEFT JOIN users u ON p.user_id = u.ID
LEFT JOIN views vw ON v.ID = vw.Post
LEFT JOIN likes l ON v.ID = l.Post
LEFT JOIN categories ca ON ca.ID = v.Categorie
WHERE (p.user_id IS NOT NULL OR p.ID IN (SELECT Subscriber FROM subscribes WHERE User = u.ID))
    AND v.Visible = 1
    AND v.Short = 1
GROUP BY v.ID
ORDER BY 
    CASE WHEN p.user_id = visitor THEN Score ELSE NULL END DESC,
    v.Created_at DESC,
    CASE WHEN p.user_id <> visitor THEN v.Created_at ELSE NULL END DESC
LIMIT st,lm$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `myVideo` (IN `visitor` INT, IN `st` INT, IN `lm` INT)  SELECT 
    v.*,
    ca.Nom AS Cat,
    p.ID AS Channel,
    p.uniid AS Uuid,
    p.PageName,
    p.Photo,
    p.Cover,
    p.Categorie AS Category,
    p.Created_at AS PageCreated,
    c.Nom AS CatPage,
    u.Mail,
    u.ID AS UserId,
    COUNT(DISTINCT vw.ID) AS Views,
    COUNT(DISTINCT l.ID) AS Likes,
    (
        CASE WHEN (SELECT MAX(w.Created_at) FROM views w WHERE w.Post = v.ID AND w.User = p.user_id AND w.Created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)) IS NOT NULL THEN 5 ELSE 0 END
        + CASE WHEN (SELECT COUNT(*) FROM likes w WHERE w.Post = v.ID AND w.User = p.user_id) > 0 THEN 4 ELSE 0 END
        + CASE WHEN (SELECT MAX(w.Created_at) FROM pages w WHERE w.ID = v.User AND w.user_id = p.user_id AND w.ID IN (SELECT Subscriber FROM subscribes WHERE User = p.user_id)) IS NOT NULL THEN 3 ELSE 0 END
        + CASE WHEN (SELECT MAX(w.Created_at) FROM pages w WHERE w.ID = v.User AND w.user_id <> p.user_id AND w.ID IN (SELECT User FROM likes WHERE User = p.user_id)) IS NOT NULL THEN 2 ELSE 0 END
        + CASE WHEN (SELECT MAX(w.Created_at) FROM pages w WHERE w.ID = v.User AND w.Created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)) IS NOT NULL THEN 1 ELSE 0 END
    ) AS Score
FROM posts v
LEFT JOIN pages p ON v.User = p.ID
LEFT JOIN pagecat c ON p.Categorie = c.ID
LEFT JOIN users u ON p.user_id = u.ID
LEFT JOIN views vw ON v.ID = vw.Post
LEFT JOIN likes l ON v.ID = l.Post
LEFT JOIN categories ca ON ca.ID = v.Categorie
WHERE (p.user_id IS NOT NULL OR p.ID IN (SELECT Subscriber FROM subscribes WHERE User = u.ID)) AND v.Visible = 1 AND v.Short = 0
GROUP BY v.ID
ORDER BY 
    CASE WHEN p.user_id = visitor THEN Score ELSE NULL END DESC,
    v.Created_at DESC,
    CASE WHEN p.user_id <> visitor THEN v.Created_at ELSE NULL END DESC LIMIT st,lm$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `myVideos` (IN `uuid` VARCHAR(50), IN `st` INT, IN `lm` INT)  SELECT 
        v.*,
        ca.Nom AS Cat,
        p.ID AS Channel,p.user_id,p.uniid Uuid,p.PageName,p.Photo,p.Cover,p.Categorie AS PageCat,p.Created_at AS PageCreated,
        c.Nom AS CatP,
        u.Mail AS Mail,
        COUNT(DISTINCT vw.ID) AS Views,
        COUNT(DISTINCT l.ID) AS Likes
    FROM posts v
    LEFT JOIN pages p ON v.User = p.ID
    LEFT JOIN pagecat c ON p.Categorie = c.ID
    LEFT JOIN users u ON p.user_id = u.ID
    LEFT JOIN views vw ON v.ID = vw.Post
    LEFT JOIN likes l ON v.ID = l.Post
    LEFT JOIN categories ca ON ca.ID = v.Categorie
    WHERE v.User IN (SELECT posts.User  FROM posts WHERE posts.uniid=uuid) AND v.Short = 0 AND v.Visible=1
    GROUP BY v.ID
    ORDER BY Views DESC
    LIMIT st,lm$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `posts` (IN `user` INT, IN `st` INT, IN `lm` INT)  SELECT 
        v.*,
        ca.Nom AS Cat,
        p.ID AS Channel,p.user_id,p.uniid Uuid,p.PageName,p.Photo,p.Cover,p.Categorie AS PageCat,p.Created_at AS PageCreated,
        c.Nom AS CatP,
        u.Mail AS Mail,
        COUNT(DISTINCT vw.ID) AS Views,
        COUNT(DISTINCT l.ID) AS Likes
    FROM posts v
    LEFT JOIN pages p ON v.User = p.ID
    LEFT JOIN pagecat c ON p.Categorie = c.ID
    LEFT JOIN users u ON p.user_id = u.ID
    LEFT JOIN views vw ON v.ID = vw.Post
    LEFT JOIN likes l ON v.ID = l.Post
    LEFT JOIN categories ca ON ca.ID = v.Categorie
    WHERE v.User  = user AND v.Visible = 1
    GROUP BY v.ID
    ORDER BY v.Created_at DESC
    LIMIT st,lm$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `postStatic` (IN `uuid` VARCHAR(50))  BEGIN
    DECLARE video_id INT;
    
    -- Sélectionner l'ID de la vidéo actuelle
    SELECT v.ID INTO video_id FROM posts v WHERE v.uniid = uuid;
    
    -- Requête principale pour afficher les mois et le nombre de vues
    SELECT
        DATE_FORMAT(v.Created_at, '%m') AS mois,
        YEAR(v.Created_at) AS YearMonth,
        COALESCE(COUNT(*), 0) AS ViewCount,
        COALESCE(
            (SELECT SUM(h.Number)
             FROM hours h
             WHERE h.Post = video_id
               AND EXTRACT(YEAR_MONTH FROM h.Created_at) = EXTRACT(YEAR_MONTH FROM v.Created_at)
             GROUP BY EXTRACT(YEAR_MONTH FROM h.Created_at)),
            0
        ) AS HourCount
    FROM
        views v
    WHERE
        v.Post = video_id
    GROUP BY
        EXTRACT(YEAR_MONTH FROM v.Created_at);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `searches` (IN `search` VARCHAR(255), IN `st` INT, IN `lm` INT)  SELECT 
        v.*,
        ca.Nom AS Cat,
        p.ID AS Channel,
        p.uniid AS Uuid,
        p.PageName,
        p.Photo,
        p.Cover,
        p.Categorie AS Category,
        p.Created_at AS PageCreated,
        c.Nom AS CatPage,
        u.Mail,
        u.ID AS UserId,
        COUNT(DISTINCT vw.ID) AS Views,
        COUNT(DISTINCT l.ID) AS Likes,
        MATCH (v.Title, v.Body) AGAINST (search) AS relevance_score
    FROM posts v
    LEFT JOIN pages p ON v.User = p.ID
    LEFT JOIN pagecat c ON p.Categorie = c.ID
    LEFT JOIN users u ON p.user_id = u.ID
    LEFT JOIN views vw ON v.ID = vw.Post
    LEFT JOIN likes l ON v.ID = l.Post
    LEFT JOIN categories ca ON ca.ID = v.Categorie
    WHERE p.user_id IS NOT NULL OR p.ID IN (SELECT Subscriber FROM subscribes WHERE User = u.ID)
        AND (MATCH (v.Title, v.Body) AGAINST (search) OR v.Title LIKE CONCAT('%', REPLACE(search, ' ', '%'), '%') OR v.Body LIKE CONCAT('%', REPLACE(search, ' ', '%'), '%'))
    GROUP BY v.ID
    ORDER BY relevance_score DESC, COUNT(DISTINCT vw.ID) DESC LIMIT st,lm$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `searchSms` (IN `search` VARCHAR(100))  SELECT  messages.*, pages.uniid, pages.user_id, pages.PageName, pages.Photo,MATCH (messages.Body) AGAINST (search) AS occ FROM pages,messages WHERE pages.ID = messages.User GROUP BY messages.User ORDER BY messages.Create_at DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `searchUser` (IN `search` VARCHAR(100))  SELECT *,MATCH (PageName) AGAINST (search) AS occ FROM pages WHERE MATCH (PageName) AGAINST (search) OR PageName LIKE CONCAT('%', REPLACE(search, ' ', '%'), '%') ORDER BY occ$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `slides` (IN `st` INT, IN `lm` INT)  SELECT 
    v.*,
    ca.Nom AS Cat,
    p.ID AS Channel,
    p.uniid AS Uuid,
    p.PageName,
    p.Photo,
    p.Cover,
    p.Categorie AS Category,
    p.Created_at AS PageCreated,
    c.Nom AS CatPage,
    u.Mail,
    u.ID AS UserId,
    COUNT(DISTINCT l.ID) AS Likes,
    SUM(CASE WHEN vw.Created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 1 ELSE 0 END) AS Views
FROM posts v
LEFT JOIN pages p ON v.User = p.ID
LEFT JOIN pagecat c ON p.Categorie = c.ID
LEFT JOIN users u ON p.user_id = u.ID
LEFT JOIN views vw ON v.ID = vw.Post
LEFT JOIN likes l ON v.ID = l.Post
LEFT JOIN categories ca ON ca.ID = v.Categorie
WHERE p.user_id IS NOT NULL OR p.ID IN (SELECT Subscriber FROM subscribes WHERE User = u.ID)
GROUP BY v.ID
ORDER BY Views DESC
LIMIT st, lm$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sms` (IN `user` VARCHAR(50), IN `st` INT, IN `lm` INT)  BEGIN
DECLARE user_id INT;
SELECT pages.ID INTO user_id FROM pages WHERE pages.uniid = user; 
UPDATE messages SET messages.read_mail = 1 WHERE messages.User = user_id;
SELECT messages.*, pages.user_id, pages.uniid, pages.PageName, pages.Photo FROM messages,pages WHERE messages.User = pages.ID AND pages.ID=user_id ORDER BY messages.Create_at ASC LIMIT st,lm;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateUser` (IN `id` INT, IN `name` VARCHAR(50), IN `mail` VARCHAR(50), IN `password` VARCHAR(100))  BEGIN
DECLARE user_id INT;
SELECT pages.user_id INTO user_id FROM pages WHERE pages.ID = id;
UPDATE pages SET PageName = name WHERE pages.user_id = id;
UPDATE users SET Mail = mail, Password = password WHERE users.ID = user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `userInfos` (IN `uuid` VARCHAR(50))  SELECT 
  IFNULL(pages.ID,NULL) AS ID, 
  IFNULL(pages.user_id,NULL) AS User,
  IFNULL(pages.PageName,NULL) AS PageName,
  IFNULL(pages.Description,NULL) AS Description,
  IFNULL(pages.Photo,NULL) AS Photo,
  IFNULL(pages.Categorie,NULL) AS Categorie,
  IFNULL(pages.Created_at,NULL) AS Created_at,
  IFNULL(pages.uniid, NULL) AS Uniid, 
  IFNULL(users.Mail, NULL) AS Mail, 
  IFNULL(users.Admin, NULL) AS Admin, 
  IFNULL(users.Actif, NULL) AS Actif, 
  IFNULL(pagecat.Nom, NULL) AS PageCat 
FROM users 
LEFT JOIN pages ON users.ID = pages.user_id 
LEFT JOIN pagecat ON pagecat.ID = pages.Categorie 
WHERE users.ID = uuid$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `userStats` (IN `user` INT)  BEGIN
    DECLARE cout_post INT DEFAULT 0;
    DECLARE cout_like INT DEFAULT 0;
    DECLARE cout_view INT DEFAULT 0;

    /* Nombre de posts */
    SELECT COUNT(*) INTO cout_post FROM posts WHERE posts.User = user;
    IF (cout_post <> 0) THEN
        SELECT
            YEAR(posts.Created_at) AS Year,
            MONTH(posts.Created_at) AS Month,
            COUNT(*) AS PostCount
        FROM
            posts
        WHERE
            posts.User = user
        GROUP BY
            YEAR(posts.Created_at),
            MONTH(posts.Created_at)
        ORDER BY
            Year,
            Month;
    ELSE
        SELECT YEAR(CURDATE()) AS Year, MONTH(CURDATE()) AS Month, 0 AS PostCount;
    END IF;

    /* Nombre de likes */
    SELECT COUNT(*) INTO cout_like FROM likes, posts WHERE posts.ID = likes.Post AND posts.User = user;
    IF (cout_like <> 0) THEN
        SELECT
            YEAR(likes.Created_at) AS Year,
            MONTH(likes.Created_at) AS Month,
            COUNT(*) AS LikeCount
        FROM
            likes
        INNER JOIN
            posts ON likes.Post = posts.ID
        WHERE
            posts.User = user
        GROUP BY
            YEAR(likes.Created_at),
            MONTH(likes.Created_at)
        ORDER BY
            Year,
            Month;
    ELSE
        SELECT YEAR(CURDATE()) AS Year, MONTH(CURDATE()) AS Month, 0 AS LikeCount;
    END IF;

    /* Nombre de vues */
    SELECT COUNT(*) INTO cout_view FROM views,posts WHERE posts.ID = views.Post AND posts.User = user;
    IF (cout_view <> 0) THEN
        SELECT
            YEAR(views.Created_at) AS Year,
            MONTH(views.Created_at) AS Month,
            COUNT(*) AS ViewCount
        FROM
            views
        INNER JOIN
            posts ON views.Post = posts.ID
        WHERE
            posts.User = user
        GROUP BY
            YEAR(views.Created_at),
            MONTH(views.Created_at)
        ORDER BY
            Year,
            Month;
    ELSE
        SELECT YEAR(CURDATE()) AS Year, MONTH(CURDATE()) AS Month, 0 AS ViewCount;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `video` (IN `st` INT, IN `lm` INT)  SELECT 
        v.*,
        ca.Nom AS Cat,
        p.ID AS Channel,p.user_id,p.uniid Uuid,p.PageName,p.Photo,p.Cover,p.Categorie AS PageCat,p.Created_at AS PageCreated,
        c.Nom AS CatP,
        u.Mail AS Mail,
        COUNT(DISTINCT vw.ID) AS Views,
        COUNT(DISTINCT l.ID) AS Likes
    FROM posts v
    LEFT JOIN pages p ON v.User = p.ID
    LEFT JOIN pagecat c ON p.Categorie = c.ID
    LEFT JOIN users u ON p.user_id = u.ID
    LEFT JOIN views vw ON v.ID = vw.Post
    LEFT JOIN likes l ON v.ID = l.Post
    LEFT JOIN categories ca ON ca.ID = v.Categorie
    GROUP BY v.ID
    ORDER BY v.Created_at DESC
    LIMIT st,lm$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `videos` (IN `uuid` VARCHAR(50), IN `st` INT, IN `lm` INT, IN `user` INT)  SELECT 
    v.*,
    ca.Nom AS Cat,
    p.ID AS Channel,
    p.uniid AS Uuid,
    p.PageName,
    p.Photo,
    p.Cover,
    p.Categorie AS Category,
    p.Created_at AS PageCreated,
    c.Nom AS CatPage,
    u.Mail,
    COUNT(DISTINCT vw.ID) AS Views,
    COUNT(DISTINCT l.ID) AS Likes,
    (
        CASE WHEN (SELECT MAX(w.Created_at) FROM views w WHERE w.Post = v.ID AND w.User = p.user_id AND w.Created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)) IS NOT NULL THEN 5 ELSE 0 END
        + CASE WHEN (SELECT MAX(w.Created_at) FROM pages w WHERE w.ID = v.User AND w.user_id = p.user_id AND w.ID IN (SELECT Subscriber FROM subscribes WHERE User = p.user_id)) IS NOT NULL THEN 4 ELSE 0 END
        + CASE WHEN (SELECT COUNT(*) FROM likes w WHERE w.Post = v.ID AND w.User = p.user_id) > 0 THEN 3 ELSE 0 END
        + CASE WHEN v.Created_at > DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 2 ELSE 0 END
        + CASE WHEN (SELECT MAX(w.Created_at) FROM views w WHERE w.Post = v.ID AND w.User = 2 AND w.Created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)) IS NOT NULL THEN 1 ELSE 0 END
        + CASE WHEN v.Categorie = (SELECT posts.Categorie FROM posts WHERE posts.uniid = uuid) THEN 5.5 ELSE 0 END
    ) AS Score,
    (
        SELECT COUNT(*) 
        FROM views w 
        WHERE w.Post = v.ID 
        AND w.User = user 
        AND w.Created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)
    ) AS RecentViews
FROM posts v
LEFT JOIN pages p ON v.User = p.ID
LEFT JOIN pagecat c ON p.Categorie = c.ID
LEFT JOIN users u ON p.user_id = u.ID
LEFT JOIN views vw ON v.ID = vw.Post
LEFT JOIN likes l ON v.ID = l.Post
LEFT JOIN categories ca ON ca.ID = v.Categorie
WHERE (p.user_id IS NOT NULL OR p.ID IN (SELECT Subscriber FROM subscribes WHERE User = u.ID))
  AND v.uniid <> uuid
  AND v.Short = 0 
  AND v.Visible = 1
GROUP BY v.ID
ORDER BY RecentViews DESC, Score DESC, 
         CASE WHEN v.ID IN (
             SELECT DISTINCT views.Post 
             FROM views 
             WHERE views.User =user
             AND views.Post <> uuid
             AND views.Created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)
         ) THEN 0 ELSE 1 END, 
         CASE WHEN v.ID IN (
             SELECT DISTINCT views.Post 
             FROM views 
             WHERE views.Post = uuid
             AND views.User = user 
             AND views.Created_at > DATE_SUB(NOW(), INTERVAL 7 DAY) 
         ) THEN 0 ELSE 1 END, 
         v.Created_at DESC
         LIMIT st,lm$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `watch` (IN `uuid` VARCHAR(50), IN `state` INT, IN `userId` INT)  BEGIN
    DECLARE video_id INT;
    DECLARE view_count INT;
    DECLARE view_hours INT;
    DECLARE next_video_uuid VARCHAR(255);
    
    -- Sélectionner l'ID de la vidéo actuelle
    SELECT v.ID INTO video_id
    FROM posts v
    LEFT JOIN pages p ON v.User = p.ID
    LEFT JOIN users u ON p.user_id = u.ID
    WHERE (p.user_id IS NOT NULL OR p.ID IN (SELECT Subscriber FROM subscribes WHERE User = u.ID))
        AND v.uniid = uuid;
    
    -- Sélectionner le nombre de vues pour la vidéo actuelle
    SELECT COUNT(*) INTO view_count FROM views WHERE views.Post = video_id AND views.User = userId AND DATE(views.Created_at) = CURDATE();
       -- Sélectionner la durée totale de visionnage de la vidéo actuelle
    SELECT SUM(h.Number) INTO view_hours
    FROM hours h
    WHERE h.Post = video_id;
 
    
    -- Sélectionner la vidéo actuelle et les informations associées, y compris le nombre d'heures de visionnage
    SELECT 
        v.*,
        ca.Nom AS Cat,
        p.ID AS Channel,
        p.uniid AS Uuid,
        p.PageName,
        p.Photo,
        p.Cover,
        p.Categorie AS Category,
        p.Created_at AS PageCreated,
        c.Nom AS CatPage,
        u.Mail,
        u.ID AS UserId,
        COUNT(DISTINCT l.ID) AS Likes,
        COUNT(DISTINCT vw.ID) AS Views,
        view_hours AS Hours,
        (
            SELECT v_next.uniid
            FROM posts v_next
            WHERE v_next.ID <> v.ID
            ORDER BY RAND()
            LIMIT 1
        ) AS NextVideo
    FROM posts v
    LEFT JOIN pages p ON v.User = p.ID
    LEFT JOIN pagecat c ON p.Categorie = c.ID
    LEFT JOIN users u ON p.user_id = u.ID
    LEFT JOIN views vw ON v.ID = vw.Post
    LEFT JOIN likes l ON v.ID = l.Post
    LEFT JOIN categories ca ON ca.ID = v.Categorie
    WHERE v.ID = video_id AND v.Visible = 1
    GROUP BY v.ID;
END$$

--
-- Fonctions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `getPoster` (`video_id` INT) RETURNS INT(11) BEGIN 
	DECLARE result INT;
    SET result = (SELECT posts.User FROM posts WHERE posts.ID = video_id);
    RETURN result;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `verify_comments` (`id_user` INT) RETURNS INT(11) BEGIN 
    DECLARE resultat INT;
    SET resultat = (SELECT comment FROM notification WHERE notification.user = id_user LIMIT 1);
    RETURN resultat;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `verify_likes` (`id_user` INT) RETURNS INT(11) BEGIN 
    DECLARE resultat INT;
    SET resultat = (SELECT likes FROM notification WHERE notification.user = id_user LIMIT 1);
    RETURN resultat;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `verify_messages` (`id_user` INT) RETURNS INT(11) BEGIN 
    DECLARE resultat INT;
    SET resultat = (SELECT message FROM notification WHERE notification.user = id_user LIMIT 1);
    RETURN resultat;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `verify_posts` (`id_user` INT) RETURNS INT(11) BEGIN 
    DECLARE resultat INT;
    SET resultat = (SELECT post FROM notification WHERE notification.user = id_user LIMIT 1);
    RETURN resultat;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `verify_subscribers` (`id_user` INT) RETURNS INT(11) BEGIN 
    DECLARE resultat INT;
    SET resultat = (SELECT subscriber FROM notification WHERE notification.user = id_user LIMIT 1);
    RETURN resultat;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `messages`
--

CREATE TABLE `messages` (
  `ID` int(11) NOT NULL,
  `Nom` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
