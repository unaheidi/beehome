$(document).on 'ready page:load', ->
  $('.remove-ip').click ->
    ip =  $(this).parents('tr').find('.need-remove-ip').val();
    ips = new Array
    ips.push ip
    that = $(this)
    bootbox.confirm
      title: "<i class='fa fa-info blue'> 提示</i>"
      message: '<div class="red" >你确定要清除<span class= "label label-warning">' + ips + '</span>的container ?</div>'
      callback: (result) ->
        if result
          $.ajax '/containers/remove_ips',
            data:
              ips: ips,
            method: 'delete',
            success: (data, status, xhr) ->
              that.parents('tr').hide()
    false
  $('.remove-ips').click ->
    ips =  $("input[name=\"ip\"]:checked")
    ip_list = new Array
    ips.each (i) ->
      ip_list.push $(this).val()

    bootbox.confirm
      title: "<i class='fa fa-info blue'> 提示</i>"
      message: '<div class="red" >你确定要清除<span class= "label label-warning">' + ip_list + '</span>的container ?</div>'
      callback: (result) ->
        if result
          $.ajax '/containers/remove_ips',
            data:
              ips: ip_list,
            method: 'delete',
            context: this,
            success: (data, status, xhr) ->
              alert("delete success")
    false
