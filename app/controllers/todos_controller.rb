class TodosController < ApplicationController
  def index
    @todos = filter_todos(Todo.all.order(created_at: :desc))
  end

  def create
    @todo = Todo.new(todo_params)
    if @todo.save
      redirect_to todos_path(filter: params[:filter]), status: :see_other
    else
      @todos = filter_todos(Todo.all.order(created_at: :desc))
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @todo = Todo.find(params[:id])
    @todo.update!(todo_params)
    redirect_to todos_path(filter: params[:filter]), status: :see_other
  end

  def destroy
    Todo.find(params[:id]).destroy!
    redirect_to todos_path(filter: params[:filter]), status: :see_other
  end

  private

  def todo_params
    params.require(:todo).permit(:title, :completed)
  end

  def filter_todos(scope)
    case params[:filter]
    when "active" then scope.active
    when "completed" then scope.completed
    else scope
    end
  end
end
