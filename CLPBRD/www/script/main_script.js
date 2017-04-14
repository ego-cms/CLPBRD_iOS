function updateButtons() {
    $("#buttonSend").prop("disabled", !$("#entryClipboardText").val());
}
updateButtons();

$("#entryClipboardText").prop("disabled", true);
$("#entryClipboardText").bind("input propertychange", updateButtons);

// Establish remote clipboard connection
$.get("clipboard", function(data) {
      var socket = new WebSocket("ws://" + data.host + ":" + data.port);
      
      $("#entryClipboardText").val(data.text);
      $("#buttonSend").prop("disabled", true);
      
      socket.onopen = function() {
      $("#entryClipboardText").prop("disabled", false);
      $("#buttonSend").prop("disabled", false);
      $("#labelError").hide();
      };
      socket.onclose = function() {
      $("#entryClipboardText").prop("disabled", true);
      $("#buttonSend").prop("disabled", true);
      
      var errorMessage = $().getTranslation("web_page_connection_error_format");
      $("#labelError").html(errorMessage.replace("{{ host }}", window.location.href));
      $("#labelError").show();
      
      setTimeout(function() { location.reload(); }, 5000);
      };
      socket.onmessage = function(message) {
      $("#entryClipboardText").val(message.data);
      }
      socket.onerror = function(error) {
      $("#labelError").text(error.message);
      $("#labelError").show();
      };
      
      $("#entryClipboardText").keydown(function (event) {
                                       if (event.ctrlKey && event.keyCode == 13) {
                                       socket.send($("#entryClipboardText").val());
                                       }
                                       return true;
                                       });
      $("#buttonSend").click(function() {
                             socket.send($("#entryClipboardText").val());
                             });
      });

var topMarginMin = $("#content").css("margin-top").replace("px", "");

function onWindowSizeChanged() {
    $("#content").css("margin-top", Math.max(($('body').height() - $("#content").height()) / 2, topMarginMin) + "px");
}
$(window).resize(onWindowSizeChanged);
$(window).load(function () {
               $('body').fadeIn(650);
               $("#entryClipboardText").css("min-height", ($('body').height() * 0.4) + "px");
               
               onWindowSizeChanged();
               });
