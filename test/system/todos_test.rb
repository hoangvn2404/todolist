require "application_system_test_case"

class TodosTest < ApplicationSystemTestCase
  test "add a todo" do
    visit todos_url
    fill_in "todo_title", with: "Test todo item"
    click_on "Add"
    assert_text "Test todo item"
  end

  test "complete a todo" do
    visit todos_url
    fill_in "todo_title", with: "Complete me"
    click_on "Add"

    # Find and click the toggle button
    within("#todo_#{Todo.last.id}") do
      find("button").click
    end

    # Check that the text has line-through styling
    within("#todo_#{Todo.last.id}") do
      assert_selector "span.line-through"
    end
  end

  test "delete a todo" do
    visit todos_url
    fill_in "todo_title", with: "Delete me"
    click_on "Add"

    todo_id = Todo.last.id

    # Hover and click delete
    within("#todo_#{todo_id}") do
      accept_confirm do
        find("button[formmethod='post']", match: :first).click
      end
    end

    # Verify it's gone
    assert_no_selector "#todo_#{todo_id}"
  end

  test "filter todos" do
    # Create a mix of todos
    Todo.create!(title: "Active todo", completed: false)
    Todo.create!(title: "Completed todo", completed: true)

    visit todos_url

    # Test "All" filter (default)
    assert_text "Active todo"
    assert_text "Completed todo"

    # Test "Active" filter
    click_on "Active"
    assert_text "Active todo"
    assert_no_text "Completed todo"

    # Test "Completed" filter
    click_on "Completed"
    assert_no_text "Active todo"
    assert_text "Completed todo"

    # Test back to "All"
    click_on "All"
    assert_text "Active todo"
    assert_text "Completed todo"
  end
end
