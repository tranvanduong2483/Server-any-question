express = require("express");
app = express();
server = require("http").createServer(app);
io = require("socket.io").listen(server);
mysql = require('mysql');
fs = require("fs");
path = require('path');
time = require('node-datetime');
nodemailer = require('nodemailer');
os = require('os');


transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'tvduong98@gmail.com', // here use your real email
        pass: ''
    }
});




transporter.verify(function(error, success) {
    if (error) {
        console.log(error);
    } else { //Nếu thành công.
        console.log('Kết nối gmail thành công!');
    }
});








app.set('port', process.env.PORT || 3000); //<--- replace with your port number

// Server
server.listen(app.get('port'), function () {
    console.log('Express server listening on port ' +getIP()+":" +app.get('port'));
});

module.exports = app;

function getDelMinute(TimeStart) {
    let Time = new Date() - TimeStart;
    let minute = Math.round(Time / 60000);
    return minute;
}


function sendVeriableCode(type,Username,Email) {
    let code = randomInteger(111111,999999);

    let SQL;
    if (type==='User')
         SQL = `UPDATE User SET Code = '${code}' WHERE user_id = '${Username}'`;
    else
        SQL = `UPDATE Expert SET Code = '${code}' WHERE expert_id = '${Username}'`;
    console.log(SQL);

    con.query(SQL, function (err, rows, result) {

        if (err) {
            return;
        }
        if (rows.length !== 0) {
            var mail = {
                from: 'toidicode.com@gmail.com', // Địa chỉ email của người gửi
                to: Email, // Địa chỉ email của người gửi
                subject: 'XÁC MINH EMAIL TÀI KHOẢN ' + Username, // Tiêu đề mail
                text: 'Toidicode.com', // Nội dung mail dạng text
                html: `<h4>Bấm vào đường dẫn sau để xác minh<br><a href="http://${getIP() +":" +app.get('port')}/xacminh?type=${type}&Username=${Username}&Code=${code}" >Xác minh tài khoản</a>`
                // Nội dung mail dạng html
            };


            //Tiến hành gửi email
            transporter.sendMail(mail, function(error, info) {
                if (error) { // nếu có lỗi
                    console.log(error);
                } else { //nếu thành công
                    console.log('Email sent: ' + info.response);
                }
            });

        }
    });






}

function getIP() {

    var interfaces = os.networkInterfaces();
    var addresses = [];
    for (var k in interfaces) {
        for (var k2 in interfaces[k]) {
            var address = interfaces[k][k2];
            if (address.family === 'IPv4' && !address.internal) {
                addresses.push(address.address);
            }
        }
    }
    return addresses;
}

const mySQL_online_config = {
    host: "db4free.net",
    port: 3306,
    user: "tranvanduong",
    password: "123456789",
    database: "anyquestion"
};

const mySQL_local_config = {
    host: "localhost",
    port: 3306,
    user: "root",
    password: "",
    database: "anyquestion"
};

//con = mysql.createConnection(mySQL_online_config);
con = mysql.createConnection(mySQL_local_config);

con.connect(function (err) {
    if (err) throw err;
    console.log("MySQL ready!");

    con.query('SELECT * FROM Messages', function (err, rows) {
        for (let i = 0; i < rows.length; i++) {
            let message = {};
            message.conversation_id = rows[i].conversation_id;
            message.sender = rows[i].sender;
            message.message = rows[i].message;
            message.typeImage = (rows[i].typeImage === 1);
            message.time = rows[i].time;
            list_message.push(message);
        }
        console.log("Đã load danh sách message");

    });

    con.query("SELECT * FROM Field", function (err, rows) {
        list_field = rows;
        console.log("Đã load danh sách lĩnh vực");
    });

    con.query("SELECT * FROM Education", function (err, rows) {
        list_education = rows;
        console.log("Đã load danh sách danh sach trinh do");
    });

    con.query("SELECT * FROM Bank", function (err, rows) {
        list_bank = rows;
        console.log("Đã load danh sách danh ngan hang");
    });

    con.query("SELECT * FROM Question", function (err, rows) {
        list_question = rows;
        console.log("Đã load danh sách câu hỏi");
    });

    GetBXH();
    setInterval(GetBXH, 20000);
});


list_login = [];

list_field = [];

list_education = [];

list_message = [];

list_bank = [];

list_question = [];

list_expert_ready = [];


list_bxh = [];


function GetBXH() {
    let SQL = `SELECT Expert.expert_id,Field.field_id,Field.name, BXH.conversation_number, BXH.AverageStars
            FROM Expert
            INNER JOIN BXH ON BXH.expert_id = Expert.expert_id
            INNER JOIN Field ON Expert.field_id = Field.field_id
            ORDER BY BXH.conversation_number ASC,BXH.AverageStars ASC;`;

    con.query(SQL, function (err, rows, result) {
        if (rows.length !== 0) {
            list_bxh = rows;
        }

    });
}

function getExpertStar(expert_id) {
    for (let i = 0; i < list_bxh.length; i++) {
        if (list_bxh[i].expert_id === expert_id) {
            return list_bxh[i].AverageStars;
        }
    }
    return -10000;
}


function getExpertField(expert_id) {

    for (let i = 0; i < list_bxh.length; i++) {
        if (list_bxh[i].expert_id === expert_id) {
            return list_bxh[i].field_id;
        }
    }
    return null;
}

function randomInteger(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max) + 1;
    return Math.floor(Math.random() * (max - min)) + min;
}

function getQuestion(question_id) {
    for (let i = list_question.length - 1; i >= 0; i--) {
        if (list_question[i].question_id === question_id) {
            return list_question[i];
        }
    }
    return null;
}

function getListmesageFromconvID(conversation_id) {
    let list_tmp = [];

    console.log("####" + conversation_id);
    for (let i = list_message.length - 1; i >= 0; i--) {
        if (list_message[i].conversation_id === conversation_id) {
            list_tmp.push(list_message[i]);
        }
    }
    return list_tmp;
}

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
    if (IdSocket === undefined || IdSocket == null) return null;
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

    if (ready === true) {
        socket.time = new Date();
        socket.Field = getExpertField(socket.account);
        list_expert_ready.push(socket);
    }

    let show = [];
    for (let i = 0; i < list_expert_ready.length; i++)
        show.push(list_expert_ready[i].account);
    console.log("Chuyên gia sẳn sàng: " + show);
}


function getListWhereField(Field) {
    let list = [];
    for (let i = 0; i < list_expert_ready.length; i++) {
        if (list_expert_ready[i].Field === Field)
            list.push(list_expert_ready[i]);
    }
    return list;
}

function XuLyTrongSoTheoThoiGianHienTai(list) {
    let sum = 0;
    for (let i = 0; i < list.length; i++) {
        let star = getExpertStar(list[i].account);

        list[i].trongso = star * 20 + getDelMinute(list[i].time) * 5 + 100;
        sum = sum + list[i].trongso;
        console.log(list[i].account, "- trọng số:", list[i].trongso)
    }
    sum = Math.round(sum);
    return [sum, list];
}

function getExpert(Field, callback) {
    if (list_expert_ready.length === 0) return callback(true, null);//Nếu không có chuyên gia sẳn sàng return null

    let list_expert_where_field = getListWhereField(Field);

    let result = XuLyTrongSoTheoThoiGianHienTai(list_expert_where_field);
    let sum = result[0];
    let list_expert_now = result[1];
    //Chuyen gia 1 ={trongso: 30}
    //Chuyen gia 1 ={trongso: 40}
    // Sum = 30 +40 =70

    let pos = randomInteger(1, sum); //random [1,sum]
    let selected_expert = null;


    let ts1 = 0;

    for (let i = 0; i < list_expert_now.length; i++) {
        let ts2 = list_expert_now[i].trongso;
        if (ts1 < pos && pos <= ts2) {
            selected_expert = list_expert_now[i];
            console.log("-> Chọn", selected_expert.account, "\n");
            break;
        }
        ts1 = ts1 + ts2;
    }

    return callback(selected_expert === null, selected_expert);
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
                VALUES ('${User.user_id}', md5('${User.Password}'), '${User.FullName}', '${User.Address}', '${User.Email}');`;

        console.log(SQL);

        con.query(SQL, function (err,result) {

            if (!err && result.affectedRows !==0) {
                sendVeriableCode("User", User.user_id,User.Email);
                socket.emit('ket-qua-dang-ki-user', {ketqua: true});
                return;

            }
            socket.emit('ket-qua-dang-ki-user', {ketqua: false});
        });
    });

    socket.on('client-dang-ki-expert', function (json_str) {
        const Expert = JSON.parse(json_str);

        const SQL = `INSERT INTO Expert (expert_id, Password, FullName, education_id, field_id, Address, Email)
        VALUES ('${Expert.expert_id}', md5('${Expert.Password}'), '${Expert.FullName}', '${Expert.education_id}', '${Expert.field_id}', '${Expert.Address}', '${Expert.Email}');`;

        console.log("expert dang ki: " + SQL);
        con.query(SQL, function (err,result) {
            if (!err && result.affectedRows !==0) {
                sendVeriableCode("Expert", Expert.expert_id,Expert.Email);
                socket.emit('ket-qua-dang-ki-expert', {ketqua: true});
            }
            socket.emit('ket-qua-dang-ki-expert', {ketqua: false});

        });
    });

    socket.on('client-dang-nhap', function (data) {
        const ThongTinDangNhap = JSON.parse(data);

        const sql1 = `SELECT * FROM User WHERE block = '0' and user_id='${ThongTinDangNhap.username}' and Password =md5('${ThongTinDangNhap.password}') and Code ='-1'`;
        const sql2 = `SELECT * FROM Expert WHERE block = '0' and expert_id ='${ThongTinDangNhap.username}' and Password =md5('${ThongTinDangNhap.password}') and Code ='-1' and Verified ='1'`;
        console.log(sql1);

        con.query(sql1, function (err, rows) {
            if (rows.length !== 0) {
                socket.account = ThongTinDangNhap.username;
                socket.type = "user";
                socket.avatar = rows[0].avatar;
                socket.emit('ket-qua-dang-nhap', {ketqua: rows[0], type: socket.type});

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
                        socket.avatar = rows[0].avatar;

                        socket.emit('ket-qua-dang-nhap', {ketqua: rows[0], type: socket.type});

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
        socket.to(socket.id_ketnoi).emit("server-send-message", {message: message_json});
        console.log(message_json);

        const SQL = `INSERT INTO Messages (conversation_id, sender, message, typeImage) VALUES ('${message.conversation_id}', '${message.sender}', '${message.message}', '${message.typeImage === true ? 1 : 0}');`;
        con.query(SQL, function (err, result) {
            if (err) throw err;
            list_message.push(message);
        });
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

    socket.on('expert-get-their-history', function (expert_id) {
        console.log("get-list-history")
        let SQL = `SELECT Conversation.conversation_id, Question.question_id,Question.title,Question.image, Field.name, Conversation.star, Conversation.id_user, Conversation.id_expert
        FROM Question
        INNER JOIN Conversation ON Conversation.question_id = Question.question_id
        INNER JOIN Field ON Question.field_id = Field.field_id
        WHERE Conversation.public='1' and Conversation.id_expert ='${expert_id}'
        `;
        // console.log(SQL);
        con.query(SQL, function (err, rows, result) {
            if (rows.length !== 0) {
                //console.log(rows);
                socket.emit("server-send-expert-history", rows);
            }
        });

    });

    socket.on('client-to-update-data', function () {
        const update_data = JSON.parse(arguments[0]);
        console.log(arguments[0]);

        let SQL;
        if (arguments[1] === "user") {
            SQL = `UPDATE User SET FullName = '${update_data.name}', avatar = '${update_data.avatar_firebase_path}', Address = '${update_data.address}', Email = '${update_data.email}' WHERE User.user_id = '${update_data.account}';`;
        } else {
            SQL = `UPDATE Expert SET FullName = '${update_data.name}', avatar = '${update_data.avatar_firebase_path}', Address = '${update_data.address}', Email = '${update_data.email}' WHERE Expert.expert_id = '${update_data.account}';`;
        }
        con.query(SQL, function (err, rows) {
            socket.emit('server-to-update-status', {status: (rows.length !== 0 ? 1 : 0)});
        });
    });

    socket.on('cancel-search-expert', function (data) {
        socket.id_ketnoi = undefined;
        console.log(data);
    });

    socket.on('expert-gui-yeu-cau-rut-tien', function () {
        const payment_request = JSON.parse(arguments[0]);
        const password = arguments[1];
        const SQL = `INSERT INTO PaymentRequest ( expert_id, bank_id, money, account_number, account_name)
        SELECT '${payment_request.expert_id}', '${payment_request.bank_id}', '${payment_request.money}', '${payment_request.account_number}', '${payment_request.account_name}'
        FROM Expert
        WHERE Expert.expert_id = '${payment_request.expert_id}' and Expert.Password =md5('${password}') and Expert.money>=${payment_request.money};`;

        con.query(SQL, function (err, result) {
            console.log(result);
            if (err || result.affectedRows === 0) {
                socket.emit("server-send-payment-request-status", 0);
                console.log(payment_request.expert_id + ": yêu cầu rút tiền lỗi");
            } else {
                socket.emit("server-send-payment-request-status", 1);
                console.log(payment_request.expert_id + ": yêu cầu rút tiền đã được ghi nhận");
            }
        });
    });

    socket.on('user-search-expert', function (question_json) {
        //if (socket.id_ketnoi !==undefined && socket.id_ketnoi!==null) return;
        socket.id_ketnoi = undefined;

        const question = JSON.parse(question_json);
        socket.account = question.user_id;
        let Field = question.field_id;
        console.log(socket.account + ": tim kiem chuyen gia");

        for (let i = 0; i < list_login.length; i++) {
            if (list_login[i].account === socket.account) {
                list_login.splice(i, 1);
            }
        }
        list_login.push(socket);

        const SQL = `INSERT INTO Question (field_id, title, image, detailed_description, money, user_id) VALUES ('${question.field_id}', '${question.title}', '${question.image}', '${question.detailed_description}', '${question.money}','${question.user_id}');`;
        con.query(SQL, function (err, result) {
            if (err) {
                socket.emit("tim kiem chuyen gia that bai", "Lỗi truy vấn cơ sở dữ liệu!");
                throw err;
            }

            con.query("SELECT * FROM Question", function (err, rows) {
                list_question = rows;
                console.log("Đã load danh sách danh ngan hang");
            });

            question.question_id = result.insertId;
            getExpert(Field, function (err, socket_expert) {
                if (err) {
                    socket.emit("tim kiem chuyen gia that bai", "Không tìm thấy chuyên gia!");
                    return;
                }

                TurnReady(socket_expert, false);
                socket.id_ketnoi = socket_expert.id;

                console.log("id ketnoi: " + socket.id_ketnoi);
                socket.to(socket.id_ketnoi).emit("send-question-to-expert", {question: question});
            });
        });

    });

    socket.on('expert-phanhoi', function (PhanHoiYeuCauGiaiDap_json) {
        const PhanHoiYeuCauGiaiDap = JSON.parse(PhanHoiYeuCauGiaiDap_json);
        let id_nguoi_dat_cau_hoi = getIDconnectionfromUsername(PhanHoiYeuCauGiaiDap.from);

        console.log(PhanHoiYeuCauGiaiDap);
        console.log(id_nguoi_dat_cau_hoi);

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

                if (socketKetNoi.id_ketnoi !== socket.id || socketKetNoi.id !== socket.id_ketnoi || socketKetNoi.id_ketnoi === null || socketKetNoi.id_ketnoi === undefined) {
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

    socket.on('user-ready-thao-luan', function (user_id) {
        socket.to(socket.id_ketnoi).emit("user-ready-thao-luan", {message: user_id});
        console.log("User đã tham gia");
    });

    socket.on('client-get-education', function (data) {
        socket.emit('server-sent-education', list_education);
    });

    socket.on('client-get-field', function (data) {
        socket.emit('server-sent-field', list_field);
    });

    socket.on('client-get-bank', function (data) {
        socket.emit('server-sent-bank', list_bank);
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

        let SQL = `UPDATE User SET Password = md5('${newpassword}')
    WHERE user_id = '${account}' AND user_id in (
        SELECT user_id FROM Security
    WHERE user_id ='${account}' and security_question_id ='${security_question_id}' and answer ='${answer}'
  )`;

        console.log("SQL1: " + SQL);

        con.query(SQL, function (err, rows, result) {
            if (rows.affectedRows !== 0) {
                socket.emit('server-sent-status-forgeting-password', 1);
            } else {

                let SQL = `UPDATE Expert SET Password = md5('${newpassword}')
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
            SQL = `UPDATE User SET Password = md5('${newpassword}') 
            WHERE user_id = '${account}' AND Password =md5('${oldpassword}');`;
        } else {
            SQL = `UPDATE Expert SET Password = md5('${newpassword}') 
                WHERE expert_id = '${account}' AND Password =md5('${oldpassword}');`;
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
                      WHERE user_id ='${account}' and Password = md5('${password}')`;

        } else {
            SQL = `INSERT INTO Security ( expert_id, security_question_id, answer)
                        SELECT expert_id, '${security_question_id}','${answer}'
                        FROM Expert
                        WHERE expert_id ='${account}' and Password = md5('${password}')`;
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
        let SQL = `SELECT Conversation.conversation_id,Question.question_id, Question.title,Question.image, Field.name, Conversation.star, Conversation.id_user, Conversation.id_expert
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
        console.log(account + ": get-introdution-expert");
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
        socket.emit("server-sent-list-bxh", list_bxh);
    });

    socket.on('get-conversation-history', function () {
        let conversation_id = arguments[0];
        let question_id = arguments[1];

        console.log(socket.id + ": lấy thông tin cuộc thảo luận mã " + conversation_id);
        let list_message_from_convID = getListmesageFromconvID(conversation_id);
        let question = getQuestion(question_id);
        socket.emit("server-sent-conversation-history", list_message_from_convID, {question: question});
        console.log({question});
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
        socket.to(socket.id_ketnoi).emit("server-bao-nguoi-kia-da-roi-cuoc-thao-luan", conversation_id);
        socket.id_ketnoi = undefined;
        console.log('client-roi-cuoc-thao-luan');
    });

    socket.on('user-nap-tien', function () {
        const user_id = arguments[0];
        const serial = arguments[1];
        const card_code = arguments[2];

        const SQL = `INSERT INTO CardUsageHistory (user_id, card_id)
                SELECT '${user_id}', card_id
                From AnyQuestionCard
                WHERE card_id in (
                    SELECT card_id
                    FROM AnyQuestionCard
                    WHERE serial ='${serial}' and card_code ='${card_code}' 
                    and  card_id not in (SELECT card_id FROM CardUsageHistory)
                );`;

        con.query(SQL, function (err, rows, result) {
            if (rows.affectedRows !== 0) {
                const SQL = `SELECT value FROM AnyQuestionCard 
                            WHERE serial ='${serial}' and card_code ='${card_code}'`;
                con.query(SQL, function (err, rows, result) {
                    if (rows.affectedRows !== 0) {
                        console.log(user_id + ": nạp thành công " + rows[0].value);
                        socket.emit('user-nap-tien-status', user_id, rows[0].value);


                        const SQL = `SELECT user_id,money FROM User WHERE user_id = '${user_id}';`;
                        con.query(SQL, function (err, rows, result) {
                            console.log(rows);
                            if (rows.length !== 0) {
                                socket.emit('server-sent-balance', rows[0].user_id, rows[0].money);
                            }
                        });


                    } else {
                        socket.emit('user-nap-tien-status', user_id, -2);
                    }
                });
            } else {
                socket.emit('user-nap-tien-status', user_id, -1);
            }
        });
    });

    socket.on('user-refresh-information', function (user_id) {
        const SQL = `SELECT user_id,money FROM User WHERE user_id = '${user_id}';`;
        con.query(SQL, function (err, rows, result) {
            console.log(rows);
            if (rows.length !== 0) {
                socket.emit('server-sent-balance', rows[0].user_id, rows[0].money);
            }
        });
    });

    socket.on('expert-refresh-information', function (expert_id) {
        const SQL = `SELECT Expert.expert_id, Expert.money, BXH.conversation_number, BXH.AverageStars
                    FROM Expert 
                    INNER JOIN BXH ON Expert.expert_id = BXH.expert_id
                    WHERE Expert.expert_id = '${expert_id}';`;
        con.query(SQL, function (err, rows, result) {

            if (err) {
                console.log("Lỗi expert-refresh-information")
                return;
            }
            console.log(rows);

            if (rows.length !== 0) {
                socket.emit('server-sent-expert-information', rows[0].expert_id, rows[0].money, rows[0].conversation_number, rows[0].AverageStars);
            }
        });
    });
});

setInterval(function () {
    XuLyTrongSoTheoThoiGianHienTai(list_expert_ready);
}, 1000);

app.get('/xacminh',function (req,res) {

    let type = req.query.type;
    let Username = req.query.Username;
    let Code = req.query.Code;

    let table = type==="User"?"User":"Expert";

    let SQL = `Update ${table} Set Code = '-1' Where Code = ${Code}`;
    con.query(SQL, function (err, result) {

        if (err) {
            return;
        }

        if (result.affectedRows !== 0) {
            res.send(Username +': Xác minh gmail thành công!');
        }else{
            res.send(Username +': Xác minh gmail không thành công!');
        }
    });


});
