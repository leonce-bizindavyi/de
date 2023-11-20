-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : lun. 20 nov. 2023 à 15:27
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
-- Base de données : `terama_20819u`
--

DELIMITER $$
--
-- Procédures
--
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

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `categories`
--

CREATE TABLE `categories` (
  `ID` varchar(10) NOT NULL,
  `Nom` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `comments`
--

CREATE TABLE `comments` (
  `ID` int(11) NOT NULL,
  `Post` int(11) NOT NULL,
  `User` int(11) NOT NULL,
  `Body` text NOT NULL,
  `Create_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `genre`
--

CREATE TABLE `genre` (
  `ID` int(11) NOT NULL,
  `Nom` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `hours`
--

CREATE TABLE `hours` (
  `ID` int(11) NOT NULL,
  `Post` int(11) NOT NULL,
  `User` int(11) NOT NULL,
  `Number` float NOT NULL,
  `Created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `likes`
--

CREATE TABLE `likes` (
  `ID` int(11) NOT NULL,
  `Post` int(11) NOT NULL,
  `User` int(11) NOT NULL,
  `Type` varchar(1) NOT NULL,
  `Etat` int(11) NOT NULL,
  `Created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `listenotif`
--

CREATE TABLE `listenotif` (
  `id` int(11) NOT NULL,
  `userid` int(11) NOT NULL,
  `typenotif` varchar(80) NOT NULL,
  `postId` int(11) NOT NULL,
  `reacteduser` int(11) NOT NULL,
  `notOpen` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `messages`
--

CREATE TABLE `messages` (
  `ID` int(11) NOT NULL,
  `Body` text NOT NULL,
  `User` int(11) NOT NULL,
  `Sent` int(11) NOT NULL,
  `read_mail` int(11) NOT NULL DEFAULT 0,
  `Create_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `notification`
--

CREATE TABLE `notification` (
  `id` int(11) NOT NULL,
  `user` int(11) NOT NULL,
  `subscriber` tinyint(4) NOT NULL,
  `message` tinyint(4) NOT NULL,
  `post` tinyint(4) NOT NULL,
  `comment` tinyint(4) NOT NULL,
  `likes` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `pagecat`
--

CREATE TABLE `pagecat` (
  `ID` int(11) NOT NULL,
  `Nom` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `pages`
--

CREATE TABLE `pages` (
  `ID` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `uniid` varchar(255) NOT NULL,
  `PageName` varchar(100) NOT NULL,
  `Description` text NOT NULL,
  `Photo` varchar(100) DEFAULT NULL,
  `Cover` varchar(255) DEFAULT NULL,
  `Categorie` varchar(1) NOT NULL DEFAULT '1',
  `Created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `payments`
--

CREATE TABLE `payments` (
  `ID` int(11) NOT NULL,
  `Nom` varchar(30) NOT NULL,
  `Token` varchar(100) NOT NULL,
  `Link` varchar(255) NOT NULL,
  `Img` varchar(100) NOT NULL,
  `Statepayment` tinyint(4) NOT NULL,
  `Admin` varchar(20) NOT NULL,
  `State_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `posts`
--

CREATE TABLE `posts` (
  `ID` int(11) NOT NULL,
  `uniid` varchar(255) NOT NULL,
  `Title` text NOT NULL,
  `Image` varchar(100) DEFAULT NULL,
  `Video` varchar(100) DEFAULT NULL,
  `Categorie` varchar(10) DEFAULT NULL,
  `Body` text DEFAULT NULL,
  `User` int(11) NOT NULL,
  `Short` tinyint(4) NOT NULL DEFAULT 0,
  `Visible` tinyint(4) NOT NULL DEFAULT 0,
  `Created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `reponses`
--

CREATE TABLE `reponses` (
  `ID` int(11) NOT NULL,
  `Body` text NOT NULL,
  `Comment` int(11) NOT NULL,
  `Create_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `shares`
--

CREATE TABLE `shares` (
  `ID` int(11) NOT NULL,
  `Post` varchar(10) NOT NULL,
  `User` varchar(10) NOT NULL,
  `Created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `subscribes`
--

CREATE TABLE `subscribes` (
  `ID` int(11) NOT NULL,
  `User` int(11) NOT NULL,
  `Subscriber` int(11) NOT NULL,
  `Create_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `system`
--

CREATE TABLE `system` (
  `ID` int(11) NOT NULL,
  `Systemstate` tinyint(4) NOT NULL,
  `Admin` varchar(10) NOT NULL,
  `Systemstate_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `ID` int(11) NOT NULL,
  `Mail` int(11) DEFAULT NULL,
  `Password` int(11) NOT NULL,
  `Actif` int(11) NOT NULL DEFAULT 0,
  `Admin` int(11) NOT NULL,
  `Create_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `activation_date` datetime DEFAULT NULL,
  `RequestToResetPass` datetime DEFAULT NULL,
  `ResetPasswordDate` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `views`
--

CREATE TABLE `views` (
  `ID` int(11) NOT NULL,
  `Post` int(11) NOT NULL,
  `User` int(11) NOT NULL,
  `Created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `visite`
--

CREATE TABLE `visite` (
  `ID` int(11) NOT NULL,
  `IdUsers` int(11) NOT NULL,
  `IdFilm` int(11) NOT NULL,
  `NombreVisite` int(11) NOT NULL,
  `Create_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `update_ut` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `visitors`
--

CREATE TABLE `visitors` (
  `ID` int(11) NOT NULL,
  `ipadd` varchar(10) NOT NULL,
  `macadd` varchar(30) NOT NULL,
  `Timeonsite` int(11) NOT NULL,
  `registred` tinyint(4) NOT NULL,
  `Date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `genre`
--
ALTER TABLE `genre`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `hours`
--
ALTER TABLE `hours`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `likes`
--
ALTER TABLE `likes`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `listenotif`
--
ALTER TABLE `listenotif`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `notification`
--
ALTER TABLE `notification`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `pagecat`
--
ALTER TABLE `pagecat`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `pages`
--
ALTER TABLE `pages`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `user_id` (`user_id`,`Categorie`);

--
-- Index pour la table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `reponses`
--
ALTER TABLE `reponses`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `shares`
--
ALTER TABLE `shares`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `subscribes`
--
ALTER TABLE `subscribes`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `system`
--
ALTER TABLE `system`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `views`
--
ALTER TABLE `views`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `visite`
--
ALTER TABLE `visite`
  ADD PRIMARY KEY (`ID`);

--
-- Index pour la table `visitors`
--
ALTER TABLE `visitors`
  ADD PRIMARY KEY (`ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
