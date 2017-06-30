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
    sch_d_contract = Helpers.determine_contract_type("Accounts", "Financial Controller", [], false)
    paye_contract = Helpers.determine_contract_type("Accounts", "Accounts Clerk", [], false)

    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Action Vehicles" do
    paye_contract = Helpers.determine_contract_type("Action Vehicles", "Carriage Master", [], false)

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Assistant Directors" do
    sch_d_contract = Helpers.determine_contract_type("Assistant Director", "1st Assistant Director", [], false)
    paye_contract = Helpers.determine_contract_type("Assistant Director", "2nd Assistant Director", [], false)

    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Aerial" do
    sch_d_contract = Helpers.determine_contract_type("Aerial", "Aerial Cameraman", [], false)

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) Animals" do
    sch_d_contract = Helpers.determine_contract_type("Animals", "Animal Wrangler", [], false)
    paye_contract = Helpers.determine_contract_type("Animals", "Assistant Horse Master", [], false)

    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Armoury" do
    sch_d_contract = Helpers.determine_contract_type("Armoury", "Archery Instructor", [], false)
    paye_contract = Helpers.determine_contract_type("Armoury", "Armoury Concept Artist", [], false)
    conditional_contract = Helpers.determine_contract_type("Armoury", "Senior Model Maker", [], false)

    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Art" do
    sch_d_contract = Helpers.determine_contract_type("Art", "Art Director", [], false)
    paye_contract = Helpers.determine_contract_type("Art", "Art Trainee", [], false)
    conditional_contract = Helpers.determine_contract_type("Art", "Scenic Painter", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Camera" do
    sch_d_contract = Helpers.determine_contract_type("Camera", "Director Of Photography", [], false)
    paye_contract = Helpers.determine_contract_type("Camera", "1st Assistant Camera", [], false)
    conditional_contract = Helpers.determine_contract_type("Camera", "Camera Operator", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Cast" do
    sch_d_contract = Helpers.determine_contract_type("Cast", "Actor", [], false)
    paye_contract = Helpers.determine_contract_type("Cast", "Actor Double", [], false)
    conditional_contract = Helpers.determine_contract_type("Cast", "Unit Driver", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Construction" do
    sch_d_contract = Helpers.determine_contract_type("Construction", "Buyer", [], false)
    paye_contract = Helpers.determine_contract_type("Construction", "Carpenter", [], false)
    conditional_contract = Helpers.determine_contract_type("Construction", "Scenic Painter", [], false)


    assert sch_d_contract == "CONSTRUCTION SCHEDULE-D"
    assert paye_contract == "CONSTRUCTION PAYE"
    assert conditional_contract == "CONSTRUCTION PAYE"
  end

  test "determine_contract_type(department, job_title) Continuity" do
    sch_d_contract = Helpers.determine_contract_type("Continuity", "Script Supervisor", [], false)
    paye_contract = Helpers.determine_contract_type("Continuity", "Assistant Script Supervisor", [], false)

    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Costume" do
    sch_d_contract = Helpers.determine_contract_type("Costume", "Buyer", [], false)
    paye_contract = Helpers.determine_contract_type("Costume", "Assistant Buyer", [], false)
    conditional_contract = Helpers.determine_contract_type("Costume", "Seamstress", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) DIT" do
    conditional_contract = Helpers.determine_contract_type("DIT", "Data Wrangler", [], false)
    paye_contract = Helpers.determine_contract_type("DIT", "Array DIT", [], false)

    assert conditional_contract == "PAYE"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Drapes" do
    conditional_contract = Helpers.determine_contract_type("Drapes", "Drapesman", [], false)
    paye_contract = Helpers.determine_contract_type("Drapes", "Drapes Master", [], false)

    assert conditional_contract == "PAYE"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Editorial" do
    sch_d_contract = Helpers.determine_contract_type("Editorial", "Assembly Editor", [], false)
    paye_contract = Helpers.determine_contract_type("Editorial", "Assistant Editor", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Electrical" do
    sch_d_contract = Helpers.determine_contract_type("Electrical", "VFX Editor", [], false)
    paye_contract = Helpers.determine_contract_type("Electrical", "Desk Operator", [], false)
    conditional_contract = Helpers.determine_contract_type("Electrical", "Balloon Technician", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Greens" do
    paye_contract = Helpers.determine_contract_type("Greens", "Greens Person", [], false)

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Grip" do
    sch_d_contract = Helpers.determine_contract_type("Grip", "Crane Grip", [], false)
    paye_contract = Helpers.determine_contract_type("Grip", "Grip Rigger", [], false)
    conditional_contract = Helpers.determine_contract_type("Grip", "Best Boy Grip", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Hair And Makeup" do
    sch_d_contract = Helpers.determine_contract_type("Hair And Makeup", "Hair Designer", [], false)
    paye_contract = Helpers.determine_contract_type("Hair And Makeup", "Hairdresser", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) IT" do
    paye_contract = Helpers.determine_contract_type("IT", "1st Line IT Support", [], false)

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Locations" do
    sch_d_contract = Helpers.determine_contract_type("Locations", "Location Manager", [], false)
    paye_contract = Helpers.determine_contract_type("Locations", "Locations Marshall", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Medical" do
    sch_d_contract = Helpers.determine_contract_type("Medical", "Medic", [], false)

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) Military" do
    sch_d_contract = Helpers.determine_contract_type("Military", "Military Advisor", [], false)

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) Photography" do
    conditional_contract = Helpers.determine_contract_type("Photography", "Photographer", [], false)

    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Post Production" do
    sch_d_contract = Helpers.determine_contract_type("Post Production", "Post Production Supervisor", [], false)
    paye_contract = Helpers.determine_contract_type("Post Production", "Coordinator", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Production" do
    sch_d_contract = Helpers.determine_contract_type("Production", "Co-Producer", [], false)
    paye_contract = Helpers.determine_contract_type("Production", "Cast Assistant", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Props" do
    sch_d_contract = Helpers.determine_contract_type("Props", "HOD Prop Modeller", [], false)
    paye_contract = Helpers.determine_contract_type("Props", "Chargehand Dresser", [], false)
    conditional_contract = Helpers.determine_contract_type("Props", "Chargehand Dressing Prop", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Publicity" do
    sch_d_contract = Helpers.determine_contract_type("Publicity", "Unit Publicist", [], false)

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) Rigging" do
    sch_d_contract = Helpers.determine_contract_type("Rigging", "HOD Rigger", [], false)
    paye_contract = Helpers.determine_contract_type("Rigging", "Rigger", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Security" do
    paye_contract = Helpers.determine_contract_type("Security", "Security", [], false)

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Set Dec" do
    sch_d_contract = Helpers.determine_contract_type("Set Dec", "Art Director", [], false)
    paye_contract = Helpers.determine_contract_type("Set Dec", "Coordinator", [], false)
    conditional_contract = Helpers.determine_contract_type("Set Dec", "Scenic Textile Artist", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) SFX" do
    sch_d_contract = Helpers.determine_contract_type("SFX", "Floor Director", [], false)
    paye_contract = Helpers.determine_contract_type("SFX", "Floor Technician", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Sound" do
    sch_d_contract = Helpers.determine_contract_type("Sound", "Production Sound Mixer", [], false)
    paye_contract = Helpers.determine_contract_type("Sound", "1st Assistant Sound", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Standby" do
    paye_contract = Helpers.determine_contract_type("Standby", "Rigger", [], false)

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Studio Unit" do
    paye_contract = Helpers.determine_contract_type("Studio Unit", "Studio Unit Manager", [], false)

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Stunts" do
    sch_d_contract = Helpers.determine_contract_type("Stunts", "Stunt Coordinator", [], false)
    paye_contract = Helpers.determine_contract_type("Stunts", "Rigger", [], false)
    conditional_contract = Helpers.determine_contract_type("Stunts", "Wire Rigger", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Supporting Artist" do
    sch_d_contract = Helpers.determine_contract_type("Supporting Artist", "Pay Direct Extra", [], false)

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) Transport" do
    sch_d_contract = Helpers.determine_contract_type("Transport", "Transport Captain", ["TRANSPORT DIRECT HIRE"], false)
    paye_contract = Helpers.determine_contract_type("Transport", "Transport Coordinator", ["TRANSPORT DIRECT HIRE"], false)
    conditional_contract = Helpers.determine_contract_type("Transport", "Unit Driver", ["TRANSPORT DIRECT HIRE"], false)
    direct_hire = Helpers.determine_contract_type("Transport", "Rushes Runner", ["TRANSPORT DIRECT HIRE"], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "TRANSPORT PAYE"
    assert direct_hire == "TRANSPORT DIRECT HIRE"
  end

  test "determine_contract_type(department, job_title) Underwater" do
    sch_d_contract = Helpers.determine_contract_type("Underwater", "Cameraman", [], false)

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) VFX" do
    sch_d_contract = Helpers.determine_contract_type("VFX", "VFX Producer", [], false)
    paye_contract = Helpers.determine_contract_type("VFX", "Data Wrangler", [], false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Video" do
    paye_contract = Helpers.determine_contract_type("Video", "Video Assistant", [], false)

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Voice" do
    sch_d_contract = Helpers.determine_contract_type("Voice", "Voice Coach", [], false)

    assert sch_d_contract == "SCHEDULE-D"
  end
end
