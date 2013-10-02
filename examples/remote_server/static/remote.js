function remoteFunction(path, data, cb) {
  $.post(path, data, cb);
}

function changeInputOutput() {
  var avrInput = $('input[name=avr_input]:checked').val(),
      avrOutput = $('input[name=avr_output]:checked').val(),
      secondaryMonitorSwitchInput = $('input[name=secondary_monitor_switch_input]:checked').val(),
      options = {
        av_receiver_input: avrInput,
        av_receiver_output: avrOutput,
        secondary_monitor_switch_input: secondaryMonitorSwitchInput
      };

  remoteFunction('/custom/set_input_output', options);
}

function increaseVolume(amount) {
  remoteFunction('/custom/increase_volume', {amount: amount}, function(response) {
    var volumeValueSpan = $('#volume_value');
    volumeValueSpan.text(' (' + response + ' dB)');
    volumeValueSpan.show();
    setTimeout(function() {
      volumeValueSpan.hide();
    }, 2000);
  });
}

function mute() {
  remoteFunction("/custom/mute", {});
}
