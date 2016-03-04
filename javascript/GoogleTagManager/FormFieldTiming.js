/*!
 * FormFieldTiming.js
 * by Vivek Menon (https://github.com/vvkmnn)
 *  Influened heavily by the work of Simo Ahava (https://github.com/sahava)
 *
 * Stores Form Field Timings in a data layer variable.
 * Full guide available here: http://www.simoahava.com/analytics/track-form-abandonment-with-google-tag-manager/#4
 */

 XHTML
 <script>
 (function() {
   // .querySelector uses CSS; must point to form via form id in format: #formnamehere
   // Can also use generic document.forms[0] to find first form on page
   // Can also use generic  var formSelector = 'form' to grab first form on page

   // var form = document.querySelector('#formidhere');
   var form = document.forms[0]
   var fields = {};

   var enterField = function(name) {
     fields[name] = new Date().getTime();
   }

   var leaveField = function(e) {
     var timeSpent;
     var fieldName = e.target.name;
     var leaveType = e.type;
     if (fields.hasOwnProperty(fieldName)) {
       timeSpent = new Date().getTime() - fields[fieldName];
       if (timeSpent > 0 && timeSpent < 1800000) {
         window.dataLayer.push({
           'event' : 'fieldTiming',
           'timingCategory' : 'Form Field Timing' + ' (' + form.name + ')',
           'timingVariable' : fieldName,
           'timingLabel' : leaveType,
           'timingValue' : timeSpent
         });
       }
       delete fields[fieldName];
     }
   }

   if (form) {
     form.addEventListener('focus', function(e) { enterField(e.target.name); }, true);
     form.addEventListener('blur', function(e) { leaveField(e); }, true);
     form.addEventListener('change', function(e) { leaveField(e); }, true);
   }
 })();
 </script>

// Requires custom dataLayer variable for all push variables, an event trigger for 'fieldTiming', and tag to import into GA.
