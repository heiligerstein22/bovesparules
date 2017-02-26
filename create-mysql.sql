-- MySQL dump 10.14  Distrib 5.5.52-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: acoes
-- ------------------------------------------------------
-- Server version	5.5.52-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `stockscreaner`
--

DROP TABLE IF EXISTS `stockscreaner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stockscreaner` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stock_name` varchar(20) NOT NULL,
  `check_date` date NOT NULL,
  `reasons` varchar(200) NOT NULL,
  `price` float NOT NULL,
  `is_rsi_d` int(1) NOT NULL,
  `is_rel_vol_d` int(1) NOT NULL,
  `is_bbands_d` int(1) NOT NULL,
  `is_hullnear_d` int(1) NOT NULL,
  `is_hullcross_d` int(1) NOT NULL,
  `is_up_w` int(1) NOT NULL,
  `is_up_m` int(1) NOT NULL,
  `num_reasons` int(11) NOT NULL,
  `rsi_prev3` float NOT NULL,
  `rsi_prev2` float NOT NULL,
  `rsi_prev1` float NOT NULL,
  `rsi` float NOT NULL,
  `bbands_prev3` float NOT NULL,
  `bbands_prev2` float NOT NULL,
  `bbands_prev1` float NOT NULL,
  `bbands` float NOT NULL,
  `relative_volume` int(11) NOT NULL,
  `volume` int(11) NOT NULL,
  `gain` float NOT NULL,
  `created` datetime DEFAULT NULL,
  `updated` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uc_stock_checkdate` (`stock_name`,`check_date`)
) ENGINE=InnoDB AUTO_INCREMENT=4962 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-02-26 10:45:48
