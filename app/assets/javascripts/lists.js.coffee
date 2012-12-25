# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


Lists=
  # Update the Lists–List
  update: ->
    $.getJSON(
      Paths.lists
      (data) ->
        console.log data
        for list in data
          unless $('#list_'+list.id).length>0
            $('#lists li:first-child').clone().attr('id','list_'+list.id).removeClass('selected').appendTo('#lists')
            $('#list_'+list.id+' a').attr('href',Paths.list.replace(':id',list.id).replace('.json',''))
            $('#list_'+list.id+' .name').text(list.name)
            $('#list_'+list.id+' .count').text(0)
    )
  # Create an empty List
  create: ->
    $.post(
      Paths.lists,
      {
        list:
          name:'New List'
      }
      (data) -> Lists.update()
    )
  unedit: ->
    $('#list_edit_input').remove()
    $(Lists.current_edit).show()
    Lists.current_edit=null
  edit: (name_span) ->
    Lists.unedit() if(Lists.current_edit!=null)
    Lists.current_edit=$(name_span)

    $(name_span).parent().parent().prepend('<input type="text" id="list_edit_input" value="'+$(name_span).text()+'" />')
    $('#list_edit_input').select()

  current_edit: null




$(->
  Lists.update()
  # Show list only on click
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

        unless $(this).data('timer')
          $(this).data 'timer', setTimeout(
            ->
              window.location.href=href
              $.get(
                href+'.json'
                (data) ->
              )
            250
          )
        return false
    # Edit List on Doubleclick 
    dblclick:
      ->
        # Clear Timeout for click
        clearTimeout $(this).data('timer')
        $(this).data('timer', null)

        name_span=$(this).children('.name')

        # Hide link
        $(name_span).hide()
        Lists.edit(name_span)

        # Hide other Input–Fields

        return false
  )
  # Update List–name on Enter
  $('#list_edit_input').live(
    keypress:
      (e) ->
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
      -> Lists.unedit()
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
