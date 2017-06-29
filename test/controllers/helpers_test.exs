defmodule Karma.Controllers.HelpersTest do
  use Karma.ConnCase

  alias Karma.Controllers.Helpers

  test "calc_day_fee_inc_holidays(fee_per_day_inc_holiday, day_fee_multiplier)" do
    day_fee_inc_holidays =  Helpers.calc_day_fee_inc_holidays(2, 1)

    assert day_fee_inc_holidays == 2
  end

  test "calc_day_fee_exc_holidays(fee_per_day_exc_holiday, day_fee_multiplier)" do
    day_fee_exc_holidays =  Helpers.calc_day_fee_exc_holidays(2, 1)

    assert day_fee_exc_holidays == 2
  end

  test "calc_fee_per_day_exc_holiday(fee_per_day_inc_holiday, project_holiday_rate)" do
    fee_per_day_exc_holiday =  Helpers.calc_fee_per_day_exc_holiday(2, 1)

    assert fee_per_day_exc_holiday == 1
  end

  test "calc_holiday_pay_per_day(fee_per_day_inc_holiday, fee_per_day_exc_holiday)" do
    holiday_pay_per_day = Helpers.calc_holiday_pay_per_day(2, 1)

    assert holiday_pay_per_day == 1
  end

  test "calc_fee_per_week_inc_holiday(fee_per_day_inc_holiday, working_week)" do
    fee_per_week_inc_holiday = Helpers.calc_fee_per_week_inc_holiday(1, 1)

    assert fee_per_week_inc_holiday == 1
  end

  test "calc_fee_per_week_exc_holiday(fee_per_week_inc_holiday, project_holiday_rate)" do
    fee_per_week_exc_holiday = Helpers.calc_fee_per_week_exc_holiday(2, 1)

    assert fee_per_week_exc_holiday == 1
  end

  test "calc_holiday_pay_per_week(fee_per_week_inc_holiday, fee_per_week_exc_holiday)" do
    holiday_pay_per_week = Helpers.calc_holiday_pay_per_week(2, 1)

    assert holiday_pay_per_week == 1
  end

  test "determine_contract_type(department, job_title) Accounts" do
    sch_d_contract = Helpers.determine_contract_type("Accounts", "Financial Controller", [])
    paye_contract = Helpers.determine_contract_type("Accounts", "Accounts Clerk", [])

    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Action Vehicles" do
    paye_contract = Helpers.determine_contract_type("Action Vehicles", "Carriage Master", [])

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Assistant Directors" do
    sch_d_contract = Helpers.determine_contract_type("Assistant Director", "1st Assistant Director", [])
    paye_contract = Helpers.determine_contract_type("Assistant Director", "2nd Assistant Director", [])

    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Aerial" do
    sch_d_contract = Helpers.determine_contract_type("Aerial", "Aerial Cameraman", [])

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) Animals" do
    sch_d_contract = Helpers.determine_contract_type("Animals", "Animal Wrangler", [])
    paye_contract = Helpers.determine_contract_type("Animals", "Assistant Horse Master", [])

    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Armoury" do
    sch_d_contract = Helpers.determine_contract_type("Armoury", "Archery Instructor", [])
    paye_contract = Helpers.determine_contract_type("Armoury", "Armoury Concept Artist", [])
    conditional_contract = Helpers.determine_contract_type("Armoury", "Senior Model Maker", [])

    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Art" do
    sch_d_contract = Helpers.determine_contract_type("Art", "Art Director", [])
    paye_contract = Helpers.determine_contract_type("Art", "Art Trainee", [])
    conditional_contract = Helpers.determine_contract_type("Art", "Scenic Painter", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Camera" do
    sch_d_contract = Helpers.determine_contract_type("Camera", "Director Of Photography", [])
    paye_contract = Helpers.determine_contract_type("Camera", "1st Assistant Camera", [])
    conditional_contract = Helpers.determine_contract_type("Camera", "Camera Operator", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Cast" do
    sch_d_contract = Helpers.determine_contract_type("Cast", "Actor", [])
    paye_contract = Helpers.determine_contract_type("Cast", "Actor Double", [])
    conditional_contract = Helpers.determine_contract_type("Cast", "Unit Driver", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Construction" do
    sch_d_contract = Helpers.determine_contract_type("Construction", "Buyer", [])
    paye_contract = Helpers.determine_contract_type("Construction", "Carpenter", [])
    conditional_contract = Helpers.determine_contract_type("Construction", "Scenic Painter", [])


    assert sch_d_contract == "CONSTRUCTION SCHEDULE-D"
    assert paye_contract == "CONSTRUCTION PAYE"
    assert conditional_contract == "CONSTRUCTION PAYE"
  end

  test "determine_contract_type(department, job_title) Continuity" do
    sch_d_contract = Helpers.determine_contract_type("Continuity", "Script Supervisor", [])
    paye_contract = Helpers.determine_contract_type("Continuity", "Assistant Script Supervisor", [])

    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Costume" do
    sch_d_contract = Helpers.determine_contract_type("Costume", "Buyer", [])
    paye_contract = Helpers.determine_contract_type("Costume", "Assistant Buyer", [])
    conditional_contract = Helpers.determine_contract_type("Costume", "Seamstress", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) DIT" do
    conditional_contract = Helpers.determine_contract_type("DIT", "Data Wrangler", [])
    paye_contract = Helpers.determine_contract_type("DIT", "Array DIT", [])

    assert conditional_contract == "PAYE"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Drapes" do
    conditional_contract = Helpers.determine_contract_type("Drapes", "Drapesman", [])
    paye_contract = Helpers.determine_contract_type("Drapes", "Drapes Master", [])

    assert conditional_contract == "PAYE"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Editorial" do
    sch_d_contract = Helpers.determine_contract_type("Editorial", "Assembly Editor", [])
    paye_contract = Helpers.determine_contract_type("Editorial", "Assistant Editor", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Electrical" do
    sch_d_contract = Helpers.determine_contract_type("Electrical", "VFX Editor", [])
    paye_contract = Helpers.determine_contract_type("Electrical", "Desk Operator", [])
    conditional_contract = Helpers.determine_contract_type("Electrical", "Balloon Technician", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Greens" do
    paye_contract = Helpers.determine_contract_type("Greens", "Greens Person", [])

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Grip" do
    sch_d_contract = Helpers.determine_contract_type("Grip", "Crane Grip", [])
    paye_contract = Helpers.determine_contract_type("Grip", "Grip Rigger", [])
    conditional_contract = Helpers.determine_contract_type("Grip", "Best Boy Grip", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Hair And Makeup" do
    sch_d_contract = Helpers.determine_contract_type("Hair And Makeup", "Hair Designer", [])
    paye_contract = Helpers.determine_contract_type("Hair And Makeup", "Hairdresser", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) IT" do
    paye_contract = Helpers.determine_contract_type("IT", "1st Line IT Support", [])

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Locations" do
    sch_d_contract = Helpers.determine_contract_type("Locations", "Location Manager", [])
    paye_contract = Helpers.determine_contract_type("Locations", "Locations Marshall", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Medical" do
    sch_d_contract = Helpers.determine_contract_type("Medical", "Medic", [])

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) Military" do
    sch_d_contract = Helpers.determine_contract_type("Military", "Military Advisor", [])

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) Photography" do
    conditional_contract = Helpers.determine_contract_type("Photography", "Photographer", [])

    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Post Production" do
    sch_d_contract = Helpers.determine_contract_type("Post Production", "Post Production Supervisor", [])
    paye_contract = Helpers.determine_contract_type("Post Production", "Coordinator", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Production" do
    sch_d_contract = Helpers.determine_contract_type("Production", "Co-Producer", [])
    paye_contract = Helpers.determine_contract_type("Production", "Cast Assistant", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Props" do
    sch_d_contract = Helpers.determine_contract_type("Props", "HOD Prop Modeller", [])
    paye_contract = Helpers.determine_contract_type("Props", "Chargehand Dresser", [])
    conditional_contract = Helpers.determine_contract_type("Props", "Chargehand Dressing Prop", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Publicity" do
    sch_d_contract = Helpers.determine_contract_type("Publicity", "Unit Publicist", [])

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) Rigging" do
    sch_d_contract = Helpers.determine_contract_type("Rigging", "HOD Rigger", [])
    paye_contract = Helpers.determine_contract_type("Rigging", "Rigger", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Security" do
    paye_contract = Helpers.determine_contract_type("Security", "Security", [])

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Set Dec" do
    sch_d_contract = Helpers.determine_contract_type("Set Dec", "Art Director", [])
    paye_contract = Helpers.determine_contract_type("Set Dec", "Coordinator", [])
    conditional_contract = Helpers.determine_contract_type("Set Dec", "Scenic Textile Artist", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) SFX" do
    sch_d_contract = Helpers.determine_contract_type("SFX", "Floor Director", [])
    paye_contract = Helpers.determine_contract_type("SFX", "Floor Technician", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Sound" do
    sch_d_contract = Helpers.determine_contract_type("Sound", "Production Sound Mixer", [])
    paye_contract = Helpers.determine_contract_type("Sound", "1st Assistant Sound", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Standby" do
    paye_contract = Helpers.determine_contract_type("Standby", "Rigger", [])

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Studio Unit" do
    paye_contract = Helpers.determine_contract_type("Studio Unit", "Studio Unit Manager", [])

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Stunts" do
    sch_d_contract = Helpers.determine_contract_type("Stunts", "Stunt Coordinator", [])
    paye_contract = Helpers.determine_contract_type("Stunts", "Rigger", [])
    conditional_contract = Helpers.determine_contract_type("Stunts", "Wire Rigger", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Supporting Artist" do
    sch_d_contract = Helpers.determine_contract_type("Supporting Artist", "Pay Direct Extra", [])

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) Transport" do
    sch_d_contract = Helpers.determine_contract_type("Transport", "Transport Captain", ["TRANSPORT DIRECT HIRE"])
    paye_contract = Helpers.determine_contract_type("Transport", "Transport Coordinator", ["TRANSPORT DIRECT HIRE"])
    conditional_contract = Helpers.determine_contract_type("Transport", "Unit Driver", ["TRANSPORT DIRECT HIRE"])
    direct_hire = Helpers.determine_contract_type("Transport", "Rushes Runner", ["TRANSPORT DIRECT HIRE"])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "TRANSPORT PAYE"
    assert direct_hire == "TRANSPORT DIRECT HIRE"
  end

  test "determine_contract_type(department, job_title) Underwater" do
    sch_d_contract = Helpers.determine_contract_type("Underwater", "Cameraman", [])

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) VFX" do
    sch_d_contract = Helpers.determine_contract_type("VFX", "VFX Producer", [])
    paye_contract = Helpers.determine_contract_type("VFX", "Data Wrangler", [])


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Video" do
    paye_contract = Helpers.determine_contract_type("Video", "Video Assistant", [])

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Voice" do
    sch_d_contract = Helpers.determine_contract_type("Voice", "Voice Coach", [])

    assert sch_d_contract == "SCHEDULE-D"
  end
end
