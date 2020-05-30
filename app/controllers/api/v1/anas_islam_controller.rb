require 'google/cloud/firestore'
require 'json'

# https://cloud.google.com/firestore/docs/query-data/order-limit-data
# https://firebase.google.com/docs/firestore/manage-data/structure-data
module Api
  module V1
    class AnasIslamController < ApplicationController
      include Api::V1::AnasIslamHelper

      protect_from_forgery with: :null_session
      skip_before_action :verify_authenticity_token
      before_action :firebase_instance

      def firebase_instance
        project_id = "anasislamqanda"
        collection = params[:collection] || 'QuestionsDev'
        key_file   = path = File.join(Rails.root, "config", "Anas-Islam-Firebase.json")
        @firestore = Google::Cloud::Firestore.new project: project_id, keyfile: key_file
        @question_ref =  @firestore.col collection

        set_pagination_data
      end

      def index
        answered = to_bool(params[:answered]) || false
        deleted = to_bool(params[:deleted]) || false
        pagination = ''
        if @last_data_created.nil?
          pagination = @question_ref.where("answered", "=", answered).where("deleted", "=", deleted).order("date_created").limit(@limit)
        else
          pagination = @question_ref.where("answered", "=", answered).where("deleted", "=", deleted).order("date_created").start_after(DateTime.parse(@last_data_created)).limit(@limit)
          # pagination = @question_ref.where("answered", "=", false).where("deleted", "=", false).order("date_created").start_after(DateTime.parse(@last_data_created) + 0.01.second).limit(@limit)
        end

        data = query_data(pagination)
        _success_response(data)
      rescue StandardError => e
        _error_response(e)
      end

      # def fatawa
      #   pagination = ''
      #   if @last_data_created.nil?
      #     pagination = @question_ref.where("deleted", "=", false).order("date_created").limit(@limit)
      #   else
      #     pagination = @question_ref.where("deleted", "=", false).order("date_created").start_after(DateTime.parse(@last_data_created)).limit(@limit)
      #     # pagination = @question_ref.where("answered", "=", false).where("deleted", "=", false).order("date_created").start_after(DateTime.parse(@last_data_created) + 0.01.second).limit(@limit)
      #   end
      #
      #   data = query_data(pagination)
      #   _success_response(data)
      # rescue StandardError => e
      #   _error_response(e)
      # end

      def create
        data = eval params[:data].to_s # need to convert to String in order to pass to eval
        data.merge!(date_created: DateTime.now)

        added_doc_ref = @question_ref.add data
        _success_response(get_snapshot_data(added_doc_ref.document_id))
        # question = Question.create(question_param)
      rescue StandardError => e
        _error_response e
      end

      def destroy
        question = Question.find(params[:id])
        question.update(deleted: true)
        question.save

        render json:
                   {status: 'SUCCESS',
                    message: 'Documents Marked Deleted!',
                    data: question},
               status: :ok
      end

      def update
        snapshot = @question_ref.doc(params[:id])
        data = eval params[:data].to_s

        snapshot.set(data, merge: true)

        _success_response snapshot.get.data.merge(document_id: snapshot.document_id)
          # question = Question.find(params[:id])
      rescue StandardError => e
          _error_response e
      end

      def format_current_question
        question_ref =  @firestore.col 'QUESTIONS'
        data = []
        question_ref.get do |entry|
          snapshot = question_ref.doc(entry.document_id)
          puts entry['date_created']

          snapshot.set({"deleted": false, "answered": false }, merge: true)
          data.push(entry.data.merge(document_id: entry.document_id))
        end

        _success_response(data)
      rescue StandardError => e
        _error_response(e)
      end

      def get_answered_questions
        pagination = ''
        if @last_data_created.nil?
          pagination = @question_ref.where("answered", "=", true).where("deleted", "=", false).order("date_created").limit(@limit)
        else
          pagination = @question_ref.where("answered", "=", true).where("deleted", "=", false).order("date_created")
                                    .start_after(DateTime.parse(@last_data_created) + 0.01.second).limit(@limit)
        end

        data = query_data(pagination)
        _success_response(data)
      rescue StandardError => e
        _error_response(e)
      end

      def get_by_device_id
        device_id = params[:device_id]
        pagination = @question_ref.where("device_id", "=", device_id).order("date_created")
        data = query_data(pagination)
        _success_response(data)
      rescue StandardError => e
        _error_response(e)
      end

      def _success_response(data)
        render json:
                   {status: 'SUCCESS',
                    action: action_name,
                    data: data},
               status: :ok
      end

      def _error_response(e)
        render json:
                   {status: 'ERROR',
                    action: action_name,
                    message: e},
               status: :unprocessable_entity
      end

      def json_to_hash(json)
        data = {}
        json.each do |k,v|
          data.merge!({"#{k}": v})
        end
        data
      end

      def valid_json?(json)
        JSON.parse(json)
        return true
      rescue JSON::ParserError => e
        return false
      end

      def query_data(query)
        data = []
        query.get do |entry|
          data.push(entry.data.merge(document_id: entry.document_id))
        end
        data
      end

      def get_snapshot_data(document_id)
        snapshot = @question_ref.doc(document_id).get
        snapshot.data.merge(document_id: snapshot.document_id)
      end

      def question_param
        params.permit(:question, :answer, :phone_detail, :deleted, :answered)
      end

      def set_pagination_data
        @limit = (params[:limit] || 50).to_i
        @last_data_created = params[:last_data_created]
      end

      def wakeup_server
        _success_response("Server is UP. Ready to take requests!")
      end
    end
  end
end

