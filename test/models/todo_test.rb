require "test_helper"

class TodoTest < ActiveSupport::TestCase
  test "todo requires a title" do
    todo = Todo.new(title: "")
    assert_not todo.valid?
    assert_includes todo.errors[:title], "can't be blank"
  end

  test "todo defaults completed to false" do
    todo = Todo.new(title: "Test Todo")
    assert_equal false, todo.completed
  end

  test "completed scope returns completed todos" do
    completed_todo = Todo.create!(title: "Completed", completed: true)
    active_todo = Todo.create!(title: "Active", completed: false)

    completed_todos = Todo.completed
    assert_includes completed_todos, completed_todo
    assert_not_includes completed_todos, active_todo
  end

  test "active scope returns active todos" do
    completed_todo = Todo.create!(title: "Completed", completed: true)
    active_todo = Todo.create!(title: "Active", completed: false)

    active_todos = Todo.active
    assert_includes active_todos, active_todo
    assert_not_includes active_todos, completed_todo
  end
end
