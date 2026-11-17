-- =========================================================
--  호텔 잠잠 DB 구조 (테이블만, 데이터 없음)
--  다른 서버에서 이 파일 하나만 실행하면 hotel 데이터베이스와 빈 테이블 9개가 만들어집니다.
--  HeidiSQL : 파일 열기 → 전체 실행(F9)
--  명령줄   : mysql -uroot -p < hotel_schema.sql
--
--  주의 : 같은 이름의 hotel 데이터베이스가 있으면 지우고 새로 만듭니다.
--  샘플 데이터(테스트 계정, 객실, 사진)까지 필요하면 db/hotel.sql 을 실행하세요.
-- =========================================================

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

/*!40000 DROP DATABASE IF EXISTS `hotel`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `hotel` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `hotel`;
DROP TABLE IF EXISTS `coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupon` (
  `couponCode` varchar(30) NOT NULL,
  `couponName` varchar(100) NOT NULL,
  `discountRate` int(11) NOT NULL,
  `startDate` date NOT NULL,
  `endDate` date NOT NULL,
  `issueType` varchar(10) NOT NULL DEFAULT '다운로드',
  PRIMARY KEY (`couponCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `faq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `faq` (
  `faqId` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(20) NOT NULL,
  `question` varchar(200) NOT NULL,
  `answer` text NOT NULL,
  PRIMARY KEY (`faqId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `translation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `translation` (
  `ko` varchar(700) NOT NULL,
  `en` text NOT NULL,
  PRIMARY KEY (`ko`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `member_coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `member_coupon` (
  `mcId` int(11) NOT NULL AUTO_INCREMENT,
  `userId` varchar(50) NOT NULL,
  `couponCode` varchar(30) NOT NULL,
  `couponName` varchar(100) NOT NULL,
  `discountRate` int(11) NOT NULL,
  `startDate` date NOT NULL,
  `endDate` date NOT NULL,
  `used` tinyint(4) NOT NULL DEFAULT 0,
  `usedResId` int(11) NOT NULL DEFAULT 0,
  `issueDate` datetime NOT NULL,
  PRIMARY KEY (`mcId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `member` (
  `userId` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `registerTime` datetime NOT NULL,
  PRIMARY KEY (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `qna`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `qna` (
  `qnaId` int(11) NOT NULL AUTO_INCREMENT,
  `userId` varchar(50) NOT NULL,
  `title` varchar(200) NOT NULL,
  `content` text NOT NULL,
  `answer` text DEFAULT NULL,
  `regDate` datetime NOT NULL,
  `answerDate` datetime DEFAULT NULL,
  PRIMARY KEY (`qnaId`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `reservation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservation` (
  `resId` int(11) NOT NULL AUTO_INCREMENT,
  `userId` varchar(50) NOT NULL,
  `roomId` int(11) NOT NULL,
  `roomType` varchar(50) NOT NULL,
  `roomNo` varchar(10) NOT NULL,
  `roomSize` int(11) NOT NULL DEFAULT 0,
  `checkIn` date NOT NULL,
  `checkOut` date NOT NULL,
  `guests` int(11) NOT NULL,
  `totalPrice` int(11) NOT NULL,
  `couponCode` varchar(30) DEFAULT NULL,
  `payMethod` varchar(20) NOT NULL,
  `payDetail` varchar(100) DEFAULT NULL,
  `requestNote` varchar(500) DEFAULT NULL,
  `status` varchar(10) NOT NULL DEFAULT '예약완료',
  `reviewed` tinyint(4) NOT NULL DEFAULT 0,
  `resDate` datetime NOT NULL,
  PRIMARY KEY (`resId`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `review` (
  `reviewId` int(11) NOT NULL AUTO_INCREMENT,
  `resId` int(11) NOT NULL,
  `userId` varchar(50) NOT NULL,
  `roomId` int(11) NOT NULL,
  `roomType` varchar(50) NOT NULL,
  `rating` int(11) NOT NULL,
  `content` text NOT NULL,
  `regDate` datetime NOT NULL,
  PRIMARY KEY (`reviewId`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `room` (
  `roomId` int(11) NOT NULL AUTO_INCREMENT,
  `roomType` varchar(50) NOT NULL,
  `roomNo` varchar(10) NOT NULL,
  `price` int(11) NOT NULL,
  `discountRate` int(11) NOT NULL DEFAULT 0,
  `capacity` int(11) NOT NULL,
  `baseGuests` int(11) NOT NULL DEFAULT 2,
  `extraPrice` int(11) NOT NULL DEFAULT 0,
  `bedCount` int(11) NOT NULL DEFAULT 1,
  `breakfast` tinyint(4) NOT NULL DEFAULT 0,
  `pet` tinyint(4) NOT NULL DEFAULT 0,
  `viewType` varchar(20) NOT NULL DEFAULT '시티뷰',
  `amenities` varchar(200) NOT NULL DEFAULT '',
  `description` text DEFAULT NULL,
  `photo` longblob DEFAULT NULL,
  `photoType` varchar(50) DEFAULT NULL,
  `avgRating` double NOT NULL DEFAULT 0,
  `reviewCount` int(11) NOT NULL DEFAULT 0,
  `resCount` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`roomId`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

