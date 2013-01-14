$(document).ready ->

  # Runs functions on page load
  initialize = ->
    allTodos = getAllTodos()
    showTodos(allTodos)
    $("#new-todo").focus()

  # Creates a new todo object
  createToDo = (name) ->
    todo =
      isDone: false
      name: name

  # Pulls what we have in localStorage
  getAllTodos = ->
    allTodos = localStorage.getItem("todo")
    allTodos = JSON.parse(allTodos) || []
    # allTodos = JSON.parse(allTodos) || [{"isDone":false,"name":"Do the laundry"}, {"isDone":false,"name":"Put out the rubbish"}, {"isDone":false,"name":"Follow @humphreybc on Twitter"}]
    allTodos

  # Gets whatever is in the input and saves it
  setNewTodo = ->
    name = $("#new-todo").val()
    unless name == ''
      newTodo = createToDo(name)
      allTodos = getAllTodos()
      allTodos.push newTodo
      setAllTodos(allTodos)

  # Updates the localStorage and runs showTodos again to update the list
  setAllTodos = (allTodos) ->
    localStorage.setItem("todo", JSON.stringify(allTodos))
    showTodos(allTodos)
    $("#new-todo").val('')
    $("#new-todo").focus()
    
  # Finds the input id, strips 'todo' from it, and converts the string to an int
  getId = (li) ->
    id = $(li).find('input').attr('id').replace('todo', '')
    parseInt(id)

  # Removes the selected todo from the list and parses that to setAllTodos to update localStorage
  markDone = (id) ->
    todos = getAllTodos()
    todos.splice(id,1)
    setAllTodos(todos)

  # Clears localStorage
  markAllDone = ->
    localStorage.clear()
    initialize()

  # Grab everything from the key 'name' out of the object
  getNames = (allTodos) ->
    names = [] # create a new array for our names
    for todo in allTodos # iterate on each
      names.push todo['name'] # append the value to our new array called names
    names # return them so allTodos() can use it

  # Gives us the list formatted nicely
  generateHTML = (allTodos) ->
    names = getNames(allTodos)
    for name, i in names
      names[i] = '<li><label><input type="checkbox" id="todo' + i + '" />' + name + '</label></li>'
    names

  # Inserts that nicely formatted list into ul #todo-list
  showTodos = (allTodos) ->
    html = generateHTML(allTodos)
    $("#todo-list").html(html)

  # Runs the initialize function when the page loads
  initialize()

  # Triggers the setting of the new todo when clicking the button
  $("#todo-submit").click (e) ->
    e.preventDefault()
    setNewTodo()

  # Click Mark all done
  $("#mark-all-done").click (e) ->
    e.preventDefault()
    if confirm "Are you sure you want to mark all tasks as done?"
      markAllDone()
    else
      return

  # When you click an li, fade it out and run markDone()
  $(document).on "click", "#todo-list li", (e) ->
    self = this
    $(self).find('input').prop('checked', true)
    $(self).fadeOut(500, ->
      markDone(getId(self)) 
      )
