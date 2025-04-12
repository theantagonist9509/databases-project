-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: RailwayDB
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookings` (
  `PNR` int NOT NULL AUTO_INCREMENT,
  `cid` int DEFAULT NULL,
  `rid` int DEFAULT NULL,
  `pid` varchar(40) DEFAULT NULL,
  `seat_class` varchar(40) DEFAULT NULL,
  `seat_number` varchar(4) DEFAULT NULL,
  `time_of_booking` datetime DEFAULT NULL,
  PRIMARY KEY (`PNR`),
  KEY `rid` (`rid`),
  KEY `cid` (`cid`),
  KEY `pid` (`pid`),
  CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`rid`) REFERENCES `routes` (`rid`),
  CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`cid`) REFERENCES `customers` (`cid`),
  CONSTRAINT `bookings_ibfk_3` FOREIGN KEY (`pid`) REFERENCES `payments` (`pid`)
) ENGINE=InnoDB AUTO_INCREMENT=1235 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookings`
--

LOCK TABLES `bookings` WRITE;
/*!40000 ALTER TABLE `bookings` DISABLE KEYS */;
INSERT INTO `bookings` VALUES (123,3,2,'XXXpayment3XXX','first_class','C321','2025-02-25 00:00:00'),(1122,2,1,'XXXpayment2XXX','first_class','B212','2025-02-02 00:00:00');
/*!40000 ALTER TABLE `bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cancelation`
--

DROP TABLE IF EXISTS `cancelation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cancelation` (
  `PNR` int NOT NULL,
  `cid` int DEFAULT NULL,
  `rid` int DEFAULT NULL,
  `pid` varchar(40) DEFAULT NULL,
  `seat_class` varchar(40) DEFAULT NULL,
  `seat_number` varchar(4) DEFAULT NULL,
  `time_of_booking` datetime DEFAULT NULL,
  PRIMARY KEY (`PNR`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cancelation`
--

LOCK TABLES `cancelation` WRITE;
/*!40000 ALTER TABLE `cancelation` DISABLE KEYS */;
INSERT INTO `cancelation` VALUES (1234,1,1,'XXXpayment1XXX','first_class','A123','2025-03-03 00:00:00');
/*!40000 ALTER TABLE `cancelation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `cid` int NOT NULL,
  `name` varchar(40) DEFAULT NULL,
  `consetion_class` varchar(40) DEFAULT NULL,
  `age` int DEFAULT NULL,
  PRIMARY KEY (`cid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Ramesh','General',54),(2,'Somu','General',14),(3,'Grant','General',34);
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `pid` varchar(40) NOT NULL,
  `type` varchar(40) DEFAULT NULL,
  `amount` int DEFAULT NULL,
  PRIMARY KEY (`pid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES ('XXXpayment2XXX','upi',300),('XXXpayment3XXX','upi',400),('XXXpayment4XXX','upi',400);
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `routes`
--

DROP TABLE IF EXISTS `routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `routes` (
  `rid` int NOT NULL,
  `tid` int DEFAULT NULL,
  `origin` varchar(40) DEFAULT NULL,
  `dest` varchar(40) DEFAULT NULL,
  `departure` datetime DEFAULT NULL,
  `arrival` datetime DEFAULT NULL,
  PRIMARY KEY (`rid`),
  KEY `tid` (`tid`),
  CONSTRAINT `routes_ibfk_1` FOREIGN KEY (`tid`) REFERENCES `trains` (`tid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `routes`
--

LOCK TABLES `routes` WRITE;
/*!40000 ALTER TABLE `routes` DISABLE KEYS */;
INSERT INTO `routes` VALUES (1,1,'Delhi','Agra','2025-03-03 11:11:11','2025-03-03 16:11:11'),(2,1,'Agra','Delhi','2025-03-03 17:11:11','2025-03-03 22:11:11'),(3,2,'Delhi','Kolkata','2025-03-03 10:20:20','2025-03-03 20:11:11');
/*!40000 ALTER TABLE `routes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seatsused`
--

DROP TABLE IF EXISTS `seatsused`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seatsused` (
  `rid` int DEFAULT NULL,
  `first_class` int DEFAULT NULL,
  `second_class` int DEFAULT NULL,
  KEY `rid` (`rid`),
  CONSTRAINT `seatsused_ibfk_1` FOREIGN KEY (`rid`) REFERENCES `routes` (`rid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seatsused`
--

LOCK TABLES `seatsused` WRITE;
/*!40000 ALTER TABLE `seatsused` DISABLE KEYS */;
INSERT INTO `seatsused` VALUES (1,2,12);
/*!40000 ALTER TABLE `seatsused` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trains`
--

DROP TABLE IF EXISTS `trains`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trains` (
  `tid` int NOT NULL,
  `first_class` int DEFAULT NULL,
  `second_class` int DEFAULT NULL,
  PRIMARY KEY (`tid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trains`
--

LOCK TABLES `trains` WRITE;
/*!40000 ALTER TABLE `trains` DISABLE KEYS */;
INSERT INTO `trains` VALUES (1,10,100),(2,15,150),(3,2,20);
/*!40000 ALTER TABLE `trains` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `waitlist`
--

DROP TABLE IF EXISTS `waitlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `waitlist` (
  `PNR` int NOT NULL AUTO_INCREMENT,
  `cid` int DEFAULT NULL,
  `rid` int DEFAULT NULL,
  `pid` varchar(40) DEFAULT NULL,
  `seat_class` varchar(40) DEFAULT NULL,
  `time_of_booking` datetime DEFAULT NULL,
  PRIMARY KEY (`PNR`),
  KEY `rid` (`rid`),
  KEY `cid` (`cid`),
  KEY `pid` (`pid`),
  CONSTRAINT `waitlist_ibfk_1` FOREIGN KEY (`rid`) REFERENCES `routes` (`rid`),
  CONSTRAINT `waitlist_ibfk_2` FOREIGN KEY (`cid`) REFERENCES `customers` (`cid`),
  CONSTRAINT `waitlist_ibfk_3` FOREIGN KEY (`pid`) REFERENCES `payments` (`pid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `waitlist`
--

LOCK TABLES `waitlist` WRITE;
/*!40000 ALTER TABLE `waitlist` DISABLE KEYS */;
/*!40000 ALTER TABLE `waitlist` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-12 14:55:21
