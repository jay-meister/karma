// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

function custom_field_listeners() {
  var custom_field_dropdown = document.getElementById('custom_field_dropdown');
  var custom_field_dropdown_container = document.getElementById('custom_field_dropdown_container');
  var custom_field_value_container = document.getElementById('custom_field_value_container');
  custom_field_dropdown.addEventListener("change", function(e) {
    var type = e.target.value;
    if (type === "Offer") {
      custom_field_value_container.className += " dn"
    } else {
      custom_field_value_container.className = custom_field_value_container.className.replace(/dn/g, "");
    }
  })
}

function document_upload_listeners() {
  var document_category = document.getElementById('category_dropdown');
  var contract_dropdown = document.getElementById('contract_dropdown');
  var contract_dropdown_container = document.getElementById('contract_dropdown_container');
  var non_contract_dropdown = document.getElementById('non_contract_dropdown');
  var non_contract_dropdown_container = document.getElementById('non_contract_dropdown_container');
  document_category.addEventListener("change", function(e) {
    var category = e.target.value;
    if (category === "Deal") {
      contract_dropdown_container.className = contract_dropdown_container.className.replace(/dn/g, "");
      non_contract_dropdown_container.className = non_contract_dropdown_container.className.concat(" dn");
    } else if (category === "Form" || category === "Info") {
      contract_dropdown_container.className = contract_dropdown_container.className.concat(" dn");
      non_contract_dropdown_container.className = non_contract_dropdown_container.className.replace(/dn/g, "")
    } else {
      contract_dropdown_container.className = contract_dropdown_container.className.concat(" dn");
      non_contract_dropdown_container.className = non_contract_dropdown_container.className.concat(" dn");
    }
  });
}

function addFileUploadNames(id) {
  var fileUploadContainer = document.getElementById("file-upload-container-" + id);
  var filenameContainer = document.getElementById("filename-container-" + id);

  fileUploadContainer.addEventListener("change", function(e) {
    var filename = e.target.value.split("\\").pop();
    filenameContainer.innerHTML = filename;
  });
}

function setupListeners(job_title) {
  var departments_with_jobs = require("./departments_with_jobs.js")

  var departmentDropdown = document.getElementById('department_dropdown');
  var jobTitleDropdown = document.getElementById('job_title_dropdown');

  var initialJobTitleValues = departments_with_jobs.default[departmentDropdown.options[departmentDropdown.selectedIndex].text]

  initialJobTitleValues.forEach(function (jobTitleValue) {
    var opt = document.createElement('option');
    opt.value = jobTitleValue;
    opt.innerHTML = jobTitleValue;
    jobTitleDropdown.appendChild(opt)
    if (job_title !== "") {
      jobTitleDropdown.value = job_title.replace("&#39;", '\'');
    }
  });


  departmentDropdown.addEventListener("change", function() {
    var jobTitleValues = departments_with_jobs.default[departmentDropdown.options[departmentDropdown.selectedIndex].text]
    jobTitleDropdown.innerHTML = "";
    var prompt = document.createElement('option');
    prompt.value = "";
    prompt.innerHTML = "select..."
    jobTitleDropdown.appendChild(prompt)
    jobTitleValues.forEach(function (jobTitleValue) {
      var opt = document.createElement('option');
      opt.value = jobTitleValue;
      opt.innerHTML = jobTitleValue;
      jobTitleDropdown.appendChild(opt)
    });
  });
}

function studentLoanRadios() {
  // containing div
  var optionalQuestionContainer = document.querySelector('[selector="container-student_loan_plan_1?"]')
  // array of 2 radios
  var direct = document.querySelectorAll('[selector="student_loan_repay_direct?"]')
  direct.forEach(function (radio) {
    // show or hide optional question depending on initial state
    if (radio.value === "true" && radio.checked) {
      optionalQuestionContainer.style.display = 'none'
    } else if (radio.value === "false" && radio.checked) {
      optionalQuestionContainer.style.display = 'block'
    }
    // add event listeners to the radio
    radio.addEventListener("change", function(v) {
      if (v.target.value === "true") {
        optionalQuestionContainer.style.display = 'none'
      } else {
        optionalQuestionContainer.style.display = 'block'
      }
    })
  })
}

function hamburgerAnimate() {
  var hamburger = document.querySelector ('#hamburger');
  var list = document.querySelector ('#list');
  var nav = document.querySelector ('nav');

  hamburger.onclick = function () {
    list.classList.toggle('height-auto');
    nav.classList.toggle('height-fixed');
    }
}

function reverseScientificNotation() {
  var numberInputs = document.querySelectorAll('input[type="number"]')
  numberInputs.forEach(function (input) {
    var num = +input.value
    if (input.id !== 'project_duration') {
      input.value = num.toFixed(2)
    }
  })
}


export var App = {
  addFileUploadNames: addFileUploadNames,
  setupListeners: setupListeners,
  studentLoanRadios: studentLoanRadios,
  hamburgerAnimate: hamburgerAnimate,
  document_upload_listeners: document_upload_listeners,
  reverseScientificNotation: reverseScientificNotation,
  custom_field_listeners: custom_field_listeners
}
