


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
  `RightName` varchar(500) NOT NULL,
  `Description` varchar(500)
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


CREATE TABLE `Bank` (
  `bank_id` int PRIMARY KEY AUTO_INCREMENT,
  `bank_name` varchar(50) NOT NULL
);

CREATE TABLE `PaymentRequest` (
  `request_id` int PRIMARY KEY AUTO_INCREMENT,
  `expert_id` varchar(50) NOT NULL,
  `bank_id` int,
  `money` int,
  `account_number` varchar(50) NOT NULL,
  `account_name` varchar(50) NOT NULL,
    CONSTRAINT FK_PaymentRequest2 FOREIGN KEY (bank_id) REFERENCES Bank(bank_id),
    CONSTRAINT FK_PaymentRequest3 FOREIGN KEY (expert_id) REFERENCES Expert(expert_id)

);

DELIMITER $$
CREATE TRIGGER after_insert_conversation3
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

       update Expert
      SET money = money + cost*0.7
      Where expert_id  = new.id_expert;

      update BXH
      SET
      AverageStars = (AverageStars*conversation_number+new.star)/(conversation_number + 1),
      conversation_number = conversation_number + 1
      Where expert_id  = new.id_expert;

  END$$
DELIMITER ;



DELIMITER $$
CREATE TRIGGER after_update_Conversation
  after update  ON Conversation
  FOR EACH ROW
  BEGIN
      update BXH
      SET

      AverageStars = (AverageStars*conversation_number -old.star + new.star)/conversation_number
      Where expert_id  = new.id_expert;

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
  `bxh_id` int AUTO_INCREMENT,
  `expert_id` varchar(50) NULL,
  `conversation_number` int DEFAULT 0,
  `AverageStars` float(15) DEFAULT 0,
   CONSTRAINT FK_PersonOrde777r FOREIGN KEY (expert_id) REFERENCES Expert(expert_id) ON DELETE CASCADE,
PRIMARY KEY(bxh_id, expert_id)
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






INSERT INTO `Education` (`education_id`, `name`) VALUES (NULL, 'Trung cấp');
INSERT INTO `Education` (`education_id`, `name`) VALUES (NULL, 'Cao Đẳng');
INSERT INTO `Education` (`education_id`, `name`) VALUES (NULL, 'Kỹ sư');
INSERT INTO `Education` (`education_id`, `name`) VALUES (NULL, 'Cử nhân');
INSERT INTO `Education` (`education_id`, `name`) VALUES (NULL, 'Thạc sĩ');
INSERT INTO `Education` (`education_id`, `name`) VALUES (NULL, 'Tiến sĩ');

INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Toán');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Vật lý');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Hóa học');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Ngữ văn');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Lịch sử');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Địa lý');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Sinh học');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Giáo dục công dân');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Anh văn');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Tin học');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Thể dục');
INSERT INTO `Field` (`field_id`, `name`) VALUES (NULL, 'Công nghệ');

INSERT INTO `SecurityQuestion` (`security_question_id`, `content`) VALUES (NULL, 'Món ăn bạn yêu thích nhất?');
INSERT INTO `SecurityQuestion` (`security_question_id`, `content`) VALUES (NULL, 'Thành phố mà bạn muốn sống?');
INSERT INTO `SecurityQuestion` (`security_question_id`, `content`) VALUES (NULL, 'Ba mẹ bạn gặp nhau lần đầu tiên ở đâu?');
INSERT INTO `SecurityQuestion` (`security_question_id`, `content`) VALUES (NULL, 'Bạn thích loại động vật nào?');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan1', '1', 'Phạm Minh Tuấn 1', NULL, '1', '10', '71 Đồng Kè', 'phamminhtuan1@gmail.com', '1', '50000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan11', '1', 'Phạm Minh Tuấn 11', NULL, '1', '10', '71 Đồng Kè', 'phamminhtuan11@gmail.com', '1', '50000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan111', '1', 'Phạm Minh Tuấn 111', NULL, '1', '10', '71 Đồng Kè', 'phamminhtuan11@gmail.com', '1', '50000');


INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan2', '1', 'Phạm Minh Tuấn 2', NULL, '2', '7', '47 Tôn Đức Thắng', 'phamminhtuan2@gmail.com', '1', '100000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan22', '1', 'Phạm Minh Tuấn 2', NULL, '2', '7', '47 Tôn Đức Thắng', 'phamminhtuan2@gmail.com', '1', '100000');
INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan222', '1', 'Phạm Minh Tuấn 2', NULL, '2', '7', '47 Tôn Đức Thắng', 'phamminhtuan2@gmail.com', '1', '100000');



INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan3', '1', 'Phạm Minh Tuấn 3', NULL, '3', '6', '55 Nguyễn Lương Bằng', 'phamminhtuan3@gmail.com', '1', '200000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan33', '1', 'Phạm Minh Tuấn 3', NULL, '3', '6', '55 Nguyễn Lương Bằng', 'phamminhtuan3@gmail.com', '1', '200000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan333', '1', 'Phạm Minh Tuấn 3', NULL, '3', '6', '55 Nguyễn Lương Bằng', 'phamminhtuan3@gmail.com', '1', '200000');



INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan4', '1', 'Phạm Minh Tuấn 4', NULL, '4', '5', '78 Điện Biên Phủ', 'phamminhtuan4@gmail.com', '1', '30000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan44', '1', 'Phạm Minh Tuấn 4', NULL, '4', '5', '78 Điện Biên Phủ', 'phamminhtuan4@gmail.com', '1', '30000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan444', '1', 'Phạm Minh Tuấn 4', NULL, '4', '5', '78 Điện Biên Phủ', 'phamminhtuan4@gmail.com', '1', '30000');


INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan5', '1', 'Phạm Minh Tuấn 5', NULL, '5', '2', '11 Nguyễn Văn Linh', 'phamminhtuan4@gmail.com', '1', '89000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan55', '1', 'Phạm Minh Tuấn 5', NULL, '5', '2', '11 Nguyễn Văn Linh', 'phamminhtuan4@gmail.com', '1', '89000');

INSERT INTO `Expert` (`expert_id`, `Password`, `FullName`, `avatar`, `education_id`, `field_id`, `Address`, `Email`, `Verified`, `money`)
VALUES ('phamminhtuan555', '1', 'Phạm Minh Tuấn 5', NULL, '5', '2', '11 Nguyễn Văn Linh', 'phamminhtuan4@gmail.com', '1', '89000');


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
INSERT INTO `Conversation` (`conversation_id`, `question_id`, `id_user`, `id_expert`, `starttime`, `finishtime`, `public`, `star`) VALUES (NULL, '1', 'duong', 'phamminhtuan1', current_timestamp(), NULL, '1', '5');
INSERT INTO `Messages` (`messages_id`, `conversation_id`, `sender`, `message`, `typeImage`, `time`) VALUES (NULL, '1', 'duong', 'Em chao thay', '0', CURRENT_TIMESTAMP);


INSERT INTO `Question` (`question_id`, `field_id`, `title`, `image`, `detailed_description`, `money`, `user_id`) VALUES (NULL, '6', 'Giải phương trình bậc 2', NULL, 'Biết sơ sơ thôi thầy ạ', '15000', 'anh');
INSERT INTO `Conversation` (`conversation_id`, `question_id`, `id_user`, `id_expert`, `starttime`, `finishtime`, `public`, `star`) VALUES (NULL, '1', 'anh', 'phamminhtuan2', current_timestamp(), NULL, '1', '5');
INSERT INTO `Messages` (`messages_id`, `conversation_id`, `sender`, `message`, `typeImage`, `time`) VALUES (NULL, '1', 'duong', 'Em chao cô', '0', CURRENT_TIMESTAMP);


INSERT INTO `AccessRights` (`right_id`, `RightName`, `Description`) VALUES (NULL, 'Toàn quyền', 'Có mọi quyền về hệ thống');
INSERT INTO `AccessRights` (`right_id`, `RightName`, `Description`) VALUES (NULL, 'Duyệt khiếu nại, duyệt chuyên gia', 'Có quyền về hủy bỏ và chấp nhận chuyên gia, giải quyết khiếu nại');



INSERT INTO `Admin` (`admin_id`, `Password`, `FullName`, `right_id`) VALUES ('admin', '1', 'Võ Đức Hoàng', '1');

INSERT INTO `Admin` (`admin_id`, `Password`, `FullName`, `right_id`) VALUES ('admin2', '1', 'Lê Thị Mỹ Hạnh', '2');

INSERT INTO `Admin` (`admin_id`, `Password`, `FullName`, `right_id`) VALUES ('admin3', '1', 'Đặng Hoài Phương', '2');

INSERT INTO `Admin` (`admin_id`, `Password`, `FullName`, `right_id`) VALUES ('admin4', '1', 'Phạm Minh Tuấn', '2');


INSERT INTO `Report` (`report_id`, `from_id`, `conversation_id`, `reason`) VALUES (NULL, 'duong', '1', 'Chuyên gia trả lời nhảm');
INSERT INTO `Report` (`report_id`, `from_id`, `conversation_id`, `reason`) VALUES (NULL, 'anh', '2', 'Chuyên gia trả lời sai');

INSERT INTO `Bank` (`bank_id`, `bank_name`) VALUES (NULL, 'Dong A Bank');
INSERT INTO `Bank` (`bank_id`, `bank_name`) VALUES (NULL, 'Saccombank');
INSERT INTO `Bank` (`bank_id`, `bank_name`) VALUES (NULL, 'Agribank');
INSERT INTO `Bank` (`bank_id`, `bank_name`) VALUES (NULL, 'Vietin Bank');
INSERT INTO `Bank` (`bank_id`, `bank_name`) VALUES (NULL, 'Nam A Bank');
INSERT INTO `Bank` (`bank_id`, `bank_name`) VALUES (NULL, 'Sai gon Bank');
INSERT INTO `Bank` (`bank_id`, `bank_name`) VALUES (NULL, 'Vietcombank');
INSERT INTO `Bank` (`bank_id`, `bank_name`) VALUES (NULL, 'BIDV Bank');

ALTER TABLE `Admin` ADD `block` INT NOT NULL DEFAULT '0' AFTER `right_id`;
ALTER TABLE `Expert` ADD `block` INT NOT NULL DEFAULT '0' AFTER `money`;
ALTER TABLE `User` ADD `block` INT NOT NULL DEFAULT '0' AFTER `money`;


ALTER TABLE `User` ADD `Code` INT NOT NULL DEFAULT '0' AFTER `block`;
ALTER TABLE `Expert` ADD `Code` INT NOT NULL DEFAULT '0' AFTER `block`;


ALTER TABLE `PaymentRequest` ADD `admin_id` varchar(50) NULL DEFAULT '' AFTER `account_name`;


ALTER TABLE `PaymentRequest` ADD `status` int NOT NULL DEFAULT 0 AFTER `admin_id`;

UPDATE  `User` SET Code = -1, Password=md5(Password);
UPDATE  `Expert` SET Code = -1,Verified=0,Password=md5(Password);


UPDATE  `Admin` SET Password=md5(Password);
