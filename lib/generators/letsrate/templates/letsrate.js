$.fn.raty.defaults.path = "/assets";
$.fn.raty.defaults.half_show = true;

$(function(){
  $(".star").each(function() {
    var $readonly = ($(this).attr('data-readonly') == 'true');
    $(this).raty({
      score: function(){
        return $(this).attr('data-rating')
      },
      number: function() {
        return $(this).attr('data-star-count')
      },
      readOnly: $readonly,
      click: function(score, evt) {
        var _this = this;
        $(document).ajaxSend(function(e, xhr, options) {
          var token = $("meta[name='csrf-token']").attr("content");
          xhr.setRequestHeader("X-CSRF-Token", token);
        });
        $.post('/rater',
        {
          score: score,
          dimension: $(this).attr('data-dimension'),
          id: $(this).attr('data-id'),
          klass: $(this).attr('data-classname')
        },
        function(data) {
          if(data) {
            // success code goes here ...

            if ($(_this).attr('data-disable-after-rate') == 'true') {
              $(_this).raty('set', { readOnly: true, score: score });
            }
          }
        });
		  }
    });
	});
});



