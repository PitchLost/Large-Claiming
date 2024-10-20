$(document).ready(function() {
    $('#claiming-container').hide()
    window.addEventListener('message', function(event) {
     
        console.log('UI request recieved!',event.data)
        console.log(event.data.data)
        if (event.data.type == 'claimingUiUpdate') { 
            $('#claiming-container').show()
            $('#time-left').text(event.data.time + ' remaining')
            $('#winning-team').text('Claimed By: ' + event.data.claimer)
        }
    });

   // Event listener for DOMContentLoaded event
   window.addEventListener('DOMContentLoaded', function(event) { 

});

})