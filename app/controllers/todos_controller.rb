class TodosController < ApplicationController
  before_action :set_todo, only: [ :update, :destroy ]

  def index
    @filter = params[:filter] || "all"
    @todos = Todo.by_filter(@filter).order(created_at: :desc)
    @todo = Todo.new
  end

  def create
    @todo = Todo.new(todo_params)
    if @todo.save
      redirect_to todos_path(filter: params[:filter])
    else
      @filter = params[:filter] || "all"
      @todos = Todo.by_filter(@filter).order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @todo.update(todo_params)
    redirect_to todos_path(filter: params[:filter])
  end

  def destroy
    @todo.destroy
    redirect_to todos_path(filter: params[:filter])
  end

  private

  def set_todo
    @todo = Todo.find(params[:id])
  end

  def todo_params
    params.expect(todo: [ :title, :completed ])
  end
end
