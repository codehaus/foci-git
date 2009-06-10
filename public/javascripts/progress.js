/* Used to handle the ajax requests for the progress page, when long processes
 * are being run with BackgrounDRb. Simply updates a given tag element in the
 * page with new progress information until a path to the result page is given,
 * meaning the background worker has finished its job. Once that happens,
 * instead of updating a part of the page, redirect the whole page to the
 * results URL.
 *
 * Params:
 * url <= The URL to call for the update info.
 * element <= Id of the tag, that gets updated with the new info.
 * error <= Id of the tag, that gets updated with error info.
 */
function progressUpdater(url, element, error) {
  var element = $(element);
  var error = $(error);

  new Ajax.Request(url, {
    method: 'get',

    onSuccess: function(transport) {
      var response = transport.responseText;

      if (response.match(/\/[a-z]*\/[a-z_]*(\?)([a-z_]*\=.*)+/))
        window.location.href = response;
      else
        element.update(response);
        error.update('');
    },

    onFailure: function() {
      error.update('Last request to server failed.');
    }
  });
}
