CREATE DATABASE AnyQuestion_DBmm CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE AnyQuestion_DBmm;

CREATE TABLE `AnyQuestionCard` (
  `card_id` int PRIMARY KEY AUTO_INCREMENT,
  `serial` varchar(10)  NULL,
  `card_code` varchar(10) NULL,
  `value` int not null,
  `date_created` date null,
  `expiry_date` date null
);


CREATE TRIGGER before_insert_AnyQuestionCard
  before  INSERT ON AnyQuestionCard
  FOR EACH ROW
  SET new.date_created = CURDATE(),
  new.expiry_date = DATE_ADD(CURDATE(), INTERVAL 5 YEAR),
  new.serial = LEFT(MD5(CONCAT(NOW(), rand())),10),
  new.card_code = FLOOR(RAND()*(9999999999-1111111111+1)+1111111111);




CREATE TABLE `Field` (
  `field_id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(50) NOT NULL
);

CREATE TABLE `Introduction` (
  `introduction_id` int PRIMARY KEY AUTO_INCREMENT,
  `expert_id` varchar(50) NOT NULL,
  `keywords` varchar(1000) NOT NULL,
  `introduction_message` varchar(1000) NOT NULL
);

CREATE TABLE `SecurityQuestion` (
  `security_question_id` int PRIMARY KEY AUTO_INCREMENT,
  `content` varchar(1000) NOT NULL
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


CREATE TABLE `CardUsageHistory` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `card_id` int Not null,
  `time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT FK_CardUsageHistoryID FOREIGN KEY (user_id) REFERENCES User(user_id),
  CONSTRAINT FK_CardUsageHistoryCardID FOREIGN KEY (card_id) REFERENCES AnyQuestionCard(card_id)
);


DELIMITER $$
CREATE TRIGGER after_insert_CardUsageHistory
  after INSERT ON CardUsageHistory
  FOR EACH ROW
  BEGIN

      DECLARE add_money INT DEFAULT 0;

      SELECT value INTO add_money
      FROM AnyQuestionCard
      where card_id = new.card_id;

      update User
      SET money = money +add_money
      Where user_id  = new.user_id;

  END$$
DELIMITER ;





CREATE TABLE `Expert` (
  `expert_id` varchar(50) PRIMARY KEY NOT NULL,
  `Password` varchar(50) NOT NULL,
  `FullName` varchar(50) NOT NULL,
  `avatar` varchar(500),
  `education_id` int NOT NULL,
  `field_id` int NOT NULL,
  `Address` varchar(50),
  `Email` varchar(50) NOT NULL,
  `Verified` boolean DEFAULT 0,
  `money` int DEFAULT 50
);

CREATE TABLE `Security` (
  `security_id` int PRIMARY KEY AUTO_INCREMENT,
  `expert_id` varchar(50) NULL,
  `user_id` varchar(50) NULL,
  `security_question_id` int,
  `answer` varchar(1000) NOT NULL,
   CONSTRAINT FK_PersonOrder FOREIGN KEY (expert_id) REFERENCES Expert(expert_id),
   CONSTRAINT FK_PersonOrder2 FOREIGN KEY (user_id) REFERENCES User(user_id)
);


ALTER TABLE `Security` ADD FOREIGN KEY (`security_question_id`) REFERENCES `SecurityQuestion` (`security_question_id`);



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
  `starttime` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `finishtime` TIMESTAMP NULL,
  `public` boolean NOT NULL,
  `star` float DEFAULT 5,
  PRIMARY KEY (`conversation_id`, `question_id`)
);


DELIMITER $$
CREATE TRIGGER after_insert_Conversation
  after INSERT ON Conversation
  FOR EACH ROW
  BEGIN

      DECLARE cost INT DEFAULT 0;

      SELECT money INTO cost
      FROM Question
      where question_id = new.question_id;

      update User
      SET money = money - cost
      Where user_id  = new.id_user;

  END$$
DELIMITER ;


CREATE TABLE `Messages` (
  `messages_id` int PRIMARY KEY AUTO_INCREMENT,
  `conversation_id` int NOT NULL,
  `sender` varchar(50),
  `message` varchar(1000) NOT NULL,
  `typeImage` boolean DEFAULT 0,
  `time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);




DELIMITER $$
CREATE TRIGGER after_insert_Messages
  after INSERT ON Messages
  FOR EACH ROW
  BEGIN
      update Conversation
      SET finishtime = CURRENT_TIMESTAMP()
      Where conversation_id  = new.conversation_id;

  END$$
DELIMITER ;


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

ALTER TABLE `Expert` ADD FOREIGN KEY (`field_id`) REFERENCES `Field` (`field_id`);

ALTER TABLE `Introduction` ADD FOREIGN KEY (`expert_id`) REFERENCES `Expert` (`expert_id`);

ALTER TABLE `Expert_Verification` ADD FOREIGN KEY (`from_id`) REFERENCES `Admin` (`admin_id`);

ALTER TABLE `Expert_Verification` ADD FOREIGN KEY (`request_id`) REFERENCES `Request_history_becomes_the_expert` (`request_id`);

ALTER TABLE `Request_history_becomes_the_expert` ADD FOREIGN KEY (`expert_id`) REFERENCES `Expert` (`expert_id`);

ALTER TABLE `Admin` ADD FOREIGN KEY (`right_id`) REFERENCES `AccessRights` (`right_id`);

ALTER TABLE `Resolve_Complaints` ADD FOREIGN KEY (`report_id`) REFERENCES `Report` (`report_id`);

ALTER TABLE `EvaluationHistory` ADD FOREIGN KEY (`conversation_id`) REFERENCES `Conversation` (`conversation_id`);

ALTER TABLE `EvaluationHistory` ADD FOREIGN KEY (`user_id`) REFERENCES `User` (`user_id`);

ALTER TABLE `Resolve_Complaints` ADD FOREIGN KEY (`from_id`) REFERENCES `Admin` (`admin_id`);

ALTER TABLE `Question` ADD FOREIGN KEY (`user_id`) REFERENCES `User` (`user_id`);




CREATE TABLE `BXH` (
  `bxh_id` int PRIMARY KEY AUTO_INCREMENT,
  `expert_id` varchar(50) NULL,
  `conversation_number` int DEFAULT 0,
  `AverageStars` float DEFAULT 0,
   CONSTRAINT FK_PersonOrde777r FOREIGN KEY (expert_id) REFERENCES Expert(expert_id)
);


DELIMITER $$
	create trigger thembanxephang after insert on Expert  FOR each row
	BEGIN
	    insert into BXH (expert_id) values (new.expert_id);
       	insert into Introduction (expert_id, keywords, introduction_message) values (new.expert_id,'','Xin chào tôi là chuyên gia của bạn');

	END$$
DELIMITER ;





INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);


INSERT INTO AnyQuestionCard (value) VALUES (20000);
INSERT INTO AnyQuestionCard (value) VALUES (20000);
INSERT INTO AnyQuestionCard (value) VALUES (20000);
INSERT INTO AnyQuestionCard (value) VALUES (20000);
INSERT INTO AnyQuestionCard (value) VALUES (20000);
INSERT INTO AnyQuestionCard (value) VALUES (20000);
INSERT INTO AnyQuestionCard (value) VALUES (20000);
INSERT INTO AnyQuestionCard (value) VALUES (20000);



INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);

INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);

INSERT INTO AnyQuestionCard (value) VALUES (200000);
INSERT INTO AnyQuestionCard (value) VALUES (200000);
INSERT INTO AnyQuestionCard (value) VALUES (200000);
INSERT INTO AnyQuestionCard (value) VALUES (200000);
INSERT INTO AnyQuestionCard (value) VALUES (200000);
INSERT INTO AnyQuestionCard (value) VALUES (200000);
INSERT INTO AnyQuestionCard (value) VALUES (200000);
INSERT INTO AnyQuestionCard (value) VALUES (200000);

INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);






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

INSERT INTO `SecurityQuestion` (`security_question_id`, `content`) VALUES (NULL, 'Món ăn bạn yêu thích nhất?');
INSERT INTO `SecurityQuestion` (`security_question_id`, `content`) VALUES (NULL, 'Thành phố mà bạn muốn sống?');
INSERT INTO `SecurityQuestion` (`security_question_id`, `content`) VALUES (NULL, 'Ba mẹ bạn gặp nhau lần đầu tiên ở đâu?');
INSERT INTO `SecurityQuestion` (`security_question_id`, `content`) VALUES (NULL, 'Bạn thích loại động vật nào?');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan1', '1', 'Phạm Minh Tuấn 1', NULL, '8', '1', '71 Đồng Kè', 'phamminhtuan1@gmail.com', '1', '50000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan2', '1', 'Phạm Minh Tuấn 2', NULL, '8', '1', '47 Tôn Đức Thắng', 'phamminhtuan2@gmail.com', '1', '100000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan3', '1', 'Phạm Minh Tuấn 3', NULL, '8', '1', '55 Nguyễn Lương Bằng', 'phamminhtuan3@gmail.com', '1', '200000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan4', '1', 'Phạm Minh Tuấn 4', NULL, '8', '1', '78 Điện Biên Phủ', 'phamminhtuan4@gmail.com', '1', '30000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan5', '1', 'Phạm Minh Tuấn 5', NULL, '8', '1', '11 Nguyễn Văn Linh', 'phamminhtuan4@gmail.com', '1', '89000');

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


INSERT INTO `Question` (`question_id`, `field_id`, `title`, `image`, `detailed_description`, `money`, `user_id`) VALUES (NULL, '6', 'Không hiểu về địa chỉ IPv6', NULL, 'Biết sơ sơ thôi thầy ạ', '15000', 'duong');
INSERT INTO `Conversation` (`conversation_id`, `question_id`, `id_user`, `id_expert`, `starttime`, `finishtime`, `public`, `star`) VALUES (NULL, '1', 'duong', 'phamminhtuan', current_timestamp(), NULL, '1', '5');





CREATE DATABASE AnyQuestion_DBmm CHARACTER SET utf8 COLLATE utf8_unicode_ci;

USE AnyQuestion_DBmm;

CREATE TABLE `AnyQuestionCard` (
  `card_id` int PRIMARY KEY AUTO_INCREMENT,
  `serial` varchar(10)  NULL,
  `card_code` varchar(10) NULL,
  `value` int not null,
  `date_created` date null,
  `expiry_date` date null
);


CREATE TRIGGER before_insert_AnyQuestionCard
  before  INSERT ON AnyQuestionCard
  FOR EACH ROW
  SET new.date_created = CURDATE(),
  new.expiry_date = DATE_ADD(CURDATE(), INTERVAL 5 YEAR),
  new.serial = LEFT(MD5(CONCAT(NOW(), rand())),10),
  new.card_code = FLOOR(RAND()*(9999999999-1111111111+1)+1111111111);




CREATE TABLE `Field` (
  `field_id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(50) NOT NULL
);

CREATE TABLE `Introduction` (
  `introduction_id` int PRIMARY KEY AUTO_INCREMENT,
  `expert_id` varchar(50) NOT NULL,
  `keywords` varchar(1000) NOT NULL,
  `introduction_message` varchar(1000) NOT NULL
);

CREATE TABLE `SecurityQuestion` (
  `security_question_id` int PRIMARY KEY AUTO_INCREMENT,
  `content` varchar(1000) NOT NULL
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


CREATE TABLE `CardUsageHistory` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `card_id` int Not null,
  `time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT FK_CardUsageHistoryID FOREIGN KEY (user_id) REFERENCES User(user_id),
  CONSTRAINT FK_CardUsageHistoryCardID FOREIGN KEY (card_id) REFERENCES AnyQuestionCard(card_id)
);


DELIMITER $$
CREATE TRIGGER after_insert_CardUsageHistory
  after INSERT ON CardUsageHistory
  FOR EACH ROW
  BEGIN

      DECLARE add_money INT DEFAULT 0;

      SELECT value INTO add_money
      FROM AnyQuestionCard
      where card_id = new.card_id;

      update User
      SET money = money +add_money
      Where user_id  = new.user_id;

  END$$
DELIMITER ;





CREATE TABLE `Expert` (
  `expert_id` varchar(50) PRIMARY KEY NOT NULL,
  `Password` varchar(50) NOT NULL,
  `FullName` varchar(50) NOT NULL,
  `avatar` varchar(500),
  `education_id` int NOT NULL,
  `field_id` int NOT NULL,
  `Address` varchar(50),
  `Email` varchar(50) NOT NULL,
  `Verified` boolean DEFAULT 0,
  `money` int DEFAULT 50
);

CREATE TABLE `Security` (
  `security_id` int PRIMARY KEY AUTO_INCREMENT,
  `expert_id` varchar(50) NULL,
  `user_id` varchar(50) NULL,
  `security_question_id` int,
  `answer` varchar(1000) NOT NULL,
   CONSTRAINT FK_PersonOrder FOREIGN KEY (expert_id) REFERENCES Expert(expert_id),
   CONSTRAINT FK_PersonOrder2 FOREIGN KEY (user_id) REFERENCES User(user_id)
);


ALTER TABLE `Security` ADD FOREIGN KEY (`security_question_id`) REFERENCES `SecurityQuestion` (`security_question_id`);



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
  `starttime` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `finishtime` TIMESTAMP NULL,
  `public` boolean NOT NULL,
  `star` float DEFAULT 5,
  PRIMARY KEY (`conversation_id`, `question_id`)
);


DELIMITER $$
CREATE TRIGGER after_insert_Conversation
  after INSERT ON Conversation
  FOR EACH ROW
  BEGIN

      DECLARE cost INT DEFAULT 0;

      SELECT money INTO cost
      FROM Question
      where question_id = new.question_id;

      update User
      SET money = money - cost
      Where user_id  = new.id_user;

  END$$
DELIMITER ;


CREATE TABLE `Messages` (
  `messages_id` int PRIMARY KEY AUTO_INCREMENT,
  `conversation_id` int NOT NULL,
  `sender` varchar(50),
  `message` varchar(1000) NOT NULL,
  `typeImage` boolean DEFAULT 0,
  `time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


DELIMITER $$
CREATE TRIGGER after_insert_Messages
  after INSERT ON Messages
  FOR EACH ROW
  BEGIN
      update Conversation
      SET finishtime = CURRENT_TIMESTAMP()
      Where conversation_id  = new.conversation_id;

  END$$
DELIMITER ;


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

ALTER TABLE `Expert` ADD FOREIGN KEY (`field_id`) REFERENCES `Field` (`field_id`);

ALTER TABLE `Introduction` ADD FOREIGN KEY (`expert_id`) REFERENCES `Expert` (`expert_id`);

ALTER TABLE `Expert_Verification` ADD FOREIGN KEY (`from_id`) REFERENCES `Admin` (`admin_id`);

ALTER TABLE `Expert_Verification` ADD FOREIGN KEY (`request_id`) REFERENCES `Request_history_becomes_the_expert` (`request_id`);

ALTER TABLE `Request_history_becomes_the_expert` ADD FOREIGN KEY (`expert_id`) REFERENCES `Expert` (`expert_id`);

ALTER TABLE `Admin` ADD FOREIGN KEY (`right_id`) REFERENCES `AccessRights` (`right_id`);

ALTER TABLE `Resolve_Complaints` ADD FOREIGN KEY (`report_id`) REFERENCES `Report` (`report_id`);

ALTER TABLE `EvaluationHistory` ADD FOREIGN KEY (`conversation_id`) REFERENCES `Conversation` (`conversation_id`);

ALTER TABLE `EvaluationHistory` ADD FOREIGN KEY (`user_id`) REFERENCES `User` (`user_id`);

ALTER TABLE `Resolve_Complaints` ADD FOREIGN KEY (`from_id`) REFERENCES `Admin` (`admin_id`);

ALTER TABLE `Question` ADD FOREIGN KEY (`user_id`) REFERENCES `User` (`user_id`);




CREATE TABLE `BXH` (
  `bxh_id` int PRIMARY KEY AUTO_INCREMENT,
  `expert_id` varchar(50) NULL,
  `conversation_number` int DEFAULT 0,
  `AverageStars` float DEFAULT 0,
   CONSTRAINT FK_PersonOrde777r FOREIGN KEY (expert_id) REFERENCES Expert(expert_id)
);


DELIMITER $$
	create trigger thembanxephang after insert on Expert  FOR each row
	BEGIN
	    insert into BXH (expert_id) values (new.expert_id);
       	insert into Introduction (expert_id, keywords, introduction_message) values (new.expert_id,'','Xin chào tôi là chuyên gia của bạn');

	END$$
DELIMITER ;





INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);
INSERT INTO AnyQuestionCard (value) VALUES (10000);


INSERT INTO AnyQuestionCard (value) VALUES (20000);
INSERT INTO AnyQuestionCard (value) VALUES (20000);
INSERT INTO AnyQuestionCard (value) VALUES (20000);
INSERT INTO AnyQuestionCard (value) VALUES (20000);
INSERT INTO AnyQuestionCard (value) VALUES (20000);
INSERT INTO AnyQuestionCard (value) VALUES (20000);
INSERT INTO AnyQuestionCard (value) VALUES (20000);
INSERT INTO AnyQuestionCard (value) VALUES (20000);



INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);
INSERT INTO AnyQuestionCard (value) VALUES (50000);

INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);
INSERT INTO AnyQuestionCard (value) VALUES (100000);

INSERT INTO AnyQuestionCard (value) VALUES (200000);
INSERT INTO AnyQuestionCard (value) VALUES (200000);
INSERT INTO AnyQuestionCard (value) VALUES (200000);
INSERT INTO AnyQuestionCard (value) VALUES (200000);
INSERT INTO AnyQuestionCard (value) VALUES (200000);
INSERT INTO AnyQuestionCard (value) VALUES (200000);
INSERT INTO AnyQuestionCard (value) VALUES (200000);
INSERT INTO AnyQuestionCard (value) VALUES (200000);

INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);
INSERT INTO AnyQuestionCard (value) VALUES (500000);






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

INSERT INTO `SecurityQuestion` (`security_question_id`, `content`) VALUES (NULL, 'Món ăn bạn yêu thích nhất?');
INSERT INTO `SecurityQuestion` (`security_question_id`, `content`) VALUES (NULL, 'Thành phố mà bạn muốn sống?');
INSERT INTO `SecurityQuestion` (`security_question_id`, `content`) VALUES (NULL, 'Ba mẹ bạn gặp nhau lần đầu tiên ở đâu?');
INSERT INTO `SecurityQuestion` (`security_question_id`, `content`) VALUES (NULL, 'Bạn thích loại động vật nào?');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan1', '1', 'Phạm Minh Tuấn 1', NULL, '8', '1', '71 Đồng Kè', 'phamminhtuan1@gmail.com', '1', '50000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan2', '1', 'Phạm Minh Tuấn 2', NULL, '8', '1', '47 Tôn Đức Thắng', 'phamminhtuan2@gmail.com', '1', '100000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan3', '1', 'Phạm Minh Tuấn 3', NULL, '8', '1', '55 Nguyễn Lương Bằng', 'phamminhtuan3@gmail.com', '1', '200000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan4', '1', 'Phạm Minh Tuấn 4', NULL, '8', '1', '78 Điện Biên Phủ', 'phamminhtuan4@gmail.com', '1', '30000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan5', '1', 'Phạm Minh Tuấn 5', NULL, '8', '1', '11 Nguyễn Văn Linh', 'phamminhtuan4@gmail.com', '1', '89000');

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


INSERT INTO `Question` (`question_id`, `field_id`, `title`, `image`, `detailed_description`, `money`, `user_id`) VALUES (NULL, '6', 'Không hiểu về địa chỉ IPv6', NULL, 'Biết sơ sơ thôi thầy ạ', '15000', 'duong');
INSERT INTO `Conversation` (`conversation_id`, `question_id`, `id_user`, `id_expert`, `starttime`, `finishtime`, `public`, `star`) VALUES (NULL, '1', 'duong', 'phamminhtuan', current_timestamp(), NULL, '1', '5');
INSERT INTO `Messages` (`messages_id`, `conversation_id`, `sender`, `message`, `typeImage`, `time`) VALUES (NULL, '1', 'duong', 'Em chao thay', '0', CURRENT_TIMESTAMP);




