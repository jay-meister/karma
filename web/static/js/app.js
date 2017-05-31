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
    prompt.innerHTML = "Pick a job title..."
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

export var App = {
  setupListeners: setupListeners,
  studentLoanRadios: studentLoanRadios
}
