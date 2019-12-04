express = require("express");
app = express();
server = require("http").createServer(app);
io = require("socket.io").listen(server);
mysql = require('mysql');
fs = require("fs");
path = require('path');

app.set('port', process.env.PORT || 26398); //<--- replace with your port number

// Server
server.listen(app.get('port'), function () {
    console.log('Express server listening on port ' + app.get('port'));
});

module.exports = app;


con = mysql.createConnection({
    host: "db4free.net",
    port: 3306,
    user: "tranvanduong",
    password: "123456789",
    database: "anyquestion"
});


con.connect(function (err) {
    if (err) throw err;
    console.log("MySQL ready!");
});


list_expert_ready = [];
list_login = [];


function remove_list_login(socket) {
    for (let i = 0; i < list_login.length; i++) {
        if (list_login[i].id === socket.id) {
            list_login.splice(i, 1);
        }
    }
}

function show_lis_login() {
    let list_tmp = [];
    for (let i = 0; i < list_login.length; i++) {
        list_tmp.push(list_login[i].account);
    }
    console.log("Danh sách đăng nhập hiện tại: " + list_tmp);
}

function getIDconnectionfromUsername(Username) {
    if (list_login.length === 0) return null;
    for (let i = 0; i < list_login.length; i++)
        if (list_login[i].account === Username)
            return list_login[i].id;
    return null;
}

function getSocketFomIdSocket(IdSocket) {
    if (IdSocket === undefined || IdSocket==null) return null;
    if (list_login.length === 0) return null;
    for (let i = 0; i < list_login.length; i++)
        if (list_login[i].id === IdSocket)
            return list_login[i];
    return null;
}

function TurnReady(socket, ready) {
    for (let i = 0; i < list_expert_ready.length; i++) {
        if (list_expert_ready[i].id === socket.id || list_expert_ready[i].account === socket.account) {
            list_expert_ready.splice(i, 1);
        }
    }

    if (ready === true)
        list_expert_ready.push(socket);

    let show = [];
    for (let i = 0; i < list_expert_ready.length; i++)
        show.push(list_expert_ready[i].account);
    console.log("Chuyên gia sẳn sàng: " + show);
}

function getExpert(callback) {
    if (list_expert_ready.length === 0) return callback(true, null);
    let i = Math.floor(Math.random() * list_expert_ready.length); // tra ve mot so nguyen ngau nhien tu 0 den 9
    return callback(false, list_expert_ready[i]);
}

function getFilenameImage(id) {
    let date = new Date();
    let mSec = date.getTime();
    return __dirname + "/public/images/" + id.substring(2) + mSec + ".png";
}

function saveImage(str_image, callback) {
    const buf = new Buffer.from(str_image, 'base64');
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
                VALUES ('${User.user_id}', '${User.Password}', '${User.FullName}', '${User.Address}', '${User.Email}');`;

        con.query(SQL, function (err) {
            socket.emit('ket-qua-dang-ki-user', {ketqua: !err});
        });
    });

    socket.on('client-dang-ki-expert', function (json_str) {
        const Expert = JSON.parse(json_str);

        const SQL = `INSERT INTO Expert (expert_id, Password, FullName, education_id, field_id, Address, Email)
        VALUES ('${Expert.expert_id}', '${Expert.Password}', '${Expert.FullName}', '${Expert.education_id}', '${Expert.field_id}', '${Expert.Address}', '${Expert.Email}');`;

        console.log("expert dang ki: " + SQL);
        con.query(SQL, function (err) {
            socket.emit('ket-qua-dang-ki-expert', {ketqua: !err});
        });
    });

    socket.on('client-dang-nhap', function (data) {
        const ThongTinDangNhap = JSON.parse(data);

        const sql1 = `SELECT * FROM User WHERE user_id='${ThongTinDangNhap.username}' and Password ='${ThongTinDangNhap.password}'`;
        const sql2 = `SELECT * FROM Expert WHERE expert_id ='${ThongTinDangNhap.username}' and Password ='${ThongTinDangNhap.password}'`;
        con.query(sql1, function (err, rows, result) {
            if (rows.length !== 0) {
                socket.account = ThongTinDangNhap.username;
                socket.type = "user";
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


                //Day nhung nguoi cung dang nhap ra:
                let id_cungtk = getIDconnectionfromUsername(socket.account);
                if (id_cungtk !== null) {
                    socket.to(id_cungtk).emit("server-request-logout-because-same-login");
                    console.log("Cùng đăng nhập: " + socket.account);
                }
                list_login.push(socket);

                show_lis_login();
            } else {
                con.query(sql2, function (err, rows) {
                    if (rows.length === 0) {
                        socket.emit('ket-qua-dang-nhap', {ketqua: "INCORRECT", type: socket.type}, "");
                    } else {
                        socket.account = ThongTinDangNhap.username;
                        socket.type = "expert";
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


                        //Day nhung nguoi cung dang nhap ra:
                        let id_cungtk = getIDconnectionfromUsername(socket.account);
                        if (id_cungtk !== null) {
                            socket.to(id_cungtk).emit("server-request-logout-because-same-login");
                            console.log("Cùng đăng nhập: " + socket.account);
                        }
                        list_login.push(socket);
                        show_lis_login();
                    }


                });
            }
        });

    });

    socket.on('client-send-message-to-other-people', function (message_json) {
        if (socket.id_ketnoi === undefined || socket.id_ketnoi === null) return;
        const message = JSON.parse(message_json);

        if (message.typeImage === false) {
            const SQL = `INSERT INTO Messages (conversation_id, sender, message, typeImage) VALUES ('${message.conversation_id}', '${message.sender}', '${message.message}', '${message.typeImage === true ? 1 : 0}');`;
            con.query(SQL, function (err, result) {
                if (err) throw err;
                socket.to(socket.id_ketnoi).emit("server-send-message", {message: message_json});
            });
        } else {
            saveImage(message.message, function (err, filename) {
                if (err) return;
                message.message = filename;

                const SQL = `INSERT INTO Messages (conversation_id, sender, message, typeImage) VALUES ('${message.conversation_id}', '${message.sender}', '${message.message}', '${message.typeImage === true ? 1 : 0}');`;

                con.query(SQL, function (err, result) {
                    if (err) throw err;
                    socket.to(socket.id_ketnoi).emit("server-send-message", {message: message_json});
                });

            });
        }
    });

    socket.on('expert-send-ready', function () {
        const ready = arguments[0];

        if (ready === true) {
            const introdution = JSON.parse(arguments[1]);
            socket.account = introdution.expert_id;

            if ((socket.keywords !== introdution.keywords && introdution.keywords !== "") || (socket.gioithieu !== introdution.introduction_message && introdution.introduction_message !== "")) {
                socket.keywords = introdution.keywords;
                socket.gioithieu = introdution.introduction_message;

                let SQL = `UPDATE Introduction SET keywords = '${socket.keywords}', introduction_message='${socket.gioithieu}' WHERE expert_id = '${socket.account}'`;
                console.log(SQL);

                con.query(SQL, function (err, rows, result) {
                    if (rows.affectedRows === 0) {
                        console.log("Lỗi lưu từ khóa và tin nhắn giới thiệu");
                    }
                });
            }


            console.log(socket.account + ": " + socket.keywords + " - " + socket.gioithieu);
        }
        TurnReady(socket, ready);
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
                    console.log(SQL);
                    con.query(SQL, function (err, rows, result) {
                        if (!err) {
                            socket.emit('server-to-update-status', {status: 1});
                        } else {
                            socket.emit('server-to-update-status', {status: 0});
                        }
                    });

                }
            });
        }
    });

    socket.on('cancel-search-expert', function (data) {
        socket.id_ketnoi = undefined;
        console.log(data);
    });

    socket.on('user-search-expert', function (question_json) {
        //if (socket.id_ketnoi !==undefined && socket.id_ketnoi!==null) return;
        socket.id_ketnoi = undefined;

        const question = JSON.parse(question_json);
        socket.account = question.from;
        console.log(socket.account + ": tim kiem chuyen gia");

        for (let i = 0; i < list_login.length; i++) {
            if (list_login[i].account === socket.account) {
                list_login.splice(i, 1);
            }
        }
        list_login.push(socket);

        saveImage(question.imageString, function (err, filename) {
            if (err) {
                socket.emit("tim kiem chuyen gia that bai", "Lỗi khi xử lý ảnh!");
                return false;
            }

            const SQL = `INSERT INTO Question (field_id, title, image, detailed_description, money, user_id) VALUES ('${question.field_id}', '${question.tittle}', '${filename}', '${question.note}', '${question.money}','${question.from}');`;
            con.query(SQL, function (err, result) {
                if (err) {
                    socket.emit("tim kiem chuyen gia that bai", "Lỗi truy vấn cơ sở dữ liệu!");
                    throw err;
                }

                question.id = result.insertId;
                getExpert(function (err, socket_expert) {
                    if (err) {
                        socket.emit("tim kiem chuyen gia that bai", "Không tìm thấy chuyên gia!");
                        return;
                    }

                    TurnReady(socket_expert, false);
                    socket.id_ketnoi = socket_expert.id;

                    console.log("id ketnoi: "+socket.id_ketnoi);
                    socket.to(socket.id_ketnoi).emit("send-question-to-expert", {question: question});
                });
            });

        });

    });

    socket.on('expert-phanhoi', function (PhanHoiYeuCauGiaiDap_json) {
        const PhanHoiYeuCauGiaiDap = JSON.parse(PhanHoiYeuCauGiaiDap_json);
        let id_nguoi_dat_cau_hoi = getIDconnectionfromUsername(PhanHoiYeuCauGiaiDap.from);

        let avatar = null;
        if (PhanHoiYeuCauGiaiDap.agree === true) {
            TurnReady(socket, false);
            socket.id_ketnoi = id_nguoi_dat_cau_hoi;

            if (socket.id_ketnoi === null || socket.id_ketnoi === undefined) {
                socket.emit("tim kiem chuyen gia that bai", "Lỗi về dữ liệu!");
                return;
            }

            avatar = socket.avatar;


            const SQL = `INSERT INTO Conversation (question_id, id_user, id_expert, public) VALUES ('${PhanHoiYeuCauGiaiDap.question_id}', '${PhanHoiYeuCauGiaiDap.from}', '${socket.account}', '1');`;


            con.query(SQL, function (err, result) {
                if (err) {
                    socket.to(id_nguoi_dat_cau_hoi).emit("tim kiem chuyen gia that bai", "Lỗi khi tạo cuộc thảo luận trên CSDL!");
                    socket.id_ketnoi = undefined;
                    throw err;
                }

                let socketKetNoi = getSocketFomIdSocket(socket.id_ketnoi);

                if ( socketKetNoi.id_ketnoi !== socket.id || socketKetNoi.id !== socket.id_ketnoi || socketKetNoi.id_ketnoi === null || socketKetNoi.id_ketnoi === undefined){
                    socket.emit("server-send-ghep-doi-khong-thanh-cong");
                    socket.id_ketnoi = undefined;
                    return;
                }

                socket.to(socket.id_ketnoi).emit("bat dau cuoc thao luan", result.insertId);
                socket.emit("bat dau cuoc thao luan", result.insertId);

            });


        } else {
            console.log("từ chối");
            TurnReady(socket, true);
            socket.to(id_nguoi_dat_cau_hoi).emit("tim kiem chuyen gia that bai", "Chuyên gia vừa tìm thấy đã từ chối!");
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

    socket.on('client-get-security-question', function (data) {
        let SQL = "SELECT * FROM SecurityQuestion";
        con.query(SQL, function (err, rows, result) {
            if (rows.length !== 0) {
                socket.emit('server-send-security-question', rows);
                console.log(data);
            }
        });
    });

    socket.on('client-request-forget-password', function () {

        const account = arguments[0];
        const security_question_id = arguments[1];
        const answer = arguments[2];
        const newpassword = arguments[3];

        let SQL = `UPDATE User SET Password = '${newpassword}'
    WHERE user_id = '${account}' AND user_id in (
        SELECT user_id FROM Security
    WHERE user_id ='${account}' and security_question_id ='${security_question_id}' and answer ='${answer}'
  )`;

        console.log("SQL1: " + SQL);

        con.query(SQL, function (err, rows, result) {
            if (rows.affectedRows !== 0) {
                socket.emit('server-sent-status-forgeting-password', 1);
            } else {

                let SQL = `UPDATE Expert SET Password = '${newpassword}'
                  WHERE expert_id = '${account}' AND expert_id in (
                      SELECT expert_id FROM Security
                  WHERE expert_id ='${account}' and security_question_id ='${security_question_id}' and answer ='${answer}'
                )`;

                console.log("SQL2: " + SQL);


                con.query(SQL, function (err, rows, result) {
                    if (rows.affectedRows !== 0) {
                        socket.emit('server-sent-status-forgeting-password', 1);
                    } else {
                        socket.emit('server-sent-status-forgeting-password', 0);
                    }

                });


            }
        });
    });

    socket.on('client-request-update-password', function () {

        const type = arguments[0];
        const account = arguments[1];
        const oldpassword = arguments[2];
        const newpassword = arguments[3];
        let SQL = "";

        console.log(type);

        if (type === "user") {
            SQL = `UPDATE User SET Password = '${newpassword}' 
            WHERE user_id = '${account}' AND Password ='${oldpassword}';`;
        } else {
            SQL = `UPDATE Expert SET Password = '${newpassword}' 
                WHERE expert_id = '${account}' AND Password ='${oldpassword}';`;
        }


        console.log(SQL);

        con.query(SQL, function (err, rows, result) {
            if (rows.affectedRows !== 0) {
                socket.emit('server-sent-status-updating-password', 1);
            } else {
                socket.emit('server-sent-status-updating-password', 0);
            }
        });
    });

    socket.on('client-change-security-question', function () {
        const type = arguments[0];
        const account = arguments[1];
        const password = arguments[2];
        const security_question_id = arguments[3];
        const answer = arguments[4];

        console.log(account, 'client-change-security-question');


        let SQL = "";

        if (type === "user") {
            SQL = `INSERT INTO Security ( user_id, security_question_id, answer)
                      SELECT user_id, '${security_question_id}','${answer}'
                      FROM User
                      WHERE user_id ='${account}' and Password = '${password}'`;

        } else {
            SQL = `INSERT INTO Security ( expert_id, security_question_id, answer)
                        SELECT expert_id, '${security_question_id}','${answer}'
                        FROM Expert
                        WHERE expert_id ='${account}' and Password = '${password}'`;
        }

        console.log(SQL);
        con.query(SQL, function (err, rows, result) {
            if (rows.affectedRows !== 0) {
                socket.emit('server-sent-status-updating-security-question', 1);
            } else {
                socket.emit('server-sent-status-updating-security-question', 0);
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
        console.log("get-list-history")
        let SQL = `SELECT Conversation.conversation_id, Question.title, Field.name, Conversation.star, Conversation.id_user, Conversation.id_expert
    FROM Question
    INNER JOIN Conversation ON Conversation.question_id = Question.question_id
    INNER JOIN Field ON Question.field_id = Field.field_id
    WHERE Conversation.public='1'`;
        // console.log(SQL);
        con.query(SQL, function (err, rows, result) {
            if (rows.length !== 0) {
                //console.log(rows);
                socket.emit("server-sent-list-history", rows);
            }
        });
    });

    socket.on('get-introdution-expert', function (account) {
        console.log(account+": get-introdution-expert");
        let SQL = `SELECT keywords, introduction_message FROM Introduction WHERE expert_id = '${account}'`;
        console.log(SQL);
        con.query(SQL, function (err, rows, result) {
            if (rows.length !== 0) {
                socket.emit("server-sent-introdution-expert", {ketqua: rows[0]});
            } else {
                socket.emit("server-sent-introdution-expert");
            }
        });
    });

    socket.on('get-list-bxh', function () {
        console.log("get-list-bxh")
        let SQL = `SELECT Expert.expert_id,Field.name, BXH.conversation_number, BXH.AverageStars
            FROM Expert
            INNER JOIN BXH ON BXH.expert_id = Expert.expert_id
            INNER JOIN Field ON Expert.field_id = Field.field_id
            ORDER BY BXH.AverageStars ASC, BXH.conversation_number ASC;`;

        con.query(SQL, function (err, rows, result) {
            if (rows.length !== 0) {
                socket.emit("server-sent-list-bxh", rows);
            }

            //console.log(rows);
        });
    });

    socket.on('get-conversation-history', function (conversation_id) {

        console.log("get-conversation-history");

        let SQL = `SELECT * FROM Messages WHERE conversation_id = '${conversation_id}'`;
        console.log(SQL)
        con.query(SQL, function (err, rows, result) {
            let json;
            if (rows.length !== 0) {

                for (let i = 0; i < rows.length; i++) {
                    rows[i].typeImage = rows[i].typeImage === 1;

                    if (rows[i].typeImage === true) {
                        fs.readFile(rows[i].message, function (err, data) {
                            if (!err) {
                                rows[i].message = data.toString('base64');
                                socket.emit("server-sent-conversation-history", rows[i]);
                                console.log(rows[i]);
                            }
                        });
                    } else {
                        socket.emit("server-sent-conversation-history", rows[i]);
                    }

                }


            }
        });
    });

    socket.on('disconnect', function () {
        TurnReady(socket, false);
        remove_list_login(socket);
        show_lis_login();
    });

    socket.on('logout', function (type) {
        TurnReady(socket, false);
        socket.emit("ketqua-logout", {ketqua: true});

        remove_list_login(socket);
        show_lis_login();
    });

    socket.on('client-roi-cuoc-thao-luan', function (conversation_id) {
        socket.to(socket.id_ketnoi).emit("server-bao-nguoi-kia-da-roi-cuoc-thao-luan",conversation_id);
        socket.id_ketnoi = undefined;
    });
});




