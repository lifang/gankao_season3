#encoding: utf-8
class ExamRater < ActiveRecord::Base
  require 'rexml/document'
  include REXML
  has_many :rater_user_relations,:dependent => :destroy
  has_many :exam_users, :through=>:rater_user_relations, :foreign_key => "exam_user_id"
  belongs_to :examination


  #选择批阅试卷
  def self.get_paper(examination)
    exam_users=ExamUser.find_by_sql("select e.id exam_user_id, r.id relation_id, r.is_marked ,
        r.exam_rater_id from exam_users e inner join orders o on o.user_id = e.user_id
        inner join examinations ex on ex.id = e.examination_id
        left join rater_user_relations r on r.exam_user_id = e.id
        where e.examination_id=#{examination} and e.answer_sheet_url is not null
        and e.is_submited=#{ExamUser::IS_SUBMITED[:YES]} and o.category_id = ex.category_id and
        o.types in (#{Order::TYPES[:CHARGE]},#{Order::TYPES[:ACCREDIT]})
        and o.status=#{Order::STATUS[:NOMAL]}")
    return exam_users
  end


  #筛选题目
  def self.answer_questions(xml,doc)
    xml.elements["blocks"].each_element do  |block|
      block.elements["problems"].each_element do |problem|
        inner=true
        problem.elements["questions"].each_element do |question|
          element=doc.elements["paper/questions/question[@id=#{question.attributes["id"]}]"]
          if question.attributes["correct_type"].to_i ==Question::CORRECT_TYPE[:CHARACTER] or
              (question.attributes["correct_type"].to_i == Question::CORRECT_TYPE[:SINGLE_CALK] and
                question.attributes["flag"].to_i != 1)
            answer = (element.nil? or element.elements["answer"].nil? or
                element.elements["answer"].text.nil?) ? "": element.elements["answer"].text
            inner=false
            question.add_attribute("user_answer","#{answer}")
          else
            if !problem.attributes["question_type"].nil? and problem.attributes["question_type"].to_i==Problem::QUESTION_TYPE[:INNER]
              question.add_attribute("inner","1")
            else
              problem.delete_element(question.xpath)
            end
          end
        end unless problem.elements["questions"].nil?
        block.delete_element(problem.xpath) if problem.elements["questions"].nil? or
          problem.elements["questions"].elements.size <= 0 or inner
      end unless block.elements["problems"].nil?
      if block.elements["problems"].nil? or block.elements["problems"].elements.size<=0
        xml.delete_element(block.xpath)
      end
    end unless xml.elements["blocks"].nil?
    return xml
  end

  #设置手动阅卷分数
  def self.rater(doc,id,score)
    unless doc.elements[1].elements["auto_score"].nil?
      auto_score=doc.elements[1].elements["auto_score"].text
      if auto_score.to_f !=0.0
        doc.elements[1].attributes["score"]=score+auto_score.to_f
        ExamUser.find(id).update_attributes(:total_score=>score+auto_score.to_f)
      end
    end
    return doc.to_s
  end

  #完成阅卷，并记录考分，错误则收藏
  def self.set_answer(score_reason,exam_user,xml,doc,url)
    score=0.0
    only_xml=ExamRater.answer_questions(xml,doc)
    category_id=exam_user.examination.category_id
    collection = Collection.find_or_create_by_user_id_and_category_id(exam_user.user_id,category_id)
    path =  Collection::COLLECTION_PATH + "/" + Time.now.to_date.to_s
    collection_url = path + "/#{collection.id}.js"
    collection.set_collection_url(path, collection_url)
    already_hash = {"problems" => {"problem" => []}}
    last_problems = ""
    file = File.open(Constant::PUBLIC_PATH + collection.collection_url)
    last_problems = file.readlines.join
    unless last_problems.nil? or last_problems.strip == ""
      already_hash = JSON(last_problems.gsub("collections = ", ""))#ActiveSupport::JSON.decode(().to_json)
    end
    file.close
    score=0.0
    question_ids=[]
    only_xml.elements["blocks"].each_element do  |block|
      block_score = 0.0
      original_score = 0.0
      block.elements["problems"].each_element do |problem|
        problem.elements["questions"].each_element do |question|
          if  question.attributes["inner"].to_i!=1
            single_score = score_reason["#{question.attributes["id"]}"][0].to_f
            reason = score_reason["#{question.attributes["id"]}"][1]
            result_question = doc.elements["/exam/paper/questions/question[@id=#{question.attributes["id"]}]"]
            answer = (result_question.nil? or result_question.elements["answer"].nil? or result_question.elements["answer"].text.nil?) ? ""
            : result_question.elements["answer"].text
            if question.attributes["score"].to_f!=single_score
              problem.add_attribute("paper_id",doc.elements[1].attributes["id"])
              question_ids << question.attributes["id"]
              already_hash=Collection.auto_add_collection(answer, problem,question,already_hash,block)
            else
              problem.delete_element(question.xpath)
            end
            original_score += result_question.attributes["score"].to_f
            result_question.attributes["score"] = single_score
            score += single_score
            block_score += single_score
            question.add_attribute("user_answer","#{answer}")
            if result_question.attributes["score_reason"].nil?
              result_question.add_attribute("score_reason","#{reason}")
            else
              result_question.attributes["score_reason"]=reason
            end
          end
        end unless problem.elements["questions"].nil?
      end
      unless doc.elements["/exam/paper/blocks"].nil?
        answer_block = doc.elements["/exam/paper/blocks/block[@id=#{block.attributes["id"]}]"]
        block_score = answer_block.attributes["score"].to_f - original_score + block_score
        answer_block.attributes["score"] = block_score
      end
    end
    paper_id=doc.elements["/exam/paper"].attributes["id"].to_i
    CollectionInfo.update_collection_infos(paper_id, exam_user.user_id, question_ids)
    doc.elements["paper"].elements["rate_score"].text = score
    @xml=ExamRater.rater(doc,exam_user.id,score)
    file = File.new(url, File::CREAT|File::TRUNC|File::RDWR, 0644)
    file.write(doc.to_s)
    file.close
    collection_js="collections = " + already_hash.to_json.to_s
    path_url = collection.collection_url.split("/")
    collection.generate_collection_url(collection_js, "/" + path_url[1] + "/" + path_url[2], collection.collection_url)
  end


end
