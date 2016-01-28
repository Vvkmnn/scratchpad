/*!
 * SessonPath.js
 * by Vivek Menon (https://github.com/vvkmnn)
 *  Influened heavily by the work of Simo Ahava (https://github.com/sahava)
 *
 * Stores Sesson Path variable and pushes to Data Layer
 */

< script >
    // intialitize function environment in GTM
    (function() {
        // if window storage exists for this browser
        if (window['Storage']) {

            //Clear Storage for Debugging purposes
            //sessionStorage.clear();

            // Define sessionPath variable
            var sessionPath = "";

            // if sessionPath already exists
            if (sessionStorage.getItem("sessionPath")) {
                // append existing session path with new page path (GTM Definition)
                sessionPath = sessionStorage.getItem("sessionPath") + " > "
                + {{Page Path}};

            } else {
                // Else initialize string at current page path
                sessionPath = {{Page Path}};
            }

            // Set sessionPath with new value
            sessionStorage.setItem('sessionPath', sessionPath);

            // Push sessionPath to dataLayer via 'sessionpath'
            window.dataLayer.push({
                'sessionpath': sessionPath
            });
        }
    })(); < /script>

// Requires custom dataLayer variable, trigger, and tag to import into GA.
