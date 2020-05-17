require 'google/cloud/firestore'
require 'json'

module Api
  module V1
    class AnasIslamController < ApplicationController
      protect_from_forgery with: :null_session
      skip_before_action :verify_authenticity_token
      before_action :firebase_instance

      def firebase_instance
        project_id = "anasislamqanda"
        key_file   = path = File.join(Rails.root, "config", "Anas-Islam-Firebase.json")
        @firestore = Google::Cloud::Firestore.new project: project_id, keyfile: key_file
      end

      def index
        question_ref =  @firestore.col "QuestionsDev"
        data = query_data(question_ref)
        _success_response(data)
      rescue StandardError => e
        _error_response(e)
      end

      def show
      end

      def new
      end

      def create
        data = eval params[:data].to_s
        question_ref = @firestore.col "QuestionsDev"
        added_doc_ref = question_ref.add data

        _success_response(data)
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
        begin
          question = Question.find(params[:id])
          if question.update(question_param)
            render json:
                       {status: 'SUCCESS',
                        message: 'Documents Updated!',
                        data: question},
                   status: :ok
          end
        rescue StandardError => e
          render json:
                     {status: 'ERROR',
                      message: 'Documents Not Updated!',
                      data: e},
                 status: :unprocessable_entity
        end
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
          data.push(entry.document_id => entry.data)
        end
        data
      end

      def question_param
        params.permit(:question, :answer, :phone_detail, :deleted, :answered)
      end
    end
  end
end

