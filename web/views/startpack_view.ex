defmodule Karma.StartpackView do
  use Karma.Web, :view

  def for_paye_only do
    ["This is my first job since last 6th April, I have not been receiving taxable jobseekers allowance, employment and support allowance, taxable incapacity benefit, state or occupational pension.": "first since april",
     "This is now my only job, but since last 6 April I have had another job, or have received taxable Jobseeker's Allowance, Employment and Support Allowance or Incapacity Benefit. I do not receive a state or occupational pension.": "now only job",
     "I have another job or receive a state or occupational pension": "have another job"
    ]
  end
end
