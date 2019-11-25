express = require("express");
app = express();
server = require("http").createServer(app);
io = require("socket.io").listen(server);
mysql = require('mysql');
fs = require("fs");


path = require('path');



app.set('port', process.env.PORT || 26398); //<--- replace with your port number

// Server
server.listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});

module.exports = app;

con = mysql.createConnection({
  host: "remotemysql.com",
  port: 3306,
  user: "Hme0LP2Gb1",
  password: "AJnZfe3CLb",
  database: "Hme0LP2Gb1"
});


con.connect(function (err) {
  if (err) throw err;
  console.log("MySQL ready!");
});


list_expert_ready = [];
list_login = [];



function  remove_list_login(Username) {
  let pos = -1;
  for (let i = 0; i < list_login.length; i++) {
    if (list_login[i].account === Username) {
      pos = i;
      break;
    }
  }

  if (pos === -1) return null;
  list_login.splice(pos, 1);
}

function getIDconnectionfromUsername(Username) {
  for (let i = 0; i < list_login.length; i++) {
    if (list_login[i].account === Username)
      return list_login[i].id;
  }
  return null;
}

function TurnReady(socket, ready) {
  let pos = -1;
  for (let i = 0; i < list_expert_ready.length; i++) {
    if (list_expert_ready[i].account === socket.account) {
      pos = i;
      break;
    }
  }

  if (ready === false && pos !== -1)
    list_expert_ready.splice(pos, 1);
  else if (ready === true) {
    if (pos !== -1)
      list_expert_ready.splice(pos, 1);
    list_expert_ready.push(socket);
  }

  let show = [];
  for (let i = 0; i < list_expert_ready.length; i++)
    show.push(list_expert_ready[i].account);
  console.log("Chuyên gia sẳn sàng: " + show);
}

function getExpert(callback) {
  if (list_expert_ready.length === 0) return callback(true, null);
  let i = Math.floor(Math.random() * list_expert_ready.length); // tra ve mot so nguyen ngau nhien tu 0 den 9
  return callback(false, list_expert_ready[i]);
};

function getFilenameImage(id) {
  let date = new Date();
  let mSec = date.getTime();
  return path.join(__dirname, 'public/images/', id.substring(2) + mSec + ".png");
}




function saveImage(str_image, callback) {
  const buf = new Buffer(str_image, 'base64');
  const filename = getFilenameImage("question_image" + Math.random() * 9999);

  fs.writeFile(filename, buf, function (err) {
    if (err) return callback(true, null);
    return callback(false, filename)
  });
}


io.sockets.on('connection', function (socket) {

  socket.on('client-dang-ki-user', function (json_str) {
    const User = JSON.parse(json_str);
    const SQL = `INSERT INTO User (user_id, Password, FullName, Address, Email)
                VALUES ('${User.Account}', '${User.Password}', '${User.FullName}', '${User.Address}', '${User.Email}');`;

    con.query(SQL, function (err) {
      socket.emit('ket-qua-dang-ki-user', {ketqua: !err});
    });
  });

  socket.on('client-dang-ki-expert', function (json_str) {
    const Expert = JSON.parse(json_str);
    const SQL = `INSERT INTO Expert (Account, Password, FullName, Education, Field, Address, Email) 
    VALUES ('${Expert.Account}', '${Expert.Password}', '${Expert.FullName}', '${Expert.Education}', '${Expert.Field}', '${Expert.Address}', '${Expert.Email}');`;
    con.query(SQL, function (err) {
      socket.emit('ket-qua-dang-ki-expert', {ketqua: !err});
    });
  });

  socket.on('client-dang-nhap', function (data) {

    const ThongTinDangNhap = JSON.parse(data);
    console.log(ThongTinDangNhap.username);


    const sql1 = `SELECT * FROM User WHERE user_id='${ThongTinDangNhap.username}' and Password ='${ThongTinDangNhap.password}'`;
    const sql2 = `SELECT * FROM Expert WHERE expert_id ='${ThongTinDangNhap.username}' and Password ='${ThongTinDangNhap.password}'`;
    con.query(sql1, function (err, rows, result) {
      if (rows.length !== 0) {
        socket.account = ThongTinDangNhap.username;
        socket.type = "user";
        list_login.push(socket.account);

        if (rows[0].avatar === null) rows[0].avatar = "";

        fs.readFile(rows[0].avatar, function (err, data) {
          if (!err) {
            socket.avatar = data.toString('base64');
            socket.emit('ket-qua-dang-nhap', {ketqua: rows[0], type: socket.type}, data);
          } else {
            socket.avatar = null;
            socket.emit('ket-qua-dang-nhap', {ketqua: rows[0], type: socket.type}, data);
          }
        });
      } else {
        con.query(sql2, function (err, rows) {
          if (rows.length === 0) {
            socket.emit('ket-qua-dang-nhap', {ketqua: "INCORRECT", type: socket.type}, "");
          } else {
            socket.account = ThongTinDangNhap.username;
            socket.type = "expert";
            list_login.push(socket.account);
            if (rows[0].avatar === null) rows[0].avatar = "";

            fs.readFile(rows[0].avatar, function (err, data) {
              if (!err) {
                socket.avatar = data.toString('base64');
                socket.emit('ket-qua-dang-nhap', {ketqua: rows[0], type: socket.type}, data);
              } else {
                socket.avatar = null;
                socket.emit('ket-qua-dang-nhap', {ketqua: rows[0], type: socket.type}, data);
              }
            });

          }
        });
      }
    });

    console.log("Danh sách đăng nhập: " + list_login);
  });

  socket.on('client-send-message-to-other-people', function (message_json) {
    if (socket.id_ketnoi === undefined) return;

    const message = JSON.parse(message_json);

    if (message.typeImage ===false) {
      const SQL = `INSERT INTO Messages (conversation_id, sender, message, typeImage, time) VALUES ('${message.conversation_id}', '${message.sender}', '${message.message}', '${message.typeImage === true ? 1 : 0}', '2019-11-12 00:00:00');`;

      con.query(SQL, function (err, result) {
        if (err) throw err;
        socket.to(socket.id_ketnoi).emit("server-send-message", {message: message_json});
      });


    }else{

      saveImage(message.message, function (err, filename) {
        if (err) return;

        message.message = filename;

        const SQL = `INSERT INTO Messages (conversation_id, sender, message, typeImage, time) VALUES ('${message.conversation_id}', '${message.sender}', '${message.message}', '${message.typeImage === true ? 1 : 0}', '2019-11-12 00:00:00');`;

        con.query(SQL, function (err, result) {
          if (err) throw err;
          socket.to(socket.id_ketnoi).emit("server-send-message", {message: message_json});
        });

      });
    }
  });

  socket.on('expert-send-ready', function (data) {
    const split_str = data.split("-");
    const ready = (split_str[1] === 'true');
    socket.account = split_str[0];
    socket.gioithieu = split_str[2];
    socket.keywords = split_str[3];
    TurnReady(socket,ready);
  });

  socket.on('client-to-update-data', function () {

    const filename = getFilenameImage(socket.id);

    const update_data = JSON.parse(arguments[0]);
    var SQL;
    if (arguments[2] === "user") {
      SQL = `UPDATE User SET FullName = '${update_data.name}', avatar = '${filename}', Address = '${update_data.address}', Email = '${update_data.email}' WHERE User.user_id = '${update_data.account}';`;
    } else {
      SQL = `UPDATE Expert SET FullName = '${update_data.name}', avatar = '${filename}', Address = '${update_data.address}', Email = '${update_data.email}' WHERE Expert.expert_id = '${update_data.account}';`;
    }
    if (arguments[1] == null) {

      con.query(SQL, function (err, rows, result) {
        if (rows.length !== 0) {
          socket.emit('server-to-update-status', {status: 1});
        } else {
          socket.emit('server-to-update-status', {status: 0});
        }
      });

    } else {
      fs.writeFile(filename, arguments[1], function (err) {
        if (err) {
          socket.emit('server-to-update-status', {status: 0});
          console.log('error', err);
        } else {
          con.query(SQL, function (err, rows, result) {
            if (rows.length !== 0) {
              socket.emit('server-to-update-status', {status: 1});
            } else {
              socket.emit('server-to-update-status', {status: 0});
            }
          });

        }
      });
    }
  });

  socket.on('user-search-expert', function (question_json) {
    const question = JSON.parse(question_json);
    socket.account = question.from;
    list_login.push(socket);

    saveImage(question.imageString, function (err, filename) {
      if (err) {
        socket.emit("ket-qua-tim-kiem-chuyen-gia", {ketqua: false});
        return false;
      }

      const SQL = `INSERT INTO Question (field_id, title, image, detailed_description, money, user_id) VALUES ('${question.field_id}', '${question.tittle}', '${filename}', '${question.note}', '${question.money}','${question.from}');`;
      con.query(SQL, function (err, result) {
        if (err) {
          socket.emit("ket-qua-tim-kiem-chuyen-gia", {ketqua: false});
          throw err;
        }

        question.id = result.insertId;
        getExpert(function (err, socket_expert) {
          if (err) {
            socket.emit("ket-qua-tim-kiem-chuyen-gia", {ketqua: false});
            return;
          }

          TurnReady(socket_expert, false);
          socket.id_ketnoi = socket_expert.id;
          socket.to(socket.id_ketnoi).emit("send-question-to-expert", {question: question});

        });
      });

    });

  });

  socket.on('expert-phanhoi', function (PhanHoiYeuCauGiaiDap_json) {
    const PhanHoiYeuCauGiaiDap = JSON.parse(PhanHoiYeuCauGiaiDap_json);

    let avatar = null;
    if (PhanHoiYeuCauGiaiDap.agree === true) {
      TurnReady(socket, false);
      socket.id_ketnoi = getIDconnectionfromUsername(PhanHoiYeuCauGiaiDap.from);

      if (socket.id_ketnoi ===null){
        socket.emit("ket-qua-tim-kiem-chuyen-gia", {ketqua: false});
        return;
      }

      avatar = socket.avatar;


      const SQL = `INSERT INTO Conversation (question_id, id_user, id_expert, starttime, public) VALUES ('${PhanHoiYeuCauGiaiDap.question_id}', '${PhanHoiYeuCauGiaiDap.from}', '${socket.account}', '2019-11-06 00:00:00', '1');`;


      con.query(SQL, function (err, result) {
        if (err) {
          socket.emit("ket-qua-tim-kiem-chuyen-gia", {ketqua: false});
          throw err;
        }


        console.log(socket.id_ketnoi);
        socket.to(socket.id_ketnoi).emit("bat dau cuoc thao luan", result.insertId);
        socket.emit("bat dau cuoc thao luan", result.insertId);
      });


    } else {
      TurnReady(socket, true);
      socket.emit("ket-qua-tim-kiem-chuyen-gia", {ketqua: false});
    }

  });

  socket.on('user-ready-thao-luan', function (data) {
    socket.to(socket.id_ketnoi).emit("user-ready-thao-luan", {message: data});
  });

  socket.on('client-get-education', function (data) {
    let SQL = "SELECT * FROM Education";
    con.query(SQL, function (err, rows, result) {
      if (rows.length !== 0) {
        socket.emit('server-sent-education', rows);
        console.log(data);
      }
    });
  });

  socket.on('client-get-field', function (data) {
    let SQL = "SELECT * FROM Field";
    con.query(SQL, function (err, rows, result) {
      if (rows.length !== 0) {
        socket.emit('server-sent-field', rows);
        console.log(data);
      }
    });
  });



  socket.on('rating-converstation', function () {
    let SQL = `UPDATE Conversation SET star = '${arguments[1]}' WHERE conversation_id = '${arguments[0]}'`;
    console.log(SQL);
    con.query(SQL, function (err, rows, result) {
      if (rows.length !== 0) {
        console.log("đã ghi nhận phản hồi");
      }
    });
  });


  socket.on('get-list-history', function () {
    console.log("OK")
    let SQL = `SELECT Conversation.conversation_id, Question.title, Field.name, Conversation.star
    FROM Question
    INNER JOIN Conversation ON Conversation.question_id = Question.question_id
    INNER JOIN Field ON Question.field_id = Field.field_id
    WHERE Conversation.public='1'`;
    // console.log(SQL);
    con.query(SQL, function (err, rows, result) {
      if (rows.length !== 0) {
        //console.log(rows);
        socket.emit("server-sent-list-history",rows);
      }
    });
  });


  socket.on('get-conversation-history', function (conversation_id) {

    let SQL = `SELECT * FROM Messages WHERE conversation_id = '${conversation_id}'`;
    console.log(SQL)
    con.query(SQL, function (err, rows, result) {
      let json;
      if (rows.length !== 0) {

        for (let i =0; i<rows.length; i++) {
          rows[i].typeImage = rows[i].typeImage === 1;

          if (rows[i].typeImage ===true) {
            fs.readFile(rows[i].message, function (err, data) {
              if (!err) {
                rows[i].message = data.toString('base64');
                socket.emit("server-sent-conversation-history", rows[i]);
                console.log(rows[i]);
              }
            });
          }else {
            socket.emit("server-sent-conversation-history", rows[i]);
          }

        }


      }
    });
  });


  socket.on('disconnect', function () {
    if (socket.type === "expert") {
      TurnReady(socket,false);
    }

    remove_list_login(socket);
  });

  socket.on('logout', function () {
    let pos = list_login.indexOf(socket.id);
    if (pos !== -1) {
      list_login.splice(pos, 1);
      console.log(socket.id + " (" + socket.type + ")" + ": logout");
    }

    if (socket.type === "expert") {
      socket.ready = "false";
      TurnReady(socket);
    }

    socket.emit("ketqua-logout", {ketqua: true})
    console.log("Danh sách đăng nhập: " + list_login);
  });
});




