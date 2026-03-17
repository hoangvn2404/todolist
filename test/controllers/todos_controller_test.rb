require "test_helper"

class TodosControllerTest < ActionDispatch::IntegrationTest
  test "GET index" do
    get todos_url
    assert_response :success
    assert_select "h1", "Todos"
  end

  test "GET index with filter" do
    get todos_url(filter: "active")
    assert_response :success

    get todos_url(filter: "completed")
    assert_response :success
  end

  test "POST create with valid params" do
    assert_difference("Todo.count") do
      post todos_url, params: { todo: { title: "New todo" } }
    end
    assert_redirected_to todos_url
  end

  test "POST create with blank title" do
    assert_no_difference("Todo.count") do
      post todos_url, params: { todo: { title: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "PATCH update toggles completed" do
    todo = todos(:one)
    patch todo_url(todo), params: { todo: { completed: true } }
    assert_redirected_to todos_url
    assert todo.reload.completed
  end

  test "DELETE destroy" do
    todo = todos(:one)
    assert_difference("Todo.count", -1) do
      delete todo_url(todo)
    end
    assert_redirected_to todos_url
  end
end
