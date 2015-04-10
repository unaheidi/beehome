$(document).on 'ready page:load', ->
  $('.rebuild-ip').click ->
    ip =  $(this).parents('tr').find('.need-rebuild-ip').val();
    ips = new Array
    ips.push ip
    that = $(this)
    bootbox.confirm
      title: "<i class='fa fa-info blue'> 提示</i>"
      message: '<div class="red" >你确定要重建<span class= "label label-warning">' + ips + '</span>的container ?</div>'
      callback: (result) ->
        if result
          $.ajax '/alpha/rebuild',
            data:
              ips: ips,
            method: 'get',
            success: (data, status, xhr) ->
              bootbox.confirm "重建成功~", (result) ->
                Turbolinks.visit(window.location)
    false

  $('.new-ip').click ->
    ip =  $("#ip").val();

    unless ip
      bootbox.alert("IP不能为空!");
    else
      exp = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/
      reg = ip.match(exp)
      unless reg? 
        bootbox.alert("IP 格式不正确")
      else
        that = $(this)
        bootbox.confirm
          title: "<i class='fa fa-info blue'> 提示</i>"
          message: '<div class="red" >你确定要IP为 <span class= "label label-warning">' + ip + '</span>的 alpha 虚机 ?</div>'
          callback: (result) ->
            if result
              $.ajax '/alpha/new_ip',
                data:
                  ip: ip,
                method: 'get',
                success: (data, status, xhr) ->
                  bootbox.confirm "新建alpha成功~", (result) ->
                    Turbolinks.visit(window.location)
                error: (data, status, xhr) ->
                  bootbox.confirm "新建alpha失败！", (result) ->
                    Turbolinks.visit(window.location)
    false
  $('.rebuild-page-ips').click ->
    ips =  $("input[name=\"ip\"]")
    ip_list = new Array
    ip_tags = ""
    ips.each (i) ->
      ip_list.push $(this).val()
      ip_tags += "<span class='label label-warning'> "+$(this).val()+"</span><br>"
    if ip_list.length

      bootbox.confirm
        title: "<i class='fa fa-info blue'> 提示</i>"
        message: '<div class="red" >你确定要重建本页:<br>' + ip_tags + 'container ?</div>'
        callback: (result) ->
          if result
            $.ajax '/alpha/rebuild',
              data:
                ips: ip_list,
              method: 'get',
              context: this,
              success: (data, status, xhr) ->
                bootbox.confirm "重建成功~", (result) ->
                  Turbolinks.visit(window.location)
    false
  $('.rebuild-all-ips').click ->
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
            message: '<div class="red" >你确定要重建以下：<br>' + ip_tags + 'container ?</div>'
            callback: (result) ->
              if result
                $.ajax '/alpha/rebuild',
                  data:
                    ips: ip_list,
                  method: 'get',
                  context: this,
                  success: (data, status, xhr) ->
                    bootbox.confirm "重建成功~", (result) ->
                      Turbolinks.visit(window.location)
    false
  $('.rebuild-ips').click ->
    ips =  $("input[name=\"ip\"]:checked")
    ip_list = new Array
    ip_tags = ""
    ips.each (i) ->
      ip_list.push $(this).val()
      ip_tags += "<span class='label label-warning'> "+$(this).val()+"</span><br>"
    if ip_list.length

      bootbox.confirm
        title: "<i class='fa fa-info blue'> 提示</i>"
        message: '<div class="red" >你确定要重建以下：<br>' + ip_tags + 'container ?</div>'
        callback: (result) ->
          if result
            $.ajax '/alpha/rebuild',
              data:
                ips: ip_list,
              method: 'get',
              context: this,
              success: (data, status, xhr) ->
                bootbox.confirm "重建成功~", (result) ->
                  Turbolinks.visit(window.location)
    false
