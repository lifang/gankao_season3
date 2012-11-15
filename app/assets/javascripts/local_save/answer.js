//创建db
try {
    if(!window.openDatabase){
    //alert('当前浏览器不支持本地存储!');
    } else {
        var shortName = 'answerDB';
        var version = '1.0';
        var displayName = 'paper answer database';
        var maxSize = 65536;
        var db = openDatabase(shortName, version, displayName, maxSize);
        //创建表
        db.transaction(
            function (transaction){
                transaction.executeSql('CREATE TABLE IF NOT EXISTS answers (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, question_id STRING NOT NULL, user_id STRING, paper_id STRING, examination_id STRING, answer TEXT NOT NULL, date DATE, is_sure STRING);',
                    [],nullDataHandler, errorHandler);
            }
            );
    }
} catch(e){
    if (e == 2){
        alert('无效的数据库版本。');
    } else {
        alert("未知错误 "+e+"。");
    }
}

//error handler
function errorHandler(transaction, error){
    alert('Oops, Error was: '+ error.message +'(Code:'+ error.code +')');

    var fatal_error = true;
    if(fatal_error){
        return true;
    }
    return false;
}

//null data handler
function nullDataHandler(transaction, results){
}

function add_answer(question_id, user_id, paper_id, examination_id, answer, is_sure){
    db.transaction(
        function (transaction){
            transaction.executeSql('INSERT INTO answers (question_id, user_id, paper_id, examination_id, answer, is_sure) VALUES ("'+question_id+'","'+ user_id +'","'+paper_id+'","'+examination_id+'","'+answer+'", "'+is_sure+'");',[],nullDataHandler,errorHandler);
            //transaction.executeSql("SELECT * from answers;",[],dataHandler, errorHandler);
        }
        );
}

function remove_answer(question_id, user_id, paper_id, examination_id) {
    db.transaction(
        function (transaction){
            transaction.executeSql('delete from answers where question_id="'+question_id+'" and user_id="'+user_id+'" and paper_id="'+paper_id+'" and examination_id="'+examination_id+'";',[],nullDataHandler,errorHandler);
        }
        );
}

//列出本地存储数据
function list_answer(user_id, paper_id, examination_id) {
    db.transaction(
        function (transaction){
            transaction.executeSql("SELECT * from answers where user_id='"+user_id+"' and paper_id='"+paper_id+"' and examination_id='"+examination_id+"';",
            [],dataHandler, errorHandler);
        }
        );
}

function dataHandler(transaction, results){
    if (results.rows.length > 0) {
        answer_hash = new Hashtable();
        for (var i = 0; i<results.rows.length; i++){
            var row = results.rows.item(i);
            answer_hash.put("" + row['question_id'], new Array(row['answer'], row['is_sure']));
        }
    }
    if (answer_hash == null || answer_hash.size() == 0) {
        setTimeout(function(){
            read_answer_xml();
        }, 100);
    }
}



