module Api
  module V1
    class AnasIslamController < ApplicationController
      protect_from_forgery with: :null_session

      def index
        @documents = Question.all
        render json:
                   {status: 'SUCCESS',
                    message: 'Documents Loaded!',
                    data: @documents},
               status: :ok
      end

      def show
      end

      def new
      end

      def create
        question = Question.create(question_param)

        if question.save
          render json:
                     {status: 'SUCCESS',
                      message: 'Documents Saved!',
                      data: question},
                 status: :ok
        else
          render json:
                     {status: 'ERROR',
                      message: 'Documents Not Saved!',
                      data: question.errors},
                 status: :unprocessable_entity
        end
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

      def question_param
        params.permit(:question, :answer, :phone_detail, :deleted, :answered)
      end
    end
  end
end

