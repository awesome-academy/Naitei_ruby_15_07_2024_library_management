import { Modal } from 'bootstrap';

document.addEventListener('DOMContentLoaded', function() {
  var form = document.getElementById('advancedSearchForm');
  var generateReportButton = document.getElementById('generateReportButton');
  var advancedSearchModalElement = document.getElementById('advancedSearchModal');
  var advancedSearchModal = new Modal(advancedSearchModalElement);

  function resetForm() {
    form.reset();

    var multiSelects = form.querySelectorAll('select[multiple]');
    multiSelects.forEach(function(select) {
      select.querySelectorAll('option').forEach(option => option.selected = false);

      const hiddenInput = select.previousElementSibling;
      hiddenInput.value = '';
    });
  }

  if (form) {
    document.getElementById('resetButton').addEventListener('click', function() {
      resetForm()
    });

    if (generateReportButton) {
      generateReportButton.addEventListener('click', function() {
        var reportUrl = generateReportButton.dataset.url;
        form.action = reportUrl;
        form.submit();

        resetForm()

        advancedSearchModal.hide();
    });
    }
  }
});
