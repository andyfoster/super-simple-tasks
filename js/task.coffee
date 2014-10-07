# Stuff to do with saving tasks

class DB

  # DO NOT CHANGE
  @db_key = 'todo'
  # @db_key = 'dev'

class Arrays

  # Arrays for priorities
  @priorities = ['minor', 'major', 'blocker']

  @default_data = [{
                      'isDone':false,
                      'name':'Add a new task above', 
                      'priority':'major'
                    },
                    {
                      'isDone':false,
                      'name':'Perhaps give it a priority', 
                      'priority':'minor'
                    },
                    {
                      'isDone':false,
                      'name':'Or even click and hold to reorder it', 
                      'priority':'minor'
                    },
                    {
                      'isDone':false,
                      'name':'Refresh to see that your task is still here', 
                      'priority':'minor'
                    },
                    {
                      'isDone':false,
                      'name':'Follow <a href="http://twitter.com/humphreybc" target="_blank">@humphreybc</a> on Twitter', 
                      'priority':'major'
                    },
                    {
                      'isDone':false,
                      'name':'Click a task’s name to complete it', 
                      'priority':'minor'
                    }]

class Task
  # Updates the order upon drag and drop
  @updateOrder: (oldLocation, newLocation) ->
    if oldLocation == newLocation
      return

    # All the tasks from localStorage
    allTasks = @getAllTasks()

    # The task we want to move
    toMove = allTasks[oldLocation]

    # if the current position (oldLocation) is above (rendered on the screen) the new location
    # the splice needs to take into account the existing toMove object and "jump" over it
    if oldLocation < newLocation
      newLocation += 1
    allTasks.splice(newLocation, 0, toMove)

    # if the newLocation is above (rendered on the screen) the old location
    # the splice needs to take into account the new toMove object and "jump" over it
    if newLocation < oldLocation
      oldLocation += 1
    allTasks.splice(oldLocation, 1)
    
    @setAllTasks(allTasks)

  # Returns what we have in storage
  @getAllTasks: ->
    allTasks = localStorage.getItem(DB.db_key)
    allTasks = JSON.parse(allTasks) || Arrays.default_data

    # Migrate from < 1.2
    # Only run if there are tasks, and if the first one has no priority attribute (hence < 1.2)

    if (allTasks.length > 0) and (allTasks[0].priority == undefined) # Only run if there
      for task, i in allTasks # Updates each task with a default priority and due date
        name = allTasks[i].name
        allTasks[i] = @createTask(name)
        @setAllTasks(allTasks) # Sets those in storage before continuing

    allTasks

  # Creates a new task object with some defaults if they're not set
  @createTask: (name) ->
    task =
      isDone: false
      name: name
      priority: 'minor'

  # Receives name which is in the input
  # If the input is blank, doesn't save it
  # Uses @createTask() to make a new task object
  # Adds the new task to the end of the array
  # Passes that updated array through to @setAllTasks() to be written to storage
  @setNewTask: (name) ->
    unless name == ''
      newTask = @createTask(name)
      allTasks = @getAllTasks()
      allTasks.push newTask
      @setAllTasks(allTasks)

  # Updates the storage and runs Views.showTasks() again to update the HTML list
  # DB.db_key is a variable set at the top of this file for the storage key
  @setAllTasks: (allTasks) ->
    localStorage.setItem(DB.db_key, JSON.stringify(allTasks))
    Views.showTasks(allTasks)

  # Change the attribute (in the DOM) and run updateAttr to change it in storage
  @changeAttr: (li, attr, value) ->
    if attr == 'priority'
      array = Arrays.priorities

    currentIndex = $.inArray(value, array)
    id = Views.getId(li)

    if currentIndex == array.length - 1
      currentIndex = -1
    value = array[currentIndex + 1]

    @updateAttr(id, attr, value)

  # Updates the attribute in storage
  @updateAttr: (id, attr, value) ->
    allTasks = @getAllTasks()
    task = allTasks[id]
    task[attr] = value
    @setAllTasks(allTasks)

  # Grab the last task from storage 'undo' and add it back to storage using @setAllTasks()
  # Then remove that entry from storage 'undo' 
  @undoLast: ->
    redo = localStorage.getItem('undo')
    redo = JSON.parse(redo)

    allTasks = @getAllTasks()

    position = redo.position
    delete redo['position']
    allTasks.splice(position, 0, redo)

    @setAllTasks(allTasks)
    localStorage.removeItem('undo')

    Views.undoUX(allTasks)

  # Removes the selected task from the list and passes that to setAllTasks to update storage
  @markDone: (id) ->
    allTasks = @getAllTasks()
    toComplete = allTasks[id]

    # Sets the item we're removing in localStorage as 'undo' just in case
    localStorage.setItem('undo', JSON.stringify(toComplete))
    Views.undoFade()

    # @updateAttr(id, 'isDone', true)
    allTasks.splice(id, 1)
    @setAllTasks(allTasks)

  # Clears storage and then runs Views.showTasks() to show the blank state message
  @markAllDone: ->
    @setAllTasks([])
    allTasks = @getAllTasks()
    Views.showTasks(allTasks)

    