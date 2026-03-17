require "test_helper"

class TodoTest < ActiveSupport::TestCase
  test "valid with title" do
    todo = Todo.new(title: "Test todo")
    assert todo.valid?
  end

  test "invalid without title" do
    todo = Todo.new(title: "")
    assert_not todo.valid?
  end

  test "completed defaults to false" do
    todo = Todo.create!(title: "Test")
    assert_equal false, todo.completed
  end

  test "scope active" do
    active_todos = Todo.active
    assert_includes active_todos, todos(:one)
    assert_includes active_todos, todos(:three)
    assert_not_includes active_todos, todos(:two)
  end

  test "scope completed" do
    completed_todos = Todo.completed
    assert_includes completed_todos, todos(:two)
    assert_not_includes completed_todos, todos(:one)
    assert_not_includes completed_todos, todos(:three)
  end

  test "scope by_filter all" do
    all_todos = Todo.by_filter("all")
    assert_equal 3, all_todos.count
  end

  test "scope by_filter active" do
    active_todos = Todo.by_filter("active")
    assert_includes active_todos, todos(:one)
    assert_includes active_todos, todos(:three)
    assert_not_includes active_todos, todos(:two)
  end

  test "scope by_filter completed" do
    completed_todos = Todo.by_filter("completed")
    assert_includes completed_todos, todos(:two)
    assert_not_includes completed_todos, todos(:one)
    assert_not_includes completed_todos, todos(:three)
  end
end
