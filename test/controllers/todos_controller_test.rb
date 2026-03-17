require "test_helper"

class TodosControllerTest < ActionDispatch::IntegrationTest
  test "GET /todos renders the todo list" do
    Todo.create!(title: "Test Todo")
    get todos_path
    assert_response :success
    assert_select "h1", "Todos"
  end

  test "POST /todos with valid title creates a todo and redirects" do
    assert_difference("Todo.count") do
      post todos_path, params: { todo: { title: "New Todo" } }
    end
    assert_redirected_to todos_path
  end

  test "POST /todos with blank title re-renders with errors" do
    assert_no_difference("Todo.count") do
      post todos_path, params: { todo: { title: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "PATCH /todos/:id toggles completed status" do
    todo = Todo.create!(title: "Test Todo", completed: false)
    patch todo_path(todo), params: { todo: { completed: true } }
    assert_redirected_to todos_path
    assert todo.reload.completed
  end

  test "DELETE /todos/:id removes the todo" do
    todo = Todo.create!(title: "Test Todo")
    assert_difference("Todo.count", -1) do
      delete todo_path(todo)
    end
    assert_redirected_to todos_path
  end

  test "filter param active returns only active todos" do
    Todo.create!(title: "Active", completed: false)
    Todo.create!(title: "Completed", completed: true)

    get todos_path(filter: "active")
    assert_response :success
    assert_select ".todo-item", 1
  end

  test "filter param completed returns only completed todos" do
    Todo.create!(title: "Active", completed: false)
    Todo.create!(title: "Completed", completed: true)

    get todos_path(filter: "completed")
    assert_response :success
    assert_select ".todo-item", 1
  end
end
