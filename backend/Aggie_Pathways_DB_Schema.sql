create database if not exists aggie_pathways;

use aggie_pathways;

CREATE TABLE `Building` (
  `building_id` integer PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(255),
  `address` varchar(255),
  `latitude` decimal(9, 6),
  `longitude` decimal(9, 6)
);

CREATE TABLE `Room` (
  `room_id` integer PRIMARY KEY AUTO_INCREMENT,
  `room_number` integer,
  `building_id` integer,
  `floor_id` integer,
  `room_type` varchar(255),
  `capacity` integer
);

CREATE TABLE `Floor` (
  `floor_id` int PRIMARY KEY AUTO_INCREMENT,
  `building_id` int,
  `floor_number` int
);

CREATE TABLE `Point_of_Interest` (
  `point_of_interest_id` integer PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(255),
  `building_id` int NULL,
  `latitude` decimal(9,6),
  `longitude` decimal(9,6),
  `category` varchar(255),
  `description` text
);

CREATE TABLE `entrance_exit` (
  `entrance_exit_id` int PRIMARY KEY AUTO_INCREMENT,
  `building_id` int,
  `name` varchar(255),
  `latitude` decimal(9,6),
  `longitude` decimal(9,6),
  `accessible` boolean
);

ALTER TABLE `Room` ADD FOREIGN KEY (`building_id`) REFERENCES `Building` (`building_id`);

ALTER TABLE `Room` ADD FOREIGN KEY (`floor_id`) REFERENCES `Floor` (`floor_id`);

ALTER TABLE `Floor` ADD FOREIGN KEY (`building_id`) REFERENCES `Building` (`building_id`);

ALTER TABLE `Point_of_Interest` ADD FOREIGN KEY (`building_id`) REFERENCES `Building` (`building_id`);

ALTER TABLE `entrance_exit` ADD FOREIGN KEY (`building_id`) REFERENCES `Building` (`building_id`);
