CREATE DATABASE AnyQuestion_DB2 CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE AnyQuestion_DB2;



CREATE TABLE `Field` (
  `field_id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(50) NOT NULL
);

CREATE TABLE `DetailField` (
  `detail_field_id` int PRIMARY KEY AUTO_INCREMENT,
  `field_id` int NOT NULL,
  `keywords` varchar(50) NOT NULL
);

CREATE TABLE `Education` (
  `education_id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(255) NOT NULL
);

CREATE TABLE `User` (
  `user_id` varchar(50) PRIMARY KEY NOT NULL,
  `Password` varchar(50) NOT NULL,
  `FullName` varchar(50) NOT NULL,
  `avatar` varchar(500),
  `Address` varchar(50),
  `Email` varchar(50) NOT NULL,
  `money` int DEFAULT 50000
);

CREATE TABLE `Expert` (
  `expert_id` varchar(50) PRIMARY KEY NOT NULL,
  `Password` varchar(50) NOT NULL,
  `FullName` varchar(50) NOT NULL,
  `avatar` varchar(500),
  `AverageStars` varchar(50),
  `education_id` int NOT NULL,
  `detail_field_id` int NOT NULL,
  `Address` varchar(50),
  `Email` varchar(50) NOT NULL,
  `Verified` boolean NOT NULL,
  `money` int DEFAULT 50
);

CREATE TABLE `AccessRights` (
  `right_id` int PRIMARY KEY AUTO_INCREMENT,
  `RightName` varchar(50) NOT NULL,
  `Description` varchar(50)
);

CREATE TABLE `Admin` (
  `admin_id` varchar(50) PRIMARY KEY NOT NULL,
  `Password` varchar(50) NOT NULL,
  `FullName` varchar(50) NOT NULL,
  `right_id` int NOT NULL
);

CREATE TABLE `Question` (
  `question_id` int PRIMARY KEY AUTO_INCREMENT,
  `field_id` int NOT NULL,
  `title` varchar(1000) NOT NULL,
  `image` varchar(1000),
  `detailed_description` varchar(1000) NOT NULL,
  `money` int DEFAULT 0,
  `user_id` varchar(50) NOT NULL
);

CREATE TABLE `Conversation` (
  `conversation_id` int AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `id_user` varchar(50) NOT NULL,
  `id_expert` varchar(50) NOT NULL,
  `starttime` datetime NOT NULL,
  `public` boolean NOT NULL,
  `star` int DEFAULT 5,
  PRIMARY KEY (`conversation_id`, `question_id`)
);

CREATE TABLE `Messages` (
  `messages_id` int PRIMARY KEY AUTO_INCREMENT,
  `conversation_id` int NOT NULL,
  `sender` varchar(50),
  `message` varchar(1000) NOT NULL,
  `typeImage` boolean DEFAULT 0,
  `time` datetime NOT NULL
);

CREATE TABLE `Report` (
  `report_id` int PRIMARY KEY AUTO_INCREMENT,
  `from_id` varchar(50) NOT NULL,
  `conversation_id` int NOT NULL,
  `reason` varchar(50) NOT NULL
);

CREATE TABLE `Request_history_becomes_the_expert` (
  `request_id` int PRIMARY KEY AUTO_INCREMENT,
  `expert_id` varchar(50) NOT NULL
);

CREATE TABLE `Expert_Verification` (
  `expert_verification_id` int PRIMARY KEY AUTO_INCREMENT,
  `request_id` int NOT NULL,
  `from_id` varchar(50) NOT NULL
);

CREATE TABLE `Resolve_Complaints` (
  `resolve_complaint_id` int PRIMARY KEY AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `from_id` varchar(50) NOT NULL
);

CREATE TABLE `EvaluationHistory` (
  `evaluation_history_id` int PRIMARY KEY AUTO_INCREMENT,
  `conversation_id` int NOT NULL,
  `weights` int DEFAULT 1,
  `user_id` varchar(50),
  `rating_level` int DEFAULT 5
);

ALTER TABLE `Messages` ADD FOREIGN KEY (`conversation_id`) REFERENCES `Conversation` (`conversation_id`);

ALTER TABLE `Conversation` ADD FOREIGN KEY (`question_id`) REFERENCES `Question` (`question_id`);

ALTER TABLE `Report` ADD FOREIGN KEY (`conversation_id`) REFERENCES `Conversation` (`conversation_id`);

ALTER TABLE `Report` ADD FOREIGN KEY (`from_id`) REFERENCES `User` (`user_id`);

ALTER TABLE `Report` ADD FOREIGN KEY (`from_id`) REFERENCES `Expert` (`expert_id`);

ALTER TABLE `Question` ADD FOREIGN KEY (`field_id`) REFERENCES `Field` (`field_id`);

ALTER TABLE `Expert` ADD FOREIGN KEY (`education_id`) REFERENCES `Education` (`education_id`);

ALTER TABLE `Expert` ADD FOREIGN KEY (`detail_field_id`) REFERENCES `DetailField` (`detail_field_id`);

ALTER TABLE `DetailField` ADD FOREIGN KEY (`field_id`) REFERENCES `Field` (`field_id`);

ALTER TABLE `Expert_Verification` ADD FOREIGN KEY (`from_id`) REFERENCES `Admin` (`admin_id`);

ALTER TABLE `Expert_Verification` ADD FOREIGN KEY (`request_id`) REFERENCES `Request_history_becomes_the_expert` (`request_id`);

ALTER TABLE `Request_history_becomes_the_expert` ADD FOREIGN KEY (`expert_id`) REFERENCES `Expert` (`expert_id`);

ALTER TABLE `Admin` ADD FOREIGN KEY (`right_id`) REFERENCES `AccessRights` (`right_id`);

ALTER TABLE `Resolve_Complaints` ADD FOREIGN KEY (`report_id`) REFERENCES `Report` (`report_id`);

ALTER TABLE `EvaluationHistory` ADD FOREIGN KEY (`conversation_id`) REFERENCES `Conversation` (`conversation_id`);

ALTER TABLE `EvaluationHistory` ADD FOREIGN KEY (`user_id`) REFERENCES `User` (`user_id`);

ALTER TABLE `Resolve_Complaints` ADD FOREIGN KEY (`from_id`) REFERENCES `Admin` (`admin_id`);

ALTER TABLE `Question` ADD FOREIGN KEY (`user_id`) REFERENCES `User` (`user_id`);





INSERT INTO `Education` (`education_id`, `name`) VALUES (NULL, 'Trung học cơ sở');
INSERT INTO `Education` (`education_id`, `name`) VALUES (NULL, 'Trung học phổ thông');
INSERT INTO `Education` (`education_id`, `name`) VALUES (NULL, 'Trung cấp');
INSERT INTO `Education` (`education_id`, `name`) VALUES (NULL, 'Cao Đẳng');
INSERT INTO `Education` (`education_id`, `name`) VALUES (NULL, 'Kỹ sư');
INSERT INTO `Education` (`education_id`, `name`) VALUES (NULL, 'Cử nhân');
INSERT INTO `Education` (`education_id`, `name`) VALUES (NULL, 'Thạc sĩ');
INSERT INTO `Education` (`education_id`, `name`) VALUES (NULL, 'Tiến sĩ');
INSERT INTO `Education` (`education_id`, `name`) VALUES (NULL, 'Bác sĩ');

INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Toán học');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Vật Lý');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Hóa Học');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Ngữ Văn');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Địa lý');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Công nghệ thông tin');

INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Công nghệ thực phẩm');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Điện tử viễn thông');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Kinh tế');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Thực phẩm');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Thú ý');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Y Đa Khoa');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Pháp luật');

INSERT INTO `DetailField` (`detail_field_id`, `field_id`, `keywords`) VALUES (NULL, '6', 'Lập trình mạng, trí tuệ nhân tạo');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `AverageStars`, `education_id`, `detail_field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan1', '1', 'Phạm Minh Tuấn 1', NULL, NULL, '8', '1', '71 Đồng Kè', 'phamminhtuan1@gmail.com', '1', '50000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `AverageStars`, `education_id`, `detail_field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan2', '1', 'Phạm Minh Tuấn 2', NULL, NULL, '8', '1', '47 Tôn Đức Thắng', 'phamminhtuan2@gmail.com', '1', '100000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `AverageStars`, `education_id`, `detail_field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan3', '1', 'Phạm Minh Tuấn 3', NULL, NULL, '8', '1', '55 Nguyễn Lương Bằng', 'phamminhtuan3@gmail.com', '1', '200000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `AverageStars`, `education_id`, `detail_field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan4', '1', 'Phạm Minh Tuấn 4', NULL, NULL, '8', '1', '78 Điện Biên Phủ', 'phamminhtuan4@gmail.com', '1', '30000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `AverageStars`, `education_id`, `detail_field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan5', '1', 'Phạm Minh Tuấn 5', NULL, NULL, '8', '1', '11 Nguyễn Văn Linh', 'phamminhtuan4@gmail.com', '1', '89000');


INSERT INTO `User` (`user_id`, `Password`, `FullName`, `avatar`, `Address`, `Email`, `money`) VALUES ('duong', '1', 'Trần Văn Dương', NULL, 'Huế', 'tranvanduong2483@gmail.com', '50000');
INSERT INTO `User` (`user_id`, `Password`, `FullName`, `avatar`, `Address`, `Email`, `money`) VALUES ('nhu', '1', 'Nguyễn Thị Khánh Như', NULL, 'Hà Nội', 'khanhnhu@gmail.com', '50000');
INSERT INTO `User` (`user_id`, `Password`, `FullName`, `avatar`, `Address`, `Email`, `money`) VALUES ('cong', '1', 'Nguyễn Hữu Công', NULL, 'Cà Mau', 'haucong@gmail.com', '50000');
INSERT INTO `User` (`user_id`, `Password`, `FullName`, `avatar`, `Address`, `Email`, `money`) VALUES ('anh', '1', 'Cái Thế Đức Anh', NULL, 'Phan Thiết', 'caitheducanh@gmail.com', '50000');
INSERT INTO `User` (`user_id`, `Password`, `FullName`, `avatar`, `Address`, `Email`, `money`) VALUES ('minh', '1', 'Nguyễn Thái Minh', NULL, 'Bắc Kinh', 'nguyenthaiminh@gmail.com', '50000');


INSERT INTO `User` (`user_id`, `Password`, `FullName`, `avatar`, `Address`, `Email`, `money`) VALUES ('duong2', '1', 'Trần Văn Dương 2', NULL, 'Huế', 'tranvanduong2483@gmail.com', '50000');
INSERT INTO `User` (`user_id`, `Password`, `FullName`, `avatar`, `Address`, `Email`, `money`) VALUES ('nhu2', '1', 'Nguyễn Thị Khánh Như 2', NULL, 'Hà Nội', 'khanhnhu@gmail.com', '50000');
INSERT INTO `User` (`user_id`, `Password`, `FullName`, `avatar`, `Address`, `Email`, `money`) VALUES ('cong2', '1', 'Nguyễn Hữu Công 2', NULL, 'Cà Mau', 'haucong@gmail.com', '50000');
INSERT INTO `User` (`user_id`, `Password`, `FullName`, `avatar`, `Address`, `Email`, `money`) VALUES ('anh2', '1', 'Cái Thế Đức Anh 2', NULL, 'Phan Thiết', 'caitheducanh@gmail.com', '50000');
INSERT INTO `User` (`user_id`, `Password`, `FullName`, `avatar`, `Address`, `Email`, `money`) VALUES ('minh2', '1', 'Nguyễn Thái Minh 2', NULL, 'Bắc Kinh', 'nguyenthaiminh@gmail.com', '50000');


