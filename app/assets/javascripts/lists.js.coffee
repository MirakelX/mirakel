# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


Lists=
  # Update the Lists–List
  update: ->
    $.getJSON(
      Routes.lists_path({format: 'json'})
      (data) ->
        for list in data
          # TODO The position of the new list-item should be the same as in the database
          unless $('#list_'+list.id).length>0
            $('#lists li:first-child').clone().attr('id','list_'+list.id).removeClass('selected').appendTo('#lists')
            $('#list_'+list.id+' a').attr('href',Routes.list_path(list.id,{format: 'html'})).attr('listid',list.id)
            $('#list_'+list.id+' .name').text(list.name)
            $('#list_'+list.id+' .count').text(0)
    )

  # Create an empty List
  create: ->
    $.post(
      Routes.lists_path({format: 'json'})
      {
        list:
          name: I18n.t('lists.create')
      }
      (data) -> Lists.update()
    )
  # Remove the edit-input-field for the list-edit
  unedit: ->
    $('#list_edit_input').remove()
    $(Lists.current_edit).show()
    Lists.current_edit=null
  # Create the input-field for the list-edit
  edit: (name_span) ->
    Lists.unedit() if(Lists.current_edit!=null)
    Lists.current_edit=$(name_span)

    $(name_span).parent().parent().prepend('<input type="text" id="list_edit_input" value="'+$(name_span).text()+'" />')
    $('#list_edit_input').data('edited',false)
    $('#list_edit_input').select()

  current_edit: null



#Tasks
Tasks=
  list_id:null
  update:
    ->
      return alert 'ERROR' if this.list_id==null
      $.getJSON(
        Routes.list_tasks_path(this.list_id,{format: 'json'})
        (tasks) ->
          $('.tasklist li').remove()
          for task in tasks
            # TODO The position of the new list-item should be the same as in the database
            unless $('#task_'+task.id).length>0
              Tasks.append task
      )
  append:
    (task) ->
      symbol='☐'
      done=':first-child'
      if task.done==true
        symbol='☑'
        done=':last-child'


      $('.tasklist' + done).append('<li>' +
        '<a href="' +Routes.list_task_toggle_done_path(Tasks.list_id,task)+'" data-method="post" class="task-toggle">'+ symbol + '</a> ' +
        '<a href="#" class="toggle-show">▸</a> ' +
        '<a href="'+Routes.list_task_path(Tasks.list_id,task,{format: 'json'})+'" class="task-name">' + task.name +
        '<a href="'+Routes.list_task_path(Tasks.list_id,task,{format: 'json'})+'" class="delete-task">' + I18n.t('lists.delete') + '</a>' +
        '<div class="task-content">'+task.content+'</div>' +
        '</li>'
        )
  unedit:
    ->
      $('#task-edit-name').siblings('.task-name').show()
      $('#task-edit-name').remove()


# Live-Events
$(->
  Tasks.list_id=$('#new_task').attr('listid')
  Lists.update()
  # Create a new list
  $('#new-list').live(
    'click'
    ->
      Lists.create()
      return false
  )

  $('#lists li a').live(
    # Redirect only after 500 milliseconds
    click:
      ->
        href = $(this).attr('href')
        Tasks.list_id=$(this).attr('listid')
        list_name=$(this).children('.name').text()
        console.log href
        console.log $('.tasklist').length
        document.location.href = href unless $('.tasklist').length>0
        window.history.pushState(null, "Page title", Routes.list_path(Tasks.list_id,{format:'html'}))
        $.getJSON(
          Routes.list_tasks_path(Tasks.list_id)
          (data) ->
            $('.tasklist li').remove()
            $('#new_task').attr('action',Routes.list_tasks_path(Tasks.list_id)).attr('listid',Tasks.list_id)
            $('#delete-list').attr('href',Routes.list_path(Tasks.list_id),{format:'html'})
            $('.selected').removeClass('selected')
            $('#list_'+Tasks.list_id).addClass('selected')
            $('.new-task').attr('placeholder',I18n.t('tasks.add',{list:list_name}))
            for task in data
              Tasks.append(task)
        )
        return false
      # Edit List on Doubleclick 
    dblclick:
      ->
        name_span=$(this).children('.name')

        # Hide link
        $(name_span).hide()
        Lists.edit(name_span)

        # Hide other Input–Fields

        return false
  )
  $('#list_edit_input').live(
    # Update List–name on Enter
    keypress:
      (e) ->
        $(this).data('edited',true)
        return true unless e.which == 13
        value=$(this).val()
        $.ajax {
          url: Paths.list.replace(':id', $(this).parent().attr('id').replace 'list_', ''),
          type: 'put',
          data: { list: {name: $(this).val() }},
          success: ->
            $(Lists.current_edit).text(value)
            Lists.unedit()
          error: (data) -> alert 'An error occured while saving :(',
        }
    blur:
      ->
        return if $(this).data('edited')
        Lists.unedit()
  )
  $('#new_task').live(
    submit:
      ->
        val=$('#task_name').val()

        $.post(
          Routes.list_tasks_path(Tasks.list_id,{format:'json'})
          { task: {name: val }}
          -> Tasks.update()
        )

        return false
  )
  $('.tasklist li .toggle-show').live(
  )
  $('.tasklist li').live(
    dblclick:
      ->
        $(this).children('.task-name').hide()
        $(this).children('.toggle-show').after('<input type="text" id="task-edit-name" value="' + $(this).children('.task-name').text() + '" />')
        $('#task-edit-name').data('edited',false).select()
        return false
  )
  $('#task-edit-name').live(
    blur:
      ->
        return if $(this).data('edited')
        Tasks.unedit()
  )
  $('.task-content').live(
    dblclick:
      ->
        #        $(this).hide()
        $('#edit-task-content').remove()
        $(this).data('text',$(this).text())
        $(this).html('<textarea id="edit-task-content">' + $(this).text() + '</textarea><br />' +
          '<input type="button" id="edit-task-content-submit" value="' + I18n.t('tasks.save') + '" />' +
          '<input type="button" id="edit-task-content-abort" value="' + I18n.t('tasks.abort') + '" />'
        )
        $('#edit-task-content-abort').click(
          ->
            $(this).parent().text($(this).parent().data('text'))
        )
        return false
  )
'''  # Delete List
  $('#lists li a .delete').live(
    click: (e) ->
      elem=$(this)
      $.ajax {
        url: Paths.list.replace(':id', $(this).parent().attr('id').replace 'list_', ''),
          type: 'delete',
          success: ->
            $(elem).parent().remove()
      }
      return false
    )'''
)
