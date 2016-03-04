/*!
 * FormTiming.js
 * by Vivek Menon (https://github.com/vvkmnn)
 *  Influened heavily by the work of Simo Ahava (https://github.com/sahava)
 *
 * Stores Form Timing in a data layer variable, built from the guide here: http://www.simoahava.com/analytics/track-form-abandonment-with-google-tag-manager/#4
 * Operates in a Custom HTML Tag
 */
 <script>
    var form = document.forms[0];
    var formTimer = new Date().getTime();

    //console.log('debug:formtimer='+ formTimer);


 var formTimerEnd = function() {
        formTimer = new Date().getTime() - formTimer;

        window.dataLayer.push({
            'event': 'formTiming',
            'timingCategory': 'Form Overall Timing',
            'timingVariable': form.name,
            'timingLabel': 'Overall',
            'timingValue': formTimer
        });

       //console.log('debug: After submit, formtimer='+ formTimer);


    }

  if (form) {
      form.querySelectorAll("submit")[0].addEventListener('click',formTimerEnd);
  }


</script>
        // Requires custom dataLayer variable for all push variables, and a trigger listening to event 'formTiming'.
