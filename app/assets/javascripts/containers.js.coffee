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
              bootbox.confirm "清除成功~", (result) ->
                document.location.reload()
    false
  $('.remove-page-ips').click ->
    ips =  $("input[name=\"ip\"]")
    ip_list = new Array
    ip_tags = ""
    ips.each (i) ->
      ip_list.push $(this).val()
      ip_tags += "<span class='label label-warning'> "+$(this).val()+"</span><br>"
    if ip_list.length

      bootbox.confirm
        title: "<i class='fa fa-info blue'> 提示</i>"
        message: '<div class="red" >你确定要清除本页:<br>' + ip_tags + 'container ?</div>'
        callback: (result) ->
          if result
            $.ajax '/containers/remove_ips',
              data:
                ips: ip_list,
              method: 'delete',
              context: this,
              success: (data, status, xhr) ->
                bootbox.confirm "清除成功~", (result) ->
                  document.location.reload()
    false
  $('.remove-all-ips').click ->
    ip_start =  $("#start_ip").val()
    ip_end = $("#end_ip").val()
    unless ip_start && ip_end
      bootbox.alert("区间不能为空!");
    else
      exp = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/
      regstart = ip_start.match(exp)
      regend = ip_end.match(exp)
      unless regstart? && regend?
        bootbox.alert("IP 格式不正确")
      else
        if ip_start > ip_end
          bootbox.alert("start 应该小于 end")
        start_pos = ip_start.lastIndexOf(".")
        end_pos = ip_end.lastIndexOf(".")
        startcheck = ip_start.substring(0, start_pos + 1)
        endcheck = ip_end.substring(0, end_pos + 1)
        ip_list = new Array()
        ip_tags = ""
        unless startcheck is endcheck
          bootbox.alert "两个区间的IP必须在同一个ip段内！"
        else
        start = ip_start.substring(start_pos + 1)
        end = ip_end.substring(end_pos + 1)
        i = start

        while i <= end
          ip_list.push startcheck  + i
          ip_tags += "<span class = 'label label-warning'>" + startcheck + i + "</span><br>"
          i++
        if ip_list.length

          bootbox.confirm
            title: "<i class='fa fa-info blue'> 提示</i>"
            message: '<div class="red" >你确定要清除以下：<br>' + ip_tags + 'container ?</div>'
            callback: (result) ->
              if result
                $.ajax '/containers/remove_ips',
                  data:
                    ips: ip_list,
                  method: 'delete',
                  context: this,
                  success: (data, status, xhr) ->
                    bootbox.confirm "清除成功~", (result) ->
                      document.location.reload()
    false
  $('.remove-ips').click ->
    ips =  $("input[name=\"ip\"]:checked")
    ip_list = new Array
    ip_tags = ""
    ips.each (i) ->
      ip_list.push $(this).val()
      ip_tags += "<span class='label label-warning'> "+$(this).val()+"</span><br>"
    if ip_list.length

      bootbox.confirm
        title: "<i class='fa fa-info blue'> 提示</i>"
        message: '<div class="red" >你确定要清除以下：<br>' + ip_tags + 'container ?</div>'
        callback: (result) ->
          if result
            $.ajax '/containers/remove_ips',
              data:
                ips: ip_list,
              method: 'delete',
              context: this,
              success: (data, status, xhr) ->
                bootbox.confirm "清除成功~", (result) ->
                  document.location.reload()
    false
