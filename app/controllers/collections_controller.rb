#encoding: utf-8
class CollectionsController < ApplicationController
  layout 'exam_user'
  require 'rexml/document'
  include REXML

  def add_collection
    collection = Collection.find_or_create_by_user_id_and_category_id(cookies[:user_id].to_i, params[:category_id].to_i)
    path = Collection::COLLECTION_PATH + "/" + Time.now.to_date.to_s
    url = path + "/#{collection.id}.js"
    collection.set_collection_url(path, url)
    already_hash = {}
    last_problems = ""
    file = File.open(Constant::PUBLIC_PATH + collection.collection_url)
    last_problems = file.read
    file.close
    unless last_problems.nil? or last_problems.strip == ""
      already_hash = JSON(last_problems.gsub("collections = ", ""))
    else
      already_hash = {"problems" => {"problem" => []}}
    end
    is_problem_in = collection.update_question_in_collection(already_hash,
      params[:problem_id].to_i, params[:question_id].to_i,
      params[:question_answer], params[:question_analysis], params[:user_answer])
    if is_problem_in == false
      problem_json = JSON(params[:problem_json])
      new_col_problem = collection.update_problem_hash(problem_json, params[:paper_id],
        params[:question_answer], params[:question_analysis], params[:user_answer], params[:question_id].to_i)
      already_hash["problems"]["problem"] << new_col_problem
    end
    collection_js = "collections = " + already_hash.to_json.to_s
    path_url = collection.collection_url.split("/")
    collection.generate_collection_url(collection_js, "/" + path_url[1] + "/" + path_url[2], collection.collection_url)

    CollectionInfo.update_collection_infos(params[:paper_id].to_i, cookies[:user_id].to_i, [params[:question_id]])

    respond_to do |format|
      format.json {
        render :json => {:message => "收藏成功！"}
      }
    end
  end

  def update_collection
    this_problem = JSON params[:problem_json]
    this_question = nil
    unless this_problem["questions"]["question"].nil?
      new_col_questions = this_problem["questions"]["question"]
      if new_col_questions.class.to_s == "Hash"
        this_question = new_col_questions
      else
        new_col_questions.each do |question|
          if question["id"].to_i == params[:question_id].to_i
            this_question = question
            break
          end
        end unless new_col_questions.blank?
      end
    end
    Collection.update_collection(cookies[:user_id].to_i, this_problem,
      params[:problem_id], this_question, params[:question_id],
      params[:paper_id], params[:question_answer], params[:question_analysis],
      params[:user_answer], params[:category_id].to_i)

    CollectionInfo.update_collection_infos(params[:paper_id].to_i, cookies[:user_id].to_i, [params[:question_id]])
    
    respond_to do |format|
      format.json {
        render :json => {:message => "收藏成功！"}
      }
    end
  end




  def get_collections
    collection=Collection.find_by_user_id_and_category_id(cookies[:user_id],params[:category].to_i)
    @collection_url = "#{Rails.root}/public#{collection.collection_url}"
    f = File.open(@collection_url)
    @problems = (JSON (f.read)[13..-1])
    f.close
    respond_to do |format|
      format.json {
        render :json => {:message =>@problems}
      }
    end
  end

  def delete_problem
    collection=Collection.find_by_user_id_and_category_id(cookies[:user_id],params[:category].to_i)
    collection_url = "#{Rails.root}/public#{collection.collection_url}"
    f = File.open(collection_url)
    problems = (JSON (f.read)[13..-1])
    f.close
    collections=problems["problems"]["problem"].delete_at(params[:problem_id].to_i)
    collection_info=CollectionInfo.first(:conditions=>"user_id=#{cookies[:user_id]} and paper_id=#{collections["paper_id"]}")
    unless collection_info.nil? or collection_info.question_ids.nil?
      ids=collection_info.question_ids.split(",")
      questions=collections["questions"]["question"]
      if questions.class.to_s=="Hash"
        questions=[questions]
      end
      questions.each do |question|
        ids.delete(question["id"].to_s)
      end
      collection_info.update_attributes(:question_ids=>ids.join(",")) unless ids.blank?
    end
    collection_js="collections = " + problems.to_json.to_s
    path_url = collection.collection_url.split("/")
    collection.generate_collection_url(collection_js, "/" + path_url[1] + "/" + path_url[2], collection.collection_url)
    respond_to do |format|
      format.json {
        render :json=>{:category=>params[:category]}
      }
    end
  end


end
