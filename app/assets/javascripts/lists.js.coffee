# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

nl2br= (str)->
  return (str + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br />' + '$2')
Lists=
  # Update the Lists–List
  update: ->
    $.getJSON(
      Routes.lists_path({format: 'json'})
      (data) ->
        for list in data
          # TODO The position of the new list-item should be the same as in the database
          unless $('#list_'+list.id).length>0
            $('#lists li:first-child').clone().attr('id','list_'+list.id).removeClass('selected').appendTo('#lists ul')
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

      if task.priority == 0
        prio_symbol='±'
      else
        if task.priority > 0
          prio_symbol='+'
        else
          prio_symbol='−'

      task.content='<i>' + I18n.t('tasks.no_task_content') + '</i>' if task.content==null


      $('.tasklist' + done).append('<li taskid="'+task.id + '">' +
        '<a href="' +Routes.list_task_toggle_done_path(Tasks.list_id,task,{format: 'html'})+'" class="task-toggle">'+ symbol + '</a> ' +
        '<a href="" class="task-priority prio-' + task.priority + '">' + prio_symbol + task.priority + '</a> ' +
        '<a href="'+Routes.list_task_path(Tasks.list_id,task,{format: 'html'})+'" class="task-name" taskid="' + task.id + '">' + task.name +
        '<a href="'+Routes.list_task_path(Tasks.list_id,task,{format: 'html'})+'" data-method="delete" class="delete-task">' + I18n.t('tasks.delete') + '</a>' +
        '<div class="task-content">'+nl2br(task.content)+'</div>' +
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
  $('#lists ul').sortable(
    update: (e,ui) ->
      id=$(ui.item).prev().children('a').attr('listid')
      if typeof(id)=='undefined'
        id=0
      $.post(Routes.list_move_after_path($(ui.item).children('a').attr('listid'),id))
  )

  $('#lists li a').live(
    # Redirect only after 500 milliseconds
    click:
      ->
        href = $(this).attr('href')
				#TODO fix sidelist
        Tasks.list_id=$(this).attr('listid')
        list_name=$(this).children('.name').text()
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
        $('#task_name').val('')

        $.post(
          Routes.list_tasks_path(Tasks.list_id,{format:'json'})
          { task: {name: val }}
          -> Tasks.update()
        )

        return false
  )
  $('.tasklist input,.tasklist textarea').live(
    click: -> return false
  )
  $('.tasklist li .task-name').live(
    click:
      ->
        $(this).hide()
        $(this).siblings('.task-toggle').after('<input type="text" id="task-edit-name" value="' + $(this).text() + '" />')
        $('#task-edit-name').data('edited',false).select()
        return false
  )
  $('.tasklist li .task-toggle').removeAttr('data-method')
  $('.tasklist li .task-toggle').live(
    click: ->
      $.post(Routes.list_task_toggle_done_path($(this).parent().attr('listid'),$(this).parent().attr('taskid'),{format: 'html'}))
      if $(this).parent().parent().hasClass('undone')
        $(this).text('☑')
        $(this).parent().appendTo('.tasklist.done')
      else
        $(this).text('☐')
        $(this).parent().appendTo('.tasklist.undone')
      return false
  )
#  $('.tasklist li .delete-task').removeAttr('data-method')
#  $('.tasklist li .delete-task').live(
#    click: ->
#      console.log 1
#      elem=$(this)
#      console.log 1
#      $.ajax({
#        url:$(elem).attr('href')
#        type:'delete'
#        success: ->
#      })
#      console.log 1
#      console.log 1
#      return false
#        
#  )

  $('.tasklist li').live(
    click:
      ->
        if $(this).data('open')==true
          $(this).children('.task-content').slideUp()
          $(this).data('open',false)
        else
          $(this).children('.task-content').slideDown()
          $(this).data('open',true)
        return false
  )
  $('#task-edit-name').live(
    blur:
      ->
        return if $(this).data('edited')
        Tasks.unedit()
    click:
      ->
        return false
    keypress:
      (e) ->
        $(this).data('edited',true)
        return true unless e.which == 13
        value=$(this).val()
        elem=$(this)
        $.ajax {
          url: Routes.list_task_path($(elem).siblings('.task-name').attr('listid'),$(elem).siblings('.task-name').attr('taskid'))
          type: 'put',
          data: { task: {name: value }},
          success: ->
            $(elem).siblings('.task-name').text(value)
            Tasks.unedit()
          error: (data) -> alert 'An error occured while saving :(',
        }
  )
  $('.task-content').live(
    click:
      ->
        #        $(this).hide()
        $('#edit-task').parent().html('<i>'+$('#edit-task-content').text()+'</i>')
        $(this).data('text',$(this).text())
        $(this).html('<div id="edit-task"><textarea id="edit-task-content">' + $(this).text() + '</textarea><br />' +
          '<input type="button" id="edit-task-content-submit" value="' + I18n.t('tasks.save') + '" />' +
          '<input type="button" id="edit-task-content-abort" value="' + I18n.t('tasks.abort') + '" /></div>'
        )
        $('#edit-task-content').select()
        $('#edit-task-content-abort').click(->
            $(this).parent().parent().html(nl2br($(this).parent().parent().data('text')))
            return false
        )
        $('#edit-task-content-submit').click(->
          val=$('#edit-task-content').val()
          id=$(this).parent().parent().parent().attr('taskid')
          elem=$(this)
          $.ajax {
            url: Routes.list_task_path($(this).parent().parent().parent().attr('listid'),id)
            type: 'put',
            data: { task: {content: val }},
            success: -> $(this).parent().parent().html(nl2br(val)),
            error: (data) -> alert 'An error occured while saving :(',
          }
          return false
        )
        return false
  )
  $('li .task-priority').live(
    mousemove: (e) ->
      offset = $(this).offset()
      $('#priopopup').css(offset).show().data({
        task: $(this)
        timer: true
        mouseover: false
      })
      setTimeout(
        ->
          $('#priopopup').data('timer',false)
          $('#priopopup').hide() unless $('#priopopup').data('mouseover')==true
        1000
      )
  )
  $('#priopopup').live(
    mouseover: ->
      $(this).data('mouseover',true)
    mouseleave: ->
      $(this).hide() unless $(this).data('timer')
  )
  $('#priopopup a').live(
    click: (e) ->
      elem=$('#priopopup').data('task')
      id=$(elem).parent().attr('taskid')
      $.ajax(
        url: Routes.list_task_path($(elem).parent().attr('listid'),id),
        type: 'PUT',
        data: {task: { priority: $(this).attr('val') }}
      )
      $('#priopopup').hide()
      $(elem).text($(this).text()).attr('class',$(this).parent().attr('class'))

      return false
  )
)
