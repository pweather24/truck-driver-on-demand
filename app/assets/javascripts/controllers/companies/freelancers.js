$(document).on("turbolinks:load", function () {
  if ($(".company-freelancers").length == 0) {
    return;
  }
  
  $("#freelance_distance").on('change', function() {
    var val = this.value;
    $("#distance").val(val);
    $("#freelancer_search_form").submit();
  });

  $("#freelance_sort").on('change', function() {
    var val = this.value;
    $("#sort").val(val);
    $("#freelancer_search_form").submit();
  });
});