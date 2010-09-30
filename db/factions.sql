# Sequel Pro dump
# Version 2492
# http://code.google.com/p/sequel-pro
#
# Host: 127.0.0.1 (MySQL 5.1.49)
# Database: eve_arena_development
# Generation Time: 2010-09-30 14:24:26 +0200
# ************************************************************

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table factions
# ------------------------------------------------------------

CREATE TABLE `factions` (
  `id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `score` int(11) DEFAULT '0',
  KEY `PRIMARY KEY` (`id`),
  KEY `index_factions_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `factions` WRITE;
/*!40000 ALTER TABLE `factions` DISABLE KEYS */;
INSERT INTO `factions` (`id`,`name`,`score`)
VALUES
	(500001,'Caldari State',0),
	(500002,'Minmatar Republic',0),
	(500003,'Amarr Empire',0),
	(500004,'Gallente Federation',0),
	(500005,'Jove Empire',0),
	(500006,'CONCORD Assembly',0),
	(500007,'Ammatar Mandate',0),
	(500008,'Khanid Kingdom',0),
	(500009,'The Syndicate',0),
	(500010,'Guristas Pirates',0),
	(500011,'Angel Cartel',0),
	(500012,'The Blood Raider Covenant',0),
	(500013,'The InterBus',0),
	(500014,'ORE',0),
	(500015,'Thukker Tribe',0),
	(500016,'The Servant Sisters of EVE',0),
	(500017,'The Society',0),
	(500018,'Mordu\'s Legion Command',0),
	(500019,'Sansha\'s Nation',0),
	(500020,'Serpentis',0);

/*!40000 ALTER TABLE `factions` ENABLE KEYS */;
UNLOCK TABLES;





/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
