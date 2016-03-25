goToPath = function(path) { 
  window.location.href = path;
}

nicePrompt = function(title,cb) {
  swal({
    title: title,
    html: '<p><input id="swal-prompt-input-field">',
  },
  function() {
    var val = $('#swal-prompt-input-field').val();
    if (val && cb) { cb(val); }    
  });
}
