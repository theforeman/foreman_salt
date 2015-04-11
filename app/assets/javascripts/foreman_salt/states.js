$(document).on( "ContentLoad", function() {
  update_salt_states($('#host_salt_environment_id'));
});

function update_salt_states(element) {
  var host_id = $("form").data('id')
  var env_id = $('*[id*=salt_environment_id]').val();
  var url = $(element).attr('data-url');
  var data = $("form").serialize().replace('method=put', 'method=post');

  if (url.match('hostgroups')) {
    data = data + '&hostgroup_id=' + host_id
  } else {
    data = data + '&host_id=' + host_id
  }

  if (env_id == "") return;

  $(element).indicator_show();
  $.ajax({
    type: 'post',
    url:  url,
    data: data,
    success: function(request) {
      $('#salt_modules').html(request);
      $('[rel="twipsy"]').tooltip();
      multiSelectOnLoad();
    },
    complete: function() {
      $(element).indicator_hide();
    }
  });
}
